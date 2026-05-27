package com.example.ikara_clone

import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

class FastYinDetector(
    private val sampleRate: Float = 44100f,
    private val bufferSize: Int = 1024,
    private val threshold: Double = 0.15
) {
    private val halfSize = bufferSize / 2          // 512
    private val fftSize  = bufferSize * 2          // 2048 (zero-padded)

    private val yinBuffer = FloatArray(halfSize)
    private val audioBufferFFT = FloatArray(fftSize * 2) // 4096: complex interleaved
    private val kernelFFT = FloatArray(fftSize * 2) // 4096
    private val yinStyleACF = FloatArray(fftSize * 2) // 4096
    private val powerTerm = FloatArray(halfSize)

    private var probability = 0f
    private var isPitched = false

    // Table size = fftSize/2 = 1024
    // angle = -2*PI*i/fftSize, i từ 0..fftSize/2-1
    private val cosTable = FloatArray(fftSize / 2)
    private val sinTable = FloatArray(fftSize / 2)

    init {
        for (i in 0 until fftSize / 2) {
            val angle = -2.0 * PI * i / fftSize  // dấu âm = forward FFT convention
            cosTable[i] = cos(angle).toFloat()
            sinTable[i] = sin(angle).toFloat()
        }
    }

    fun getPitch(audioBuffer: FloatArray): Float {
        difference(audioBuffer)
        cumulativeMeanNormalizedDifference()
        val tau = absoluteThreshold()
        if (tau == -1) return -1f
        return sampleRate / parabolicInterpolation(tau)
    }

    private fun difference(audioBuffer: FloatArray) {
        // Power term
        powerTerm[0] = 0f
        for (i in 0 until halfSize) {
            powerTerm[0] += audioBuffer[i] * audioBuffer[i]
        }
        for (tau in 1 until halfSize) {
            powerTerm[tau] = powerTerm[tau - 1] -
                    audioBuffer[tau - 1] * audioBuffer[tau - 1] +
                    audioBuffer[tau + halfSize] * audioBuffer[tau + halfSize]
        }

        // Audio FFT: bufferSize samples + zero-pad đến fftSize
        audioBufferFFT.fill(0f)
        for (j in 0 until bufferSize) {
            audioBufferFFT[2 * j] = audioBuffer[j]
        }
        fft(audioBufferFFT, false)

        // Kernel: reversed halfSize + zero-pad đến fftSize
        kernelFFT.fill(0f)
        for (j in 0 until halfSize) {
            kernelFFT[2 * j] = audioBuffer[halfSize - 1 - j]
        }
        fft(kernelFFT, false)

        // Multiply trong frequency domain
        for (j in 0 until fftSize) {
            val re = audioBufferFFT[2*j] * kernelFFT[2*j] -
                    audioBufferFFT[2*j+1] * kernelFFT[2*j+1]
            val im = audioBufferFFT[2*j+1] * kernelFFT[2*j] +
                    audioBufferFFT[2*j] * kernelFFT[2*j+1]
            yinStyleACF[2*j] = re
            yinStyleACF[2*j+1] = im
        }

        // Inverse FFT
        fft(yinStyleACF, true)

        // YIN difference
        for (j in 0 until halfSize) {
            yinBuffer[j] = powerTerm[0] + powerTerm[j] -
                    2f * yinStyleACF[2 * (halfSize - 1 + j)]
        }
    }

    private fun cumulativeMeanNormalizedDifference() {
        yinBuffer[0] = 1f
        var runningSum = 0f
        for (tau in 1 until halfSize) {
            runningSum += yinBuffer[tau]
            yinBuffer[tau] *= tau.toFloat() / runningSum
        }
    }

    private fun absoluteThreshold(): Int {
        var tau = 2
        while (tau < halfSize) {
            if (yinBuffer[tau] < threshold) {
                while (tau + 1 < halfSize && yinBuffer[tau + 1] < yinBuffer[tau]) {
                    tau++
                }
                probability = 1f - yinBuffer[tau]
                isPitched = true
                return tau
            }
            tau++
        }
        probability = 0f
        isPitched = false
        return -1
    }

    private fun parabolicInterpolation(tauEstimate: Int): Float {
        val x0 = if (tauEstimate < 1) tauEstimate else tauEstimate - 1
        val x2 = if (tauEstimate + 1 < halfSize) tauEstimate + 1 else tauEstimate
        return when {
            x0 == tauEstimate -> {
                if (yinBuffer[tauEstimate] <= yinBuffer[x2]) tauEstimate.toFloat()
                else x2.toFloat()
            }
            x2 == tauEstimate -> {
                if (yinBuffer[tauEstimate] <= yinBuffer[x0]) tauEstimate.toFloat()
                else x0.toFloat()
            }
            else -> {
                val s0 = yinBuffer[x0]
                val s1 = yinBuffer[tauEstimate]
                val s2 = yinBuffer[x2]
                tauEstimate + (s2 - s0) / (2f * (2f * s1 - s2 - s0))
            }
        }
    }


    // Cooley-Tukey FFT
    private fun fft(data: FloatArray, invert: Boolean) {
        val n = data.size / 2  // số complex samples

        // Bit-reversal
        var j = 0
        for (i in 1 until n) {
            var bit = n shr 1
            while ((j and bit) != 0) { j = j xor bit; bit = bit shr 1 }
            j = j xor bit
            if (i < j) {
                var t = data[2*i]
                data[2*i] = data[2*j]
                data[2*j] = t
                t = data[2*i+1]
                data[2*i+1] = data[2*j+1]
                data[2*j+1] = t
            }
        }

        // Butterfly với precomputed table
        var len = 2
        while (len <= n) {
            val halfLen = len / 2
            val step = fftSize / len  // step trong table

            for (i in 0 until n step len) {
                for (k in 0 until halfLen) {
                    val tableIdx = k * step
                    val wRe =  cosTable[tableIdx]
                    val wIm = if (invert) -sinTable[tableIdx] else sinTable[tableIdx]

                    val uIdx = 2 * (i + k)
                    val vIdx = 2 * (i + k + halfLen)

                    val uRe = data[uIdx]
                    val uIm = data[uIdx+1]
                    val vRe = data[vIdx]*wRe - data[vIdx+1]*wIm
                    val vIm = data[vIdx]*wIm + data[vIdx+1]*wRe

                    data[uIdx] = uRe + vRe
                    data[uIdx+1] = uIm + vIm
                    data[vIdx] = uRe - vRe
                    data[vIdx+1] = uIm - vIm
                }
            }
            len = len shl 1
        }

        if (invert) {
            val nf = n.toFloat()
            for (i in data.indices) data[i] /= nf
        }
    }
}
package com.example.ikara_clone

import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * Bộ phát hiện cao độ âm thanh (pitch detection) dựa trên thuật toán YIN kết hợp với FFT để tăng tốc độ,
 *
 * @param sampleRate  Tốc độ lấy mẫu (Hz), mặc định 44100
 * @param bufferSize  Kích thước buffer đầu vào, mặc định 1024
 * @param threshold   Ngưỡng xác định có cao độ hay không, mặc định 0.15
 */
class FastYinDetector(
    private val sampleRate: Float = 44100f,
    private val bufferSize: Int = 1024,
    private val threshold: Double = 0.15
) {
    private val halfSize = bufferSize / 2
    private val fftSize  = bufferSize * 2

    private val yinBuffer = FloatArray(halfSize)


    // Buffer FFT Tín hiệu âm thanh
    private val audioBufferFFT = FloatArray(fftSize * 2)

    // Buffer FFT Tín hiệu audio đảo ngược (dùng để tính tương quan chéo)
    private val kernelFFT = FloatArray(fftSize * 2)

    //Buffer FFT lưu tích phức (audioBufferFFT * kernelFFT) trước khi IFFT.
    private val yinStyleACF = FloatArray(fftSize * 2)

    // Tổng năng lượng của cửa sổ tín hiệu tại vị trí tau (powerTerm[tau]).
    private val powerTerm = FloatArray(halfSize)

    private var probability = 0f
    private var isPitched = false

    private val cosTable = FloatArray(fftSize / 2)
    private val sinTable = FloatArray(fftSize / 2)

    init {
        for (i in 0 until fftSize / 2) {
            val angle = -2.0 * PI * i / fftSize
            cosTable[i] = cos(angle).toFloat()
            sinTable[i] = sin(angle).toFloat()
        }
    }

    /**
     * Tính cao độ (tần số cơ bản) của buffer âm thanh đầu vào.
     * @return Tần số (Hz) nếu phát hiện được cao độ, hoặc -1f nếu không có.
     */
    fun getPitch(audioBuffer: FloatArray): Float {
        difference(audioBuffer)
        cumulativeMeanNormalizedDifference()
        val tau = absoluteThreshold()
        if (tau == -1) return -1f
        return sampleRate / parabolicInterpolation(tau)
    }

    /**
     * Tính hàm hiệu bình phương (SDF) dùng FFT để tăng tốc,
     */
    private fun difference(audioBuffer: FloatArray) {
        powerTerm[0] = 0f
        for (i in 0 until halfSize) {
            powerTerm[0] += audioBuffer[i] * audioBuffer[i]
        }
        for (tau in 1 until halfSize) {
            powerTerm[tau] = powerTerm[tau - 1] -
                    audioBuffer[tau - 1] * audioBuffer[tau - 1] +
                    audioBuffer[tau + halfSize] * audioBuffer[tau + halfSize]
        }

        audioBufferFFT.fill(0f)
        for (j in 0 until bufferSize) {
            audioBufferFFT[2 * j] = audioBuffer[j]
        }
        fft(audioBufferFFT, false)

        kernelFFT.fill(0f)
        for (j in 0 until halfSize) {
            kernelFFT[2 * j] = audioBuffer[halfSize - 1 - j]
        }
        fft(kernelFFT, false)

        for (j in 0 until fftSize) {
            val re = audioBufferFFT[2*j] * kernelFFT[2*j] -
                    audioBufferFFT[2*j+1] * kernelFFT[2*j+1]
            val im = audioBufferFFT[2*j+1] * kernelFFT[2*j] +
                    audioBufferFFT[2*j] * kernelFFT[2*j+1]
            yinStyleACF[2*j] = re
            yinStyleACF[2*j+1] = im
        }

        // Đưa dữ liệu từ miền tần số về miền thời gian
        fft(yinStyleACF, true)

        for (j in 0 until halfSize) {
            yinBuffer[j] = powerTerm[0] + powerTerm[j] -
                    2f * yinStyleACF[2 * (halfSize - 1 + j)]
        }
    }

    /**
     * Chuẩn hóa SDF bằng trung bình tích lũy (CMND) để loại bỏ
     * thiên lệch vì d(tau) thô thường có xu hướng nhỏ ở tau nhỏ. Dễ nhận sai cao độ.
     */
    private fun cumulativeMeanNormalizedDifference() {
        yinBuffer[0] = 1f
        var runningSum = 0f
        for (tau in 1 until halfSize) {
            runningSum += yinBuffer[tau]
            yinBuffer[tau] *= tau.toFloat() / runningSum
        }
    }

    /**
     * Tìm tau tối ưu bằng cách duyệt đến điểm đầu tiên có giá trị
     * CMND dưới ngưỡng, rồi lấy cực tiểu cục bộ trong vùng đó.
     * @return Tau tìm được, hoặc -1 nếu không có cao độ.
     */
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

    /**
     * Tinh chỉnh tau về mức sub-sample bằng nội suy parabol
     * dùng 3 điểm lân cận, giúp tăng độ chính xác tần số.
     */
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

    /**
     * FFT Cooley-Tukey in-place trên mảng số phức dạng interleaved.
     * Hỗ trợ cả forward FFT và inverse FFT.
     * @param data   Mảng [re0, im0, re1, im1, ...] sẽ bị biến đổi in-place.
     * @param invert true = Inverse FFT; false = Forward FFT.
     */
    private fun fft(data: FloatArray, invert: Boolean) {
        val n = data.size / 2

        // bit - reverse
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

        var len = 2
        while (len <= n) {
            val halfLen = len / 2
            val step = fftSize / len

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
            len = len shl 1 // dịch sang trái 1 bit
        }

        if (invert) {
            val nf = n.toFloat()
            for (i in data.indices) data[i] /= nf
        }
    }
}
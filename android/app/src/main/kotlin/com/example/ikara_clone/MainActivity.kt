    package com.example.ikara_clone
    import io.flutter.embedding.android.FlutterActivity
    import io.flutter.embedding.engine.FlutterEngine
    import io.flutter.plugin.common.MethodChannel

    class MainActivity : FlutterActivity() {
        private val _channel = "com.example.ikara_clone/pitch"
        private var detector: FastYinDetector? = null
        override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
            super.configureFlutterEngine(flutterEngine)

            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _channel).setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialize" -> {
                        val args = call.arguments as? Map<*, *>

                        val sampleRate = (args?.get("sampleRate") as? Double ?: 44100.0).toFloat()
                        val bufferSize = args?.get("bufferSize") as? Int ?: 1024
                        val threshold  = args?.get("threshold")  as? Double ?: 0.15
                        detector = FastYinDetector(sampleRate = sampleRate, bufferSize = bufferSize, threshold = threshold)
                        result.success(null)
                    }

                    "getPitch" -> {
                        val det = detector
                        if (det == null) {
                            result.error("NOT_INITIALIZE", "Gọi initialize() trước", null)
                            return@setMethodCallHandler
                        }

                        @Suppress("UNCHECKED_CAST")
                        val rawBuffer = (call.arguments as? Map<*, *>)?.get("buffer") as? ByteArray
                            ?: run {
                                result.error("INVALID_ARGUMENT", "Thiếu tham số 'buffer'", null)
                                return@setMethodCallHandler
                            }

                        val floatBuffer = FloatArray(rawBuffer.size / 2) { i ->
                            val lo = rawBuffer[2 * i].toInt() and 0xFF
                            val hi = rawBuffer[2 * i + 1].toInt()
                            val sample = (hi shl 8) or lo
                            sample.toShort() / 32768f
                        }
                        val pitch = det.getPitch(floatBuffer)
                        result.success(pitch.toDouble())
                    }
                    "dispose" -> {
                        detector = null
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
        }
    }
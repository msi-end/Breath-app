package com.breathecare.breathecare

import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.content.Context
import android.os.Build
import android.util.Log
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Captures crashes so the next launch can show them to the user.
 *
 * - Java/Kotlin crashes: full stack trace written by an uncaught-exception handler.
 * - Native crashes / ANRs (Android 11+): read back from ApplicationExitInfo.
 */
object CrashReporter {
    private const val FILE_NAME = "last_crash.txt"
    private const val PREFS = "breathecare_crash_reporter"
    private const val KEY_LAST_EXIT = "last_reported_exit_ts"

    fun install(context: Context) {
        val app = context.applicationContext
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, error ->
            try {
                File(app.filesDir, FILE_NAME).writeText(
                    header(app) + "Type: Java/Kotlin exception\nThread: ${thread.name}\n\n" +
                        Log.getStackTraceString(error)
                )
            } catch (_: Throwable) {
            }
            previous?.uncaughtException(thread, error)
        }
    }

    /** A report the user hasn't seen yet, or null. */
    fun pendingReport(context: Context): String? {
        val file = File(context.filesDir, FILE_NAME)
        if (file.exists()) {
            val text = runCatching { file.readText() }.getOrNull()
            if (!text.isNullOrBlank()) return text
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return null
        return runCatching { exitReport(context) }.getOrNull()
    }

    private fun exitReport(context: Context): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return null
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val info = am.getHistoricalProcessExitReasons(context.packageName, 0, 1).firstOrNull() ?: return null
        val seen = prefs(context).getLong(KEY_LAST_EXIT, 0L)
        if (info.timestamp <= seen) return null
        val type = when (info.reason) {
            ApplicationExitInfo.REASON_CRASH -> "Java/Kotlin crash"
            ApplicationExitInfo.REASON_CRASH_NATIVE -> "Native crash"
            ApplicationExitInfo.REASON_ANR -> "App not responding (ANR)"
            ApplicationExitInfo.REASON_INITIALIZATION_FAILURE -> "Initialization failure"
            else -> return null
        }
        val sb = StringBuilder(header(context))
        sb.append("Type: ").append(type).append('\n')
        sb.append("When: ").append(format(info.timestamp)).append('\n')
        sb.append("Description: ").append(info.description ?: "-").append('\n')
        sb.append("Exit status: ").append(info.status).append('\n')
        if (info.reason == ApplicationExitInfo.REASON_ANR) {
            runCatching {
                info.traceInputStream?.bufferedReader()?.use { r ->
                    sb.append("\n").append(r.readText().take(20000))
                }
            }
        }
        return sb.toString()
    }

    fun markSeen(context: Context) {
        runCatching { File(context.filesDir, FILE_NAME).delete() }
        var latest = System.currentTimeMillis()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            runCatching {
                val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                am.getHistoricalProcessExitReasons(context.packageName, 0, 1).firstOrNull()?.let {
                    latest = maxOf(latest, it.timestamp)
                }
            }
        }
        prefs(context).edit().putLong(KEY_LAST_EXIT, latest).apply()
    }

    private fun prefs(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun format(ts: Long) = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US).format(Date(ts))

    private fun header(context: Context): String {
        val version = runCatching {
            val pi = context.packageManager.getPackageInfo(context.packageName, 0)
            "${pi.versionName} (${if (Build.VERSION.SDK_INT >= 28) pi.longVersionCode else @Suppress("DEPRECATION") pi.versionCode.toLong()})"
        }.getOrDefault("?")
        return "BreatheCare $version\n" +
            "Device: ${Build.MANUFACTURER} ${Build.MODEL}\n" +
            "Android: ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})\n" +
            "ABIs: ${Build.SUPPORTED_ABIS.joinToString()}\n" +
            "Reported: ${format(System.currentTimeMillis())}\n"
    }
}

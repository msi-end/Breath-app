package com.breathecare.breathecare

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast

/**
 * Entry point. Opens the Flutter app immediately, unless the previous run
 * crashed — then it first shows the crash details so they can be shared.
 */
class LaunchActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val report = CrashReporter.pendingReport(this)
        if (report == null) {
            openApp()
        } else {
            showReport(report)
        }
    }

    private fun openApp() {
        startActivity(Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION))
        finish()
        @Suppress("DEPRECATION")
        overridePendingTransition(0, 0)
    }

    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()

    private fun showReport(report: String) {
        val forest = Color.parseColor("#24442F")
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(40), dp(20), dp(20))
            setBackgroundColor(Color.parseColor("#FBF6EC"))
        }
        root.addView(TextView(this).apply {
            text = "BreatheCare closed unexpectedly"
            textSize = 22f
            setTypeface(typeface, Typeface.BOLD)
            setTextColor(forest)
        })
        root.addView(TextView(this).apply {
            text = "Sorry about that. Please copy or share the details below with the developer so it can be fixed."
            textSize = 15f
            setTextColor(forest)
            setPadding(0, dp(8), 0, dp(12))
        })
        val details = TextView(this).apply {
            text = report
            textSize = 11f
            typeface = Typeface.MONOSPACE
            setTextColor(Color.parseColor("#333333"))
            setTextIsSelectable(true)
            setPadding(dp(12), dp(12), dp(12), dp(12))
            setBackgroundColor(Color.WHITE)
        }
        root.addView(ScrollView(this).apply { addView(details) }, LinearLayout.LayoutParams(MATCH_PARENT, 0, 1f))

        val buttons = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, dp(12), 0, 0)
        }
        fun button(label: String, onClick: () -> Unit) = Button(this).apply {
            text = label
            setOnClickListener { onClick() }
        }
        buttons.addView(button("Copy") {
            val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            cm.setPrimaryClip(ClipData.newPlainText("BreatheCare crash report", report))
            Toast.makeText(this, "Copied", Toast.LENGTH_SHORT).show()
        }, LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f))
        buttons.addView(button("Share") {
            val send = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_SUBJECT, "BreatheCare crash report")
                putExtra(Intent.EXTRA_TEXT, report)
            }
            startActivity(Intent.createChooser(send, "Share crash report"))
        }, LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f))
        buttons.addView(button("Open app") {
            CrashReporter.markSeen(this)
            openApp()
        }, LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f))
        root.addView(buttons, LinearLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT))
        setContentView(root)
    }
}

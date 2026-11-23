package com.breathecare.breathecare

import android.app.Application

class BreatheCareApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        CrashReporter.install(this)
    }
}

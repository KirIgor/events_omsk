package ru.admomsk.omsk_events

import io.flutter.app.FlutterApplication
import com.vk.sdk.VKSdk

class Application : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        VKSdk.initialize(this)
    }
}
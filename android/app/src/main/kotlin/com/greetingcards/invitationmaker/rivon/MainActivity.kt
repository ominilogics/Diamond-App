package com.greetingcards.invitationmaker.rivon

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // BYPASS TESTING: Native share sheet channel.
    // Remove configureFlutterEngine override when reverting to production Twilio flow.
    private val SHARE_CHANNEL = "com.greetingcards.invitationmaker.rivon/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "shareText") {
                    val text = call.argument<String>("text") ?: ""
                    val intent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, text)
                    }
                    startActivity(Intent.createChooser(intent, "Send card via…"))
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}

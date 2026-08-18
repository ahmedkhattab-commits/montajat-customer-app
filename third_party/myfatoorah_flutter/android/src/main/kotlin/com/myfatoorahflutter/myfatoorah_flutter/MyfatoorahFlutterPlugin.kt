package com.myfatoorahflutter.myfatoorah_flutter

import android.content.Intent
import androidx.activity.result.ActivityResultCaller
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.myfatoorah.sdk.entity.MFError
import com.myfatoorah.sdk.views.embeddedpayment.googlepay.MFGooglePayLauncher
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.IMFGPayListener
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.IMFListener
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.MFGPayModule
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.MyfatoorahModule
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.utils.MFConstants
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.PluginRegistry

/**
 * Myfatoorah Flutter Plugin - Main plugin class that bridges Flutter and native SDK
 *
 * Key responsibilities:
 * - Setup method channels for SDK operations
 * - Register platform views (CardView, GooglePayButton)
 * - Manage event channels for payment callbacks
 * - Handle activity lifecycle and result callbacks
 */
class MyfatoorahFlutterPlugin : FlutterPlugin, ActivityAware,
    PluginRegistry.ActivityResultListener {

    private val myfatoorahModule = MyfatoorahModule()
    private val mFGPayModule = MFGPayModule()

    // Store references for proper cleanup
    private var eventChannel: EventChannel? = null
    private var eventChannelGPay: EventChannel? = null
    private var streamHandler: StreamHandler? = null
    private var streamHandlerGPay: StreamHandler? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        setupMethodChannels(flutterPluginBinding)
        registerPlatformViews(flutterPluginBinding)
        setupEventChannels(flutterPluginBinding)
    }

    private fun setupMethodChannels(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        MfSDKHelper.MFSDKHelper.setup(flutterPluginBinding.binaryMessenger, myfatoorahModule)
        MfGPayHelper.MFGPayHelper.setup(flutterPluginBinding.binaryMessenger, mFGPayModule)
    }

    private fun registerPlatformViews(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // Register CardView factory
        val cardViewFactory = CardViewFactory()
        myfatoorahModule.cardViewFactory = cardViewFactory
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            MFConstants.MFCardViewModuleNAME,
            cardViewFactory
        )

        // Register GooglePayButton factory (shared between modules)
        val googlePayButtonFactory = GooglePayButtonFactory()
        myfatoorahModule.googlePayButtonFactory = googlePayButtonFactory
        mFGPayModule.googlePayButtonFactory = googlePayButtonFactory

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            MFConstants.MFGooglePayButtonModuleNAME,
            googlePayButtonFactory
        )
    }

    private fun setupEventChannels(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        setupMainEventChannel(flutterPluginBinding)
        setupGPayEventChannel(flutterPluginBinding)
    }

    private fun setupMainEventChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, MFConstants.MFEventChannelName)
        streamHandler = object : StreamHandler {
            private var eventHandler: MainThreadEventHandler? = null

            override fun onListen(arguments: Any?, events: EventSink?) {
                events?.let {
                    eventHandler = MainThreadEventHandler(it)
                    myfatoorahModule.mfListener = object : IMFListener {
                        override fun OnInvoiceCreated(invoiceId: String) {
                            eventHandler?.success(invoiceId)
                        }

                        override fun OnCardBinChanged(bin: String) {
                            eventHandler?.success(bin)
                        }

                        override fun OnCardHeightChanged(height: Float) {
                            eventHandler?.success(height)
                        }

                        override fun OnSessionUpdated(sessionId: String?) {
                            eventHandler?.success(sessionId)
                        }
                    }
                }
            }

            override fun onCancel(arguments: Any?) {
                eventHandler = null
                myfatoorahModule.mfListener = null
            }
        }
        eventChannel?.setStreamHandler(streamHandler)
    }

    private fun setupGPayEventChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        eventChannelGPay = EventChannel(flutterPluginBinding.binaryMessenger, MFConstants.MFEventChannelGPayName)
        streamHandlerGPay = object : StreamHandler {
            private var eventHandler: MainThreadEventHandler? = null

            override fun onListen(arguments: Any?, events: EventSink?) {
                events?.let {
                    eventHandler = MainThreadEventHandler(it)
                    mFGPayModule.mfGPayListener = object : IMFGPayListener {
                        override fun OnGPayReceivedToken(token: String) {
                            val result = mapOf(
                                "eventType" to "onReceivedToken",
                                "token" to token
                            )
                            eventHandler?.success(result)
                        }

                        override fun OnGPaySessionUpdated(sessionId: String?) {
                            val result = mapOf(
                                "eventType" to "onSessionUpdated",
                                "sessionId" to sessionId
                            )
                            eventHandler?.success(result)
                        }

                        override fun OnGPayInvoiceCreated(invoiceId: String) {
                            val result = mapOf(
                                "eventType" to "onInvoiceCreated",
                                "invoiceId" to invoiceId
                            )
                            eventHandler?.success(result)
                        }

                        override fun OnGPayExecutePaymentSuccess(
                            invoiceId: String,
                            getPaymentStatusResponse: String
                        ) {
                            val paymentStatus = try {
                                val mapType = object : TypeToken<Map<String, Any?>>() {}.type
                                Gson().fromJson<Map<String, Any?>>(
                                    getPaymentStatusResponse,
                                    mapType
                                )
                            } catch (e: Exception) {
                                val errorCode = "GPAY_PAYMENT_STATUS_PARSE_ERROR"
                                val errorMessage =
                                    "Failed to parse Google Pay payment status response: ${e.message}"
                                val errorMap = mapOf("code" to errorCode, "message" to errorMessage)
                                val result = mapOf("eventType" to "onError", "error" to errorMap)
                                eventHandler?.error(
                                    errorCode = errorCode,
                                    errorMessage = errorMessage,
                                    errorDetails = result
                                )
                                return
                            }

                            val result = mapOf(
                                "eventType" to "onExecutePaymentSuccess",
                                "invoiceId" to invoiceId,
                                "paymentStatus" to paymentStatus
                            )
                            eventHandler?.success(result)
                        }

                        override fun OnGPayError(error: MFError) {
                            val errorMap = mapOf("code" to error.code, "message" to error.message)
                            val result = mapOf("eventType" to "onError", "error" to errorMap)
                            eventHandler?.error(
                                errorCode = error.code,
                                errorMessage = error.message,
                                errorDetails = result
                            )
                        }
                    }
                }
            }

            override fun onCancel(arguments: Any?) {
                eventHandler = null
                mFGPayModule.mfGPayListener = null
            }
        }
        eventChannelGPay?.setStreamHandler(streamHandlerGPay)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Cleanup event channels and handlers
        eventChannel?.setStreamHandler(null)
        eventChannelGPay?.setStreamHandler(null)

        // Clear listeners to prevent memory leaks
        myfatoorahModule.mfListener = null
        mFGPayModule.mfGPayListener = null

        // Clear references
        eventChannel = null
        eventChannelGPay = null
        streamHandler = null
        streamHandlerGPay = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val act = binding.activity
        myfatoorahModule.activity = act
        myfatoorahModule.cardViewFactory?.EnableNFC(act)

        mFGPayModule.activity = act
        mFGPayModule.mfGooglePayLauncher = if (act is ActivityResultCaller) {
            MFGooglePayLauncher(act, act)
        } else {
            null
        }

        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        cleanupActivityReferences()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        cleanupActivityReferences()
    }

    private fun cleanupActivityReferences() {
        myfatoorahModule.activity = null
        myfatoorahModule.cardViewFactory?.DisableNFC()
        mFGPayModule.mfGooglePayLauncher = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        // Handle GooglePay activity results with null safety
        myfatoorahModule.mfGooglePayHelper?.let { helper ->
            if (requestCode == MFConstants.GooglePayRequestCODE) {
                helper.onActivityResult(requestCode, resultCode, data)
            }
        }

        myfatoorahModule.mfGooglePayTokenHelper?.let { helper ->
            if (requestCode == MFConstants.GooglePayRequestCODE) {
                helper.onActivityResult(requestCode, resultCode, data)
            }
        }

        return false
    }
}

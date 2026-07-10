package com.yubikit

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.yubico.yubikit.android.transport.nfc.NfcConfiguration
import com.yubico.yubikit.android.transport.nfc.NfcNotAvailable
import com.yubico.yubikit.android.transport.usb.UsbConfiguration
import com.yubico.yubikit.core.fido.FidoConnection
import com.yubico.yubikit.core.otp.OtpConnection
import com.yubico.yubikit.core.smartcard.SmartCardConnection
import com.yubikit.YubiKitManagerHolder.deviceToBundle
import com.yubikit.utils.YubikitUtils.base64Decode
import com.yubikit.utils.YubikitUtils.base64Encode
import com.yubikit.utils.YubikitUtils.toWritableMap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.IOException

@Suppress("unused")
class YubikitCoreModule(reactContext: ReactApplicationContext) :
  NativeYubikitCoreSpec(reactContext) {

  private val moduleScope = CoroutineScope(Dispatchers.IO)

  init {
    YubiKitManagerHolder.setEventHandler { params -> emitOnYubiKeyEvent(params) }
  }

  override fun getName(): String = NAME

  @ReactMethod
  override fun startUsbDiscovery(config: ReadableMap?) {
    YubiKitManagerHolder.initialize(reactApplicationContext)
    val usbConfig = UsbConfiguration()
    config?.let {
      if (it.hasKey("handlePermissions") && !it.isNull("handlePermissions")) {
        usbConfig.handlePermissions(it.getBoolean("handlePermissions"))
      }
    }
    YubiKitManagerHolder.setUsbConfiguration(usbConfig)
    YubiKitManagerHolder.startUsbDiscovery()
  }

  @ReactMethod
  override fun stopUsbDiscovery() {
    YubiKitManagerHolder.stopUsbDiscovery()
  }

  @ReactMethod
  override fun startNfcDiscovery(config: ReadableMap?) {
    YubiKitManagerHolder.initialize(reactApplicationContext)
    val nfcConfig = NfcConfiguration()
    config?.let {
      if (it.hasKey("timeout") && !it.isNull("timeout")) {
        nfcConfig.timeout(it.getInt("timeout"))
      }
      if (it.hasKey("disableNfcDiscoverySound") && !it.isNull("disableNfcDiscoverySound")) {
        nfcConfig.disableNfcDiscoverySound(it.getBoolean("disableNfcDiscoverySound"))
      }
      if (it.hasKey("skipNdefCheck") && !it.isNull("skipNdefCheck")) {
        nfcConfig.skipNdefCheck(it.getBoolean("skipNdefCheck"))
      }
      if (it.hasKey("handleUnavailableNfc") && !it.isNull("handleUnavailableNfc")) {
        nfcConfig.handleUnavailableNfc(it.getBoolean("handleUnavailableNfc"))
      }
    }
    YubiKitManagerHolder.setNfcConfiguration(nfcConfig)
    val activity = reactApplicationContext.currentActivity
      ?: throw IllegalStateException("No current Activity for NFC discovery")
    YubiKitManagerHolder.startNfcDiscovery(activity)
  }

  @ReactMethod
  override fun stopNfcDiscovery() {
    val activity = reactApplicationContext.currentActivity
      ?: throw IllegalStateException("No current Activity for NFC discovery")
    YubiKitManagerHolder.stopNfcDiscovery(activity)
  }

  @ReactMethod
  override fun requestConnection(deviceHandle: String, connectionType: String, promise: Promise) {
    moduleScope.launch {
      try {
        val clazz = when (connectionType) {
          "SmartCardConnection" -> SmartCardConnection::class.java
          "OtpConnection" -> OtpConnection::class.java
          "FidoConnection" -> FidoConnection::class.java
          else -> throw IllegalArgumentException("Unknown connection type: $connectionType")
        }
        var result: Result<Pair<String, com.yubico.yubikit.core.YubiKeyConnection>>? = null
        YubiKitManagerHolder.requestConnection(deviceHandle, clazz) { res ->
          result = res
        }
        // Wait briefly for callback (requestConnection callback is typically synchronous-ish)
        withContext(Dispatchers.IO) {
          var waited = 0
          while (result == null && waited < 5000) {
            Thread.sleep(50)
            waited += 50
          }
        }
        val pair = result?.getOrThrow()
          ?: throw IOException("Timeout waiting for connection")
        promise.resolve(pair.first)
      } catch (e: Exception) {
        promise.reject("CONNECTION_ERROR", e.message, e)
      }
    }
  }

  @ReactMethod
  override fun sendApdu(connectionHandle: String, apdu: String, promise: Promise) {
    moduleScope.launch {
      try {
        val connection = YubiKitManagerHolder.getConnection(connectionHandle)
        if (connection !is SmartCardConnection) {
          throw IllegalArgumentException("sendApdu requires a SmartCardConnection")
        }
        val data = base64Decode(apdu) ?: byteArrayOf()
        val response = connection.sendAndReceive(data)
        promise.resolve(base64Encode(response))
      } catch (e: Exception) {
        promise.reject("APDU_ERROR", e.message, e)
      }
    }
  }

  @ReactMethod
  override fun closeConnection(connectionHandle: String) {
    YubiKitManagerHolder.removeConnection(connectionHandle)
  }

  @ReactMethod
  override fun getDiscoveredDevices(): WritableArray {
    val array = Arguments.createArray()
    YubiKitManagerHolder.listDevices().forEach { (handle, device) ->
      array.pushMap(deviceToBundle(handle, device).toWritableMap())
    }
    return array
  }

  companion object {
    const val NAME = "YubikitCore"
  }
}

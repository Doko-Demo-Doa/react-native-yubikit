package com.yubikit

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.yubico.yubikit.management.ManagementSession
import com.yubico.yubikit.core.UsbInterface
import com.yubikit.utils.YubikitUtils.base64Decode
import com.yubikit.utils.YubikitUtils.deviceInfoToMap
import com.yubikit.utils.YubikitUtils.parseDeviceConfig
import com.yubikit.utils.YubikitUtils.parseUsbMode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Suppress("unused")
class YubikitManagementModule(reactContext: ReactApplicationContext) :
  NativeYubikitManagementSpec(reactContext) {

  private val moduleScope = CoroutineScope(Dispatchers.IO)

  override fun getName(): String = NAME

  override fun getDeviceInfo(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val info = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          ManagementSession(connection).use { session ->
            session.deviceInfo
          }
        }
        promise.resolve(deviceInfoToMap(info))
      } catch (e: Exception) {
        promise.reject("MANAGEMENT_ERROR", e.message, e)
      }
    }
  }

  override fun updateDeviceConfig(
    deviceHandle: String,
    config: ReadableMap,
    reboot: Boolean,
    currentLockCode: String?,
    newLockCode: String?,
    promise: Promise
  ) {
    moduleScope.launch {
      try {
        val deviceConfig = parseDeviceConfig(config)
        YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          ManagementSession(connection).use { session ->
            session.updateDeviceConfig(
              deviceConfig,
              reboot,
              base64Decode(currentLockCode),
              base64Decode(newLockCode)
            )
          }
        }
        promise.resolve(null)
      } catch (e: Exception) {
        promise.reject("MANAGEMENT_ERROR", e.message, e)
      }
    }
  }

  override fun setMode(
    deviceHandle: String,
    mode: String,
    chalrespTimeout: Double,
    autoejectTimeout: Double,
    promise: Promise
  ) {
    moduleScope.launch {
      try {
        YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          ManagementSession(connection).use { session ->
            session.setMode(
              parseUsbMode(mode),
              chalrespTimeout.toInt().toByte(),
              autoejectTimeout.toInt().toShort()
            )
          }
        }
        promise.resolve(null)
      } catch (e: Exception) {
        promise.reject("MANAGEMENT_ERROR", e.message, e)
      }
    }
  }

  override fun deviceReset(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          ManagementSession(connection).use { session ->
            session.deviceReset()
          }
        }
        promise.resolve(null)
      } catch (e: Exception) {
        promise.reject("MANAGEMENT_ERROR", e.message, e)
      }
    }
  }

  companion object {
    const val NAME = "YubikitManagement"
  }
}

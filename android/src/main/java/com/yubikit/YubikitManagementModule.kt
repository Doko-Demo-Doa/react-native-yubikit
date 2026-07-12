package com.yubikit

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.yubico.yubikit.core.YubiKeyConnection
import com.yubico.yubikit.core.fido.FidoConnection
import com.yubico.yubikit.core.otp.OtpConnection
import com.yubico.yubikit.core.smartcard.SmartCardConnection
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

  // ManagementSession supports SmartCard, Otp and Fido connections; hardcoding
  // SmartCardConnection breaks OTP-only and FIDO-only-mode devices (e.g. a YubiKey
  // with CCID disabled via USB mode config).
  private val managementConnectionOrder = listOf(
    SmartCardConnection::class.java as Class<out YubiKeyConnection>,
    OtpConnection::class.java,
    FidoConnection::class.java
  )

  private fun openManagementSession(connection: YubiKeyConnection): ManagementSession {
    return when (connection) {
      is SmartCardConnection -> ManagementSession(connection)
      is OtpConnection -> ManagementSession(connection)
      is FidoConnection -> ManagementSession(connection)
      else -> throw IllegalArgumentException("Unsupported connection type for Management: $connection")
    }
  }

  override fun getName(): String = NAME

  override fun getDeviceInfo(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val info = YubiKitManagerHolder.withAnyConnection(deviceHandle, managementConnectionOrder) { connection ->
          openManagementSession(connection).use { session ->
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
        YubiKitManagerHolder.withAnyConnection(deviceHandle, managementConnectionOrder) { connection ->
          openManagementSession(connection).use { session ->
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
        YubiKitManagerHolder.withAnyConnection(deviceHandle, managementConnectionOrder) { connection ->
          openManagementSession(connection).use { session ->
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
        YubiKitManagerHolder.withAnyConnection(deviceHandle, managementConnectionOrder) { connection ->
          openManagementSession(connection).use { session ->
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

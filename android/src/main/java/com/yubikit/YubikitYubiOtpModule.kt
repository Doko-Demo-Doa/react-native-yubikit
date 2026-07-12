package com.yubikit

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.yubico.yubikit.yubiotp.ConfigurationState
import com.yubico.yubikit.yubiotp.HmacSha1SlotConfiguration
import com.yubico.yubikit.yubiotp.HotpSlotConfiguration
import com.yubico.yubikit.yubiotp.Slot
import com.yubico.yubikit.yubiotp.SlotConfiguration
import com.yubico.yubikit.yubiotp.StaticPasswordSlotConfiguration
import com.yubico.yubikit.yubiotp.StaticTicketSlotConfiguration
import com.yubico.yubikit.yubiotp.UpdateConfiguration
import com.yubico.yubikit.yubiotp.YubiOtpSession
import com.yubico.yubikit.yubiotp.YubiOtpSlotConfiguration
import com.yubikit.utils.YubikitUtils.base64Decode
import com.yubikit.utils.YubikitUtils.base64Encode
import com.yubikit.utils.YubikitUtils.versionToMap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Suppress("unused")
class YubikitYubiOtpModule(reactContext: ReactApplicationContext) :
  NativeYubikitYubiOtpSpec(reactContext) {

  private val moduleScope = CoroutineScope(Dispatchers.IO)

  override fun getName(): String = NAME

  private inline fun <R> withYubiOtpSession(
    deviceHandle: String,
    promise: Promise,
    crossinline block: (YubiOtpSession) -> R
  ) {
    moduleScope.launch {
      try {
        val device = YubiKitManagerHolder.getDevice(deviceHandle)
        val result = when {
          device.supportsConnection(com.yubico.yubikit.core.smartcard.SmartCardConnection::class.java) -> {
            YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
              YubiOtpSession(connection).use { session -> block(session) }
            }
          }
          device.supportsConnection(com.yubico.yubikit.core.otp.OtpConnection::class.java) -> {
            YubiKitManagerHolder.withOtp(deviceHandle) { connection ->
              YubiOtpSession(connection).use { session -> block(session) }
            }
          }
          else -> throw IllegalArgumentException("Device does not support OTP")
        }
        @Suppress("UNCHECKED_CAST")
        when (result) {
          is Unit -> promise.resolve(null)
          else -> promise.resolve(result)
        }
      } catch (e: Exception) {
        promise.reject("YUBIOTP_ERROR", e.message, e)
      }
    }
  }

  private fun slotFromString(value: String): Slot {
    return Slot.valueOf(value)
  }

  private fun configurationStateToMap(state: ConfigurationState): com.facebook.react.bridge.WritableMap {
    return Arguments.createMap().apply {
      putBoolean("slot1Configured", state.isConfigured(Slot.ONE))
      putBoolean("slot2Configured", state.isConfigured(Slot.TWO))
      putBoolean("slot1TouchTriggered", state.isTouchTriggered(Slot.ONE))
      putBoolean("slot2TouchTriggered", state.isTouchTriggered(Slot.TWO))
      putBoolean("ledInverted", state.isLedInverted)
    }
  }

  private fun buildSlotConfiguration(map: ReadableMap): SlotConfiguration {
    val type = map.getString("type") ?: throw IllegalArgumentException("configuration type is required")
    return when (type) {
      "HmacSha1" -> {
        val cfg = HmacSha1SlotConfiguration(base64Decode(map.getString("secret")) ?: byteArrayOf())
        if (map.hasKey("requireTouch") && !map.isNull("requireTouch")) {
          cfg.requireTouch(map.getBoolean("requireTouch"))
        }
        if (map.hasKey("lt64") && !map.isNull("lt64")) {
          cfg.lt64(map.getBoolean("lt64"))
        }
        cfg
      }
      "HOTP" -> {
        val cfg = HotpSlotConfiguration(base64Decode(map.getString("secret")) ?: byteArrayOf())
        if (map.hasKey("digits") && !map.isNull("digits")) {
          if (map.getInt("digits") == 8) cfg.digits8(true)
        }
        if (map.hasKey("imf") && !map.isNull("imf")) {
          cfg.imf(map.getInt("imf"))
        }
        cfg
      }
      "StaticPassword" -> {
        StaticPasswordSlotConfiguration(base64Decode(map.getString("scanCodes")) ?: byteArrayOf())
      }
      "StaticTicket" -> {
        StaticTicketSlotConfiguration(
          base64Decode(map.getString("fixed")) ?: byteArrayOf(),
          base64Decode(map.getString("uid")) ?: byteArrayOf(),
          base64Decode(map.getString("key")) ?: byteArrayOf()
        )
      }
      "YubiOtp" -> {
        YubiOtpSlotConfiguration(
          base64Decode(map.getString("fixed")) ?: byteArrayOf(),
          base64Decode(map.getString("uid")) ?: byteArrayOf(),
          base64Decode(map.getString("key")) ?: byteArrayOf()
        )
      }
      else -> throw IllegalArgumentException("Slot configuration type not supported for putConfiguration: $type")
    }
  }

  private fun buildUpdateConfiguration(map: ReadableMap): UpdateConfiguration {
    val type = map.getString("type") ?: throw IllegalArgumentException("configuration type is required")
    if (type != "Update") {
      throw IllegalArgumentException("updateConfiguration only supports Update configuration type")
    }
    val cfg = UpdateConfiguration()
    if (map.hasKey("appendCr") && !map.isNull("appendCr")) {
      cfg.appendCr(map.getBoolean("appendCr"))
    }
    if (map.hasKey("serialApiVisible") && !map.isNull("serialApiVisible")) {
      cfg.serialApiVisible(map.getBoolean("serialApiVisible"))
    }
    if (map.hasKey("serialUsbVisible") && !map.isNull("serialUsbVisible")) {
      cfg.serialUsbVisible(map.getBoolean("serialUsbVisible"))
    }
    if (map.hasKey("allowUpdate") && !map.isNull("allowUpdate")) {
      cfg.allowUpdate(map.getBoolean("allowUpdate"))
    }
    if (map.hasKey("dormant") && !map.isNull("dormant")) {
      cfg.dormant(map.getBoolean("dormant"))
    }
    if (map.hasKey("invertLed") && !map.isNull("invertLed")) {
      cfg.invertLed(map.getBoolean("invertLed"))
    }
    return cfg
  }

  override fun getConfigurationState(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val state = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          YubiOtpSession(connection).use { it.configurationState }
        }
        promise.resolve(configurationStateToMap(state))
      } catch (e: Exception) {
        promise.reject("YUBIOTP_ERROR", e.message, e)
      }
    }
  }

  override fun getVersion(deviceHandle: String, promise: Promise) {
    withYubiOtpSession(deviceHandle, promise) { versionToMap(it.version) }
  }

  override fun getSerialNumber(deviceHandle: String, promise: Promise) {
    withYubiOtpSession(deviceHandle, promise) { it.serialNumber }
  }

  override fun swapConfigurations(deviceHandle: String, promise: Promise) {
    withYubiOtpSession(deviceHandle, promise) { it.swapConfigurations() }
  }

  override fun deleteConfiguration(
    deviceHandle: String,
    slot: String,
    currentAccessCode: String?,
    promise: Promise
  ) {
    withYubiOtpSession(deviceHandle, promise) {
      it.deleteConfiguration(slotFromString(slot), base64Decode(currentAccessCode))
    }
  }

  override fun putConfiguration(
    deviceHandle: String,
    slot: String,
    configuration: ReadableMap,
    accessCode: String?,
    currentAccessCode: String?,
    promise: Promise
  ) {
    withYubiOtpSession(deviceHandle, promise) {
      it.putConfiguration(
        slotFromString(slot),
        buildSlotConfiguration(configuration),
        base64Decode(accessCode),
        base64Decode(currentAccessCode)
      )
    }
  }

  override fun updateConfiguration(
    deviceHandle: String,
    slot: String,
    configuration: ReadableMap,
    accessCode: String?,
    currentAccessCode: String?,
    promise: Promise
  ) {
    withYubiOtpSession(deviceHandle, promise) {
      it.updateConfiguration(
        slotFromString(slot),
        buildUpdateConfiguration(configuration),
        base64Decode(accessCode),
        base64Decode(currentAccessCode)
      )
    }
  }

  override fun setNdefConfiguration(
    deviceHandle: String,
    slot: String,
    uri: String?,
    currentAccessCode: String?,
    promise: Promise
  ) {
    withYubiOtpSession(deviceHandle, promise) {
      it.setNdefConfiguration(
        slotFromString(slot),
        uri,
        base64Decode(currentAccessCode)
      )
    }
  }

  override fun calculateHmacSha1(
    deviceHandle: String,
    slot: String,
    challenge: String,
    promise: Promise
  ) {
    withYubiOtpSession(deviceHandle, promise) {
      base64Encode(
        it.calculateHmacSha1(
          slotFromString(slot),
          base64Decode(challenge) ?: byteArrayOf(),
          null
        )
      )
    }
  }

  companion object {
    const val NAME = "YubikitYubiOtp"
  }
}

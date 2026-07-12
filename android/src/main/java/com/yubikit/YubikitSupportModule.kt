package com.yubikit

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.yubico.yubikit.android.transport.usb.UsbYubiKeyDevice
import com.yubico.yubikit.core.Transport
import com.yubico.yubikit.core.UsbPid
import com.yubico.yubikit.core.YubiKeyType
import com.yubico.yubikit.core.fido.FidoConnection
import com.yubico.yubikit.core.otp.OtpConnection
import com.yubico.yubikit.core.smartcard.SmartCardConnection
import com.yubico.yubikit.support.DeviceUtil
import com.yubikit.utils.YubikitUtils.deviceInfoToMap
import com.yubikit.utils.YubikitUtils.formFactorToString
import com.yubikit.utils.YubikitUtils.versionToMap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Suppress("unused")
class YubikitSupportModule(reactContext: ReactApplicationContext) :
  NativeYubikitSupportSpec(reactContext) {

  private val moduleScope = CoroutineScope(Dispatchers.IO)

  override fun getName(): String = NAME

  override fun readInfo(deviceHandle: String, pid: Double?, promise: Promise) {
    moduleScope.launch {
      try {
        val device = YubiKitManagerHolder.getDevice(deviceHandle)
        // The USB PID is required by DeviceUtil.readInfo whenever the connection is
        // over USB. Prefer an explicitly supplied pid, but fall back to the one the
        // Android USB device itself already knows, since callers shouldn't need to
        // plumb this Android-specific detail through the JS API.
        val usbPid = pid?.toInt()?.let { UsbPid.fromValue(it) }
          ?: (device as? UsbYubiKeyDevice)?.pid
        val info = when {
          device.supportsConnection(SmartCardConnection::class.java) ->
            YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
              DeviceUtil.readInfo(connection, usbPid)
            }
          device.supportsConnection(OtpConnection::class.java) ->
            YubiKitManagerHolder.withOtp(deviceHandle) { connection ->
              DeviceUtil.readInfo(connection, usbPid)
            }
          device.supportsConnection(FidoConnection::class.java) ->
            YubiKitManagerHolder.withFido(deviceHandle) { connection ->
              DeviceUtil.readInfo(connection, usbPid)
            }
          else -> throw IllegalArgumentException("Device does not support any known connection type")
        }
        promise.resolve(deviceInfoToMap(info))
      } catch (e: Exception) {
        promise.reject("SUPPORT_ERROR", e.message, e)
      }
    }
  }

  override fun getName(info: com.facebook.react.bridge.ReadableMap, keyType: String?): String {
    val deviceInfo = parseDeviceInfo(info)
    val ykType = keyType?.let { YubiKeyType.valueOf(it) }
    return DeviceUtil.getName(deviceInfo, ykType)
  }

  private fun parseDeviceInfo(map: com.facebook.react.bridge.ReadableMap): com.yubico.yubikit.management.DeviceInfo {
    val builder = com.yubico.yubikit.management.DeviceInfo.Builder()
    builder.version(com.yubico.yubikit.core.Version(
      map.getMap("version")!!.getInt("major"),
      map.getMap("version")!!.getInt("minor"),
      map.getMap("version")!!.getInt("micro")
    ))
    map.getString("formFactor")?.let {
      builder.formFactor(com.yubico.yubikit.management.FormFactor.valueOf(it))
    }
    if (map.hasKey("serialNumber") && !map.isNull("serialNumber")) {
      builder.serialNumber(map.getInt("serialNumber"))
    }
    builder.isLocked(map.getBoolean("isLocked"))
    builder.isFips(map.getBoolean("isFips"))
    // getName() relies on hasTransport(Transport.NFC)/(USB), which in turn is just
    // "does the map below contain this key" - if this isn't reconstructed here,
    // hasTransport() is always false for every transport and getName() can never
    // report NFC-capable devices correctly, regardless of the real hardware.
    val supportedCapabilities = mutableMapOf<Transport, Int>()
    map.getMap("supportedCapabilities")?.let { caps ->
      if (caps.hasKey("usb") && !caps.isNull("usb")) {
        supportedCapabilities[Transport.USB] = caps.getInt("usb")
      }
      if (caps.hasKey("nfc") && !caps.isNull("nfc")) {
        supportedCapabilities[Transport.NFC] = caps.getInt("nfc")
      }
    }
    builder.supportedCapabilities(supportedCapabilities)
    // DeviceInfo.Builder may not expose all setters; this is a best-effort reconstruction.
    return builder.build()
  }

  companion object {
    const val NAME = "YubikitSupport"
  }
}

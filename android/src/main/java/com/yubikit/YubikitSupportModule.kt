package com.yubikit

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.yubico.yubikit.core.YubiKeyType
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

  @ReactMethod
  override fun readInfo(deviceHandle: String, pid: Double?, promise: Promise) {
    moduleScope.launch {
      try {
        val connection = YubiKitManagerHolder.getConnection(deviceHandle)
        val info = DeviceUtil.readInfo(
          connection,
          pid?.toInt()?.let { com.yubico.yubikit.core.UsbPid.fromValue(it) }
        )
        promise.resolve(deviceInfoToMap(info))
      } catch (e: Exception) {
        promise.reject("SUPPORT_ERROR", e.message, e)
      }
    }
  }

  @ReactMethod
  override fun getName(info: com.facebook.react.bridge.ReadableMap, keyType: String?, promise: Promise) {
    try {
      val deviceInfo = parseDeviceInfo(info)
      val ykType = keyType?.let { YubiKeyType.valueOf(it) }
      promise.resolve(DeviceUtil.getName(deviceInfo, ykType))
    } catch (e: Exception) {
      promise.reject("SUPPORT_ERROR", e.message, e)
    }
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
    // DeviceInfo.Builder may not expose all setters; this is a best-effort reconstruction.
    return builder.build()
  }

  companion object {
    const val NAME = "YubikitSupport"
  }
}

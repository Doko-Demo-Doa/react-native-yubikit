package com.yubikit

import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class YubikitPackage : com.facebook.react.BaseReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return when (name) {
      YubikitCoreModule.NAME -> YubikitCoreModule(reactContext)
      YubikitManagementModule.NAME -> YubikitManagementModule(reactContext)
      YubikitOathModule.NAME -> YubikitOathModule(reactContext)
      YubikitPivModule.NAME -> YubikitPivModule(reactContext)
      YubikitOpenPgpModule.NAME -> YubikitOpenPgpModule(reactContext)
      YubikitYubiOtpModule.NAME -> YubikitYubiOtpModule(reactContext)
      YubikitFidoModule.NAME -> YubikitFidoModule(reactContext)
      YubikitSupportModule.NAME -> YubikitSupportModule(reactContext)
      else -> null
    }
  }

  override fun getReactModuleInfoProvider() = ReactModuleInfoProvider {
    mapOf(
      YubikitCoreModule.NAME to moduleInfo(YubikitCoreModule.NAME),
      YubikitManagementModule.NAME to moduleInfo(YubikitManagementModule.NAME),
      YubikitOathModule.NAME to moduleInfo(YubikitOathModule.NAME),
      YubikitPivModule.NAME to moduleInfo(YubikitPivModule.NAME),
      YubikitOpenPgpModule.NAME to moduleInfo(YubikitOpenPgpModule.NAME),
      YubikitYubiOtpModule.NAME to moduleInfo(YubikitYubiOtpModule.NAME),
      YubikitFidoModule.NAME to moduleInfo(YubikitFidoModule.NAME),
      YubikitSupportModule.NAME to moduleInfo(YubikitSupportModule.NAME)
    )
  }

  private fun moduleInfo(name: String) = ReactModuleInfo(
    name = name,
    className = name,
    canOverrideExistingModule = false,
    needsEagerInit = false,
    isCxxModule = false,
    isTurboModule = true
  )
}

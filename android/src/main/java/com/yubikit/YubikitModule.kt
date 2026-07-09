package com.yubikit

import com.facebook.react.bridge.ReactApplicationContext

class YubikitModule(reactContext: ReactApplicationContext) :
  NativeYubikitSpec(reactContext) {

  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  companion object {
    const val NAME = NativeYubikitSpec.NAME
  }
}

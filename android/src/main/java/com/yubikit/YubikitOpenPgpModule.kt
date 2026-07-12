package com.yubikit

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.yubico.yubikit.openpgp.KeyRef
import com.yubico.yubikit.openpgp.OpenPgpSession
import com.yubico.yubikit.openpgp.OpenPgpCurve
import com.yubico.yubikit.openpgp.Uif
import com.yubico.yubikit.openpgp.PinPolicy
import com.yubikit.utils.YubikitUtils.base64Decode
import com.yubikit.utils.YubikitUtils.base64Encode
import com.yubikit.utils.YubikitUtils.versionToMap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Suppress("unused")
class YubikitOpenPgpModule(reactContext: ReactApplicationContext) :
  NativeYubikitOpenPgpSpec(reactContext) {

  private val moduleScope = CoroutineScope(Dispatchers.IO)

  override fun getName(): String = NAME

  private inline fun <R> withOpenPgpSession(
    deviceHandle: String,
    promise: Promise,
    crossinline block: (OpenPgpSession) -> R
  ) {
    moduleScope.launch {
      try {
        val result = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          OpenPgpSession(connection).use { session ->
            block(session)
          }
        }
        @Suppress("UNCHECKED_CAST")
        when (result) {
          is Unit -> promise.resolve(null)
          else -> promise.resolve(result)
        }
      } catch (e: Exception) {
        promise.reject("OPENPGP_ERROR", e.message, e)
      }
    }
  }

  private fun keyRefFromString(value: String): KeyRef {
    return KeyRef.valueOf(value)
  }

  private fun openPgpCurveFromString(value: String): OpenPgpCurve {
    return OpenPgpCurve.valueOf(value)
  }

  private fun uifFromString(value: String): Uif {
    return Uif.valueOf(value)
  }

  private fun pinPolicyFromString(value: String): PinPolicy {
    return PinPolicy.valueOf(value)
  }

  override fun getVersion(deviceHandle: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) { versionToMap(it.version) }
  }

  override fun getApplicationRelatedData(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val data = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          OpenPgpSession(connection).use { session ->
            session.applicationRelatedData
          }
        }
        promise.resolve(Arguments.createMap().apply {
          putString("aid", base64Encode(data.aid.bytes))
          putString("historical", base64Encode(data.historical))
        })
      } catch (e: Exception) {
        promise.reject("OPENPGP_ERROR", e.message, e)
      }
    }
  }

  override fun verifyUserPin(
    deviceHandle: String,
    pin: String,
    extended: Boolean?,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      it.verifyUserPin(pin.toCharArray(), extended ?: false)
    }
  }

  override fun verifyAdminPin(deviceHandle: String, pin: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) { it.verifyAdminPin(pin.toCharArray()) }
  }

  override fun unverifyUserPin(deviceHandle: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) { it.unverifyUserPin() }
  }

  override fun unverifyAdminPin(deviceHandle: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) { it.unverifyAdminPin() }
  }

  override fun getSignatureCounter(deviceHandle: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) { it.signatureCounter }
  }

  override fun getChallenge(deviceHandle: String, length: Double, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      base64Encode(it.getChallenge(length.toInt()))
    }
  }

  override fun reset(deviceHandle: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) { it.reset() }
  }

  override fun setPinAttempts(
    deviceHandle: String,
    userAttempts: Double,
    resetAttempts: Double,
    adminAttempts: Double,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      it.setPinAttempts(userAttempts.toInt(), resetAttempts.toInt(), adminAttempts.toInt())
    }
  }

  override fun changeUserPin(
    deviceHandle: String,
    pin: String,
    newPin: String,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      it.changeUserPin(pin.toCharArray(), newPin.toCharArray())
    }
  }

  override fun changeAdminPin(
    deviceHandle: String,
    pin: String,
    newPin: String,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      it.changeAdminPin(pin.toCharArray(), newPin.toCharArray())
    }
  }

  override fun setSignaturePinPolicy(
    deviceHandle: String,
    policy: String,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      it.setSignaturePinPolicy(pinPolicyFromString(policy))
    }
  }

  override fun getUif(deviceHandle: String, keyRef: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      it.getUif(keyRefFromString(keyRef)).name
    }
  }

  override fun setUif(
    deviceHandle: String,
    keyRef: String,
    uif: String,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      it.setUif(keyRefFromString(keyRef), uifFromString(uif))
    }
  }

  override fun getAlgorithmInformation(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val info = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          OpenPgpSession(connection).use { session ->
            session.algorithmInformation
          }
        }
        val result = Arguments.createArray()
        info.forEach { (keyRef, attributes) ->
          val attrArray = Arguments.createArray()
          attributes.forEach { attr ->
            attrArray.pushMap(Arguments.createMap().apply {
              putString("keyRef", keyRef.name)
              putString("attributes", attr.toString())
            })
          }
          result.pushMap(Arguments.createMap().apply {
            putString("keyRef", keyRef.name)
            putArray("attributes", attrArray)
          })
        }
        promise.resolve(result)
      } catch (e: Exception) {
        promise.reject("OPENPGP_ERROR", e.message, e)
      }
    }
  }

  override fun setAlgorithmAttributes(
    deviceHandle: String,
    keyRef: String,
    attributes: ReadableMap,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      // OpenPgp AlgorithmAttributes is complex; expose minimal constructor path.
      throw NotImplementedError("setAlgorithmAttributes requires native-side AlgorithmAttributes construction")
    }
  }

  override fun getCertificate(deviceHandle: String, keyRef: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      base64Encode(it.getCertificate(keyRefFromString(keyRef))?.encoded)
    }
  }

  override fun putCertificate(
    deviceHandle: String,
    keyRef: String,
    certificate: String,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      val cert = java.security.cert.CertificateFactory.getInstance("X.509")
        .generateCertificate(
          java.io.ByteArrayInputStream(base64Decode(certificate) ?: byteArrayOf())
        ) as java.security.cert.X509Certificate
      it.putCertificate(keyRefFromString(keyRef), cert)
    }
  }

  override fun deleteCertificate(deviceHandle: String, keyRef: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      it.deleteCertificate(keyRefFromString(keyRef))
    }
  }

  override fun generateRsaKey(
    deviceHandle: String,
    keyRef: String,
    keySize: Double,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      base64Encode(it.generateRsaKey(keyRefFromString(keyRef), keySize.toInt()).encoded)
    }
  }

  override fun generateEcKey(
    deviceHandle: String,
    keyRef: String,
    curve: String,
    promise: Promise
  ) {
    withOpenPgpSession(deviceHandle, promise) {
      base64Encode(
        it.generateEcKey(keyRefFromString(keyRef), openPgpCurveFromString(curve)).encoded
      )
    }
  }

  override fun getPublicKey(deviceHandle: String, keyRef: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      base64Encode(it.getPublicKey(keyRefFromString(keyRef)).encoded)
    }
  }

  override fun deleteKey(deviceHandle: String, keyRef: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      it.deleteKey(keyRefFromString(keyRef))
    }
  }

  override fun sign(deviceHandle: String, payload: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      base64Encode(it.sign(base64Decode(payload) ?: byteArrayOf()))
    }
  }

  override fun decrypt(deviceHandle: String, payload: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      base64Encode(it.decrypt(base64Decode(payload) ?: byteArrayOf()))
    }
  }

  override fun authenticate(deviceHandle: String, payload: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      base64Encode(it.authenticate(base64Decode(payload) ?: byteArrayOf()))
    }
  }

  override fun attestKey(deviceHandle: String, keyRef: String, promise: Promise) {
    withOpenPgpSession(deviceHandle, promise) {
      base64Encode(it.attestKey(keyRefFromString(keyRef)).encoded)
    }
  }

  companion object {
    const val NAME = "YubikitOpenPgp"
  }
}

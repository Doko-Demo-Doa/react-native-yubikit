package com.yubikit

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.yubico.yubikit.piv.PivSession
import com.yubikit.utils.YubikitUtils.base64Decode
import com.yubikit.utils.YubikitUtils.base64Encode
import com.yubikit.utils.YubikitUtils.keyTypeFromString
import com.yubikit.utils.YubikitUtils.managementKeyTypeFromString
import com.yubikit.utils.YubikitUtils.pinPolicyFromString
import com.yubikit.utils.YubikitUtils.slotFromString
import com.yubikit.utils.YubikitUtils.touchPolicyFromString
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Suppress("unused")
class YubikitPivModule(reactContext: ReactApplicationContext) :
  NativeYubikitPivSpec(reactContext) {

  private val moduleScope = CoroutineScope(Dispatchers.IO)

  override fun getName(): String = NAME

  private inline fun <R> withPivSession(
    deviceHandle: String,
    promise: Promise,
    crossinline block: (PivSession) -> R
  ) {
    moduleScope.launch {
      try {
        val result = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          PivSession(connection).use { session ->
            block(session)
          }
        }
        @Suppress("UNCHECKED_CAST")
        when (result) {
          is Unit -> promise.resolve(null)
          else -> promise.resolve(result)
        }
      } catch (e: Exception) {
        promise.reject("PIV_ERROR", e.message, e)
      }
    }
  }

  override fun reset(deviceHandle: String, promise: Promise) {
    withPivSession(deviceHandle, promise) { it.reset() }
  }

  override fun getSerialNumber(deviceHandle: String, promise: Promise) {
    withPivSession(deviceHandle, promise) { it.serialNumber }
  }

  override fun authenticate(deviceHandle: String, managementKey: String, promise: Promise) {
    withPivSession(deviceHandle, promise) {
      it.authenticate(base64Decode(managementKey) ?: byteArrayOf())
    }
  }

  override fun setManagementKey(
    deviceHandle: String,
    keyType: String,
    managementKey: String,
    requireTouch: Boolean,
    promise: Promise
  ) {
    withPivSession(deviceHandle, promise) {
      it.setManagementKey(
        managementKeyTypeFromString(keyType),
        base64Decode(managementKey) ?: byteArrayOf(),
        requireTouch
      )
    }
  }

  override fun verifyPin(deviceHandle: String, pin: String, promise: Promise) {
    withPivSession(deviceHandle, promise) { it.verifyPin(pin.toCharArray()) }
  }

  override fun getPinAttempts(deviceHandle: String, promise: Promise) {
    withPivSession(deviceHandle, promise) { it.pinAttempts }
  }

  override fun changePin(
    deviceHandle: String,
    oldPin: String,
    newPin: String,
    promise: Promise
  ) {
    withPivSession(deviceHandle, promise) {
      it.changePin(oldPin.toCharArray(), newPin.toCharArray())
    }
  }

  override fun changePuk(
    deviceHandle: String,
    oldPuk: String,
    newPuk: String,
    promise: Promise
  ) {
    withPivSession(deviceHandle, promise) {
      it.changePuk(oldPuk.toCharArray(), newPuk.toCharArray())
    }
  }

  override fun unblockPin(
    deviceHandle: String,
    puk: String,
    newPin: String,
    promise: Promise
  ) {
    withPivSession(deviceHandle, promise) {
      it.unblockPin(puk.toCharArray(), newPin.toCharArray())
    }
  }

  override fun setPinAttempts(
    deviceHandle: String,
    pinAttempts: Double,
    pukAttempts: Double,
    promise: Promise
  ) {
    withPivSession(deviceHandle, promise) {
      it.setPinAttempts(pinAttempts.toInt(), pukAttempts.toInt())
    }
  }

  override fun getPinMetadata(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val meta = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          PivSession(connection).use { session ->
            session.pinMetadata
          }
        }
        promise.resolve(Arguments.createMap().apply {
          putInt("attemptsRemaining", meta.attemptsRemaining)
        })
      } catch (e: Exception) {
        promise.reject("PIV_ERROR", e.message, e)
      }
    }
  }

  override fun getPukMetadata(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val meta = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          PivSession(connection).use { session ->
            session.pukMetadata
          }
        }
        promise.resolve(Arguments.createMap().apply {
          putInt("attemptsRemaining", meta.attemptsRemaining)
        })
      } catch (e: Exception) {
        promise.reject("PIV_ERROR", e.message, e)
      }
    }
  }

  override fun getManagementKeyMetadata(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val meta = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          PivSession(connection).use { session ->
            session.managementKeyMetadata
          }
        }
        promise.resolve(Arguments.createMap().apply {
          putString("keyType", com.yubikit.utils.YubikitUtils.managementKeyTypeToString(meta.keyType))
          putBoolean("defaultValue", meta.isDefaultValue)
          // The JS-facing type is `touchRequired: boolean`, not the raw TouchPolicy
          // string used by getSlotMetadata - DEFAULT/NEVER both mean "not required".
          putBoolean(
            "touchRequired",
            meta.touchPolicy != com.yubico.yubikit.piv.TouchPolicy.DEFAULT &&
              meta.touchPolicy != com.yubico.yubikit.piv.TouchPolicy.NEVER
          )
        })
      } catch (e: Exception) {
        promise.reject("PIV_ERROR", e.message, e)
      }
    }
  }

  override fun getSlotMetadata(deviceHandle: String, slot: String, promise: Promise) {
    moduleScope.launch {
      try {
        val meta = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          PivSession(connection).use { session ->
            session.getSlotMetadata(slotFromString(slot))
          }
        }
        promise.resolve(Arguments.createMap().apply {
          putString("keyType", com.yubikit.utils.YubikitUtils.keyTypeToString(meta.keyType))
          putString("pinPolicy", com.yubikit.utils.YubikitUtils.pinPolicyToString(meta.pinPolicy))
          putString("touchPolicy", com.yubikit.utils.YubikitUtils.touchPolicyToString(meta.touchPolicy))
          putBoolean("generated", meta.isGenerated)
          meta.publicKeyValues?.let { putString("publicKey", base64Encode(it.encoded)) }
        })
      } catch (e: Exception) {
        promise.reject("PIV_ERROR", e.message, e)
      }
    }
  }

  override fun getCertificate(deviceHandle: String, slot: String, promise: Promise) {
    withPivSession(deviceHandle, promise) {
      base64Encode(it.getCertificate(slotFromString(slot)).encoded)
    }
  }

  override fun putCertificate(
    deviceHandle: String,
    slot: String,
    certificate: String,
    compress: Boolean?,
    promise: Promise
  ) {
    withPivSession(deviceHandle, promise) {
      val cert = java.security.cert.CertificateFactory.getInstance("X.509")
        .generateCertificate(
          java.io.ByteArrayInputStream(base64Decode(certificate) ?: byteArrayOf())
        ) as java.security.cert.X509Certificate
      if (compress == true) {
        it.putCertificate(slotFromString(slot), cert, true)
      } else {
        it.putCertificate(slotFromString(slot), cert)
      }
    }
  }

  override fun deleteCertificate(deviceHandle: String, slot: String, promise: Promise) {
    withPivSession(deviceHandle, promise) { it.deleteCertificate(slotFromString(slot)) }
  }

  override fun attestKey(deviceHandle: String, slot: String, promise: Promise) {
    withPivSession(deviceHandle, promise) {
      base64Encode(it.attestKey(slotFromString(slot)).encoded)
    }
  }

  override fun generateKey(
    deviceHandle: String,
    slot: String,
    keyType: String,
    pinPolicy: String,
    touchPolicy: String,
    promise: Promise
  ) {
    withPivSession(deviceHandle, promise) {
      val publicKey = it.generateKey(
        slotFromString(slot),
        keyTypeFromString(keyType),
        pinPolicyFromString(pinPolicy),
        touchPolicyFromString(touchPolicy)
      )
      base64Encode(publicKey.encoded)
    }
  }

  override fun deleteKey(deviceHandle: String, slot: String, promise: Promise) {
    withPivSession(deviceHandle, promise) { it.deleteKey(slotFromString(slot)) }
  }

  override fun rawSignOrDecrypt(
    deviceHandle: String,
    slot: String,
    keyType: String,
    payload: String,
    promise: Promise
  ) {
    withPivSession(deviceHandle, promise) {
      base64Encode(
        it.rawSignOrDecrypt(
          slotFromString(slot),
          keyTypeFromString(keyType),
          base64Decode(payload) ?: byteArrayOf()
        )
      )
    }
  }

  override fun getBioMetadata(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val meta = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          PivSession(connection).use { session ->
            session.bioMetadata
          }
        }
        promise.resolve(Arguments.createMap().apply {
          putInt("attemptsRemaining", meta.attemptsRemaining)
          putBoolean("configured", meta.isConfigured)
          putBoolean("temporaryPin", meta.hasTemporaryPin())
        })
      } catch (e: Exception) {
        promise.reject("PIV_ERROR", e.message, e)
      }
    }
  }

  companion object {
    const val NAME = "YubikitPiv"
  }
}

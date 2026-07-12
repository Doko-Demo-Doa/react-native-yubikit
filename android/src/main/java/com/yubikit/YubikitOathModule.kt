package com.yubikit

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.yubico.yubikit.oath.OathSession
import com.yubikit.utils.YubikitUtils.base64Decode
import com.yubikit.utils.YubikitUtils.base64Encode
import com.yubikit.utils.YubikitUtils.codeToMap
import com.yubikit.utils.YubikitUtils.credentialDataFromMap
import com.yubikit.utils.YubikitUtils.credentialToMap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Suppress("unused")
class YubikitOathModule(reactContext: ReactApplicationContext) :
  NativeYubikitOathSpec(reactContext) {

  private val moduleScope = CoroutineScope(Dispatchers.IO)

  override fun getName(): String = NAME

  private inline fun <R> withOathSession(
    deviceHandle: String,
    promise: Promise,
    crossinline block: (OathSession) -> R
  ) {
    moduleScope.launch {
      try {
        val result = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          OathSession(connection).use { session ->
            block(session)
          }
        }
        @Suppress("UNCHECKED_CAST")
        when (result) {
          is Unit -> promise.resolve(null)
          else -> promise.resolve(result)
        }
      } catch (e: Exception) {
        promise.reject("OATH_ERROR", e.message, e)
      }
    }
  }

  override fun getDeviceId(deviceHandle: String, promise: Promise) {
    withOathSession(deviceHandle, promise) { it.deviceId }
  }

  override fun reset(deviceHandle: String, promise: Promise) {
    withOathSession(deviceHandle, promise) { it.reset() }
  }

  override fun isAccessKeySet(deviceHandle: String, promise: Promise) {
    withOathSession(deviceHandle, promise) { it.isAccessKeySet }
  }

  override fun isLocked(deviceHandle: String, promise: Promise) {
    withOathSession(deviceHandle, promise) { it.isLocked }
  }

  override fun unlockWithPassword(deviceHandle: String, password: String, promise: Promise) {
    withOathSession(deviceHandle, promise) { it.unlock(password.toCharArray()) }
  }

  override fun unlockWithAccessKey(deviceHandle: String, accessKey: String, promise: Promise) {
    withOathSession(deviceHandle, promise) {
      val key = com.yubikit.utils.YubikitUtils.accessKeyFromBytes(base64Decode(accessKey))
        ?: throw IllegalArgumentException("accessKey is required")
      it.unlock(key)
    }
  }

  override fun setPassword(deviceHandle: String, password: String, promise: Promise) {
    withOathSession(deviceHandle, promise) { it.setPassword(password.toCharArray()) }
  }

  override fun setAccessKey(deviceHandle: String, accessKey: String, promise: Promise) {
    withOathSession(deviceHandle, promise) {
      it.setAccessKey(base64Decode(accessKey) ?: byteArrayOf())
    }
  }

  override fun deleteAccessKey(deviceHandle: String, promise: Promise) {
    withOathSession(deviceHandle, promise) { it.deleteAccessKey() }
  }

  override fun getCredentials(deviceHandle: String, promise: Promise) {
    moduleScope.launch {
      try {
        val credentials = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          OathSession(connection).use { session ->
            session.credentials
          }
        }
        val array = Arguments.createArray()
        credentials.forEach { array.pushMap(credentialToMap(it)) }
        promise.resolve(Arguments.createMap().apply { putArray("credentials", array) })
      } catch (e: Exception) {
        promise.reject("OATH_ERROR", e.message, e)
      }
    }
  }

  override fun calculateCodes(deviceHandle: String, timestamp: Double?, promise: Promise) {
    moduleScope.launch {
      try {
        val entries = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          OathSession(connection).use { session ->
            if (timestamp != null) session.calculateCodes(timestamp.toLong())
            else session.calculateCodes()
          }
        }
        val array = Arguments.createArray()
        entries.forEach { (credential, code) ->
          array.pushMap(Arguments.createMap().apply {
            putMap("credential", credentialToMap(credential))
            code?.let { putMap("code", codeToMap(it)) }
          })
        }
        promise.resolve(Arguments.createMap().apply { putArray("codes", array) })
      } catch (e: Exception) {
        promise.reject("OATH_ERROR", e.message, e)
      }
    }
  }

  override fun calculateResponse(
    deviceHandle: String,
    credentialId: String,
    challenge: String,
    promise: Promise
  ) {
    withOathSession(deviceHandle, promise) {
      base64Encode(
        it.calculateResponse(
          base64Decode(credentialId) ?: byteArrayOf(),
          base64Decode(challenge) ?: byteArrayOf()
        )
      )
    }
  }

  override fun calculateCode(
    deviceHandle: String,
    credentialId: String,
    timestamp: Double?,
    promise: Promise
  ) {
    moduleScope.launch {
      try {
        val code = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          OathSession(connection).use { session ->
            val credential = session.credentials.find {
              it.id.contentEquals(base64Decode(credentialId) ?: byteArrayOf())
            } ?: throw IllegalArgumentException("Credential not found")
            if (timestamp != null) {
              session.calculateCode(credential, timestamp.toLong())
            } else {
              session.calculateCode(credential)
            }
          }
        }
        promise.resolve(codeToMap(code))
      } catch (e: Exception) {
        promise.reject("OATH_ERROR", e.message, e)
      }
    }
  }

  override fun putCredential(
    deviceHandle: String,
    credentialData: com.facebook.react.bridge.ReadableMap,
    requireTouch: Boolean,
    promise: Promise
  ) {
    moduleScope.launch {
      try {
        val credential = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          OathSession(connection).use { session ->
            session.putCredential(credentialDataFromMap(credentialData), requireTouch)
          }
        }
        promise.resolve(credentialToMap(credential))
      } catch (e: Exception) {
        promise.reject("OATH_ERROR", e.message, e)
      }
    }
  }

  override fun deleteCredential(deviceHandle: String, credentialId: String, promise: Promise) {
    withOathSession(deviceHandle, promise) {
      it.deleteCredential(base64Decode(credentialId) ?: byteArrayOf())
    }
  }

  override fun renameCredential(
    deviceHandle: String,
    credentialId: String,
    newAccountName: String,
    newIssuer: String?,
    promise: Promise
  ) {
    moduleScope.launch {
      try {
        val credential = YubiKitManagerHolder.withSmartCard(deviceHandle) { connection ->
          OathSession(connection).use { session ->
            val cred = session.credentials.find { it.id.contentEquals(base64Decode(credentialId) ?: byteArrayOf()) }
              ?: throw IllegalArgumentException("Credential not found")
            session.renameCredential(cred, newAccountName, newIssuer)
          }
        }
        promise.resolve(credentialToMap(credential))
      } catch (e: Exception) {
        promise.reject("OATH_ERROR", e.message, e)
      }
    }
  }

  companion object {
    const val NAME = "YubikitOath"
  }
}

package com.yubikit

import android.util.Base64
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.yubico.yubikit.fido.client.Ctap2Client
import com.yubico.yubikit.fido.client.CredentialManager
import com.yubico.yubikit.fido.client.WebAuthnClient
import com.yubico.yubikit.fido.client.clientdata.ClientDataProvider
import com.yubico.yubikit.fido.ctap.Ctap2Session
import com.yubico.yubikit.fido.webauthn.AuthenticatorAssertionResponse
import com.yubico.yubikit.fido.webauthn.AuthenticatorAttestationResponse
import com.yubico.yubikit.fido.webauthn.PublicKeyCredential
import com.yubico.yubikit.fido.webauthn.PublicKeyCredentialCreationOptions
import com.yubico.yubikit.fido.webauthn.PublicKeyCredentialDescriptor
import com.yubico.yubikit.fido.webauthn.PublicKeyCredentialParameters
import com.yubico.yubikit.fido.webauthn.PublicKeyCredentialRequestOptions
import com.yubico.yubikit.fido.webauthn.PublicKeyCredentialRpEntity
import com.yubico.yubikit.fido.webauthn.PublicKeyCredentialUserEntity
import com.yubikit.utils.YubikitUtils.base64Decode
import com.yubikit.utils.YubikitUtils.base64Encode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONObject

@Suppress("unused")
class YubikitFidoModule(reactContext: ReactApplicationContext) :
  NativeYubikitFidoSpec(reactContext) {

  private val moduleScope = CoroutineScope(Dispatchers.IO)

  override fun getName(): String = NAME

  private inline fun <R> withFidoConnection(
    deviceHandle: String,
    promise: Promise,
    crossinline block: (com.yubico.yubikit.core.fido.FidoConnection) -> R
  ) {
    moduleScope.launch {
      try {
        val result = YubiKitManagerHolder.withFido(deviceHandle) { connection -> block(connection) }
        when (result) {
          is Unit -> promise.resolve(null)
          else -> promise.resolve(result)
        }
      } catch (e: Exception) {
        promise.reject("FIDO_ERROR", e.message, e)
      }
    }
  }

  /**
   * The SDK only accepts a pre-built clientDataJSON hash, so the standard WebAuthn
   * clientDataJSON must be constructed here from the JS-supplied challenge.
   */
  private fun base64UrlEncode(bytes: ByteArray): String {
    return Base64.encodeToString(bytes, Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP)
  }

  private fun buildClientData(type: String, challenge: ByteArray, effectiveDomain: String): ClientDataProvider {
    val json = JSONObject().apply {
      put("type", type)
      put("challenge", base64UrlEncode(challenge))
      put("origin", "https://$effectiveDomain")
      put("crossOrigin", false)
    }
    return ClientDataProvider.fromClientDataJson(json.toString().toByteArray(Charsets.UTF_8))
  }

  private fun mapToPublicKeyCredential(cred: PublicKeyCredential): WritableMap {
    return Arguments.createMap().apply {
      putString("id", base64Encode(cred.rawId))
      putString("rawId", base64Encode(cred.rawId))
      putString("type", "public-key")
      putMap("response", Arguments.createMap().apply {
        val response = cred.response
        putString("clientDataJSON", base64Encode(response.clientDataJson))
        when (response) {
          is AuthenticatorAttestationResponse -> {
            putString("authenticatorData", base64Encode(response.authenticatorData.bytes))
            putString("attestationObject", base64Encode(response.attestationObject))
          }
          is AuthenticatorAssertionResponse -> {
            putString("authenticatorData", base64Encode(response.authenticatorData))
            putString("signature", base64Encode(response.signature))
            response.userHandle?.let { putString("userHandle", base64Encode(it)) }
          }
        }
      })
    }
  }

  private fun mapCtap2Info(info: Ctap2Session.InfoData): WritableMap {
    return Arguments.createMap().apply {
      val versions = Arguments.createArray()
      info.versions.forEach { versions.pushString(it) }
      putArray("versions", versions)
      putString("aaguid", base64Encode(info.aaguid))
      val extensions = Arguments.createArray()
      info.extensions.forEach { extensions.pushString(it) }
      putArray("extensions", extensions)
      val optsMap = Arguments.createMap()
      info.options.forEach { (k, v) -> if (v is Boolean) optsMap.putBoolean(k, v) }
      putMap("options", optsMap)
      putInt("maxMsgSize", info.maxMsgSize)
      val protos = Arguments.createArray()
      info.pinUvAuthProtocols.forEach { protos.pushInt(it) }
      putArray("pinUvAuthProtocols", protos)
      info.maxCredentialCountInList?.let { putInt("maxCredentialCountInList", it) }
      info.maxCredentialIdLength?.let { putInt("maxCredentialIdLength", it) }
      val transports = Arguments.createArray()
      info.transports.forEach { transports.pushString(it) }
      putArray("transports", transports)
      val algorithms = Arguments.createArray()
      info.algorithms.forEach { alg ->
        algorithms.pushMap(Arguments.createMap().apply {
          putString("type", alg.type)
          putInt("alg", alg.alg)
        })
      }
      putArray("algorithms", algorithms)
      putInt("maxLargeBlob", info.maxSerializedLargeBlobArray)
      putInt("minPinLength", info.minPinLength)
      putInt("maxCredBlobLength", info.maxCredBlobLength)
      putInt("maxRpidsForMinPinLength", info.maxRpidsForSetMinPinLength)
      info.preferredPlatformUvAttempts?.let { putInt("preferredPlatformUvAttempts", it) }
      putInt("uvModality", info.uvModality)
      val certsMap = Arguments.createMap()
      info.certifications.forEach { (k, v) -> if (v is Int) certsMap.putInt(k, v) }
      putMap("certifications", certsMap)
      info.remainingDiscoverableCredentials?.let { putInt("remainingDiscoverableCredentials", it) }
      info.vendorPrototypeConfigCommands?.let { cmds ->
        val arr = Arguments.createArray()
        cmds.forEach { arr.pushInt(it) }
        putArray("vendorPrototypeConfigCommands", arr)
      }
    }
  }

  @ReactMethod
  override fun getInfo(deviceHandle: String, promise: Promise) {
    withFidoConnection(deviceHandle, promise) { connection ->
      Ctap2Session(connection).use { session ->
        mapCtap2Info(session.info)
      }
    }
  }

  @ReactMethod
  override fun makeCredential(
    deviceHandle: String,
    options: ReadableMap,
    effectiveDomain: String,
    pin: String?,
    enterpriseAttestation: Double?,
    promise: Promise
  ) {
    moduleScope.launch {
      try {
        val credential = YubiKitManagerHolder.withFido(deviceHandle) { connection ->
          WebAuthnClient.create(connection, null, null).use { client ->
            val rpMap = options.getMap("rp")!!
            val userMap = options.getMap("user")!!
            val challenge = base64Decode(options.getString("challenge")) ?: byteArrayOf()
            val clientData = buildClientData("webauthn.create", challenge, effectiveDomain)

            val pubKeyCredParams = options.getArray("pubKeyCredParams")!!.let { arr ->
              (0 until arr.size()).map { i ->
                val m = arr.getMap(i)!!
                PublicKeyCredentialParameters(
                  m.getString("type") ?: "public-key",
                  m.getInt("alg")
                )
              }
            }

            val rp = PublicKeyCredentialRpEntity(
              rpMap.getString("name") ?: rpMap.getString("id") ?: effectiveDomain,
              rpMap.getString("id") ?: effectiveDomain
            )
            val user = PublicKeyCredentialUserEntity(
              userMap.getString("name") ?: "",
              base64Decode(userMap.getString("id")) ?: byteArrayOf(),
              userMap.getString("displayName") ?: ""
            )

            val excludeCredentials = options.getArray("excludeCredentials")?.let { arr ->
              (0 until arr.size()).map { i ->
                val m = arr.getMap(i)!!
                PublicKeyCredentialDescriptor(
                  m.getString("type") ?: "public-key",
                  base64Decode(m.getString("id")) ?: byteArrayOf()
                )
              }
            }

            val creationOptions = PublicKeyCredentialCreationOptions(
              rp,
              user,
              challenge,
              pubKeyCredParams,
              null,
              excludeCredentials,
              null,
              null,
              null
            )

            client.makeCredential(
              clientData,
              creationOptions,
              effectiveDomain,
              pin?.toCharArray(),
              enterpriseAttestation?.toInt(),
              null
            )
          }
        }
        promise.resolve(mapToPublicKeyCredential(credential))
      } catch (e: Exception) {
        promise.reject("FIDO_ERROR", e.message, e)
      }
    }
  }

  @ReactMethod
  override fun getAssertion(
    deviceHandle: String,
    options: ReadableMap,
    effectiveDomain: String,
    pin: String?,
    promise: Promise
  ) {
    moduleScope.launch {
      try {
        val credential = YubiKitManagerHolder.withFido(deviceHandle) { connection ->
          WebAuthnClient.create(connection, null, null).use { client ->
            val challenge = base64Decode(options.getString("challenge")) ?: byteArrayOf()
            val clientData = buildClientData("webauthn.get", challenge, effectiveDomain)
            val rpId = options.getString("rpId") ?: effectiveDomain

            val allowCredentials = options.getArray("allowCredentials")?.let { arr ->
              (0 until arr.size()).map { i ->
                val m = arr.getMap(i)!!
                PublicKeyCredentialDescriptor(
                  m.getString("type") ?: "public-key",
                  base64Decode(m.getString("id")) ?: byteArrayOf()
                )
              }
            }

            val requestOptions = PublicKeyCredentialRequestOptions(
              challenge,
              null,
              rpId,
              allowCredentials,
              null,
              null
            )

            client.getAssertion(clientData, requestOptions, effectiveDomain, pin?.toCharArray(), null)
          }
        }
        promise.resolve(mapToPublicKeyCredential(credential))
      } catch (e: Exception) {
        promise.reject("FIDO_ERROR", e.message, e)
      }
    }
  }

  @ReactMethod
  override fun reset(deviceHandle: String, promise: Promise) {
    withFidoConnection(deviceHandle, promise) { connection ->
      Ctap2Session(connection).use { it.reset(null) }
    }
  }

  private fun withCredentialManager(
    deviceHandle: String,
    pin: String,
    promise: Promise,
    block: (CredentialManager) -> Any?
  ) {
    moduleScope.launch {
      try {
        val result = YubiKitManagerHolder.withFido(deviceHandle) { connection ->
          Ctap2Client(Ctap2Session(connection)).use { client ->
            val manager = client.getCredentialManager(pin.toCharArray())
            block(manager)
          }
        }
        when (result) {
          is Unit -> promise.resolve(null)
          else -> promise.resolve(result)
        }
      } catch (e: Exception) {
        promise.reject("FIDO_ERROR", e.message, e)
      }
    }
  }

  @ReactMethod
  override fun getCredentialCount(deviceHandle: String, pin: String, promise: Promise) {
    withCredentialManager(deviceHandle, pin, promise) { it.credentialCount }
  }

  @ReactMethod
  override fun getRpIdList(deviceHandle: String, pin: String, promise: Promise) {
    withCredentialManager(deviceHandle, pin, promise) {
      val list = it.rpIdList
      val arr = Arguments.createArray()
      list.forEach { rpId -> arr.pushString(rpId) }
      arr
    }
  }

  @ReactMethod
  override fun getCredentials(
    deviceHandle: String,
    rpId: String,
    pin: String,
    promise: Promise
  ) {
    withCredentialManager(deviceHandle, pin, promise) { manager ->
      val creds = manager.getCredentials(rpId)
      val arr = Arguments.createArray()
      creds.forEach { (descriptor, user) ->
        arr.pushMap(Arguments.createMap().apply {
          putMap("credential", Arguments.createMap().apply {
            putString("id", base64Encode(descriptor.id))
            putString("type", descriptor.type)
          })
          putMap("user", Arguments.createMap().apply {
            putString("id", base64Encode(user.id))
            putString("name", user.name)
            putString("displayName", user.displayName)
          })
        })
      }
      arr
    }
  }

  @ReactMethod
  override fun deleteCredential(
    deviceHandle: String,
    credential: ReadableMap,
    pin: String,
    promise: Promise
  ) {
    withCredentialManager(deviceHandle, pin, promise) { manager ->
      manager.deleteCredential(
        PublicKeyCredentialDescriptor(
          credential.getString("type") ?: "public-key",
          base64Decode(credential.getString("id")) ?: byteArrayOf()
        )
      )
    }
  }

  @ReactMethod
  override fun updateUserInformation(
    deviceHandle: String,
    credential: ReadableMap,
    user: ReadableMap,
    pin: String,
    promise: Promise
  ) {
    withCredentialManager(deviceHandle, pin, promise) { manager ->
      manager.updateUserInformation(
        PublicKeyCredentialDescriptor(
          credential.getString("type") ?: "public-key",
          base64Decode(credential.getString("id")) ?: byteArrayOf()
        ),
        PublicKeyCredentialUserEntity(
          user.getString("name") ?: "",
          base64Decode(user.getString("id")) ?: byteArrayOf(),
          user.getString("displayName") ?: ""
        )
      )
    }
  }

  companion object {
    const val NAME = "YubikitFido"
  }
}

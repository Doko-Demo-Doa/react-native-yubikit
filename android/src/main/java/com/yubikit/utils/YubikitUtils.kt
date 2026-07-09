package com.yubikit.utils

import android.os.Bundle
import android.util.Base64
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.yubico.yubikit.core.Transport
import com.yubico.yubikit.core.Version
import com.yubico.yubikit.core.UsbInterface
import com.yubico.yubikit.management.Capability
import com.yubico.yubikit.management.DeviceConfig
import com.yubico.yubikit.management.DeviceInfo
import com.yubico.yubikit.management.FormFactor
import com.yubico.yubikit.oath.AccessKey
import com.yubico.yubikit.oath.Code
import com.yubico.yubikit.oath.Credential
import com.yubico.yubikit.oath.CredentialData
import com.yubico.yubikit.oath.HashAlgorithm
import com.yubico.yubikit.oath.OathType
import com.yubico.yubikit.piv.KeyType
import com.yubico.yubikit.piv.ManagementKeyType
import com.yubico.yubikit.piv.PinPolicy
import com.yubico.yubikit.piv.Slot
import com.yubico.yubikit.piv.TouchPolicy
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

object YubikitUtils {

    @JvmStatic
    fun base64Encode(bytes: ByteArray?): String? {
        return bytes?.let { Base64.encodeToString(it, Base64.NO_WRAP) }
    }

    @JvmStatic
    fun base64Decode(encoded: String?): ByteArray? {
        return encoded?.let { Base64.decode(it, Base64.DEFAULT) }
    }

    @JvmStatic
    fun versionToMap(version: Version): WritableMap {
        return Arguments.createMap().apply {
            putInt("major", version.major.toInt())
            putInt("minor", version.minor.toInt())
            putInt("micro", version.micro.toInt())
        }
    }

    @JvmStatic
    fun parseVersion(map: ReadableMap?): Version? {
        if (map == null) return null
        return Version(
            map.getInt("major"),
            map.getInt("minor"),
            map.getInt("micro")
        )
    }

    @JvmStatic
    fun transportFromString(value: String?): Transport {
        return when (value?.uppercase()) {
            "USB" -> Transport.USB
            "NFC" -> Transport.NFC
            else -> throw IllegalArgumentException("Unknown transport: $value")
        }
    }

    @JvmStatic
    fun transportToString(transport: Transport): String {
        return transport.name
    }

    @JvmStatic
    fun capabilityToString(capability: Capability): String {
        return capability.name
    }

    @JvmStatic
    fun capabilityFromString(value: String): Capability {
        return Capability.valueOf(value)
    }

    @JvmStatic
    fun formFactorToString(formFactor: FormFactor): String {
        return formFactor.name
    }

    @JvmStatic
    fun formFactorFromString(value: String): FormFactor {
        return FormFactor.valueOf(value)
    }

    @JvmStatic
    fun oathTypeFromString(value: String): OathType {
        return OathType.valueOf(value)
    }

    @JvmStatic
    fun oathTypeToString(type: OathType): String {
        return type.name
    }

    @JvmStatic
    fun hashAlgorithmFromString(value: String): HashAlgorithm {
        return HashAlgorithm.valueOf(value)
    }

    @JvmStatic
    fun hashAlgorithmToString(algorithm: HashAlgorithm): String {
        return algorithm.name
    }

    @JvmStatic
    fun slotFromString(value: String): Slot {
        return Slot.valueOf(value)
    }

    @JvmStatic
    fun slotToString(slot: Slot): String {
        return slot.name
    }

    @JvmStatic
    fun keyTypeFromString(value: String): KeyType {
        return KeyType.valueOf(value)
    }

    @JvmStatic
    fun keyTypeToString(keyType: KeyType): String {
        return keyType.name
    }

    @JvmStatic
    fun pinPolicyFromString(value: String): PinPolicy {
        return PinPolicy.valueOf(value)
    }

    @JvmStatic
    fun pinPolicyToString(policy: PinPolicy): String {
        return policy.name
    }

    @JvmStatic
    fun touchPolicyFromString(value: String): TouchPolicy {
        return TouchPolicy.valueOf(value)
    }

    @JvmStatic
    fun touchPolicyToString(policy: TouchPolicy): String {
        return policy.name
    }

    @JvmStatic
    fun managementKeyTypeFromString(value: String): ManagementKeyType {
        return ManagementKeyType.valueOf(value)
    }

    @JvmStatic
    fun managementKeyTypeToString(type: ManagementKeyType): String {
        return type.name
    }

    @JvmStatic
    fun deviceInfoToMap(info: DeviceInfo): WritableMap {
        return Arguments.createMap().apply {
            putMap("version", versionToMap(info.version))
            putString("versionName", info.versionName)
            putString("formFactor", formFactorToString(info.formFactor))
            info.serialNumber?.let { putInt("serialNumber", it) }
            putBoolean("isLocked", info.isLocked)
            putBoolean("isFips", info.isFips)
            putBoolean("isSky", info.isSky)
            info.partNumber?.let { putString("partNumber", it) }
            putInt("fipsCapable", info.fipsCapable)
            putInt("fipsApproved", info.fipsApproved)
            putBoolean("pinComplexity", info.pinComplexity)
            putInt("resetBlocked", info.resetBlocked)
            putMap("supportedCapabilities", capabilitiesToMap(info))
            putBoolean("hasTransportUsb", info.hasTransport(Transport.USB))
            putBoolean("hasTransportNfc", info.hasTransport(Transport.NFC))
            info.config?.let { putMap("config", deviceConfigToMap(it)) }
            info.fpsVersion?.let { putMap("fpsVersion", versionToMap(it)) }
            info.stmVersion?.let { putMap("stmVersion", versionToMap(it)) }
        }
    }

    @JvmStatic
    fun capabilitiesToMap(info: DeviceInfo): WritableMap {
        return Arguments.createMap().apply {
            listOf(Transport.USB, Transport.NFC).forEach { transport ->
                info.getSupportedCapabilities(transport)?.let { value ->
                    putInt(transport.name.lowercase(), value)
                }
            }
        }
    }

    @JvmStatic
    fun deviceConfigToMap(config: DeviceConfig): WritableMap {
        return Arguments.createMap().apply {
            val capsMap = Arguments.createMap()
            var hasCaps = false
            listOf(Transport.USB, Transport.NFC).forEach { transport ->
                config.getEnabledCapabilities(transport)?.let { value ->
                    capsMap.putInt(transport.name.lowercase(), value)
                    hasCaps = true
                }
            }
            if (hasCaps) {
                putMap("enabledCapabilities", capsMap)
            }
            config.autoEjectTimeout?.let { putInt("autoEjectTimeout", it.toInt()) }
            config.challengeResponseTimeout?.let { putInt("challengeResponseTimeout", it.toInt()) }
            config.nfcRestricted?.let { putBoolean("nfcRestricted", it) }
            config.deviceFlags?.let { putInt("deviceFlags", it) }
        }
    }

    @JvmStatic
    fun parseDeviceConfig(map: ReadableMap?): DeviceConfig {
        if (map == null) return DeviceConfig.Builder().build()
        val builder = DeviceConfig.Builder()
        map.getMap("enabledCapabilities")?.let { capsMap ->
            listOf(Transport.USB, Transport.NFC).forEach { transport ->
                val key = transport.name.lowercase()
                if (capsMap.hasKey(key) && !capsMap.isNull(key)) {
                    builder.enabledCapabilities(transport, capsMap.getInt(key))
                }
            }
        }
        if (map.hasKey("autoEjectTimeout") && !map.isNull("autoEjectTimeout")) {
            builder.autoEjectTimeout(map.getInt("autoEjectTimeout").toShort())
        }
        if (map.hasKey("challengeResponseTimeout") && !map.isNull("challengeResponseTimeout")) {
            builder.challengeResponseTimeout(map.getInt("challengeResponseTimeout").toByte())
        }
        if (map.hasKey("nfcRestricted") && !map.isNull("nfcRestricted")) {
            builder.nfcRestricted(map.getBoolean("nfcRestricted"))
        }
        if (map.hasKey("deviceFlags") && !map.isNull("deviceFlags")) {
            builder.deviceFlags(map.getInt("deviceFlags"))
        }
        return builder.build()
    }

    @JvmStatic
    fun credentialToMap(credential: Credential): WritableMap {
        return Arguments.createMap().apply {
            putString("id", base64Encode(credential.id))
            putString("oathType", oathTypeToString(credential.oathType))
            putString("accountName", credential.accountName)
            credential.issuer?.let { putString("issuer", it) }
            putInt("period", credential.period)
            putBoolean("touchRequired", credential.isTouchRequired)
        }
    }

    @JvmStatic
    fun credentialDataFromMap(map: ReadableMap): CredentialData {
        return CredentialData(
            map.getString("accountName") ?: "",
            oathTypeFromString(map.getString("oathType") ?: "TOTP"),
            hashAlgorithmFromString(map.getString("hashAlgorithm") ?: "SHA1"),
            base64Decode(map.getString("secret")) ?: byteArrayOf(),
            map.getInt("digits"),
            map.getInt("period"),
            map.getInt("counter"),
            map.getString("issuer")
        )
    }

    @JvmStatic
    fun codeToMap(code: Code): WritableMap {
        return Arguments.createMap().apply {
            putString("value", code.value)
            putDouble("validFrom", code.validFrom.toDouble())
            putDouble("validUntil", code.validUntil.toDouble())
        }
    }

    @JvmStatic
    fun parseUsbMode(mode: String): UsbInterface.Mode {
        return UsbInterface.Mode.valueOf(mode)
    }

    @JvmStatic
    fun readableArrayToBytes(array: ReadableArray?): ByteArray? {
        if (array == null) return null
        return ByteArray(array.size()) { array.getInt(it).toByte() }
    }

    @JvmStatic
    fun bytesToWritableArray(bytes: ByteArray?): WritableArray? {
        if (bytes == null) return null
        return Arguments.createArray().apply {
            bytes.forEach { pushInt(it.toInt()) }
        }
    }

    @JvmStatic
    fun Bundle.toWritableMap(): WritableMap {
        return Arguments.fromBundle(this)
    }

    @JvmStatic
    fun accessKeyFromBytes(key: ByteArray?): AccessKey? {
        if (key == null) return null
        return ByteArrayAccessKey(key)
    }
}

private class ByteArrayAccessKey(private val key: ByteArray) : AccessKey {
    override fun calculateResponse(challenge: ByteArray): ByteArray {
        val mac = Mac.getInstance("HmacSHA1")
        mac.init(SecretKeySpec(key, "HmacSHA1"))
        return mac.doFinal(challenge)
    }
}

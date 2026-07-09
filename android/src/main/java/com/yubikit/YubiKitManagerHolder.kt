package com.yubikit

import android.app.Activity
import android.content.Context
import android.os.Bundle
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.yubico.yubikit.android.YubiKitManager
import com.yubico.yubikit.android.transport.nfc.NfcConfiguration
import com.yubico.yubikit.android.transport.nfc.NfcNotAvailable
import com.yubico.yubikit.android.transport.nfc.NfcYubiKeyDevice
import com.yubico.yubikit.android.transport.usb.UsbConfiguration
import com.yubico.yubikit.android.transport.usb.UsbYubiKeyDevice
import com.yubico.yubikit.core.YubiKeyConnection
import com.yubico.yubikit.core.YubiKeyDevice
import com.yubico.yubikit.core.fido.FidoConnection
import com.yubico.yubikit.core.otp.OtpConnection
import com.yubico.yubikit.core.smartcard.SmartCardConnection
import java.io.IOException
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference

/**
 * Singleton holder for the YubiKitManager and discovered devices/connections.
 */
object YubiKitManagerHolder {
    @Volatile
    private var manager: YubiKitManager? = null

    private val devices = ConcurrentHashMap<String, YubiKeyDevice>()
    private val connections = ConcurrentHashMap<String, YubiKeyConnection>()

    private var usbConfiguration = UsbConfiguration()
    private var nfcConfiguration = NfcConfiguration()

    @JvmStatic
    fun initialize(context: Context) {
        if (manager == null) {
            synchronized(this) {
                if (manager == null) {
                    manager = YubiKitManager(context.applicationContext)
                }
            }
        }
    }

    @JvmStatic
    fun getManager(): YubiKitManager {
        return manager ?: throw IllegalStateException("YubiKitManager not initialized")
    }

    @JvmStatic
    fun putDevice(device: YubiKeyDevice): String {
        val handle = UUID.randomUUID().toString()
        devices[handle] = device
        return handle
    }

    @JvmStatic
    fun getDevice(handle: String): YubiKeyDevice {
        return devices[handle] ?: throw IllegalArgumentException("Unknown device handle: $handle")
    }

    @JvmStatic
    fun removeDevice(handle: String) {
        devices.remove(handle)
    }

    @JvmStatic
    fun listDevices(): List<Pair<String, YubiKeyDevice>> {
        return devices.toList()
    }

    @JvmStatic
    fun putConnection(connection: YubiKeyConnection): String {
        val handle = UUID.randomUUID().toString()
        connections[handle] = connection
        return handle
    }

    @JvmStatic
    fun getConnection(handle: String): YubiKeyConnection {
        return connections[handle]
            ?: throw IllegalArgumentException("Unknown connection handle: $handle")
    }

    @JvmStatic
    fun removeConnection(handle: String) {
        connections.remove(handle)?.close()
    }

    @JvmStatic
    fun closeAllConnections() {
        connections.values.forEach { try { it.close() } catch (_: IOException) {} }
        connections.clear()
    }

    @JvmStatic
    fun setUsbConfiguration(config: UsbConfiguration) {
        usbConfiguration = config
    }

    @JvmStatic
    fun getUsbConfiguration(): UsbConfiguration = usbConfiguration

    @JvmStatic
    fun setNfcConfiguration(config: NfcConfiguration) {
        nfcConfiguration = config
    }

    @JvmStatic
    fun getNfcConfiguration(): NfcConfiguration = nfcConfiguration

    @JvmStatic
    fun emitDeviceAttached(reactContext: ReactContext?, device: YubiKeyDevice) {
        val handle = putDevice(device)
        val params = Bundle().apply {
            putString("type", "attached")
            putBundle("device", deviceToBundle(handle, device))
        }
        reactContext?.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            ?.emit("YubiKeyEvent", Arguments.fromBundle(params))
    }

    @JvmStatic
    fun emitDeviceDetached(reactContext: ReactContext?, handle: String) {
        removeDevice(handle)
        val params = Bundle().apply {
            putString("type", "detached")
            putString("handle", handle)
        }
        reactContext?.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            ?.emit("YubiKeyEvent", Arguments.fromBundle(params))
    }

    @JvmStatic
    fun emitError(reactContext: ReactContext?, error: String) {
        val params = Bundle().apply {
            putString("type", "error")
            putString("error", error)
        }
        reactContext?.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            ?.emit("YubiKeyEvent", Arguments.fromBundle(params))
    }

    @JvmStatic
    fun deviceToBundle(handle: String, device: YubiKeyDevice): android.os.Bundle {
        return android.os.Bundle().apply {
            putString("handle", handle)
            putString("transport", device.transport.name.lowercase())
            putStringArrayList(
                "supportedConnections",
                ArrayList(
                    listOfNotNull(
                        if (device.supportsConnection(SmartCardConnection::class.java)) "SmartCardConnection" else null,
                        if (device.supportsConnection(OtpConnection::class.java)) "OtpConnection" else null,
                        if (device.supportsConnection(FidoConnection::class.java)) "FidoConnection" else null
                    )
                )
            )
        }
    }

    @JvmStatic
    fun startUsbDiscovery(reactContext: ReactContext?) {
        getManager().startUsbDiscovery(usbConfiguration) { device: UsbYubiKeyDevice ->
            val handle = putDevice(device)
            device.setOnClosed {
                emitDeviceDetached(reactContext, handle)
            }
            emitDeviceAttached(reactContext, device)
        }
    }

    @JvmStatic
    fun stopUsbDiscovery() {
        getManager().stopUsbDiscovery()
    }

    @JvmStatic
    @Throws(NfcNotAvailable::class)
    fun startNfcDiscovery(activity: Activity, reactContext: ReactContext?) {
        getManager().startNfcDiscovery(nfcConfiguration, activity) { device: NfcYubiKeyDevice ->
            val handle = putDevice(device)
            emitDeviceAttached(reactContext, device)
        }
    }

    @JvmStatic
    fun stopNfcDiscovery(activity: Activity) {
        getManager().stopNfcDiscovery(activity)
    }

    /**
     * Open a connection synchronously. Must not be called on the UI thread.
     */
    @JvmStatic
    fun <T : YubiKeyConnection> openConnection(
        deviceHandle: String,
        connectionType: Class<T>
    ): Pair<String, T> {
        val device = getDevice(deviceHandle)
        val connection = device.openConnection(connectionType)
        val handle = putConnection(connection)
        return handle to connection
    }

    /**
     * Open a connection asynchronously and return the handle.
     */
    @JvmStatic
    fun requestConnection(
        deviceHandle: String,
        connectionType: Class<out YubiKeyConnection>,
        callback: (Result<Pair<String, YubiKeyConnection>>) -> Unit
    ) {
        val device = getDevice(deviceHandle)
        device.requestConnection(connectionType) { result ->
            try {
                val connection = result.value
                val handle = putConnection(connection)
                callback(Result.success(handle to connection))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    /**
     * Run a synchronous operation on a connection inside a requestConnection callback.
     * This is the preferred pattern because it automatically closes the connection.
     */
    @JvmStatic
    fun <T : YubiKeyConnection, R> withConnection(
        deviceHandle: String,
        connectionType: Class<T>,
        timeoutMs: Long = 30000,
        block: (T) -> R
    ): R {
        val device = getDevice(deviceHandle)
        val latch = CountDownLatch(1)
        val resultRef = AtomicReference<Result<R>>()

        device.requestConnection(connectionType) { result ->
            try {
                val connection = result.value
                connection.use {
                    resultRef.set(Result.success(block(connection)))
                }
            } catch (e: Exception) {
                resultRef.set(Result.failure(e))
            } finally {
                latch.countDown()
            }
        }

        if (!latch.await(timeoutMs, TimeUnit.MILLISECONDS)) {
            throw IOException("Timeout waiting for YubiKey connection")
        }

        return resultRef.get().getOrThrow()
    }

    @JvmStatic
    fun <R> withSmartCard(deviceHandle: String, block: (SmartCardConnection) -> R): R {
        return withConnection(deviceHandle, SmartCardConnection::class.java, block = block)
    }

    @JvmStatic
    fun <R> withOtp(deviceHandle: String, block: (OtpConnection) -> R): R {
        return withConnection(deviceHandle, OtpConnection::class.java, block = block)
    }

    @JvmStatic
    fun <R> withFido(deviceHandle: String, block: (FidoConnection) -> R): R {
        return withConnection(deviceHandle, FidoConnection::class.java, block = block)
    }
}

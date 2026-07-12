package com.yubikit

import android.app.Activity
import android.content.Context
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
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
import com.yubikit.utils.YubikitUtils.toWritableMap
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
    private val connectionReleaseLatches = ConcurrentHashMap<String, CountDownLatch>()

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
        // Wakes up the requestConnection() call still blocked on this handle's
        // latch below, letting its try-with-resources finally close.
        connectionReleaseLatches.remove(handle)?.countDown()
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

    // Set by YubikitCoreModule while the TurboModule instance is alive, so device
    // attach/detach/failure can be routed to its generated emitOnYubiKeyEvent(...).
    @Volatile
    private var eventHandler: ((WritableMap) -> Unit)? = null

    @JvmStatic
    fun setEventHandler(handler: ((WritableMap) -> Unit)?) {
        eventHandler = handler
    }

    @JvmStatic
    fun emitDeviceAttached(handle: String, device: YubiKeyDevice) {
        val params = Arguments.createMap().apply {
            putString("type", "attached")
            putMap("device", deviceToBundle(handle, device).toWritableMap())
        }
        eventHandler?.invoke(params)
    }

    @JvmStatic
    fun emitDeviceDetached(handle: String) {
        removeDevice(handle)
        val params = Arguments.createMap().apply {
            putString("type", "detached")
            putString("handle", handle)
        }
        eventHandler?.invoke(params)
    }

    @JvmStatic
    fun emitError(error: String) {
        val params = Arguments.createMap().apply {
            putString("type", "error")
            putString("error", error)
        }
        eventHandler?.invoke(params)
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
    fun startUsbDiscovery() {
        getManager().startUsbDiscovery(usbConfiguration) { device: UsbYubiKeyDevice ->
            val handle = putDevice(device)
            device.setOnClosed {
                emitDeviceDetached(handle)
            }
            emitDeviceAttached(handle, device)
        }
    }

    @JvmStatic
    fun stopUsbDiscovery() {
        getManager().stopUsbDiscovery()
    }

    @JvmStatic
    @Throws(NfcNotAvailable::class)
    fun startNfcDiscovery(activity: Activity) {
        getManager().startNfcDiscovery(nfcConfiguration, activity) { device: NfcYubiKeyDevice ->
            val handle = putDevice(device)
            emitDeviceAttached(handle, device)
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

    // Non-OTP connections are opened by the SDK inside a try-with-resources block that
    // closes the connection the instant device.requestConnection()'s callback returns
    // (see UsbYubiKeyDevice.requestConnection). Since this module's requestConnection/
    // sendApdu/closeConnection are exposed as three separate, independently-timed JS
    // calls, the callback below is kept alive on a latch until closeConnection() (or
    // this timeout) releases it, so the connection stays open across those calls.
    private const val CONNECTION_HOLD_TIMEOUT_MS = 120_000L

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
            var handle: String? = null
            try {
                val connection = result.value
                handle = putConnection(connection)
                val releaseLatch = CountDownLatch(1)
                connectionReleaseLatches[handle] = releaseLatch
                callback(Result.success(handle to connection))
                releaseLatch.await(CONNECTION_HOLD_TIMEOUT_MS, TimeUnit.MILLISECONDS)
            } catch (e: Exception) {
                callback(Result.failure(e))
            } finally {
                // No-op if closeConnection() already removed it; guards against the
                // timeout case where the JS side never explicitly released it.
                handle?.let { connections.remove(it)?.close(); connectionReleaseLatches.remove(it) }
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

    /**
     * Opens whichever of SmartCard/Otp/Fido the device actually supports, in that
     * preference order. Several sessions (ManagementSession, Ctap2Session) accept more
     * than one connection type, and hardcoding a single type breaks devices/transports
     * that don't support it (e.g. NFC devices only ever support SmartCardConnection).
     */
    @JvmStatic
    fun <R> withAnyConnection(
        deviceHandle: String,
        preferredOrder: List<Class<out YubiKeyConnection>>,
        block: (YubiKeyConnection) -> R
    ): R {
        val device = getDevice(deviceHandle)
        val connectionType = preferredOrder.firstOrNull { device.supportsConnection(it) }
            ?: throw IllegalArgumentException("Device does not support any of: ${preferredOrder.map { it.simpleName }}")
        return when (connectionType) {
            SmartCardConnection::class.java -> withConnection(deviceHandle, SmartCardConnection::class.java) { block(it) }
            OtpConnection::class.java -> withConnection(deviceHandle, OtpConnection::class.java) { block(it) }
            FidoConnection::class.java -> withConnection(deviceHandle, FidoConnection::class.java) { block(it) }
            else -> throw IllegalArgumentException("Unsupported connection type: $connectionType")
        }
    }
}

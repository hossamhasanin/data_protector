package com.hossam.hasanin.data_protector.wifi_p2p

import android.net.wifi.p2p.WifiP2pDevice
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class TransferredDataStreamHandler : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    suspend fun transferData(data:Map<String , Any>){
        withContext(Dispatchers.Main){
            sink?.success(data)
        }
    }

    fun setCurrentDevice(device: WifiP2pDevice){
        sink?.success(mapOf<String , Any>(
            "currentDevice" to mapOf(
                "deviceName" to device.deviceName,
                "deviceAddress" to device.deviceAddress,
                "deviceType" to device.primaryDeviceType,
                "status" to device.status
            )
        ))
    }

}
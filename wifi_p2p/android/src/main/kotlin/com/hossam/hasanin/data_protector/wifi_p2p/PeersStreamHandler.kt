package com.hossam.hasanin.data_protector.wifi_p2p

import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pDeviceList
import io.flutter.plugin.common.EventChannel

class PeersStreamHandler : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun sendListOfBeers(peers: WifiP2pDeviceList?){
        peers?.let {
            val map:List<Map<String , Any>> = it.deviceList.map { device ->
                mapOf(
                    "deviceName" to device.deviceName,
                    "deviceAddress" to device.deviceAddress,
                    "deviceType" to device.primaryDeviceType,
                    "status" to device.status
                )
            }.toList()
            sink?.success(map)
        }
    }



}
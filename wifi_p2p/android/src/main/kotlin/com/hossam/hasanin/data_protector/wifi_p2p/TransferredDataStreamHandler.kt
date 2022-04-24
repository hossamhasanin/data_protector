package com.hossam.hasanin.data_protector.wifi_p2p

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

}
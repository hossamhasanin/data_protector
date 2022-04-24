package com.hossam.hasanin.data_protector.wifi_p2p

import android.util.Log
import com.beust.klaxon.Klaxon
import kotlinx.coroutines.*
import java.io.DataOutputStream
import java.lang.Exception
import java.net.InetSocketAddress
import java.net.Socket

const val SOCKET_TIMEOUT = 3000
class FileTransferService(
    private val data: List<TransferredFile>,
    private val transferHandler: TransferredDataStreamHandler,
    private val host: String,
    private val port: Int
) {
    lateinit var serviceJob: Job

    fun transfer(){
        serviceJob = CoroutineScope(Dispatchers.IO).launch {
            val socket = Socket()
            try {

                socket.bind(null)
                socket.connect(InetSocketAddress(host , port) , SOCKET_TIMEOUT)
                val outputStream = socket.getOutputStream()


                val dataDescription = DataDescription.generateDataDescription(data)
                transferHandler.transferData(mapOf(
                    "metaData" to dataDescription.toMap()
                ))
                val totalSendingSteps = dataDescription.files.size + 1
                var currentSendingStep = 0
                var jsonToSend = ""
                val s = "#".toByteArray()

                while (currentSendingStep < totalSendingSteps){
                    val klaxon = Klaxon()
                    jsonToSend = if (currentSendingStep == 0){
                        klaxon.toJsonString(dataDescription)
                    } else {
                        klaxon.toJsonString(data[currentSendingStep - 1])
                    }
                    Log.d("koko" , "json data to send $jsonToSend");

                    var len:Int
                    var totalBytesSent = 0
                    val fileStream = jsonToSend.byteInputStream()
                    Log.d("koko" , "sending")
                    DataOutputStream(outputStream).writeLong(jsonToSend.length.toLong())
                    Log.d("koko" , "sending item no.${currentSendingStep} total length to send ${jsonToSend.length}")
                    while (true){
                        val buffer = ByteArray(1024)

                        len = fileStream.read(buffer)
                        if (len == -1){
                            break
                        }
                        Log.d("koko" , "sending item no.${currentSendingStep} bytes $len , ${String(buffer.slice(0 until len).toByteArray())}")
                        totalBytesSent += len
                        outputStream.write(buffer.slice(0 until len).toByteArray() , 0 , len)

                        if (currentSendingStep > 0){
                            transferHandler.transferData(mapOf(
                                "itemIndex" to currentSendingStep - 1,
                                "transferred" to totalBytesSent
                            ))
                        }
                    }
//                    delay(300)
//                    outputStream.write(s, 0 , s.size)
//                    outputStream.flush()
//                    delay(300)
                    Log.d("koko" , "sent item no.${currentSendingStep} total bytes $totalBytesSent")
                    currentSendingStep += 1
                }

                Log.d("koko" , "done sending $data")
            } catch (e: Exception){
                Log.d("koko" , e.stackTraceToString())
                transferHandler.transferData(mapOf(
                    "disconnected" to true
                ))

            } finally {
                if (socket.isConnected){
                    try {
                        socket.close()
                        serviceJob.cancel()
                    } catch (e:Exception){
                        e.printStackTrace()
                    }
                }


            }
        }


    }

}
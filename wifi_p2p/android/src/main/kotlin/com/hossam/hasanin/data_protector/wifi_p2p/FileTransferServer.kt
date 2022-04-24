package com.hossam.hasanin.data_protector.wifi_p2p

import android.util.Log
import com.beust.klaxon.Klaxon
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import java.io.DataInputStream
import java.lang.Exception
import java.net.ServerSocket

class FileTransferServer(
    private val dataHandler : TransferredDataStreamHandler
) {

    lateinit var serverJob: Job


    fun run(){
        serverJob = CoroutineScope(Dispatchers.IO).launch {
            try {
                val serverSocket = ServerSocket(8080)
                val client = serverSocket.accept()
                val inputStream = client.getInputStream()

                var totalReceivingSteps = 1
                var currentReceivingStep = 0
//                var totalFilesReadLength = 0L


                var metaData: DataDescription
                while (currentReceivingStep < totalReceivingSteps){
                    val str = StringBuffer()
                    var len: Int
                    var totalRead = 0L
                    val totalFileSize = DataInputStream(inputStream).readLong()
                    Log.d("koko" , "item no.${currentReceivingStep} total file size $totalFileSize")
                    while (true) {
                        val buf = ByteArray(1024)
                        len = inputStream.read(buf , 0 , if (totalFileSize-totalRead > buf.size) buf.size else (totalFileSize-totalRead).toInt())
                        val line = String(buf.slice(0 until len).toByteArray())
                        Log.d("koko" , "item no.${currentReceivingStep} received $len bytes , $line")

                        totalRead += len
                        str.append(line)

                        if (currentReceivingStep > 0){
                            dataHandler.transferData(mapOf(
                                "itemIndex" to currentReceivingStep - 1,
                                "transferred" to totalRead
                            ))
                        }
                        if (totalRead == totalFileSize || len == -1){
                            break
                        }
                    }
                    Log.d("koko" , "item no.${currentReceivingStep} total $totalRead")


                    Log.d("koko" , "Done receiving $currentReceivingStep , str $str")


                    // First data received are info about the files transferred
                    if (currentReceivingStep == 0){
                        metaData = Klaxon().parse<DataDescription>(str.toString())!!
                        totalReceivingSteps += metaData.files.size
                        dataHandler.transferData(mapOf(
                            "metaData" to metaData.toMap()
                        ))
                    } else {
                        val data = Klaxon().parse<TransferredFile>(str.toString())!!
                        dataHandler.transferData(mapOf(
                            "itemIndex" to currentReceivingStep - 1,
                            "file" to data.base64StringFile
                        ))
                    }

                    currentReceivingStep += 1
                }
//                Log.d("koko" , result.toString())
                Log.d("koko" , "done receiving all")
                inputStream.close()
                client.close()
                serverSocket.close()
                dispose()
            } catch (e: Exception){
              Log.d("koko" , e.stackTraceToString())
            }
        }
    }

    fun dispose(){
        serverJob.cancel()
    }

}
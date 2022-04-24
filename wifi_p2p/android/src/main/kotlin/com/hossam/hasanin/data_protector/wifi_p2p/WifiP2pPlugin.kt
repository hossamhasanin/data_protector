package com.hossam.hasanin.data_protector.wifi_p2p

import WiFiDirectBroadcastReceiver
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.wifi.p2p.*
import androidx.annotation.NonNull
import io.flutter.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** WifiP2pPlugin */
class WifiP2pPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private lateinit var context: Context
  private lateinit var activity: Activity

  val manager: WifiP2pManager? by lazy(LazyThreadSafetyMode.NONE) {
    context.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager?
  }

  val connectivityManager: ConnectivityManager? by lazy(LazyThreadSafetyMode.NONE) {
    context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager?
  }

  var wifichannel: WifiP2pManager.Channel? = null
  var receiver: BroadcastReceiver? = null
  var data:List<TransferredFile>? = null

  val peersStreamHandler = PeersStreamHandler()
  val transferredDataStreamHandler = TransferredDataStreamHandler()

  val intentFilter = IntentFilter().apply {
    addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
    addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
    addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
    addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
  }



  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {


    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_p2p")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext

    val peersStreamChannel = EventChannel(flutterPluginBinding.binaryMessenger, "peersStream")
    val transferredDataStream = EventChannel(flutterPluginBinding.binaryMessenger, "transferredDataStream")

    peersStreamChannel.setStreamHandler(peersStreamHandler)
    transferredDataStream.setStreamHandler(transferredDataStreamHandler)
  }





  fun startSending(hostAddress: String , data: List<TransferredFile>){
    val transferService = FileTransferService(
      host = hostAddress,
      port = 8080,
      data = data,
      transferHandler = transferredDataStreamHandler
    )
    peersStreamHandler.sendCurrentDevice()
    transferService.transfer()
  }

  fun startServer(){
    val transferServer = FileTransferServer(dataHandler = transferredDataStreamHandler)
    transferServer.run()
  }

  fun startTransferProcess(){
    manager?.requestConnectionInfo(wifichannel , object : WifiP2pManager.ConnectionInfoListener {
      override fun onConnectionInfoAvailable(it: WifiP2pInfo?) {
        it?.let {
          if (it.groupFormed && it.isGroupOwner){
            startServer()
            Log.d("koko" , "start server")

          } else {
            if (it.groupOwnerAddress != null){
              it.groupOwnerAddress.hostAddress?.let { address ->
                startSending(address , data!!)
                Log.d("koko" , "sending")
              }
            }
          }
        }
      }

    })
  }

  fun setCurrentDeviceData(device: WifiP2pDevice){
      peersStreamHandler.setCurrentDevice(device)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "discoverPeers"){
      Log.d("koko" ,"init chanel")
      manager?.discoverPeers(wifichannel , object : WifiP2pManager.ActionListener {
        override fun onSuccess() {
          result.success("Discovery done")
        }

        override fun onFailure(p0: Int) {
          result.error("DISCOVERY_ERR" , "Discovery error" , null);
        }

      })
    } else if (call.method == "connect"){
      val device: WifiP2pDevice = WifiP2pDevice().also {
        it.deviceName = call.argument("name")
        it.deviceAddress = call.argument("address")
        it.status = call.argument<Int>("status") ?: 0
        it.primaryDeviceType = call.argument("type")
      }
      val config = WifiP2pConfig()
      config.deviceAddress = device.deviceAddress

      manager?.connect(wifichannel, config, object : WifiP2pManager.ActionListener {

        override fun onSuccess() {
          //success logic
          result.success("Connect done")
        }

        override fun onFailure(reason: Int) {
          //failure logic
          result.error("CONNECTION_ERR" , "Connection error" , null);
        }
      })


    } else if (call.method == "setData") {
      val transferredFiles = call.argument<List<Map<String , String>>>("transferredFiles")!!
      data = TransferredFile.getFiles(transferredFiles)
      result.success("")
    } else if (call.method == "cancelConnect"){
      manager?.removeGroup(wifichannel , object : WifiP2pManager.ActionListener {

        override fun onSuccess() {
          //success logic
//          manager?.discoverPeers(wifichannel , null)
          result.success("Cancel done")
        }

        override fun onFailure(reason: Int) {
          //failure logic
          result.error("CANCEL_CONNECTION_ERR" , "Cancel connection error" , null);
        }
      })
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity

    wifichannel = manager?.initialize(context, activity.mainLooper, null)
    wifichannel?.also { channel ->
      receiver = WiFiDirectBroadcastReceiver(manager!!, channel , this)
    }

    receiver?.also {
      activity.registerReceiver(it , intentFilter)
    }

  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    receiver?.also {
      activity.unregisterReceiver(it)
    }
  }


}

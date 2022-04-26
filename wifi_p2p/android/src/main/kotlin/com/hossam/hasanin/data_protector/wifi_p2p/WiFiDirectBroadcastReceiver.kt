import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pDeviceList
import android.net.wifi.p2p.WifiP2pManager
import com.hossam.hasanin.data_protector.wifi_p2p.WifiP2pPlugin

import android.util.Log


class WiFiDirectBroadcastReceiver(
        private val manager: WifiP2pManager,
        private val channel: WifiP2pManager.Channel,
        private val plugin: WifiP2pPlugin
) : BroadcastReceiver() {

    var isConnected = false

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
                // Check to see if Wi-Fi is enabled and notify appropriate activity
                val state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1)
                if (state == WifiP2pManager.WIFI_P2P_STATE_ENABLED){
                    Log.d("koko" , "wifi enabled")
                }
            }
            WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                // Call WifiP2pManager.requestPeers() to get a list of current peers
                manager.requestPeers(channel) { peers: WifiP2pDeviceList? ->
                    // Handle peers list
                    plugin.peersStreamHandler.sendListOfBeers(peers)
                }

            }
            WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                // Respond to new connection or disconnections
                Log.d("koko" , "connection changed")

                if (isConnected){
                    isConnected = false
                    plugin.startTransferProcess()
                    Log.d("koko" , "connected")
                } else {
                    // isConnected = false
                    Log.d("koko" , "disconnected")
                }
 

            }
            WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION -> {
                // Respond to this device's wifi state changing
                Log.d("koko" , "device changed")
                val device: WifiP2pDevice = intent.getParcelableExtra(
                    WifiP2pManager.EXTRA_WIFI_P2P_DEVICE)!!

                when (device.status){
                    WifiP2pDevice.CONNECTED -> {
                        isConnected = true
                        Log.d("koko" , "connected for sure ${device.deviceName}")
                    }
                    WifiP2pDevice.AVAILABLE -> {
                        Log.d("koko" , "available ${device.deviceName}")
                        plugin.setCurrentDeviceData(device)
                    }
                    WifiP2pDevice.FAILED -> {
                        Log.d("koko" , "failed ${device.deviceName}")
                    }
                    WifiP2pDevice.UNAVAILABLE -> {
                        Log.d("koko" , "unavailable ${device.deviceName}")
                    }
                }

            }
        }
    }
}

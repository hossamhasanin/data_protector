package com.hossam.hasanin.data_protector.wifi_p2p

data class TransferredFile(
    val name: String,
    val base64StringFile: String
) {
    fun toMap(): Map<String , Any>{
        return mapOf(
            "name" to name,
            "base64StringFile" to base64StringFile
        )
    }

    companion object{
        fun getFiles(list: List<Map<String , String>>): List<TransferredFile>{
            val transferList = mutableListOf<TransferredFile>()
            for (item in list){
                transferList.add(TransferredFile(name = item["name"].toString() ,
                    base64StringFile = item["base64StringFile"].toString()))
            }
            return transferList
        }
    }

}
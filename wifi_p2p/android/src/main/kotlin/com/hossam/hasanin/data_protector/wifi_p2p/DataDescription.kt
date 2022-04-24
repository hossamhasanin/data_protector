package com.hossam.hasanin.data_protector.wifi_p2p

data class DataDescription(
    val totalSize: Int,
    val files: List<FileInfo>
){
    fun toMap(): Map<String , Any>{
        return  mapOf(
            "files" to files.map {
                mapOf<String , Any>(
                    "name" to it.name,
                    "size" to it.size
                )
            },
            "totalSize" to totalSize
        );
    }

    companion object {
        fun generateDataDescription(files: List<TransferredFile>) : DataDescription{
            var totalSize = 0
            val filesInfo = mutableListOf<FileInfo>()
            for (file in files){
                totalSize += file.base64StringFile.length
                filesInfo.add(FileInfo(name = file.name , size = file.base64StringFile.length))
            }
            return DataDescription(totalSize , filesInfo)
        }
    }
}
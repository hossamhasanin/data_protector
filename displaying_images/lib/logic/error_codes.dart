enum DisplayImagesErrorCodes {
  fileNameAlreadyExists,
  exceededMaxDecryptNum,
  couldNotDeleteFiles,
  couldNotDecryptImages,
  couldNotEncryptImages,
  failedToShareImages,
  failedToImportImages,
}

String translateErrorCodes(String code) {
    print(code);
    if (code == DisplayImagesErrorCodes.couldNotDecryptImages.toString()) {
      return "Could not decrypt images";
    } else if (code == DisplayImagesErrorCodes.couldNotDeleteFiles.toString()) {
      return "Could not delete files";
    } else if (code == DisplayImagesErrorCodes.failedToShareImages.toString()) {
      return "Could not share images";
    } else if (code ==
        DisplayImagesErrorCodes.exceededMaxDecryptNum.toString()) {
      return "Exceeded max decrypt number";
    } else if (code == DisplayImagesErrorCodes.couldNotDeleteFiles.toString()) {
      return "Could not delete files";
    } else if (code ==
        DisplayImagesErrorCodes.failedToImportImages.toString()) {
      return "Failed to import images";
    } else if (code ==
        DisplayImagesErrorCodes.fileNameAlreadyExists.toString()) {
      return "This file is here already";
    } else if (code ==
        DisplayImagesErrorCodes.couldNotEncryptImages.toString()) {
      return "Could not encrypt images";
    } else {
      throw "Not found error code";
    }
  }
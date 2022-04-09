class SelectionViewState {
  final Map<int , bool> selectedFiles;
  final bool isSelectingFolders;
  final bool isSelectingImages;

  SelectionViewState(
      {required this.selectedFiles,
       required this.isSelectingFolders,
       required this.isSelectingImages});

  factory SelectionViewState.init(){
    return SelectionViewState(
        selectedFiles: {},
        isSelectingFolders: false,
        isSelectingImages: false
    );
  }

  SelectionViewState copy({
    Map<int , bool>? selectedFiles,
    bool? isSelectingFolders,
    bool? isSelectingImages
  }){
    return SelectionViewState(
        selectedFiles: selectedFiles ?? this.selectedFiles,
        isSelectingFolders: isSelectingFolders ?? this.isSelectingFolders,
        isSelectingImages: isSelectingImages ?? this.isSelectingImages
    );
  }
}
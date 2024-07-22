import 'package:base/models/user.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';

class ViewSate {
  final List<FileWrapper> files;
  final bool loading;
  final bool loadingMore;
  final bool noMoreData;
  final User user;
  // final bool stillLoading;

  ViewSate({
    required this.files,
    required this.loadingMore,
    required this.noMoreData,
    required this.loading,
    required this.user
  });

  factory ViewSate.init(){
    return ViewSate(
        files: [],
        loadingMore: false,
        noMoreData: false,
        loading: false,
        user: User.init()
    );
  }

  ViewSate copy({
    List<FileWrapper>? files,
    bool? loading,
    bool? loadingMore,
    bool? noMoreData,
    User? user
  }){
    return ViewSate(
        files: files ?? this.files,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        noMoreData: noMoreData ?? this.noMoreData,
        user: user ?? this.user
    );
  }

}
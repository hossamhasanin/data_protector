import 'package:hive/hive.dart';

part 'File.g.dart';

@HiveType(typeId: 0)
class File{
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String path;

  File({this.name , this.id , this.path});

}
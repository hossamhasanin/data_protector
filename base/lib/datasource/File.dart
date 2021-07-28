import 'package:hive/hive.dart';

part 'File.g.dart';

@HiveType(typeId: 0)
class File {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String path;

  @HiveField(3)
  int type;

  File(
      {required this.name,
      required this.id,
      required this.path,
      required this.type});
}

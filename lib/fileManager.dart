import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';


/// A file manager
/// - each class instance can only handle one file.
class FileManager {
  // === Attributes ===
  String fileName;
  bool onCache;
  File file;

  // === helper getters ===
  Future<String> get _docPath async {
    final directory = await getExternalStorageDirectory();//getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get _cachePath async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  /// === Constructors ===
  FileManager(String fileName, {bool onCache: true}) {
    this.fileName = fileName;
    this.onCache = onCache;
  }

  Future<File> getFile() async{
    return this.file;
  }

  // === Methods ===

  // Method to create and return a file on documents
  Future<File> createFile() async{
    String path;

    // get path based on onCache
    if(this.onCache){
      path = await _cachePath;
    }else{
      path = await _docPath;
    }

    this.file = File('$path/$fileName');
    print("The file is stored at $path/$fileName");
    return this.file;
  }

  Future<File> writePosition(double longitude, double latitude){
    var now = DateTime.now();
    return this.file.writeAsString('$longitude, $latitude, $now\n', mode: FileMode.append);
  }

  // Method to write to the file
  Future<File> write(int Tem, int ACX, int ACZ,  int BAT, int RED, int IR) async{
    // write the file
    return this.file.writeAsString('$Tem, $ACX, $ACZ, $BAT, $RED, $IR\n', mode: FileMode.append);
  }


}

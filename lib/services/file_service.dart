import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

class WriteResult {
  final int bytesWritten;
  final String filePath;
  WriteResult({required this.bytesWritten, required this.filePath});
}

class FileService {
  Future<void> init() async {}

  /// writes bytes to a file named fileName; returns number of bytes written
  static Future<WriteResult> write(
      {required Uint8List data,
      required String fileName,
      Function? onProgress}) async {
    return WriteResult(bytesWritten: 0, filePath: "TODO");
  }

  static Future<XFile?> chooseFile() async {
    const XTypeGroup typeGroup =
        XTypeGroup(label: "Cards backup file", extensions: ["bin"]);
    return await openFile(acceptedTypeGroups: [typeGroup]);
  }
}

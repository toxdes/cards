import 'dart:io';

class FileUtils {
  static String getFileName(File file) {
    return file.uri.pathSegments.last;
  }
}

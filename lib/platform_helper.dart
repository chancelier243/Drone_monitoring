import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PlatformHelper {
  static Future<Directory> getExportDirectory() async {
    if (Platform.isWindows) {
      // Sur Windows, utiliser le dossier Downloads
      final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '';
      final downloadsPath = '$home\\Downloads';
      final dir = Directory(downloadsPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } else if (Platform.isAndroid) {
      // Sur Android, utiliser getExternalStorageDirectory ou getApplicationDocumentsDirectory
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      // Sur iOS, utiliser getApplicationDocumentsDirectory
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isLinux || Platform.isMacOS) {
      // Sur Linux/macOS, utiliser le home directory
      return await getApplicationDocumentsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  static String getPathSeparator() {
    return Platform.isWindows ? '\\' : '/';
  }

  static String getFileName(String path) {
    final separator = getPathSeparator();
    return path.split(separator).last;
  }

  static String getFileNameWithExtension(String baseName, String extension) {
    return '$baseName${extension.startsWith('.') ? extension : '.$extension'}';
  }
}

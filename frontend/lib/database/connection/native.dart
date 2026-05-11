import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

QueryExecutor openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final cacheDir = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cacheDir;
    final dbDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbDir.path, 'shg_portal.sqlite'));
    return NativeDatabase.createBackgroundConnection(file);
  }));
}

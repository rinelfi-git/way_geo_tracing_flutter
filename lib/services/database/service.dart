import 'package:device_info_plus/device_info_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:where_are_you/services/schema/history.dart';
import 'package:where_are_you/services/schema/point.dart';
import 'package:where_are_you/services/schema/setting.dart';

class Service {
  static final Service instance = Service._init();
  static Database? _database;
  Service._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('way.sqlite');
    return _database!;
  }

  Future<Database> _initDB(String filename) async {
    String path = await getDatabasesPath();
    path = join(path, filename);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${HistorySchema.TABLE} (
        ${HistorySchema.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${HistorySchema.DEPARTURE} TEXT NOT NULL,
        ${HistorySchema.ARRIVAL} TEXT,
        ${HistorySchema.FINISHED_LINE} BOOLEAN NOT NULL DEFAULT '0'
      );
    ''');
    await db.execute('''
     CREATE TABLE ${PointSchema.TABLE} (
        ${PointSchema.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PointSchema.HISTORY} INTEGER NOT NULL,
        ${PointSchema.DATE} DATETIME NOT NULL,
        ${PointSchema.LATITUDE} REAL NOT NULL,
        ${PointSchema.LONGITUDE} REAL NOT NULL
      )
    ''');
    await db.execute('''
     CREATE TABLE ${SettingSchema.TABLE} (
        ${SettingSchema.DEVICE_NAME} TEXT NOT NULL,
        ${SettingSchema.SERVER} TEXT,
        ${SettingSchema.UUID} TEXT,
        ${SettingSchema.AUTOSYNC} BOOLEAN NOT NULL
      )
    ''');
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    const uuid = Uuid();
    await db.insert(
        SettingSchema.TABLE,
        Setting(
          deviceName: androidInfo.model!,
          server: 'http://192.168.43.24:5000',
          uuid: uuid.v1(),
          autoSync: true,
        ).toMap());
  }
}

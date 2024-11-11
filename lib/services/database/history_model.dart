import 'package:sqflite/sqflite.dart';
import 'package:where_are_you/services/database/service.dart';
import 'package:where_are_you/services/schema/history.dart';

class HistoryModel {
  static final HistoryModel instance = HistoryModel._init();
  HistoryModel._init();

  Future<History> create(History history) async {
    final database = await Service.instance.database;
    final id = await database.insert(HistorySchema.TABLE, history.toMap());
    return history.copy(id: id);
  }

  Future<int> update(History history) async {
    final database = await Service.instance.database;
    return await database.update(
      HistorySchema.TABLE,
      history.toMap(),
      where: '${HistorySchema.ID}=?',
      whereArgs: [history.id!],
    );
  }

  Future<History> select(int id) async {
    final database = await Service.instance.database;
    final result = await database.query(
      HistorySchema.TABLE,
      columns: HistorySchema.VALUES,
      where: '${HistorySchema.ID}=?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return History.fromMap(result.first);
    }
    throw Exception('history [$id] is not found');
  }

  Future<History?> getLastUnfinished() async {
    final database = await Service.instance.database;
    final result = await database.query(
      HistorySchema.TABLE,
      columns: HistorySchema.VALUES,
      orderBy: '${HistorySchema.ID} DESC',
      where: '${HistorySchema.FINISHED_LINE}=?',
      whereArgs: [0],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return History.fromMap(result.first);
    }
    return null;
  }

  Future<List<History>> selectAll() async {
    final database = await Service.instance.database;
    final result = await database.query(
      HistorySchema.TABLE,
      orderBy: '${HistorySchema.ID} ASC',
    );
    return result.map((e) => History.fromMap(e)).toList();
  }

  Future<List<History>> selectDepartureArrival(String keyword) async {
    final database = await Service.instance.database;
    final result = await database.query(
      HistorySchema.TABLE,
      orderBy: '${HistorySchema.ID} ASC',
      where:
          'UPPER(${HistorySchema.DEPARTURE}) LIKE UPPER(?) OR UPPER(${HistorySchema.ARRIVAL}) LIKE UPPER(?)',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return result.map((e) => History.fromMap(e)).toList();
  }

  Future close() async {
    final database = await Service.instance.database;
    database.close();
  }
}

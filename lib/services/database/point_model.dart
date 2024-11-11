import 'package:where_are_you/services/database/service.dart';
import 'package:where_are_you/services/schema/point.dart';

class PointModel {
  static final PointModel instance = PointModel._init();
  PointModel._init();

  Future<Point> create(Point point) async {
    final database = await Service.instance.database;
    final id = await database.insert(PointSchema.TABLE, point.toMap());
    return point.copy(id: id);
  }

  Future<Point> select(int id) async {
    final database = await Service.instance.database;
    final result = await database.query(
      PointSchema.TABLE,
      columns: PointSchema.VALUES,
      where: '${PointSchema.ID}=?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Point.fromMap(result.first);
    }
    throw Exception('point [$id] is not found');
  }

  Future<List<Point>> selectByHistory(int history) async {
    final database = await Service.instance.database;
    final result = await database.query(
      PointSchema.TABLE,
      where: '${PointSchema.HISTORY}=?',
      whereArgs: [history],
      orderBy: '${PointSchema.DATE} DESC',
    );
    return result.map((e) => Point.fromMap(e)).toList();
  }

  Future<List<Point>> selectAll() async {
    final database = await Service.instance.database;
    final result = await database.query(
      PointSchema.TABLE,
      orderBy: '${PointSchema.DATE} DESC',
    );
    return result.map((e) => Point.fromMap(e)).toList();
  }

  Future close() async {
    final database = await Service.instance.database;
    database.close();
  }
}

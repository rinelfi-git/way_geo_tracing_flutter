// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:where_are_you/providers/setting_provider.dart';
import 'package:where_are_you/services/database/service.dart';
import 'package:where_are_you/services/schema/setting.dart';

class SettingModel {
  static final SettingModel instance = SettingModel._init();
  SettingModel._init();

  Future<int> update(BuildContext context, Setting setting) async {
    final database = await Service.instance.database;
    int rowCount = await database.update(
      SettingSchema.TABLE,
      setting.toMap(),
    );
    if (rowCount > 0) context.read<SettingProvider>().update(setting);
    return rowCount;
  }

  Future<Setting> select() async {
    final database = await Service.instance.database;
    final result = await database.query(
      SettingSchema.TABLE,
      columns: SettingSchema.VALUES,
    );
    return Setting.fromMap(result.first);
  }

  Future close() async {
    final database = await Service.instance.database;
    database.close();
  }
}

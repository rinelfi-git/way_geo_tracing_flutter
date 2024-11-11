import 'package:flutter/cupertino.dart';
import 'package:where_are_you/services/database/setting_model.dart';
import 'package:where_are_you/services/schema/setting.dart';

class SettingProvider with ChangeNotifier {
  Setting? _setting;

  Future<Setting> get setting async {
    _setting ??= await SettingModel.instance.select();
    return _setting!;
  }

  void update(Setting setting) {
    _setting = setting;
    notifyListeners();
  }
}

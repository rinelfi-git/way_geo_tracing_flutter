import 'package:flutter/material.dart';
import 'package:where_are_you/services/database/history_model.dart';
import 'package:where_are_you/services/schema/history.dart';

class NavigationProvider with ChangeNotifier {
  bool? _enabled;
  History? _history;
  List coordinates = [0.0, 0.0];

  NavigationProvider() {
    enable();
  }

  Future<bool> get enabled async {
    if (_enabled == null) {
      final history = await HistoryModel.instance.getLastUnfinished();
      _enabled = history != null;
    }
    return _enabled!;
  }

  Future<History?> get history async {
    _history ??= await HistoryModel.instance.getLastUnfinished();
    return _history;
  }

  Future<void> enable() async {
    _history = await HistoryModel.instance.getLastUnfinished();
    _enabled = _history != null;
    notifyListeners();
  }

  void disable() {
    _enabled = false;
    _history = null;
    notifyListeners();
  }

  void moveTo(double latitude, double longitude) {
    coordinates = [latitude, longitude];
    notifyListeners();
  }
}

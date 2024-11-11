import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:where_are_you/services/database/history_model.dart';
import 'package:where_are_you/services/database/point_model.dart';
import 'package:where_are_you/services/schema/history.dart';
import 'package:where_are_you/services/schema/setting.dart';

class SocketProvider with ChangeNotifier {
  Socket? _socket;
  final Setting _setting;

  SocketProvider(this._setting);

  final Map<String, dynamic> _socketParameter = {
    'transports': ['websocket']
  };

  Future<Socket> get socket async {
    if (_socket != null) {
      return _socket!;
    } else {
      _socket = io(_setting.server!, _socketParameter);
      _setEvents();
      return _socket!;
    }
  }

  update(String server) async {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.close();
      _socket = null;
    }
    _socket = io(server, _socketParameter);
    _setEvents();
  }

  _setEvents() async {
    _socket!.onConnect((data) {
      _socket!.emit('mobile:register', {
        'name': _setting.deviceName,
        'uuid': _setting.uuid,
      });
      if (_setting.autoSync!) {
        _doSync();
      }
      notifyListeners();
    });
    _socket!.onDisconnect((data) {
      notifyListeners();
    });
  }

  _doSync() async {
    final dio = Dio();
    Response remoteResponse = await dio.get('${_setting.server}/history/device/${_setting.uuid}');
    List<Map<String, Object?>> remoteHistories = (remoteResponse.data as List)
        .map((e) => {
              'id': e['_id'],
              '_id': e['id'],
              'departure': e['departure'],
            })
        .toList();
    final localHistories = await HistoryModel.instance.selectAll();
    for (final history in localHistories) {
      final remoteHistory = remoteHistories.firstWhere((element) => History.fromMap(element).id == history.id, orElse: () => {});
      final itExists = remoteHistory.isNotEmpty;
      if (itExists) {
        remoteResponse = await dio.get('${_setting.server}/point/history/${remoteHistory['_id']}/${_setting.uuid}');
        final List<Map<String, Object?>> remotePoints = (remoteResponse.data as List)
            .map((e) => {
                  'id': e['_id'],
                  '_id': e['id'],
                })
            .toList();
        final localPoints = await PointModel.instance.selectByHistory(history.id!);
        if (localPoints.length != remotePoints.length) {
          await dio.delete('${_setting.server}/point/history/${remoteHistory['_id']}');
          var transform = history.toMap(device: _setting.uuid);
          transform['_id'] = remoteHistory['_id'];
          await dio.patch('${_setting.server!}/history', data: transform);
          var jsons = localPoints.map((e) => e.toMap()).toList();
          await dio.put('${_setting.server!}/point/many/${_setting.uuid}', data: jsons);
        }
      } else {
        await dio.patch('${_setting.server}/history', data: history.toMap(device: _setting.uuid));
        final localPoints = await PointModel.instance.selectByHistory(history.id!);
        final jsons = localPoints.map((e) => e.toMap()).toList();
        await dio.put('${_setting.server}/point/many/${_setting.uuid}', data: jsons);
        print('sync done');
      }
    }
  }
}

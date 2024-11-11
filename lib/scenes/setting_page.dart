import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:where_are_you/providers/setting_provider.dart';
import 'package:where_are_you/providers/socket_provider.dart';
import 'package:where_are_you/scenes/widget/setting/form_control.dart';
import 'package:where_are_you/services/database/history_model.dart';
import 'package:where_are_you/services/database/point_model.dart';
import 'package:where_are_you/services/database/setting_model.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _syncAutomatically = false;
  bool _serverConnected = false;
  FormControl _deviceControl = FormControl(label: 'substitute');
  FormControl _serverControl = FormControl(label: 'substitute');

  final offlineServer = Text('DISCONNECTED', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 20.0));
  final onlineServer = Text('CONNECTED', style: TextStyle(color: Colors.green[400], fontWeight: FontWeight.bold, fontSize: 20.0));

  @override
  void initState() {
    super.initState();
    final settingProvider = context.read<SettingProvider>();

    // when setting changes
    settingProvider.addListener(() {
      if (mounted) {
        setState(() {
          settingProvider.setting.then((newSetting) {
            _serverControl.update(newSetting.server!);
            _deviceControl.update(newSetting.deviceName!);
          });
        });
      }
    });

    _initState();
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.disable();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff00d1b2),
          title: const Text('Setting'),
          actions: const [],
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _deviceControl,
              _serverControl,
              if (_serverConnected)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('Pairing identity'),
                        FutureBuilder(
                          future: context.read<SocketProvider>().socket,
                          builder: ((context, snapshot) {
                            if (snapshot.hasData) {
                              final socket = snapshot.data! as Socket;
                              if (socket.id != null) {
                                return Text(
                                  socket.id!,
                                  style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, fontFamily: 'Cascadia Code'),
                                );
                              }
                            }
                            return Container();
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              const Text(
                'Synchronization',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Server connection status : ',
                  ),
                  _serverConnected ? onlineServer : offlineServer,
                ],
              ),
              SwitchListTile(
                value: _syncAutomatically,
                title: const Text('Automatically synchronize'),
                subtitle: const Text('Sync data automatically when connected to server?'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (state) {
                  setState(() {
                    _syncAutomatically = state;
                    context.read<SettingProvider>().setting.then((setting) {
                      final newSetting = setting.copy(autoSync: state);
                      SettingModel.instance.update(context, newSetting);
                      context.read<SettingProvider>().update(newSetting);
                    });
                  });
                },
              ),
              if (!_syncAutomatically)
                ElevatedButton(
                  onPressed: () async {
                    final setting = await context.read<SettingProvider>().setting;
                    final histories = await HistoryModel.instance.selectAll();
                    final points = await PointModel.instance.selectAll();
                    var jsons = histories.map((e) => e.toMap(device: setting.uuid)).toList();
                    final dio = Dio();
                    await dio.put('${setting.server!}/history/many', data: jsons);
                    jsons = points.map((e) => e.toMap()).toList();
                    await dio.put('${setting.server!}/point/many', data: jsons);
                  },
                  child: const Text('Sync now'),
                ),
            ],
          ),
        )),
      ),
    );
  }

  _initState() async {
    final socketProvider = context.read<SocketProvider>();
    socketProvider.addListener(() {
      if (mounted) {
        socketProvider.socket.then((socket) {
          setState(() {
            _serverConnected = socket.connected;
          });
          if (socket.connected) _initSocket(socket);
        });
      }
    });

    _initSocket(await socketProvider.socket);
    final setting = await context.read<SettingProvider>().setting;
    setState(() {
      _deviceControl = FormControl(
        label: 'Device name',
        value: setting.deviceName,
        onValidate: (value) {
          final newSetting = setting.copy(deviceName: value);
          SettingModel.instance.update(context, newSetting);
          context.read<SettingProvider>().update(newSetting);
        },
      );
      _serverControl = FormControl(
        label: 'Server',
        value: setting.server,
        onValidate: (value) {
          final newSetting = setting.copy(server: value);
          SettingModel.instance.update(context, newSetting);
          context.read<SettingProvider>().update(newSetting);
          context.read<SocketProvider>().update(value);
        },
      );
      _syncAutomatically = setting.autoSync!;
    });
  }

  _initSocket(Socket socket) {
    _serverConnected = socket.connected;
  }
}

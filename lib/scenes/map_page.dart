import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:wakelock/wakelock.dart';
import 'package:where_are_you/providers/navigation_provider.dart';
import 'package:where_are_you/providers/socket_provider.dart';
import 'package:where_are_you/scenes/widget/map/map_container.dart';
import 'package:where_are_you/scenes/widget/map/road_plan.dart';
import 'package:where_are_you/scenes/widget/map/search_bar.dart';
import 'package:where_are_you/scenes/widget/map/search_result.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? _searchKeyword;

  @override
  initState() {
    super.initState();
    _initState();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<NavigationProvider>().enabled.then((enabled) {
      if (enabled) {
        Wakelock.enable();
      } else {
        Wakelock.disable();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          const MapContainer(),
          SafeArea(
            child: Column(
              children: [
                SearchBar(onEdit: (value) {
                  setState(() {
                    _searchKeyword = value;
                  });
                }),
                if (_searchKeyword != null && _searchKeyword!.isNotEmpty) SearchResult(keyword: _searchKeyword!),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.dehaze,
        activeIcon: Icons.close,
        backgroundColor: const Color(0xff00d1b2),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.navigation_sharp),
            onTap: _openStartNavigation,
          ),
          SpeedDialChild(
            child: const Icon(Icons.settings),
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              Navigator.of(context).pushNamed('/setting');
            },
          ),
        ],
      ),
    );
  }

  _openStartNavigation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const RoadPlan(),
    );
  }

  _initState() async {
    final socketProvider = context.read<SocketProvider>();
    socketProvider.addListener(() {
      if (mounted) {
        socketProvider.socket.then((socket) {
          setState(() {
            //_serverConnected = socket.connected;
          });
          if (socket.connected) _initSocket(socket);
        });
      }
    });

    _initSocket(await socketProvider.socket);
  }

  _initSocket(Socket socket) {}
}

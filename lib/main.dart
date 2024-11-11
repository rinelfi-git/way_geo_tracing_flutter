import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:where_are_you/scenes/map_page.dart';
import 'package:where_are_you/providers/navigation_provider.dart';
import 'package:where_are_you/providers/setting_provider.dart';
import 'package:where_are_you/providers/socket_provider.dart';
import 'package:where_are_you/scenes/setting_page.dart';
import 'package:where_are_you/services/database/setting_model.dart';
import 'package:where_are_you/services/schema/setting.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Setting setting = await SettingModel.instance.select();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SocketProvider(setting),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => SettingProvider(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const MapPage(),
          '/setting': (context) => const SettingPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

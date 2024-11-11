import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:where_are_you/providers/navigation_provider.dart';
import 'package:where_are_you/providers/setting_provider.dart';
import 'package:where_are_you/services/database/history_model.dart';
import 'package:where_are_you/services/schema/history.dart';

class RoadPlan extends StatefulWidget {
  const RoadPlan({Key? key}) : super(key: key);

  @override
  State<RoadPlan> createState() => _RoadPlanState();
}

class _RoadPlanState extends State<RoadPlan> {
  TextEditingController departureController = TextEditingController();
  TextEditingController arrivalController = TextEditingController();
  History? _history;

  @override
  void initState() {
    super.initState();
    context.read<NavigationProvider>().history.then((history) {
      setState(() {
        departureController.text = (history ?? const History(departure: '')).departure;
      });
    });
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: mediaQuery.viewInsets,
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: const [
                    Text(
                      'Road plan',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: departureController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      labelText: 'Departure place',
                      prefixIcon: Icon(Icons.location_on_sharp),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: arrivalController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      labelText: 'Arrival place',
                      prefixIcon: Icon(Icons.location_on_sharp),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Consumer<NavigationProvider>(
                        builder: (context, navigation, child) {
                          return FutureBuilder(
                              future: navigation.enabled,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final enabled = snapshot.data as bool;
                                  if (enabled) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red[700],
                                      ),
                                      onPressed: () {
                                        navigation.history.then((value) async {
                                          setState(() {
                                            _history = value!.copy(
                                              arrival: arrivalController.text,
                                              finishedLine: true,
                                            );
                                          });
                                          await HistoryModel.instance.update(_history!);
                                          final dio = Dio();
                                          final setting = await context.read<SettingProvider>().setting;
                                          dio.patch('${setting.server!}/history', data: _history!.toMap(device: setting.uuid));

                                          context.read<NavigationProvider>().disable();
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: const Text('Stop navigation'),
                                    );
                                  }
                                }
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: const Color(0xff00d1b2),
                                  ),
                                  onPressed: () async {
                                    // sending information to server
                                    var history = await HistoryModel.instance.create(History(departure: departureController.text));
                                    final dio = Dio();
                                    final setting = await context.read<SettingProvider>().setting;
                                    dio.put('${setting.server!}/history', data: history.toMap(device: setting.uuid));
                                    context.read<NavigationProvider>().enable();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Start navigation'),
                                );
                              });
                        },
                      ),
                    ],
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadHistory() async {
    _history = await HistoryModel.instance.getLastUnfinished();
    if (_history != null) {
      context.read<NavigationProvider>().enable();
    }
  }
}

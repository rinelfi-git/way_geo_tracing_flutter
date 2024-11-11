import 'package:flutter/material.dart';
import 'package:where_are_you/services/database/history_model.dart';
import 'package:where_are_you/services/schema/history.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({Key? key, required this.keyword}) : super(key: key);
  final String keyword;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Card(
        child: FutureBuilder<List<History>>(
          future: HistoryModel.instance.selectDepartureArrival(keyword),
          builder: (_, snapshot) => ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: (snapshot.data ?? []).length,
              itemBuilder: (_, index) {
                History history = snapshot.data![index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'From: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  history.departure,
                                  style: const TextStyle(
                                    color: Color.fromARGB(160, 0, 0, 0),
                                    fontSize: 20.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'To: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  history.arrival ?? '',
                                  style: const TextStyle(
                                    color: Color.fromARGB(160, 0, 0, 0),
                                    fontSize: 20.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}

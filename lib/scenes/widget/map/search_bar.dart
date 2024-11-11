import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key, required this.onEdit}) : super(key: key);
  final Function onEdit;
  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late DateTime selectedDate;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 1),
      child: Card(
        child: Row(
          children: [
            Flexible(
              child: TextFormField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onEditingComplete: () {
                  widget.onEdit(controller.text);
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search",
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _selectDate(context),
              icon: const Icon(
                Icons.calendar_month,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}

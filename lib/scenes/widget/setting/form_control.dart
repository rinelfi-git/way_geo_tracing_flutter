import 'package:flutter/material.dart';

class FormControl extends StatelessWidget {
  FormControl({
    Key? key,
    required this.label,
    this.value,
    this.onValidate,
  }) : super(key: key);

  final String label;
  final String? value;
  final Function? onValidate;

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.text = value ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
          ),
        ),
        onEditingComplete: () {
          if (onValidate != null) {
            onValidate!(controller.text);
          }
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
    );
  }

  void update(String value) {
    controller.text = value;
  }
}

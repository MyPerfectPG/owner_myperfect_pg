import 'package:flutter/material.dart';

class CustomCheckboxWidget extends StatefulWidget {
  final String title;
  final List<String> options;
  final Function(List<String>) onSelectionChanged;

  CustomCheckboxWidget({
    required this.title,
    required this.options,
    required this.onSelectionChanged,
  });

  @override
  _CustomCheckboxWidgetState createState() => _CustomCheckboxWidgetState();
}

class _CustomCheckboxWidgetState extends State<CustomCheckboxWidget> {
  Map<String, bool> values = {};

  @override
  void initState() {
    super.initState();
    widget.options.forEach((option) {
      values[option] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...widget.options.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: values[option],
            onChanged: (bool? value) {
              setState(() {
                values[option] = value!;
              });
              widget.onSelectionChanged(values.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .toList());
            },
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Color(0xff0094FF),
          );
        }).toList(),
      ],
    );
  }
}


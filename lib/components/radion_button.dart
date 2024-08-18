import 'package:flutter/material.dart';

class CustomRadioWidget extends StatefulWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final Function(String) onSelectionChanged;

  CustomRadioWidget({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelectionChanged,
  });

  @override
  _CustomRadioWidgetState createState() => _CustomRadioWidgetState();
}

class _CustomRadioWidgetState extends State<CustomRadioWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
        ...widget.options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: widget.selectedValue,
            onChanged: (value) {
              if (value != null) {
                widget.onSelectionChanged(value);
              }
            },
          );
        }).toList(),
      ],
    );
  }
}

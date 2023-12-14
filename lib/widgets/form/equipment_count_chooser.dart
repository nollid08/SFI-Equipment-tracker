import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class EquipmentCountChooser extends StatefulWidget {
  const EquipmentCountChooser({
    super.key,
    required this.onSliderChanged,
    required this.equipmentCount,
    required this.initialValue,
  });
  final void Function(num?) onSliderChanged;
  final int equipmentCount;
  final int initialValue;

  @override
  State<EquipmentCountChooser> createState() => _EquipmentCountChooserState();
}

class _EquipmentCountChooserState extends State<EquipmentCountChooser> {
  int currentValue = -1;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (currentValue == -1) {
          currentValue = widget.initialValue;
        }
      });
    });
    if (widget.equipmentCount == 1) {
      return const Text("1 Item To be transferred");
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Select Amount to be transferred, (Max: ${widget.equipmentCount})'),
          Center(
            child: NumberPicker(
              value: currentValue > 0 ? currentValue : widget.initialValue,
              minValue: 1,
              maxValue: widget.equipmentCount,
              onChanged: (value) => setState(() {
                currentValue = value;
                widget.onSliderChanged(value);
              }),
              axis: Axis.vertical,
              haptics: true,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

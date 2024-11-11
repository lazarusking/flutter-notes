import 'package:flutter/material.dart';
import 'package:notes/presentation/notes_provider.dart';

class ColorPicker extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final bool isBlockStyle;

  const ColorPicker(
      {super.key,
      required this.selectedColor,
      required this.onColorSelected,
      this.isBlockStyle = false});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
    print("initial $_selectedColor");
  }

  @override
  Widget build(BuildContext context) {
    //stateful builder is probably not needed again since
    //I moved the whole thing from a method to a class whew won't touch
    return StatefulBuilder(builder: (context, setNewState) {
      return Material(
          color: _selectedColor,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              title: Text('Pick a color'),
            ),
            Container(
              padding: const EdgeInsets.all(11.0),
              child: widget.isBlockStyle
                  ? GridView.count(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(1.0),
                      crossAxisCount: 4, // Increase the number of columns
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 1,
                      children: [
                        _buildColorOptions(
                          color: Color(0xFF202124),
                          colorName: 'Default color',
                        ),
                        ...colors.entries.map((entry) {
                          final colorName = entry.key;
                          final colorValue = entry.value;
                          return _buildColorOptions(
                            color: colorValue,
                            colorName: colorName,
                          );
                        }),
                      ],
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildColorOptions(
                              color: defaultColor, colorName: "Default color"),
                          ...colors.entries.map((entry) {
                            final colorName = entry.key;
                            final value = entry.value;

                            return _buildColorOptions(
                                color: value, colorName: colorName);
                          }),
                        ],
                      ),
                    ),
            ),
            SizedBox(
              height: 40,
            )
          ]));
    });
  }

  Widget _buildColorOptions(
      {required Color color,
      required colorName,
      Color defaultColor = const Color(0xFF202124)}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
        widget.onColorSelected(color);
      },
      child: Tooltip(
        message: colorName,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == _selectedColor
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                    width: color == _selectedColor ? 2 : 0.5,
                  ),
                ),
              ),
              if (color == _selectedColor)
                Icon(
                  Icons.check,
                  color: Colors.grey.shade300,
                ),
              if (colorName == "Default color")
                Icon(
                  _selectedColor == defaultColor
                      ? Icons.check
                      : Icons.invert_colors_off_outlined,
                  color: Colors.grey.shade300,
                )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/utils/helpers.dart';

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
    // print("initial $_selectedColor");
  }

  @override
  Widget build(BuildContext context) {
    //stateful builder is probably not needed again since
    //I moved the whole thing from a method to a class whew won't touch
    return Consumer(
      builder: (context, ref, child) {
        // final themeMode = ref.watch(themeModeProvider);
        // final isDark = themeMode == ThemeMode.dark ||
        //     (themeMode == ThemeMode.system &&
        //         WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        //             Brightness.dark);
        // final themeColors = isDark ? darkColors : lightColors;
        final Color defaultColor = Helpers.getDefaultBackgroundColor(context);

        return StatefulBuilder(builder: (context, setNewState) {
          return Material(
              color: widget.isBlockStyle
                  ? Colors.transparent
                  : _selectedColor.getThemeAwareColor(ref),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                  title: Text('Pick a color $_selectedColor'),
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
                              color: defaultColor,
                              colorName: 'Default color',
                            ),
                            ...darkColors.entries.map((entry) {
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
                                  color: defaultColor,
                                  colorName: "Default color"),
                              ...darkColors.entries.map((entry) {
                                final colorName = entry.key;
                                final value = entry.value;

                                return _buildColorOptions(
                                    color: value, colorName: colorName);
                              }),
                            ],
                          ),
                        ),
                ),
                const SizedBox(
                  height: 40,
                )
              ]));
        });
      },
    );
  }

  Widget _buildColorOptions({required Color color, required colorName}) {
    final themeAwareColor =
        getThemeAwareColor(color, Theme.of(context).brightness);
    final adaptiveColorSelection =
        getThemeAwareColor(_selectedColor, Theme.of(context).brightness);
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
                  color: themeAwareColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeAwareColor == adaptiveColorSelection
                        ? Colors.lightBlue
                        : Colors.grey.shade500,
                    width: themeAwareColor == adaptiveColorSelection ? 2 : 0.5,
                  ),
                ),
              ),
              if (themeAwareColor == adaptiveColorSelection)
                const Icon(
                  Icons.check,
                  size: 30,
                  color: Colors.lightBlue,
                ),
              if (colorName == "Default color")
                Icon(
                  size: 20,
                  adaptiveColorSelection == Colors.transparent
                      ? Icons.check
                      : Icons.invert_colors_off_outlined,
                  color: Colors.grey,
                )
            ],
          ),
        ),
      ),
    );
  }
}

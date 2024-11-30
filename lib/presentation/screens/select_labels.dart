import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/providers/notes_provider.dart';

class SelectLabelsScreen extends ConsumerStatefulWidget {
  const SelectLabelsScreen({super.key});

  @override
  SelectLabelsScreenState createState() => SelectLabelsScreenState();
}

class SelectLabelsScreenState extends ConsumerState<SelectLabelsScreen> {
  final TextEditingController _searchLabelController = TextEditingController();
  int _isCreatingIndex = -1;
  final TextEditingController _editLabelController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusCreateNode = FocusNode();
  String _searchQuery = '';
  final Set<String> _selectedLabels = {};

  @override
  void dispose() {
    _searchLabelController.dispose();
    _focusNode.dispose();
    _focusCreateNode.dispose();
    _editLabelController.dispose();
    super.dispose();
  }

  void _addLabel() {
    final newLabelName = _searchLabelController.text;
    if (newLabelName.isNotEmpty) {
      ref.read(labelsProvider.notifier).addLabel(newLabelName);
      _searchLabelController.clear();
      _focusCreateNode.unfocus();
      setState(() {
        _isCreatingIndex = -1;
        _searchQuery = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(labelsProvider);

    final filteredLabels = labels
        .where((label) =>
            label.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final labelExists = labels
        .any((label) => label.name.toLowerCase() == _searchQuery.toLowerCase());

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Navigator.of(context).pop(_selectedLabels);
          // return _selectedLabels;
          // Navigator.of(context).pop(_selectedLabels);

          print('$result popscope');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(_selectedLabels);
                Navigator.of(context).pop();
              }
            },
          ),
          title: TextField(
            controller: _searchLabelController,
            focusNode: _focusCreateNode,
            onTap: () {
              setState(() {
                _isCreatingIndex = 0;
              });
            },
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onEditingComplete: () {
              if (_isCreatingIndex == 0) {
                _addLabel();
              }
            },
            decoration: const InputDecoration(
              hintText: 'Enter label name',
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              isDense: true,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              debugPaintSizeEnabled = !debugPaintSizeEnabled;
              debugPaintLayerBordersEnabled = !debugPaintLayerBordersEnabled;
            });
          },
        ),
        body: labels.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sell_rounded,
                      size: 48,
                      color: Colors.blueGrey[200],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No labels yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        // color: Colors.grey[800],
                        // color: Theme.of(context).primaryColor
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first label',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          // color: Colors.grey[600],
                          color: Theme.of(context).textTheme.bodySmall!.color),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  if (_searchQuery.isNotEmpty && !labelExists)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      leading: const Icon(Icons.add, size: 20),
                      title: Text('Create "$_searchQuery"'),
                      onTap: _addLabel,
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredLabels.length,
                      itemBuilder: (context, index) {
                        // final label = filteredLabels[index];
                        final label =
                            filteredLabels[filteredLabels.length - 1 - index];

                        return CheckboxListTile.adaptive(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          value: _selectedLabels.contains(label.id),
                          onChanged: (bool? value) {
                            toggleLabel(value, label);
                            print(_selectedLabels);
                          },
                          title: InkWell(
                            onTap: () {
                              setState(() {
                                toggleLabel(
                                    _selectedLabels.contains(label.id), label);
                                _isCreatingIndex = -1;
                                _editLabelController.text = label.name;
                                _searchLabelController.clear();
                                _focusCreateNode.unfocus();
                                _focusNode.requestFocus();
                              });
                            },
                            child: Text('${label.name} ${label.id} $index'),
                          ),
                          secondary: const Icon(
                            Icons.label_outline,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void toggleLabel(bool? value, Label label) {
    return setState(() {
      if (value == true) {
        _selectedLabels.add(label.id!);
      } else {
        _selectedLabels.remove(label.id);
      }
    });
  }
}

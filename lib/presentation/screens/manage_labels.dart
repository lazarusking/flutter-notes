import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/notes/note.dart';
import 'package:notes/providers/notes_provider.dart';

class ManageLabelsScreen extends ConsumerStatefulWidget {
  const ManageLabelsScreen({super.key});

  @override
  ManageLabelsScreenState createState() => ManageLabelsScreenState();
}

class ManageLabelsScreenState extends ConsumerState<ManageLabelsScreen> {
  final TextEditingController _newLabelController = TextEditingController();
  int _isEditingIndex = -1;
  int _isCreatingIndex = -1;
  final TextEditingController _editLabelController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusCreateNode = FocusNode();

  @override
  void dispose() {
    _newLabelController.dispose();
    _focusNode.dispose();
    _focusCreateNode.dispose();
    _editLabelController.dispose();
    super.dispose();
  }

  void _addLabel() {
    final newLabelName = _newLabelController.text;
    if (newLabelName.isNotEmpty) {
      ref.read(labelsProvider.notifier).addLabel(newLabelName);
      _newLabelController.clear();
      _focusCreateNode.unfocus();
      setState(() {
        _isCreatingIndex = -1;
        _isEditingIndex = -1;
      });
    }
  }

  void _updateLabel(Label label) {
    final newLabelName = _editLabelController.text;
    if (newLabelName.isNotEmpty) {
      ref.read(labelsProvider.notifier).updateLabel(
            label.copyWith(name: newLabelName),
          );
      setState(() {
        _isEditingIndex = -1;
        _isCreatingIndex = -1;
      });
    }
  }

  void _deleteLabel(String id) {
    ref.read(labelsProvider.notifier).deleteLabelById(id);
    setState(() {
      _isEditingIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(labelsProvider);

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit labels',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // debugPaintSizeEnabled = !debugPaintSizeEnabled;
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
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  shape: _isCreatingIndex == 0
                      ? Border.all(color: Theme.of(context).dividerColor)
                      : Border.all(color: Colors.transparent),
                  leading: IconButton(
                    icon: Icon(
                      _isCreatingIndex == 0 ? Icons.close : Icons.add,
                      size: 20,
                    ),
                    onPressed: () {
                      if (_isCreatingIndex == 0) {
                        setState(() {
                          _newLabelController.clear();
                          _focusCreateNode.unfocus();
                          _isCreatingIndex = -1;
                          _isEditingIndex = -1;
                        });
                      }
                    },
                  ),
                  title: TextField(
                    controller: _newLabelController,
                    focusNode: _focusCreateNode,
                    onTap: () {
                      setState(() {
                        _isCreatingIndex = 0;
                        _isEditingIndex = -1;
                      });
                    },
                    onEditingComplete: () {
                      if (_isCreatingIndex == 0) {
                        _addLabel();
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter new label',
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      isDense: true,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      if (_isCreatingIndex == 0) {
                        _addLabel();
                      }
                    },
                    icon: Icon(
                      _isCreatingIndex == 0 ? Icons.check : null,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: labels.length,
                    itemBuilder: (context, index) {
                      final label = labels[labels.length - 1 - index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 0),
                        shape: _isEditingIndex == index
                            ? Border.all(color: Theme.of(context).dividerColor)
                            : Border.all(color: Colors.transparent),
                        leading: IconButton(
                          icon: Icon(
                            _isEditingIndex == index
                                ? CupertinoIcons.delete
                                : Icons.label_outline,
                            size: 20,
                          ),
                          onPressed: () {
                            if (_isEditingIndex == index) {
                              _deleteLabel(label.id!);
                            }
                          },
                        ),
                        title: _isEditingIndex == index
                            ? TextField(
                                focusNode: _focusNode,
                                controller: _editLabelController
                                  ..text = label.name,
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 0),
                                  isDense: true,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  focusOnEditTextField(index, label);
                                },
                                child: Text(
                                  label.name,
                                ),
                              ),
                        trailing: IconButton(
                          icon: Icon(
                            _isEditingIndex == index ? Icons.check : Icons.edit,
                            size: 20,
                          ),
                          onPressed: () {
                            if (_isEditingIndex == index) {
                              _updateLabel(label);
                            } else {
                              focusOnEditTextField(index, label);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void focusOnEditTextField(int index, Label label) {
    return setState(() {
      _isCreatingIndex = -1;
      _isEditingIndex = index;
      _editLabelController.text = label.name;
      _newLabelController.clear();
      _focusCreateNode.unfocus();
      _focusNode.requestFocus();
    });
  }
}

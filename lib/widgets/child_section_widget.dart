import 'package:flutter/material.dart';
import '../models/form_config.dart' as models;
import 'dynamic_form_field.dart';

class ChildSectionWidget extends StatefulWidget {
  final models.ChildSection childSection;
  final Map<String, dynamic> formValues;
  final ValueChanged<Map<String, dynamic>> onChildDataChanged;

  const ChildSectionWidget({
    super.key,
    required this.childSection,
    required this.formValues,
    required this.onChildDataChanged,
  });

  @override
  State<ChildSectionWidget> createState() => _ChildSectionWidgetState();
}

class _ChildSectionWidgetState extends State<ChildSectionWidget> {
  List<Map<String, dynamic>> _childItems = [];

  @override
  void initState() {
    super.initState();
    _childItems = [{}];
  }

  @override
  void didUpdateWidget(ChildSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formValues.isEmpty && oldWidget.formValues.isNotEmpty) {
      setState(() {
        _childItems = [{}];
      });
    }
    if (widget.formValues.isEmpty) {
      setState(() {
        _childItems = [{}];
      });
    }
  }

  void _addItem() {
    setState(() {
      _childItems.add({});
    });
  }

  void _removeItem(int index) {
    setState(() {
      _childItems.removeAt(index);
      _updateParentData();
    });
  }

  void _updateFieldValue(int itemIndex, String fieldName, dynamic value) {
    setState(() {
      if (itemIndex < _childItems.length) {
        _childItems[itemIndex][fieldName] = value;
        _updateParentData();
      }
    });
  }

  void _updateParentData() {
    final key = widget.childSection.tableName;
    widget.onChildDataChanged({key: _childItems});
  }

  @override
  Widget build(BuildContext context) {
    final sortedFields = List<models.FormField>.from(widget.childSection.fields)
      ..sort((a, b) => (a.ordering ?? 0).compareTo(b.ordering ?? 0));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.childSection.childHeading,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.childSection.isChildCopy)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addItem,
                    tooltip: 'Add ${widget.childSection.childHeading}',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(_childItems.length, (itemIndex) {
              return Card(
                color: Colors.grey[100],
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_childItems.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Item ${itemIndex + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(itemIndex),
                            ),
                          ],
                        ),
                      ...sortedFields.map((field) {
                        final fieldName = field.fieldname;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DynamicFormField(
                            field: field,
                            initialValue: _childItems[itemIndex][fieldName],
                            formValues: widget.formValues,
                            onChanged: (value) =>
                                _updateFieldValue(itemIndex, fieldName, value),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}


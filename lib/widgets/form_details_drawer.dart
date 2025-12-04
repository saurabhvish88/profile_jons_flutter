import 'package:flutter/material.dart';
import '../screens/form_details_screen.dart';

class FormDetailsDrawer extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Map<String, String> fieldLabels;

  const FormDetailsDrawer({
    super.key,
    required this.formData,
    required this.fieldLabels,
  });

  @override
  State<FormDetailsDrawer> createState() => _FormDetailsDrawerState();
}

class _FormDetailsDrawerState extends State<FormDetailsDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, dynamic>> _getFilteredData() {
    if (_searchQuery.isEmpty) {
      return widget.formData.entries.toList();
    }

    final query = _searchQuery.toLowerCase();
    final filtered = <MapEntry<String, dynamic>>[];

    widget.formData.forEach((key, value) {
      final fieldLabel = widget.fieldLabels[key] ?? key;
      final keyLower = key.toLowerCase();
      final labelLower = fieldLabel.toLowerCase();
      final valueStr = value.toString().toLowerCase();

      if (keyLower.contains(query) ||
          labelLower.contains(query) ||
          valueStr.contains(query)) {
        filtered.add(MapEntry(key, value));
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Form Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Fields: ${widget.formData.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormDetailsScreen(
                            formData: widget.formData,
                            fieldLabels: widget.fieldLabels,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('View Full Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search form data...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredData.length} result(s) found',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
            ),
          ),

          Expanded(
            child: widget.formData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No form data available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill the form to see details here',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try different search terms',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: _buildFormDataList(filteredData),
                      ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormDataList(List<MapEntry<String, dynamic>> filteredData) {
    final List<Widget> widgets = [];

    final mainFields = <String, dynamic>{};
    final childSections = <String, dynamic>{};

    for (var entry in filteredData) {
      final key = entry.key;
      final value = entry.value;
      
      if (key.startsWith('tbl') ||
          key.contains('Education') ||
          key.contains('WorkExperience')) {
        childSections[key] = value;
      } else {
        mainFields[key] = value;
      }
    }

    if (mainFields.isNotEmpty) {
      widgets.add(_buildSectionHeader('Main Details'));
      mainFields.forEach((key, value) {
        widgets.add(_buildDataItem(key, value));
      });
    }

    if (childSections.isNotEmpty) {
      childSections.forEach((sectionKey, sectionData) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(_buildSectionHeader(_getSectionTitle(sectionKey)));

        if (sectionData is List) {
          for (int i = 0; i < sectionData.length; i++) {
            if (sectionData[i] is Map) {
              widgets.add(_buildSubSectionHeader('Item ${i + 1}'));
              (sectionData[i] as Map).forEach((key, value) {
                widgets.add(_buildDataItem(key, value, isChild: true));
              });
              if (i < sectionData.length - 1) {
                widgets.add(const Divider(height: 24));
              }
            }
          }
        } else if (sectionData is Map) {
          sectionData.forEach((key, value) {
            widgets.add(_buildDataItem(key, value, isChild: true));
          });
        }
      });
    }

    return widgets;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildDataItem(String key, dynamic value, {bool isChild = false}) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    final label = widget.fieldLabels[key] ?? _formatKey(key);
    final displayValue = _formatValue(value);

    final highlightedLabel = _highlightText(label, _searchQuery);
    final highlightedValue = _highlightText(displayValue, _searchQuery);

    return Card(
      margin: EdgeInsets.only(
        bottom: isChild ? 8 : 12,
        left: isChild ? 16 : 0,
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: highlightedLabel,
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: highlightedValue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      );
    }

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    final index = textLower.indexOf(queryLower);

    if (index == -1) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: TextStyle(
              backgroundColor: Colors.yellow[300],
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    String formatted = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    formatted = formatted.trim();
    if (formatted.isEmpty) {
      formatted = key;
    }
    if (formatted.isNotEmpty) {
      formatted = formatted[0].toUpperCase() + formatted.substring(1);
    }
    return formatted;
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is List) {
      return value.map((e) => e.toString()).join(', ');
    }
    if (value is Map) {
      return value.entries
          .map((e) => '${_formatKey(e.key.toString())}: ${e.value}')
          .join(', ');
    }
    return value.toString();
  }

  String _getSectionTitle(String key) {
    if (key.contains('Education')) return 'Education Details';
    if (key.contains('WorkExperience')) return 'Work Experience';
    if (key.contains('tblEducation')) return 'Education Details';
    if (key.contains('tblWorkExperience')) return 'Work Experience';
    return _formatKey(key);
  }
}

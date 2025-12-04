import 'package:flutter/material.dart';
import '../models/form_config.dart' as models;
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/dynamic_form_field.dart';
import '../widgets/child_section_widget.dart';
import '../widgets/success_card.dart';
import '../widgets/form_details_drawer.dart';

class ProfileFormScreen extends StatefulWidget {
  final models.FormConfig formConfig;

  const ProfileFormScreen({super.key, required this.formConfig});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formValues = {};
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _showSuccessCard = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      setState(() {
        _formValues = {};
      });
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onFieldChanged(String fieldName, dynamic value) {
    setState(() {
      _formValues[fieldName] = value;
    });
    StorageService.saveFormData(_formValues);
  }

  void _onChildDataChanged(Map<String, dynamic> childData) {
    setState(() {
      _formValues.addAll(childData);
    });
    StorageService.saveFormData(_formValues);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await StorageService.saveFormData(_formValues);
      await StorageService.saveFormSubmission(_formValues);
      await ApiService.submitForm(_formValues);

      if (mounted) {
        setState(() {
          _showSuccessCard = true;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _clearFormFields();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearFormFields() {
    _formKey.currentState?.reset();
    
    setState(() {
      _formValues = {};
      _showSuccessCard = false;
    });
    
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _formValues = {};
          });
        }
      });
    }
  }

  void _dismissSuccessCard() {
    setState(() {
      _showSuccessCard = false;
    });
    _clearFormFields();
  }

  Map<String, List<models.FormField>> _groupFieldsBySection() {
    final Map<String, List<models.FormField>> sections = {};
    for (var field in widget.formConfig.fields) {
      final key = field.sectionHeader ?? 'Other';
      if (!sections.containsKey(key)) {
        sections[key] = [];
      }
      sections[key]!.add(field);
    }
    sections.forEach((key, fields) {
      fields.sort((a, b) => (a.ordering ?? 0).compareTo(b.ordering ?? 0));
    });
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sections = _groupFieldsBySection();
    final sortedSections = sections.entries.toList()
      ..sort((a, b) {
        final orderA = widget.formConfig.fields
                .where((f) => f.sectionHeader == a.key)
                .isNotEmpty
            ? (widget.formConfig.fields
                .where((f) => f.sectionHeader == a.key)
                .first
                .sectionOrder ?? 999)
            : 999;
        final orderB = widget.formConfig.fields
                .where((f) => f.sectionHeader == b.key)
                .isNotEmpty
            ? (widget.formConfig.fields
                .where((f) => f.sectionHeader == b.key)
                .first
                .sectionOrder ?? 999)
            : 999;
        return orderA.compareTo(orderB);
      });

    final Map<String, String> fieldLabels = {};
    for (var field in widget.formConfig.fields) {
      fieldLabels[field.fieldname] = field.yourlabel;
    }
    for (var child in widget.formConfig.child) {
      for (var field in child.fields) {
        fieldLabels[field.fieldname] = field.yourlabel;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.formConfig.menuID),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'View Form Details',
          ),
        ),
      ),
      drawer: FutureBuilder<Map<String, dynamic>?>(
        future: StorageService.getLatestFormSubmission(),
        builder: (context, snapshot) {
          final displayData = snapshot.data ?? _formValues;
          return FormDetailsDrawer(
            formData: displayData,
            fieldLabels: fieldLabels,
          );
        },
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...sortedSections.map((section) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (section.key != 'Other')
                              Text(
                                section.key,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (section.key != 'Other')
                              const SizedBox(height: 16),
                            ...section.value.map((field) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: DynamicFormField(
                                  key: ValueKey('${field.fieldname}_${_formValues['countryId']}_${_formValues['stateId']}'),
                                  field: field,
                                  initialValue: _formValues[field.fieldname],
                                  formValues: _formValues,
                                  onChanged: (value) =>
                                      _onFieldChanged(field.fieldname, value),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }),

                  ...widget.formConfig.child.map((childSection) {
                    return ChildSectionWidget(
                      childSection: childSection,
                      formValues: _formValues,
                      onChildDataChanged: _onChildDataChanged,
                    );
                  }),

                  const SizedBox(height: 24),

                  ...widget.formConfig.buttons.map((button) {
                    return ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              button.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                    );
                  }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_showSuccessCard)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: SuccessCard(
                    message: 'Form submitted successfully!',
                    onDismiss: _dismissSuccessCard,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

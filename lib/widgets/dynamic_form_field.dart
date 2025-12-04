import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/form_config.dart' as models;
import '../services/api_service.dart';

class DynamicFormField extends StatefulWidget {
  final models.FormField field;
  final ValueChanged<dynamic> onChanged;
  final dynamic initialValue;
  final Map<String, dynamic> formValues;

  const DynamicFormField({
    super.key,
    required this.field,
    required this.onChanged,
    this.initialValue,
    required this.formValues,
  });

  @override
  State<DynamicFormField> createState() => _DynamicFormFieldState();
}

class _DynamicFormFieldState extends State<DynamicFormField> {
  List<Map<String, dynamic>> _dropdownOptions = [];
  bool _isLoading = false;
  dynamic _selectedValue;
  TextEditingController? _textController;
  
  bool _needsValidation() {
    return widget.field.fieldname == 'contactNumber' ||
           widget.field.fieldname == 'alternateMobileNumber' ||
           widget.field.fieldname == 'emailAddress';
  }
  
  int? _getMaxLength() {
    final fieldName = widget.field.fieldname.toLowerCase();
    if (fieldName.contains('contact') || fieldName.contains('mobile')) {
      return 10;
    }
    return widget.field.size;
  }
  
  List<TextInputFormatter>? _getInputFormatters() {
    final fieldName = widget.field.fieldname.toLowerCase();
    if (fieldName.contains('contact') || fieldName.contains('mobile')) {
      return [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
    }
    return null;
  }
  
  dynamic _findMatchingValue(dynamic selectedValue) {
    if (selectedValue == null || _dropdownOptions.isEmpty) return null;
    
    final selectedStr = selectedValue.toString();
    
    for (int i = 0; i < _dropdownOptions.length; i++) {
      final option = _dropdownOptions[i];
      final optionId = option['_id']?.toString();
      final optionName = option['name']?.toString();
      
      if (optionId == selectedStr || optionName == selectedStr) {
        if (optionId != null) {
          return '${optionId}_$i';
        } else if (optionName != null) {
          return '${optionName}_$i';
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    
    if (widget.field.controlname == 'text') {
      _textController = TextEditingController(
        text: widget.initialValue?.toString() ?? '',
      );
    }
    
    if (widget.field.controlname == 'dropdown' &&
        widget.field.referenceTable != null) {
      if (widget.field.referenceTable!.contains('.')) {
        if (widget.field.referenceTable == 'tblCountry.tblState') {
          print('State dropdown initState - fieldname: ${widget.field.fieldname}, countryId: ${widget.formValues['countryId']}');
          if (widget.formValues['countryId'] != null && widget.formValues['countryId'].toString().isNotEmpty) {
            print('State dropdown - Loading data in initState');
            _loadDropdownData();
          } else {
            print('State dropdown - countryId is null/empty, waiting for country selection');
          }
        } else if (widget.field.referenceTable == 'tblCountry.tblCity') {
          print('City dropdown initState - fieldname: ${widget.field.fieldname}, stateId: ${widget.formValues['stateId']}');
          if (widget.formValues['stateId'] != null && widget.formValues['stateId'].toString().isNotEmpty) {
            print('City dropdown - Loading data in initState');
            _loadDropdownData();
          } else {
            print('City dropdown - stateId is null/empty, waiting for state selection');
          }
        }
      } else {
        _loadDropdownData();
      }
    }
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DynamicFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.initialValue == null && oldWidget.initialValue != null) {
      setState(() {
        _selectedValue = null;
        if (widget.field.controlname == 'text' && _textController != null) {
          _textController!.clear();
        }
      });
    }
    
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
        if (widget.field.controlname == 'text' && _textController != null) {
          if (widget.initialValue == null || 
              widget.initialValue.toString().isEmpty ||
              widget.initialValue.toString() == 'null') {
            _textController!.clear();
          } else {
            _textController!.text = widget.initialValue.toString();
          }
        }
      });
    }
    
    if (widget.field.controlname == 'dropdown' &&
        widget.field.referenceTable != null) {
      if (widget.field.referenceTable == 'tblCountry.tblState') {
        final currentCountryId = widget.formValues['countryId'];
        final oldCountryId = oldWidget.formValues['countryId'];
        
        print('State dropdown - didUpdateWidget: currentCountryId=$currentCountryId, oldCountryId=$oldCountryId');
        
        String? currentId = currentCountryId?.toString();
        String? oldId = oldCountryId?.toString();
        if (currentId != null && currentId.contains('_')) {
          currentId = currentId.split('_')[0];
        }
        if (oldId != null && oldId.contains('_')) {
          oldId = oldId.split('_')[0];
        }
        
        print('State dropdown - Clean IDs: currentId=$currentId, oldId=$oldId');
        
        if (currentId != null && currentId.isNotEmpty && (oldId == null || oldId != currentId)) {
          print('Country changed from $oldId to $currentId, loading states for ${widget.field.fieldname}');
          _loadDropdownData();
          if (oldId != null && oldId != currentId) {
            _selectedValue = null;
            widget.onChanged(null);
          }
        } else if (currentId == null || currentId.isEmpty) {
          print('Country is null/empty, clearing states');
          setState(() {
            _dropdownOptions = [];
            _selectedValue = null;
          });
        } else {
          print('State dropdown - No change detected, currentId=$currentId, oldId=$oldId');
        }
      }
      else if (widget.field.referenceTable == 'tblCountry.tblCity') {
        final currentStateId = widget.formValues['stateId'];
        final oldStateId = oldWidget.formValues['stateId'];
        
        print('City dropdown - didUpdateWidget: currentStateId=$currentStateId, oldStateId=$oldStateId');
        
        String? currentId = currentStateId?.toString();
        String? oldId = oldStateId?.toString();
        if (currentId != null && currentId.contains('_')) {
          currentId = currentId.split('_')[0];
        }
        if (oldId != null && oldId.contains('_')) {
          oldId = oldId.split('_')[0];
        }
        
        print('City dropdown - Clean IDs: currentId=$currentId, oldId=$oldId');
        
        if (currentId != null && currentId.isNotEmpty && (oldId == null || oldId != currentId)) {
          print('State changed from $oldId to $currentId, loading cities for ${widget.field.fieldname}');
          _loadDropdownData();
          if (oldId != null && oldId != currentId) {
            _selectedValue = null;
            widget.onChanged(null);
          }
        } else if (currentId == null || currentId.isEmpty) {
          print('State is null/empty, clearing cities');
          setState(() {
            _dropdownOptions = [];
            _selectedValue = null;
          });
        } else {
          print('City dropdown - No change detected, currentId=$currentId, oldId=$oldId');
        }
      }
    }
  }

  Future<void> _loadDropdownData() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> data = [];

      if (widget.field.referenceTable!.contains('.')) {
        if (widget.field.referenceTable == 'tblCountry.tblState') {
          final countryId = widget.formValues['countryId'];
          print('State dropdown - Loading for countryId: $countryId, Type: ${countryId.runtimeType}');
          print('All form values: ${widget.formValues}');
          
          if (countryId != null && countryId.toString().isNotEmpty) {
            String cleanCountryId = countryId.toString();
            if (cleanCountryId.contains('_')) {
              final parts = cleanCountryId.split('_');
              cleanCountryId = parts[0];
            }
            
            print('Loading states for clean country ID: $cleanCountryId');
            data = await ApiService.getStatesForCountry(cleanCountryId);
            print('Loaded ${data.length} states for country: $cleanCountryId');
            if (data.isNotEmpty) {
              print('First state: ${data[0]}');
            }
          } else {
            print('Country ID is null or empty, cannot load states');
            data = [];
          }
        } else if (widget.field.referenceTable == 'tblCountry.tblCity') {
          final stateId = widget.formValues['stateId'];
          print('City dropdown - Loading for stateId: $stateId, Type: ${stateId.runtimeType}');
          print('All form values: ${widget.formValues}');
          
          if (stateId != null && stateId.toString().isNotEmpty) {
            String cleanStateId = stateId.toString();
            if (cleanStateId.contains('_')) {
              final parts = cleanStateId.split('_');
              cleanStateId = parts[0];
            }
            
            print('Loading cities for clean state ID: $cleanStateId');
            data = await ApiService.getCitiesForState(cleanStateId);
            print('Loaded ${data.length} cities for state: $cleanStateId');
            if (data.isNotEmpty) {
              print('First city: ${data[0]}');
            }
          } else {
            print('State ID is null or empty, cannot load cities');
            data = [];
          }
        }
      } else {
        data = await ApiService.getDropdownData(
          widget.field.referenceTable!,
          widget.field.referenceColumn,
          widget.field.dropdownFilter,
        );
      }

      setState(() {
        _dropdownOptions = data;
        _isLoading = false;
        print('Dropdown loaded for ${widget.field.fieldname}: ${data.length} items');
        if (data.isNotEmpty) {
          print('Sample option: ${data[0]}');
          print('All options: $data');
        } else {
          print('WARNING: No data loaded for ${widget.field.fieldname}');
        }
      });
    } catch (e, stackTrace) {
      print('Error loading dropdown data for ${widget.field.fieldname}: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _dropdownOptions = [];
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!widget.field.isControlShow) {
      return const SizedBox.shrink();
    }

    final isRequired = widget.field.isRequired ?? false;
    final isEditable = widget.field.isEditable ?? true;

    if (widget.field.controlname == 'dropdown') {
      return _buildDropdown(isRequired, isEditable);
    } else {
      return _buildTextField(isRequired, isEditable);
    }
  }

  Widget _buildDropdown(bool isRequired, bool isEditable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.field.yourlabel}${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _isLoading
            ? const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              )
            : _dropdownOptions.isEmpty
                ? DropdownButtonFormField<dynamic>(
                    value: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: !isEditable,
                      fillColor: !isEditable ? Colors.grey[200] : null,
                      hintText: 'No ${widget.field.yourlabel} available',
                    ),
                    hint: Text('No ${widget.field.yourlabel} available'),
                    items: const [],
                    onChanged: null,
                  )
                : DropdownButtonFormField<dynamic>(
                    value: _selectedValue != null && _dropdownOptions.isNotEmpty
                        ? _findMatchingValue(_selectedValue)
                        : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: !isEditable,
                      fillColor: !isEditable ? Colors.grey[200] : null,
                    ),
                    hint: Text('Select ${widget.field.yourlabel}'),
                    items: _dropdownOptions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        
                        String displayValue = '';
                        
                        if (option.containsKey('name') && option['name'] != null) {
                          displayValue = option['name'].toString();
                        }
                        
                        if (widget.field.referenceColumn != null && displayValue.isEmpty) {
                          String refCol = widget.field.referenceColumn!
                              .replaceAll('\$', '')
                              .replaceAll('tblState.', '')
                              .replaceAll('tblCity.', '')
                              .trim();
                          
                          print('Reference column: ${widget.field.referenceColumn}, parsed: $refCol');
                          print('Option: $option');
                          print('Option keys: ${option.keys}');
                          
                          if (refCol.isNotEmpty && option.containsKey(refCol)) {
                            displayValue = option[refCol]?.toString() ?? '';
                            print('Found value from $refCol: $displayValue');
                          }
                        }
                        
                        if (displayValue.isEmpty) {
                          displayValue = option['name']?.toString() ?? 
                                        option['jobTitle']?.toString() ?? 
                                        '';
                        }
                        
                        if (displayValue.isEmpty) {
                          displayValue = 'Option ${index + 1}';
                          print('Warning: No display value found for option: $option');
                        }
                        
                        print('Final displayValue for ${widget.field.fieldname}: $displayValue');
                        
                        dynamic value;
                        if (option['_id'] != null) {
                          value = '${option['_id']}_$index';
                        } else if (option['name'] != null) {
                          value = '${option['name']}_$index';
                        } else {
                          value = '${option.toString()}_$index';
                        }

                        return DropdownMenuItem<dynamic>(
                          value: value,
                          child: Text(displayValue),
                        );
                      }).toList(),
                onChanged: isEditable
                    ? (value) {
                        dynamic originalValue = value;
                        if (value != null && value.toString().contains('_')) {
                          final parts = value.toString().split('_');
                          if (parts.length > 1) {
                            final index = int.tryParse(parts.last);
                            if (index != null && index < _dropdownOptions.length) {
                              final option = _dropdownOptions[index];
                              originalValue = option['_id'] ?? option['name'] ?? value;
                            } else {
                              originalValue = parts.sublist(0, parts.length - 1).join('_');
                            }
                          }
                        }
                        
                        setState(() => _selectedValue = value);
                        widget.onChanged(originalValue);
                      }
                    : null,
                validator: isRequired
                    ? (value) {
                        if (value == null) {
                          return '${widget.field.yourlabel} is required';
                        }
                        return null;
                      }
                    : null,
              ),
      ],
    );
  }

  Widget _buildTextField(bool isRequired, bool isEditable) {
    final fieldName = widget.field.fieldname.toLowerCase();
    final isNumberField = widget.field.type == 'number' ||
        fieldName.contains('experience') ||
        fieldName.contains('yearofpassing') ||
        fieldName.contains('passingyear') ||
        fieldName.contains('score') ||
        fieldName.contains('percentage') ||
        fieldName.contains('pincode');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.field.yourlabel}${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _textController,
          enabled: isEditable,
          keyboardType: isNumberField ? TextInputType.number : TextInputType.text,
          maxLength: _getMaxLength(),
          inputFormatters: _getInputFormatters(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: !isEditable,
            fillColor: !isEditable ? Colors.grey[200] : null,
            hintText: 'Enter ${widget.field.yourlabel}',
            counterText: '',
          ),
          onChanged: (value) => widget.onChanged(value),
          validator: isRequired || _needsValidation()
              ? (value) {
                  if (isRequired && (value == null || value.isEmpty)) {
                    return '${widget.field.yourlabel} is required';
                  }
                  
                  if (widget.field.fieldname == 'emailAddress') {
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                  }
                  
                  if (widget.field.fieldname == 'contactNumber' || 
                      widget.field.fieldname == 'alternateMobileNumber') {
                    if (value != null && value.isNotEmpty) {
                      final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digitsOnly.length != 10) {
                        return '${widget.field.yourlabel} must be exactly 10 digits';
                      }
                    }
                  }
                  
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}


import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/form_config.dart';

class ApiService {
  static Map<String, dynamic>? _countryDataCache;

  static final Map<String, List<Map<String, dynamic>>> _mockData = {
    'tblJobs': [
      {'_id': '1', 'jobTitle': 'Software Developer'},
      {'_id': '2', 'jobTitle': 'Flutter Developer'},
      {'_id': '3', 'jobTitle': 'Senior Developer'},
      {'_id': '4', 'jobTitle': 'Team Lead'},
    ],
    'tblDesignation': [
      {'_id': '1', 'name': 'Junior Developer'},
      {'_id': '2', 'name': 'Developer'},
      {'_id': '3', 'name': 'Senior Developer'},
      {'_id': '4', 'name': 'Tech Lead'},
    ],
    'tblProfileStatus': [
      {'_id': '1', 'name': 'Active'},
      {'_id': '2', 'name': 'Inactive'},
      {'_id': '3', 'name': 'Pending'},
    ],
  };

  static Future<Map<String, dynamic>> _loadCountryData() async {
    if (_countryDataCache != null) {
      return _countryDataCache!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/country_state_city_data.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      _countryDataCache = data;
      return data;
    } catch (e) {
      throw Exception('Failed to load country data: $e');
    }
  }

  static Future<List<FormConfig>> loadFormConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/Assingment JSON.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => FormConfig.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load form config: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getDropdownData(
    String referenceTable,
    String? referenceColumn,
    String? filter,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (referenceTable == 'tblCountry') {
      try {
        final countryData = await _loadCountryData();
        final countries = countryData['countries'] as List;
        return countries.map((country) => {
          '_id': country['_id'].toString(),
          'name': country['name'].toString(),
        }).toList().cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error loading countries: $e');
        return [];
      }
    }

    if (!_mockData.containsKey(referenceTable)) {
      print('Table not found in mock data: $referenceTable');
      return [];
    }

    var data = _mockData[referenceTable]!;
    
    final formattedData = data.map((item) {
      final newItem = Map<String, dynamic>.from(item);
      if (newItem.containsKey('_id')) {
        newItem['_id'] = newItem['_id'].toString();
      }
      if (newItem.containsKey('name')) {
        newItem['name'] = newItem['name'].toString();
      }
      if (newItem.containsKey('jobTitle')) {
        newItem['jobTitle'] = newItem['jobTitle'].toString();
      }
      return newItem;
    }).toList();

    print('Loaded ${formattedData.length} items for $referenceTable');
    return formattedData;
  }

  static Future<List<Map<String, dynamic>>> getStatesForCountry(
      String countryId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final countryData = await _loadCountryData();
      final countries = countryData['countries'] as List;

      for (var country in countries) {
        final countryIdStr = country['_id'].toString();
        final requestedIdStr = countryId.toString();
        
        if (countryIdStr == requestedIdStr) {
          final states = country['states'] as List;
          final result = states.map((state) => {
            '_id': state['_id'].toString(),
            'name': state['name'].toString(),
          }).toList().cast<Map<String, dynamic>>();
          
          print('Found ${result.length} states for country $countryIdStr');
          return result;
        }
      }
      print('No states found for country: $countryId');
      return [];
    } catch (e) {
      print('Error getting states for country $countryId: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getCitiesForState(
      String stateId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final countryData = await _loadCountryData();
      final countries = countryData['countries'] as List;

      print('Searching for cities for state ID: $stateId');
      
      for (var country in countries) {
        final states = country['states'] as List;
        for (var state in states) {
          final stateIdStr = state['_id'].toString();
          final requestedIdStr = stateId.toString();
          
          print('Comparing state ID: $stateIdStr with requested: $requestedIdStr');
          
          if (stateIdStr == requestedIdStr) {
            final cities = state['cities'] as List;
            print('Found ${cities.length} cities in state: ${state['name']}');
            
            final result = cities.map((city) {
              return {
                '_id': city['_id'].toString(),
                'name': city['name'].toString(),
              };
            }).toList().cast<Map<String, dynamic>>();
            
            print('Returning cities: $result');
            return result;
          }
        }
      }
      print('No cities found for state: $stateId');
      return [];
    } catch (e) {
      print('Error getting cities for state $stateId: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> submitForm(
      Map<String, dynamic> formData) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Form submitted successfully',
      'data': formData,
    };
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _formDataKey = 'form_data';
  static const String _formSubmissionsKey = 'form_submissions';
  static const String _formConfigKey = 'form_config';
  
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> saveFormData(Map<String, dynamic> formData) async {
    try {
      final jsonString = json.encode(formData);
      await _secureStorage.write(key: _formDataKey, value: jsonString);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_formDataKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save form data: $e');
    }
  }

  static Future<void> saveFormSubmission(Map<String, dynamic> formData) async {
    try {
      List<Map<String, dynamic>> submissions = await getFormSubmissions();
      final submissionWithTimestamp = Map<String, dynamic>.from(formData);
      submissionWithTimestamp['_submittedAt'] = DateTime.now().toIso8601String();
      submissions.add(submissionWithTimestamp);
      final jsonString = json.encode(submissions);
      await _secureStorage.write(key: _formSubmissionsKey, value: jsonString);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_formSubmissionsKey, jsonString);
      print('Saved form submission. Total submissions: ${submissions.length}');
    } catch (e) {
      throw Exception('Failed to save form submission: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFormSubmissions() async {
    try {
      String? data = await _secureStorage.read(key: _formSubmissionsKey);
      if (data == null) {
        final prefs = await SharedPreferences.getInstance();
        data = prefs.getString(_formSubmissionsKey);
      }
      if (data != null) {
        final decoded = json.decode(data);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final data = prefs.getString(_formSubmissionsKey);
        if (data != null) {
          final decoded = json.decode(data);
          if (decoded is List) {
            return decoded.cast<Map<String, dynamic>>();
          }
        }
      } catch (e2) {
      }
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getLatestFormSubmission() async {
    try {
      final submissions = await getFormSubmissions();
      if (submissions.isNotEmpty) {
        return submissions.last;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getFormData() async {
    try {
      String? data = await _secureStorage.read(key: _formDataKey);
      if (data == null) {
        final prefs = await SharedPreferences.getInstance();
        data = prefs.getString(_formDataKey);
      }
      if (data != null) {
        return json.decode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final data = prefs.getString(_formDataKey);
        if (data != null) {
          return json.decode(data) as Map<String, dynamic>;
        }
      } catch (e2) {
      }
      return null;
    }
  }

  static Future<void> saveFormConfig(String configJson) async {
    try {
      await _secureStorage.write(key: _formConfigKey, value: configJson);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_formConfigKey, configJson);
    } catch (e) {
      throw Exception('Failed to save form config: $e');
    }
  }

  static Future<String?> getFormConfig() async {
    try {
      String? config = await _secureStorage.read(key: _formConfigKey);
      if (config == null) {
        final prefs = await SharedPreferences.getInstance();
        config = prefs.getString(_formConfigKey);
      }
      return config;
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_formConfigKey);
      } catch (e2) {
        return null;
      }
    }
  }

  static Future<void> clearAllData() async {
    try {
      await _secureStorage.delete(key: _formDataKey);
      await _secureStorage.delete(key: _formConfigKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_formDataKey);
      await prefs.remove(_formConfigKey);
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  static Future<void> saveSensitiveData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Failed to save sensitive data: $e');
    }
  }

  static Future<String?> getSensitiveData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteSensitiveData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete sensitive data: $e');
    }
  }
}


import 'package:flutter/material.dart';
import 'package:project/screens/profile_form_screen.dart';
import 'package:project/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic>? _formConfigs;

  @override
  void initState() {
    super.initState();
    _loadFormConfig();
  }

  Future<void> _loadFormConfig() async {
    try {
      final configs = await ApiService.loadFormConfig();
      setState(() {
        _formConfigs = configs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading form: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFormConfig,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_formConfigs == null || _formConfigs!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('No Forms'),
        ),
        body: const Center(
          child: Text('No form configurations found'),
        ),
      );
    }
    final firstConfig = _formConfigs!.first;
    return ProfileFormScreen(formConfig: firstConfig);
  }
}

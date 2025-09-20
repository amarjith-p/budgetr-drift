import 'package:flutter/material.dart';
import '../../../core/models/percentage_config_model.dart';
import '../../../core/services/firestore_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  late Future<PercentageConfig> _configFuture;

  final _necessitiesController = TextEditingController();
  final _lifestyleController = TextEditingController();
  final _investmentController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _bufferController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _configFuture = _firestoreService.getPercentageConfig();
    _configFuture.then((config) {
      _necessitiesController.text = config.necessities.toStringAsFixed(0);
      _lifestyleController.text = config.lifestyle.toStringAsFixed(0);
      _investmentController.text = config.investment.toStringAsFixed(0);
      _emergencyController.text = config.emergency.toStringAsFixed(0);
      _bufferController.text = config.buffer.toStringAsFixed(0);
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final necessities = double.tryParse(_necessitiesController.text) ?? 0;
      final lifestyle = double.tryParse(_lifestyleController.text) ?? 0;
      final investment = double.tryParse(_investmentController.text) ?? 0;
      final emergency = double.tryParse(_emergencyController.text) ?? 0;
      final buffer = double.tryParse(_bufferController.text) ?? 0;

      if (necessities + lifestyle + investment + emergency + buffer != 100.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Percentages must add up to 100!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newConfig = PercentageConfig(
        necessities: necessities,
        lifestyle: lifestyle,
        investment: investment,
        emergency: emergency,
        buffer: buffer,
      );

      try {
        await _firestoreService.setPercentageConfig(newConfig);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving settings: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _necessitiesController.dispose();
    _lifestyleController.dispose();
    _investmentController.dispose();
    _emergencyController.dispose();
    _bufferController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculation Settings')),
      body: FutureBuilder<PercentageConfig>(
        future: _configFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set the percentage split for your effective income. The total must be 100%.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  _buildPercentField(_necessitiesController, 'Necessities %'),
                  _buildPercentField(_lifestyleController, 'Lifestyle %'),
                  _buildPercentField(_investmentController, 'Investment %'),
                  _buildPercentField(_emergencyController, 'Emergency %'),
                  _buildPercentField(_bufferController, 'Buffer %'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saveSettings,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPercentField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Cannot be empty';
          if (double.tryParse(value) == null) return 'Must be a number';
          return null;
        },
      ),
    );
  }
}

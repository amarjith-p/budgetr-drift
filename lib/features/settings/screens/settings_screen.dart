import 'package:budget/core/widgets/modern_loader.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../../../core/models/percentage_config_model.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _settingsService = SettingsService();
  final LocalAuthentication auth = LocalAuthentication();

  bool _isLoading = true;
  bool _isEditing = false;
  List<CategoryConfig> _categories = [];

  // Track total for real-time feedback
  double _currentTotal = 0.0;

  // Colors matching your Home Screen
  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _cardColor = const Color(0xFF1B263B).withOpacity(0.9);
  final Color _accentColor = const Color(0xFF3A86FF);

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _calculateTotal() {
    double total = _categories.fold(0, (sum, item) => sum + item.percentage);
    setState(() {
      _currentTotal = total;
    });
  }

  Future<void> _loadConfig() async {
    try {
      final config = await _settingsService.getPercentageConfig();
      setState(() {
        _categories = config.categories;
        _isLoading = false;
        _calculateTotal();
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool isSupported = await auth.isDeviceSupported();

      if (!canCheck && !isSupported) {
        setState(() => _isEditing = true);
        return;
      }

      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to edit budget configurations',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auth Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isEditing = authenticated;
      });
    }
  }

  void _addCategory() {
    setState(() {
      _categories.add(CategoryConfig(name: '', percentage: 0.0, note: ''));
      _calculateTotal();
    });
  }

  void _removeCategory(int index) {
    setState(() {
      _categories.removeAt(index);
      _calculateTotal();
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _calculateTotal(); // Ensure total is fresh

      if ((_currentTotal - 100.0).abs() > 0.1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Total must be exactly 100% (Current: ${_currentTotal.toStringAsFixed(1)}%)',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      try {
        await _settingsService.setPercentageConfig(
          PercentageConfig(categories: _categories),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine status color for total
    Color statusColor = Colors.redAccent;
    if ((_currentTotal - 100.0).abs() < 0.1)
      statusColor = Colors.greenAccent;
    else if (_currentTotal < 100)
      statusColor = Colors.orangeAccent;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Configurations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.lock_outline),
              onPressed: _authenticate,
              tooltip: 'Unlock to Edit',
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addCategory,
              tooltip: 'Add Bucket',
            ),
            IconButton(
              icon: const Icon(Icons.lock_open, color: Colors.orangeAccent),
              onPressed: () => setState(() => _isEditing = false),
              tooltip: 'Lock Editing',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: ModernLoader())
          : Column(
              children: [
                // --- Status Header (View Mode) ---
                if (!_isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "View Only Mode. Tap the lock to edit allocations.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // --- List Area ---
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        100,
                      ), // Space for bottom bar
                      itemCount: _categories.length,
                      buildDefaultDragHandles: _isEditing,
                      onReorder: (oldIndex, newIndex) {
                        if (!_isEditing) return;
                        setState(() {
                          if (oldIndex < newIndex) newIndex -= 1;
                          final item = _categories.removeAt(oldIndex);
                          _categories.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildProfessionalRow(index);
                      },
                    ),
                  ),
                ),
              ],
            ),

      // --- Sticky Bottom Action Bar (Edit Mode) ---
      bottomNavigationBar: _isEditing
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _bgColor,
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Allocation:",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        "${_currentTotal.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentTotal / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildProfessionalRow(int index) {
    return Container(
      key: ValueKey(_categories[index]),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- ROW 1: Name and Controls ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Row(
              children: [
                // Icon based on editing state
                Icon(
                  _isEditing ? Icons.drag_indicator : Icons.label_outline,
                  color: Colors.white30,
                  size: 20,
                ),
                const SizedBox(width: 12),

                // NAME INPUT (Expanded)
                Expanded(
                  child: TextFormField(
                    initialValue: _categories[index].name,
                    enabled: _isEditing,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Enter Bucket Name',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                    onChanged: (val) => _categories[index].name = val,
                    onSaved: (val) => _categories[index].name = val!,
                  ),
                ),

                // Delete Button
                if (_isEditing)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () => _removeCategory(index),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),

          // Divider
          Divider(color: Colors.white.withOpacity(0.05), height: 1),

          // --- ROW 2: Percentage and Note ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PERCENTAGE BOX
                Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accentColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ALLOCATION",
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _categories[index].percentage
                                  .toStringAsFixed(0),
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty &&
                                    double.tryParse(val) != null) {
                                  _categories[index].percentage = double.parse(
                                    val,
                                  );
                                  _calculateTotal(); // Update bottom bar instantly
                                }
                              },
                              onSaved: (val) => _categories[index].percentage =
                                  double.parse(val!),
                            ),
                          ),
                          const Text(
                            "%",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // NOTE INPUT
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      initialValue: _categories[index].note,
                      enabled: _isEditing,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add a description...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        icon: Icon(
                          Icons.notes,
                          color: Colors.white24,
                          size: 18,
                        ),
                      ),
                      onChanged: (val) => _categories[index].note = val,
                      onSaved: (val) => _categories[index].note = val ?? '',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

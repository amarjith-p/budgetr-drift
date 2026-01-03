import 'package:flutter/material.dart';
import '../../../core/constants/bank_list.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';

class DashboardAccountConfigSheet extends StatefulWidget {
  const DashboardAccountConfigSheet({super.key});

  @override
  State<DashboardAccountConfigSheet> createState() =>
      _DashboardAccountConfigSheetState();
}

class _DashboardAccountConfigSheetState
    extends State<DashboardAccountConfigSheet> {
  List<ExpenseAccountModel> _accounts = [];
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final stream = ExpenseService().getAccounts();
    stream.first.then((accounts) {
      if (mounted) {
        setState(() {
          // Sort initially: Dashboard accounts first (by order), then hidden accounts
          accounts.sort((a, b) {
            if (a.showOnDashboard && !b.showOnDashboard) return -1;
            if (!a.showOnDashboard && b.showOnDashboard) return 1;
            if (a.showOnDashboard && b.showOnDashboard) {
              return a.dashboardOrder.compareTo(b.dashboardOrder);
            }
            return 0;
          });
          _accounts = accounts;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _saveConfig() async {
    setState(() => _isLoading = true);

    // Update dashboardOrder based on current list index
    final List<ExpenseAccountModel> updatedAccounts = [];
    for (int i = 0; i < _accounts.length; i++) {
      updatedAccounts.add(_accounts[i].copyWith(dashboardOrder: i));
    }

    try {
      await ExpenseService().updateDashboardConfig(updatedAccounts);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _accounts.removeAt(oldIndex);
      _accounts.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  void _toggleVisibility(int index, bool? value) {
    if (value == true) {
      // Check limit
      int currentCount = _accounts.where((a) => a.showOnDashboard).length;
      if (currentCount >= 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Maximum 6 accounts allowed on Dashboard")),
        );
        return;
      }
    }

    setState(() {
      _accounts[index] = _accounts[index].copyWith(showOnDashboard: value);
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int selectedCount = _accounts.where((a) => a.showOnDashboard).length;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          0, 16, 0, MediaQuery.of(context).viewInsets.bottom + 16),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Customize Dashboard",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "$selectedCount/6 Selected",
                  style: TextStyle(
                      color: selectedCount == 6
                          ? Colors.orangeAccent
                          : Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Select accounts for Dashboard display & drag to set order.",
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _accounts.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final account = _accounts[index];
                      // Determine accent color
                      final Color baseColor = account.color != 0
                          ? Color(account.color)
                          : const Color(0xFF1E1E1E);

                      return Container(
                        key: ValueKey(account.id),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: const Icon(Icons.drag_handle_rounded,
                              color: Colors.white24),
                          title: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    BankConstants.getBankLogoPath(
                                        account.bankName),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Icon(
                                        Icons.account_balance,
                                        size: 12,
                                        color: baseColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  account.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          trailing: Checkbox(
                            value: account.showOnDashboard,
                            activeColor: const Color(0xFF00B4D8),
                            checkColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => _toggleVisibility(index, val),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Action Buttons (Cancel & Save)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // CANCEL BUTTON
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // SAVE BUTTON
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (_isLoading || !_hasChanges) ? null : _saveConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white10,
                      disabledForegroundColor: Colors.white38,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text("Save Changes",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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

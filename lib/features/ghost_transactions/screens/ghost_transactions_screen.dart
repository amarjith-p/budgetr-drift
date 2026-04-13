import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:notification_listener_service/notification_listener_service.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/widgets/modern_app_bar.dart';
import '../../../core/widgets/futuristic_loader.dart';
import '../widgets/ghost_transaction_card.dart';
import '../services/ghost_listener_service.dart';

// --- IMPORTS FOR DAILY EXPENSE ROUTING ---
import '../../daily_expense/screens/new_expense_screen.dart';
import '../../daily_expense/models/expense_models.dart';

class GhostTransactionsScreen extends StatefulWidget {
  const GhostTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<GhostTransactionsScreen> createState() =>
      _GhostTransactionsScreenState();
}

class _GhostTransactionsScreenState extends State<GhostTransactionsScreen> {
  final AppDatabase _db = locator<AppDatabase>();
  bool _hasNotificationPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool status = await NotificationListenerService.isPermissionGranted();
    if (mounted) {
      setState(() {
        _hasNotificationPermission = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: SafeArea(
        // We moved the StreamBuilder up to wrap the Column,
        // so the AppBar knows if it should show the Clear All button.
        child: StreamBuilder<List<GhostTransactionEntry>>(
          stream: (_db.select(_db.ghostTransactions)
                ..where((tbl) => tbl.status.equals('PENDING'))
                ..orderBy([
                  (t) => drift.OrderingTerm(
                      expression: t.id, mode: drift.OrderingMode.desc)
                ]))
              .watch(),
          builder: (context, snapshot) {
            final ghosts = snapshot.data ?? [];
            final hasGhosts = ghosts.isNotEmpty;

            return Column(
              children: [
                ModernAppBar(
                  title: 'Ghost Transactions',
                  subtitle: 'Pending unverified entries',
                  onLeadingPressed: () => Navigator.pop(context),
                  // --- NEW: CLEAR ALL BUTTON ---
                  trailingIcon: hasGhosts ? Icons.delete_sweep_rounded : null,
                  onTrailingPressed: hasGhosts
                      ? () => _showClearAllSheet(ghosts.length)
                      : null,
                ),
                if (!_hasNotificationPermission) _buildPermissionBanner(),
                Expanded(
                  child: _buildListContent(snapshot, ghosts),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Extracted list building logic to keep the build method clean
  Widget _buildListContent(AsyncSnapshot<List<GhostTransactionEntry>> snapshot,
      List<GhostTransactionEntry> ghosts) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: FuturisticLoader());
    }
    if (ghosts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ghosts.length,
      itemBuilder: (context, index) {
        final ghost = ghosts[index];
        return GhostTransactionCard(
          ghost: ghost,
          onDelete: () => _showDeleteSheet(ghost),
          onConfirm: () => _routeToDailyExpense(ghost),
        );
      },
    );
  }

  // --- NEW: BULK CLEAR ALL BOTTOM SHEET ---
  void _showClearAllSheet(int count) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xff1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.delete_sweep_rounded,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              "Clear All Ghosts?",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Are you sure you want to dismiss all $count pending transactions? This will permanently clear your inbox.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.white60,
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _clearAllGhosts();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Clear All",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  // --- NEW: BULK DATABASE UPDATE ---
  Future<void> _clearAllGhosts() async {
    // This executes a single SQL query that instantly updates ALL pending rows to 'DISMISSED'
    await (_db.update(_db.ghostTransactions)
          ..where((tbl) => tbl.status.equals('PENDING')))
        .write(
            const GhostTransactionsCompanion(status: drift.Value('DISMISSED')));
  }

  // --- INDIVIDUAL DELETE BOTTOM SHEET ---
  void _showDeleteSheet(GhostTransactionEntry ghost) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xff1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.delete_forever_rounded,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              "Delete Ghost Transaction?",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Are you sure you want to permanently dismiss this background transaction? It cannot be recovered.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.white60,
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _updateStatus(ghost.id, 'DISMISSED');
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Delete",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

// --- DAILY EXPENSE ROUTING & SUCCESS BOTTOM SHEET ---
  Future<void> _routeToDailyExpense(GhostTransactionEntry ghost) async {
    String accountId = '';
    String? linkedCreditCardId;

    if (ghost.detectedAccountId != null) {
      if (ghost.isCreditCardMatch) {
        linkedCreditCardId = ghost.detectedAccountId;
      } else {
        accountId = ghost.detectedAccountId!;
      }
    }

    // --- UPDATED: Proper Type & Category Mapping ---
    String mappedType = 'Expense';
    String mappedCategory = 'Ghost Transaction';

    if (ghost.detectedType == 'Credit') {
      mappedType = 'Income';
    } else if (ghost.detectedType == 'Transfer') {
      // 'Transfer Out' triggers the Transfer segment control in NewExpenseScreen
      mappedType = 'Transfer Out';
      mappedCategory = 'Transfer';
    }

    final dummyTxn = ExpenseTransactionModel(
      id: 'ghost_temp_${ghost.id}',
      accountId: accountId,
      linkedCreditCardId: linkedCreditCardId,
      amount: ghost.detectedAmount ?? 0.0,
      date: ghost.detectedDate ?? DateTime.now(),
      type: mappedType, // Now safely passes Transfer Out
      category: mappedCategory, // Pre-sets the category to Transfer
      subCategory: 'General',
      bucket: 'Unallocated',
      notes: ghost.rawText,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewExpenseScreen(
          txnToEdit: dummyTxn,
          isDuplicate: true,
        ),
      ),
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xff1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.check_circle_rounded,
                size: 48, color: Colors.greenAccent),
            const SizedBox(height: 16),
            const Text(
              "Clear Ghost Entry?",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Did you successfully save this transaction to your ledger? If yes, we can clear it from your inbox.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.white60,
                    ),
                    child: const Text("No, Keep it"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _updateStatus(ghost.id, 'APPROVED');
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Yes, Clear it",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.privacy_tip_outlined,
                  color: Colors.blueAccent, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "To automatically catch background bank notifications, FinStack 360 requires Notification Access.",
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                foregroundColor: Colors.blueAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await GhostListenerService()
                    .checkAndRequestNotificationPermission();
                _checkPermissions();
              },
              child: const Text("Enable Access (App will restart)"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No pending ghost transactions.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    await (_db.update(_db.ghostTransactions)..where((tbl) => tbl.id.equals(id)))
        .write(GhostTransactionsCompanion(status: drift.Value(newStatus)));
  }
}

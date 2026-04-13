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

// --- NEW: Added WidgetsBindingObserver mixin ---
class _GhostTransactionsScreenState extends State<GhostTransactionsScreen>
    with WidgetsBindingObserver {
  final AppDatabase _db = locator<AppDatabase>();
  bool _hasNotificationPermission = true;

  @override
  void initState() {
    super.initState();
    // --- NEW: Register the lifecycle observer ---
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    // --- NEW: Clean up the observer ---
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- NEW: Listen for the app resuming from the Android settings ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The app just came back to the foreground. Re-verify the permission.
      _refreshPermissionUI();
    }
  }

  Future<void> _refreshPermissionUI() async {
    bool isGranted = await NotificationListenerService.isPermissionGranted();
    if (mounted) {
      setState(() {
        _hasNotificationPermission = isGranted;
      });

      // If they granted it in the settings, ensure the listener boots up immediately
      if (isGranted) {
        GhostListenerService().initializeListeners();
      }
    }
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

  Future<void> _clearAllGhosts() async {
    await (_db.update(_db.ghostTransactions)
          ..where((tbl) => tbl.status.equals('PENDING')))
        .write(
            const GhostTransactionsCompanion(status: drift.Value('DISMISSED')));
  }

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
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final partner = await _updateStatus(ghost, 'DISMISSED');
                      if (partner != null && mounted) {
                        _showPairResolutionSheet(partner, 'DISMISSED');
                      }
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

    String mappedType = 'Expense';
    String mappedCategory = 'Ghost Transaction';

    if (ghost.detectedType == 'Credit') {
      mappedType = 'Income';
    } else if (ghost.detectedType == 'Transfer') {
      mappedType = 'Transfer Out';
      mappedCategory = 'Transfer';
    }

    final dummyTxn = ExpenseTransactionModel(
      id: 'ghost_temp_${ghost.id}',
      accountId: accountId,
      linkedCreditCardId: linkedCreditCardId,
      amount: ghost.detectedAmount ?? 0.0,
      date: ghost.detectedDate ?? DateTime.now(),
      type: mappedType,
      category: mappedCategory,
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
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final partner = await _updateStatus(ghost, 'APPROVED');
                      if (partner != null && mounted) {
                        _showPairResolutionSheet(partner, 'APPROVED');
                      }
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

  void _showPairResolutionSheet(
      GhostTransactionEntry partner, String statusApplied) {
    String actionText = statusApplied == 'APPROVED' ? 'saved' : 'deleted';

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
            const Icon(Icons.sync_alt_rounded,
                size: 48, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              "Matching Transfer Found",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "We found the other half of this transfer from ${partner.detectedAccount ?? 'another account'}. Since you $actionText the first one, do you want to clear this one too?",
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
                    child: const Text("Keep it"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _updateStatus(partner, statusApplied);
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
                  "To automatically catch background transaction notifications, FinStack 360 requires The Notification Access.\n\nNote: We only read the title and body of transaction-related notifications, and we do not collect any personal data or share it with third parties.\n\nPlease grant access by selecting 'FinStack 360' in the list and toggle Allow Notification Access to ON.\n\nRESTART THE APP MANUALLY AFTER GRANTING PERMISSION.",
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
                // Removed the immediate _checkPermissions() call here because the
                // native intent now handles bridging and didChangeAppLifecycleState will catch the return
              },
              child: const Text("Allow Access"),
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

  Future<GhostTransactionEntry?> _updateStatus(
      GhostTransactionEntry ghost, String newStatus) async {
    await (_db.update(_db.ghostTransactions)
          ..where((tbl) => tbl.id.equals(ghost.id)))
        .write(GhostTransactionsCompanion(status: drift.Value(newStatus)));

    if (ghost.detectedType == 'Transfer' && ghost.detectedAmount != null) {
      return await (_db.select(_db.ghostTransactions)
            ..where((tbl) =>
                tbl.detectedType.equals('Transfer') &
                tbl.detectedAmount.equals(ghost.detectedAmount!) &
                tbl.status.equals('PENDING') &
                tbl.id.equals(ghost.id).not())
            ..orderBy([
              (t) => drift.OrderingTerm(
                  expression: t.id, mode: drift.OrderingMode.desc)
            ])
            ..limit(1))
          .getSingleOrNull();
    }
    return null;
  }
}

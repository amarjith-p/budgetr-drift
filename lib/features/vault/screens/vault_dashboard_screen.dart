import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // [NEW] Required for swipe to delete
import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/modern_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/status_bottom_sheet.dart'; // [NEW] Required for delete confirmation
import '../services/vault_auth_service.dart';
import '../services/vault_encryption_service.dart';
import '../widgets/add_vault_item_sheet.dart';
import '../widgets/vault_settings_sheet.dart';

class VaultDashboardScreen extends StatefulWidget {
  const VaultDashboardScreen({super.key});

  @override
  State<VaultDashboardScreen> createState() => _VaultDashboardScreenState();
}

class _VaultDashboardScreenState extends State<VaultDashboardScreen>
    with WidgetsBindingObserver {
  final _db = locator<AppDatabase>();
  final _auth = locator<VaultAuthService>();
  final _encryption = locator<VaultEncryptionService>();

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _decryptedRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _auth.enableSecureMode();
    });

    WidgetsBinding.instance.addObserver(this);
    _loadAndDecryptData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_auth.pauseAutoLock) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _auth.lockVault();
      _auth.disableSecureMode();

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  Future<void> _loadAndDecryptData() async {
    if (!_auth.isVaultUnlocked) return;
    final rawRecords = await _db.select(_db.vaultRecords).get();

    List<Map<String, dynamic>> tempRecords = [];
    for (var record in rawRecords) {
      try {
        final decryptedJson = _encryption.decryptPayload(
            record.encryptedPayload, record.iv, _auth.activeKey!);
        tempRecords.add({
          'id': record.id,
          'title': record.title,
          'type': record.type,
          'data': jsonDecode(decryptedJson),
        });
      } catch (e) {
        debugPrint("Decryption error on record: ${record.id}");
      }
    }

    setState(() {
      _decryptedRecords = tempRecords;
      _filteredRecords = tempRecords;
    });
  }

  void _filterSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredRecords = _decryptedRecords
          .where((item) => item['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showAddSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddVaultItemSheet(),
    );
    if (result == true) _loadAndDecryptData();
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VaultSettingsSheet(),
    );
  }

  // [NEW] Handles the physical deletion from the Drift database
  Future<void> _deleteRecord(String recordId) async {
    await (_db.delete(_db.vaultRecords)
          ..where((tbl) => tbl.id.equals(recordId)))
        .go();
    _loadAndDecryptData(); // Refresh the list
  }

  // [NEW] Shows the confirmation bottom sheet (Same as PassiveIncomeHistorySheet)
  void _showDeleteSheet(BuildContext context, String recordId) {
    showStatusSheet(
      context: context,
      title: "Delete Record?",
      message:
          "This will permanently remove this encrypted record from your vault.",
      icon: Icons.delete_forever_rounded,
      color: Colors.redAccent,
      buttonText: "Delete",
      cancelButtonText: "Cancel",
      onCancel: () {},
      onDismiss: () async {
        await _deleteRecord(recordId);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Icon(
                _searchQuery.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.lock_outline_rounded,
                size: 48,
                color: Colors.white.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(_searchQuery.isNotEmpty ? "NO SECRETS FOUND" : "VAULT IS EMPTY",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(
              _searchQuery.isNotEmpty
                  ? "Try adjusting your search query."
                  : "Tap the add button below to securely store your first item.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _auth.lockVault();
        await _auth.disableSecureMode();
        return true;
      },
      child: Scaffold(
        backgroundColor: BudgetrColors.background,
        body: Stack(
          children: [
            Positioned(
                top: 50,
                right: -100,
                child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BudgetrColors.accent.withOpacity(0.08)))),
            Positioned(
                bottom: 100,
                left: -100,
                child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00E676).withOpacity(0.05)))),
            Positioned.fill(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: const SizedBox())),
            SafeArea(
              child: Column(
                children: [
                  ModernAppBar(
                    title: "Secure Vault",
                    subtitle: "ENCRYPTED STORAGE",
                    trailingIcon: Icons.lock_outline_rounded,
                    onTrailingPressed: () async {
                      _auth.lockVault();
                      await _auth.disableSecureMode();
                      if (mounted) Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.05)),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              onChanged: _filterSearch,
                              decoration: InputDecoration(
                                hintText: "Search Vault...",
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.3)),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.white38),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          _filterSearch("");
                                        },
                                        child: const Icon(Icons.close,
                                            color: Colors.white38, size: 18),
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _showSettingsSheet,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.05)),
                            ),
                            child: const Icon(Icons.settings_rounded,
                                color: Colors.white70, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredRecords.isEmpty
                        ? _buildEmptyState()
                        // [NEW] Wrapped in SlidableAutoCloseBehavior
                        : SlidableAutoCloseBehavior(
                            child: ListView.separated(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 16, bottom: 100),
                              itemCount: _filteredRecords.length,
                              // [NEW] Handled spacing with separatorBuilder instead of margins on cards
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final item = _filteredRecords[index];
                                final isCard = item['type'] == 'CARD';
                                final data =
                                    item['data'] as Map<String, dynamic>;

                                return Slidable(
                                  key: ValueKey(item['id']),

                                  // [NEW] Right-side delete action pane
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    extentRatio: 0.25,
                                    children: [
                                      const SizedBox(
                                          width: 8), // Padding spacer
                                      SlidableAction(
                                        onPressed: (_) => _showDeleteSheet(
                                            context, item['id']),
                                        backgroundColor:
                                            const Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete_rounded,
                                        label: 'Delete',
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ],
                                  ),

                                  child: GlassCard(
                                    borderRadius: 16,
                                    margin: EdgeInsets
                                        .zero, // Removed bottom margin here
                                    padding: EdgeInsets.zero,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        tilePadding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 8),
                                        leading: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: BudgetrColors.accent
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: BudgetrColors.accent
                                                    .withOpacity(0.2)),
                                          ),
                                          child: Icon(
                                              isCard
                                                  ? Icons.credit_card_rounded
                                                  : Icons.vpn_key_rounded,
                                              color: BudgetrColors.accent,
                                              size: 22),
                                        ),
                                        title: Text(item['title'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                              isCard
                                                  ? "Card Details"
                                                  : "Account Credentials",
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  fontSize: 12)),
                                        ),
                                        iconColor: Colors.white,
                                        collapsedIconColor: Colors.white54,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                bottom: 20),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.black26,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.05)),
                                            ),
                                            child: Column(
                                              children: data.entries.map((e) {
                                                if (e.value
                                                    .toString()
                                                    .isEmpty) {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 12),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        width: 110,
                                                        child: Text(
                                                            e.key
                                                                .replaceAll(
                                                                    '_', ' ')
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                                color: BudgetrColors
                                                                    .accent
                                                                    .withOpacity(
                                                                        0.8),
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                letterSpacing:
                                                                    0.5)),
                                                      ),
                                                      Expanded(
                                                        child: SelectableText(
                                                            e.value.toString(),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: BudgetrColors.accent,
          elevation: 8,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add New",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0)),
          onPressed: _showAddSheet,
        ),
      ),
    );
  }
}

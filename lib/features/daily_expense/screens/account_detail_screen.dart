import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/constants/icon_constants.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';
import '../widgets/add_expense_txn_sheet.dart';

class AccountDetailScreen extends StatefulWidget {
  final ExpenseAccountModel account;
  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  // --- Filter States ---
  String _selectedType = 'All';
  String _sortOption = 'Newest';
  DateTimeRange? _dateRange;
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedBuckets = {};

  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF00B4D8);

  bool _isLoading = false;

  late Stream<List<TransactionCategoryModel>> _categoryStream;
  late Stream<List<ExpenseTransactionModel>> _transactionStream;

  @override
  void initState() {
    super.initState();
    _categoryStream = CategoryService().getCategories();
    _transactionStream =
        ExpenseService().getTransactionsForAccount(widget.account.id);
  }

  // --- SYNC LOGIC (Fixed for Correct Details & Linking) ---
  Future<void> _handleSync(List<ExpenseTransactionModel> transactions) async {
    // 1. Filter only unsynced Credit Card entries
    final creditEntries = transactions
        .where((t) =>
            t.linkedCreditCardId != null && t.linkedCreditCardId!.isNotEmpty)
        .toList();

    if (creditEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No transactions to sync.")));
      return;
    }

    // Confirm Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xff1B263B),
        title: const Text("Sync to Credit Tracker?",
            style: TextStyle(color: Colors.white)),
        content: Text(
            "This will move ${creditEntries.length} transactions to the Credit Tracker.\n\nNote: Transfers will be linked. If you delete them in Credit Tracker, the Bank deduction will also be removed.",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text("Sync Now",
                  style: TextStyle(color: Colors.cyanAccent))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      int successCount = 0;

      for (var txn in creditEntries) {
        String creditType = 'Expense';
        String finalNotes = txn.notes;
        String? linkedExpenseId;

        // Handle Transfer In (Payment from Bank)
        if (txn.type == 'Transfer In' || txn.type == 'Income') {
          creditType = 'Income';

          // 1. Find the Source Transaction ID (Bank Debit) for linking
          final sourceTxn = await ExpenseService().findLinkedTransfer(txn);
          if (sourceTxn != null) {
            linkedExpenseId = sourceTxn.id;
          }

          // 2. Generate Note with Source Details
          // We use 'txn' because in a "Transfer In", txn.transferAccountBankName IS the Source Bank Name.
          if (txn.type == 'Transfer In' &&
              txn.transferAccountBankName != null) {
            final sourceInfo =
                "Transfer from ${txn.transferAccountBankName} - ${txn.transferAccountName}";
            if (txn.notes.isEmpty) {
              finalNotes = sourceInfo;
            } else {
              finalNotes = "$sourceInfo. ${txn.notes}";
            }
          }
        }

        final creditTxn = CreditTransactionModel(
          id: '', // Auto-gen
          cardId: txn.linkedCreditCardId!,
          amount: txn.amount,
          date: txn.date,
          bucket: txn.bucket,
          type: creditType,
          category: txn.category,
          subCategory: txn.subCategory,
          notes: finalNotes,
          linkedExpenseId: linkedExpenseId, // Pass the link ID
        );

        // 3. Add to Credit Module
        await CreditService().addTransaction(creditTxn);

        // 4. Remove from Pool (Keep Bank Debit intact)
        await ExpenseService().deleteTransactionSingle(txn);

        successCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Successfully synced $successCount transactions!"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Sync Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if this is the Pool Account
    final isPoolAccount =
        widget.account.bankName == 'Credit Card Pool Account' ||
            widget.account.accountType == 'Credit Card';

    return StreamBuilder<List<TransactionCategoryModel>>(
      stream: _categoryStream,
      builder: (context, catSnapshot) {
        final Map<String, IconData> categoryIconMap = {};
        if (catSnapshot.hasData) {
          for (var cat in catSnapshot.data!) {
            if (cat.iconCode != null) {
              categoryIconMap[cat.name] =
                  IconConstants.getIconByCode(cat.iconCode!);
            }
          }
        }

        return Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.account.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  widget.account.bankName,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              StreamBuilder<List<ExpenseTransactionModel>>(
                stream: _transactionStream,
                builder: (context, snapshot) {
                  final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
                  final txns = snapshot.data ?? [];
                  return Row(
                    children: [
                      // SYNC BUTTON (Only for Pool Account)
                      if (isPoolAccount)
                        IconButton(
                          onPressed: hasData ? () => _handleSync(txns) : null,
                          icon: const Icon(Icons.sync_rounded,
                              color: Colors.cyanAccent),
                          tooltip: "Sync to Credit Tracker",
                        ),

                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          IconButton(
                            onPressed: hasData
                                ? () =>
                                    _openFilterSheet(context, snapshot.data!)
                                : null,
                            icon: const Icon(Icons.filter_list_rounded),
                            tooltip: "Filter Transactions",
                          ),
                          if (_hasActiveFilters)
                            Container(
                              margin: const EdgeInsets.all(10),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  if (_hasActiveFilters) _buildActiveFiltersList(),
                  Expanded(
                    child: StreamBuilder<List<ExpenseTransactionModel>>(
                      stream: _transactionStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: ModernLoader());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}",
                                  style: const TextStyle(color: Colors.red)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return isPoolAccount
                              ? _buildEmptyState(
                                  "All caught up! No unsynced entries.")
                              : _buildEmptyState("No transactions found.");
                        }

                        final filteredList = _applyFilters(snapshot.data!);
                        if (filteredList.isEmpty) {
                          return _buildEmptyState(
                              "No transactions match your filters.");
                        }

                        final grouped =
                            groupBy(filteredList, (ExpenseTransactionModel t) {
                          return DateFormat('MMMM yyyy')
                              .format(t.date.toDate());
                        });

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: grouped.length,
                          itemBuilder: (context, index) {
                            final month = grouped.keys.elementAt(index);
                            final txns = grouped[month]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    month,
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1),
                                  ),
                                ),
                                ...txns
                                    .map((t) => TransactionItem(
                                          txn: t,
                                          iconData:
                                              categoryIconMap[t.category] ??
                                                  Icons.category_outlined,
                                          onEdit: () => _handleEdit(context, t),
                                          onDelete: () =>
                                              _handleDeleteTransaction(
                                                  context, t),
                                        ))
                                    .toList(),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                    color: Colors.black54,
                    child: const Center(child: ModernLoader(size: 60))),
            ],
          ),
        );
      },
    );
  }

  // --- Logic Methods ---

  void _handleEdit(BuildContext context, ExpenseTransactionModel txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => AddExpenseTransactionSheet(txnToEdit: txn),
    );
  }

  void _handleDeleteTransaction(
      BuildContext context, ExpenseTransactionModel txn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff0D1B2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: const Text("Delete Transaction?",
            style: TextStyle(color: Colors.white)),
        content: Text(
            "This will permanently remove the transaction and update your account balance.",
            style: TextStyle(color: Colors.white.withOpacity(0.7))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await ExpenseService().deleteTransaction(txn);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Transaction deleted"),
                      backgroundColor: Colors.redAccent));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text("Delete",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Filtering & Helper Widgets ---

  List<ExpenseTransactionModel> _applyFilters(
      List<ExpenseTransactionModel> data) {
    var list = List<ExpenseTransactionModel>.from(data);
    if (_selectedType != 'All') {
      if (_selectedType == 'Transfer') {
        // Show both In and Out transfers
        list = list
            .where((t) => t.type == 'Transfer Out' || t.type == 'Transfer In')
            .toList();
      } else {
        list = list.where((t) => t.type == _selectedType).toList();
      }
    }
    if (_dateRange != null) {
      list = list.where((t) {
        final date = t.date.toDate();
        final end = _dateRange!.end
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
        return date.isAfter(_dateRange!.start) && date.isBefore(end);
      }).toList();
    }
    if (_selectedCategories.isNotEmpty) {
      list =
          list.where((t) => _selectedCategories.contains(t.category)).toList();
    }
    if (_selectedBuckets.isNotEmpty) {
      list = list.where((t) => _selectedBuckets.contains(t.bucket)).toList();
    }

    switch (_sortOption) {
      case 'Newest':
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Amount High':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Amount Low':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return list;
  }

  bool get _hasActiveFilters =>
      _selectedType != 'All' ||
      _dateRange != null ||
      _selectedCategories.isNotEmpty ||
      _selectedBuckets.isNotEmpty ||
      _sortOption != 'Newest';

  Widget _buildEmptyState(String msg) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off, size: 48, color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 16),
        Text(msg, style: TextStyle(color: Colors.white.withOpacity(0.5)))
      ]));

  void _openFilterSheet(
      BuildContext context, List<ExpenseTransactionModel> allTxns) {
    final uniqueCategories = allTxns.map((e) => e.category).toSet().toList()
      ..sort();
    final uniqueBuckets = allTxns.map((e) => e.bucket).toSet().toList()..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
              color: _bgColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: StatefulBuilder(
                builder: (ctx, setModalState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Filter & Sort",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedType = 'All';
                              _sortOption = 'Newest';
                              _dateRange = null;
                              _selectedCategories.clear();
                              _selectedBuckets.clear();
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text("Reset",
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Sort By"),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _sortChip("Newest", setModalState),
                          _sortChip("Oldest", setModalState),
                          _sortChip("Amount High", setModalState),
                          _sortChip("Amount Low", setModalState),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Type"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _typeButton("All", setModalState)),
                        const SizedBox(width: 6),
                        Expanded(child: _typeButton("Expense", setModalState)),
                        const SizedBox(width: 6),
                        Expanded(child: _typeButton("Income", setModalState)),
                        const SizedBox(width: 6),
                        Expanded(child: _typeButton("Transfer", setModalState)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Date Range"),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: _accentColor,
                                onPrimary: Colors.white,
                                surface: const Color(0xFF1B263B),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (range != null) {
                          setModalState(() => _dateRange = range);
                          setState(() => _dateRange = range);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.white54, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              _dateRange == null
                                  ? "All Time"
                                  : "${DateFormat('dd MMM yyyy').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            if (_dateRange != null)
                              GestureDetector(
                                onTap: () {
                                  setModalState(() => _dateRange = null);
                                  setState(() => _dateRange = null);
                                },
                                child: const Icon(Icons.close,
                                    color: Colors.white54, size: 18),
                              )
                            else
                              const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white24, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (uniqueBuckets.isNotEmpty) ...[
                      _buildSectionTitle("Buckets"),
                      const SizedBox(height: 12),
                      Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: uniqueBuckets
                              .map((b) => _bucketChip(b, setModalState))
                              .toList()),
                      const SizedBox(height: 24),
                    ],
                    if (uniqueCategories.isNotEmpty) ...[
                      _buildSectionTitle("Categories"),
                      const SizedBox(height: 12),
                      Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: uniqueCategories
                              .map((c) => _categoryChip(c, setModalState))
                              .toList()),
                      const SizedBox(height: 40),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Apply Filters",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      );

  Widget _sortChip(String label, StateSetter setModalState) {
    final isSelected = _sortOption == label;
    return GestureDetector(
      onTap: () {
        setModalState(() => _sortOption = label);
        setState(() => _sortOption = label);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _accentColor : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String label, StateSetter setModalState) {
    final isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () {
        setModalState(() => _selectedType = label);
        setState(() => _selectedType = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? _accentColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _accentColor : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? _accentColor : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String label, StateSetter setModalState) {
    final isSelected = _selectedCategories.contains(label);
    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (isSelected) {
            _selectedCategories.remove(label);
          } else {
            _selectedCategories.add(label);
          }
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _bucketChip(String label, StateSetter setModalState) {
    final isSelected = _selectedBuckets.contains(label);
    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (isSelected) {
            _selectedBuckets.remove(label);
          } else {
            _selectedBuckets.add(label);
          }
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersList() {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _selectedType = 'All';
              _sortOption = 'Newest';
              _dateRange = null;
              _selectedCategories.clear();
              _selectedBuckets.clear();
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Center(
                child: Text(
                  "Clear All",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          if (_selectedType != 'All')
            _buildFilterChip(
              _selectedType,
              () => setState(() => _selectedType = 'All'),
            ),
          if (_dateRange != null)
            _buildFilterChip(
              "${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM').format(_dateRange!.end)}",
              () => setState(() => _dateRange = null),
            ),
          ..._selectedCategories.map((c) => _buildFilterChip(c, () {
                setState(() => _selectedCategories.remove(c));
              })),
          ..._selectedBuckets.map((b) => _buildFilterChip("Bucket: $b", () {
                setState(() => _selectedBuckets.remove(b));
              })),
          if (_sortOption != 'Newest')
            _buildFilterChip(
              "Sort: $_sortOption",
              () => setState(() => _sortOption = 'Newest'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: _accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Icon(Icons.close, size: 16, color: _accentColor),
          ),
        ],
      ),
    );
  }
}

class TransactionItem extends StatefulWidget {
  final ExpenseTransactionModel txn;
  final IconData iconData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionItem({
    super.key,
    required this.txn,
    required this.iconData,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isExpense = widget.txn.type == 'Expense';
    final isTransferOut = widget.txn.type == 'Transfer Out';
    final isTransferIn = widget.txn.type == 'Transfer In';
    Color amountColor;
    Color iconColor;
    IconData icon;
    String title;
    String sign;

    if (isExpense) {
      amountColor = Colors.redAccent;
      iconColor = const Color(0xFF00B4D8);
      icon = widget.iconData;
      title = widget.txn.category;
      sign = '-';
    } else if (isTransferOut) {
      amountColor = Colors.orangeAccent;
      iconColor = Colors.orangeAccent;
      icon = Icons.arrow_outward_rounded;
      final bank = widget.txn.transferAccountBankName ?? '';
      final acc = widget.txn.transferAccountName ?? 'Account';
      title = bank.isNotEmpty ? "Transfer to $bank - $acc" : "Transfer to $acc";
      sign = '-';
    } else if (isTransferIn) {
      amountColor = Colors.greenAccent;
      iconColor = Colors.greenAccent;
      icon = Icons.arrow_downward_rounded;
      final bank = widget.txn.transferAccountBankName ?? '';
      final acc = widget.txn.transferAccountName ?? 'Account';
      title =
          bank.isNotEmpty ? "Transfer from $bank - $acc" : "Transfer from $acc";
      sign = '+';
    } else {
      amountColor = Colors.greenAccent;
      iconColor = Colors.green;
      icon = widget.iconData;
      title = widget.txn.category;
      sign = '+';
    }

    final bool hasSummary = (isExpense && widget.txn.bucket.isNotEmpty) ||
        widget.txn.notes.isNotEmpty;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF1B263B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _isExpanded
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05)),
            boxShadow: _isExpanded
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : []),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(icon, color: iconColor, size: 20)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      if (widget.txn.subCategory.isNotEmpty &&
                          widget.txn.subCategory != 'General')
                        Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(widget.txn.subCategory,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("$sign ${currency.format(widget.txn.amount)}",
                        style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM').format(widget.txn.date.toDate()),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),

            // --- CHANGED: AnimatedCrossFade for Clean Toggle ---
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              // First Child: Summary Line (Visible when Collapsed)
              firstChild: hasSummary
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          top: 8, left: 56), // Align with title
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (isExpense && widget.txn.bucket.isNotEmpty)
                            _buildTag(widget.txn.bucket),
                          if (widget.txn.notes.isNotEmpty)
                            Text(
                              widget.txn.notes,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),

              // Second Child: Expanded Details (Visible when Expanded)
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, hh:mm a')
                            .format(widget.txn.date.toDate()),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                      if (isExpense && widget.txn.bucket.isNotEmpty)
                        _buildTag("Bucket: ${widget.txn.bucket}"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.txn.notes.isNotEmpty) ...[
                    Text("Notes:",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.txn.notes,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 20),
                  ],
                  Row(children: [
                    Expanded(
                        child: _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: "Edit",
                            color: Colors.white,
                            onTap: widget.onEdit)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildActionButton(
                            icon: Icons.delete_outline,
                            label: "Delete",
                            color: Colors.redAccent,
                            onTap: widget.onDelete))
                  ]),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
            // --------------------------------------------------------
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500)));

  Widget _buildActionButton(
          {required IconData icon,
          required String label,
          required Color color,
          required VoidCallback onTap}) =>
      InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2))),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13))
              ])));
}

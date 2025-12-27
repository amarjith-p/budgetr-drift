import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_loader.dart';
import '../models/investment_model.dart';
import '../services/investment_service.dart';
import '../widgets/add_investment_sheet.dart';
import '../widgets/investment_summary_card.dart';
import '../widgets/investment_list_item.dart';
import '../../custom_entry/services/custom_entry_service.dart';
import '../../../core/models/custom_data_models.dart';

enum SortOption {
  valueHighLow,
  valueLowHigh,
  nameAZ,
  returnHighLow,
  returnLowHigh,
}

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final _service = InvestmentService();
  final _customEntryService = CustomEntryService();

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  final _preciseFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  String _searchQuery = "";
  final Set<InvestmentType> _filterTypes = {};
  final Set<String> _filterBuckets = {};

  SortOption _currentSort = SortOption.valueHighLow;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service.refreshAllPrices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // --- Logic to Snapshot Portfolio Data ---
  Future<void> _handleRecordSnapshot(
    double invested,
    double current,
    double dayGain,
  ) async {
    // 1. VALIDATION: Block if Asset Type filter is selected
    if (_filterTypes.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Row(
              children: [
                Icon(Icons.block, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Snapshot not allowed for Asset Types.\nPlease use Bucket filters or view all.",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return; // STOP EXECUTION
    }

    // 2. Determine Template Name based on active filters
    String templateName = "Investment AutoTracker"; // Default

    if (_filterBuckets.isNotEmpty) {
      // Priority 1: Buckets (Multi-select)
      // Sort to ensure "A & B" is treated same as "B & A"
      final sortedBuckets = _filterBuckets.toList()..sort();
      templateName = "${sortedBuckets.join(' & ')} AutoTracker";
    }

    try {
      // 3. Ensure Template Exists (Get ID)
      final String templateId = await _customEntryService
          .ensureInvestmentTemplateExists(templateName);

      // 4. Calculate Derived Metrics
      final now = DateTime.now();
      final totalReturn = current - invested;
      final returnPercent = invested == 0
          ? 0.0
          : (totalReturn / invested) * 100;

      // 5. Check for Existing Record (Same Day)
      // CONSTRAINT: Only applicable for Investment AutoTrackers
      // This prevents accidental overwriting if logic is ever reused for manual sheets
      final bool isAutoTracker = templateName.endsWith("AutoTracker");
      CustomRecord? existingRecord;

      if (isAutoTracker) {
        final existingRecords = await _customEntryService.fetchCustomRecords(
          templateId,
        );
        try {
          existingRecord = existingRecords.firstWhere((r) {
            final rDate = r.data['Date'];
            if (rDate is DateTime) {
              return rDate.year == now.year &&
                  rDate.month == now.month &&
                  rDate.day == now.day;
            }
            return false;
          });
        } catch (e) {
          existingRecord = null; // Not found
        }
      }

      final recordData = {
        'Date': now,
        'Invested': invested,
        'Current Value': current,
        'Day Gain': dayGain,
        'Total Return': totalReturn,
        'Return %': double.parse(returnPercent.toStringAsFixed(2)),
      };

      if (existingRecord != null) {
        // OVERWRITE EXISTING (Only happens if isAutoTracker was true and record found)
        final updatedRecord = CustomRecord(
          id: existingRecord.id,
          templateId: existingRecord.templateId,
          createdAt: existingRecord.createdAt, // Keep original creation time
          data: recordData,
        );
        await _customEntryService.updateCustomRecord(updatedRecord);
      } else {
        // CREATE NEW
        final newRecord = CustomRecord(
          id: '', // Generated by Firestore
          templateId: templateId,
          createdAt: now,
          data: recordData,
        );
        await _customEntryService.addCustomRecord(newRecord);
      }

      // 6. Feedback
      if (mounted) {
        final message = existingRecord != null
            ? "Snapshot updated for today in '$templateName'"
            : "Snapshot added to '$templateName'";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2EC4B6),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            content: Text("Error recording data: $e"),
          ),
        );
      }
    }
  }

  void _showOptionsSheet(InvestmentRecord item) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text(
                "Edit Asset",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddSheet(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                "Delete Asset",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteRecord(item.id);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddSheet([InvestmentRecord? record]) {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddInvestmentSheet(recordToEdit: record),
    );
  }

  Future<void> _deleteRecord(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff0D1B2A),
        title: const Text(
          "Delete Asset?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) await _service.deleteInvestment(id);
  }

  // --- Filter Sheet ---
  void _showFilterSheet(List<String> availableBuckets) {
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter & Sort",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _searchFocusNode.unfocus();

                      setSheetState(() {
                        _filterTypes.clear();
                        _filterBuckets.clear();
                        _currentSort = SortOption.valueHighLow;
                      });
                      setState(() {});

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "RESET",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),

              _buildSectionTitle("Sort By"),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: [
                  _buildSortChip(
                    "Value (Hi-Lo)",
                    SortOption.valueHighLow,
                    setSheetState,
                  ),
                  _buildSortChip(
                    "Value (Lo-Hi)",
                    SortOption.valueLowHigh,
                    setSheetState,
                  ),
                  _buildSortChip(
                    "Name (A-Z)",
                    SortOption.nameAZ,
                    setSheetState,
                  ),
                  _buildSortChip(
                    "Returns %",
                    SortOption.returnHighLow,
                    setSheetState,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Asset Type (Multi-Select)"),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(
                    "Stocks",
                    InvestmentType.stock,
                    setSheetState,
                  ),
                  _buildFilterChip(
                    "Mutual Funds",
                    InvestmentType.mutualFund,
                    setSheetState,
                  ),
                  _buildFilterChip(
                    "Others",
                    InvestmentType.other,
                    setSheetState,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (availableBuckets.isNotEmpty) ...[
                _buildSectionTitle("Bucket / Goal (Multi-Select)"),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableBuckets
                      .map(
                        (b) => FilterChip(
                          label: Text(b),
                          selected: _filterBuckets.contains(b),
                          onSelected: (s) {
                            setSheetState(() {
                              if (s) {
                                _filterBuckets.add(b);
                              } else {
                                _filterBuckets.remove(b);
                              }
                            });
                            setState(() {});
                          },
                          backgroundColor: Colors.white10,
                          selectedColor: const Color(0xFFFF9F1C),
                          checkmarkColor: Colors.black,
                          labelStyle: TextStyle(
                            color: _filterBuckets.contains(b)
                                ? Colors.black
                                : Colors.white70,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 32),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A86FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _searchFocusNode.unfocus();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "APPLY VIEW",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _buildSortChip(
    String label,
    SortOption option,
    StateSetter setSheetState,
  ) {
    final isSelected = _currentSort == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setSheetState(() => _currentSort = option);
          setState(() {});
        }
      },
      backgroundColor: Colors.white.withOpacity(0.05),
      selectedColor: const Color(0xFF3A86FF),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    InvestmentType type,
    StateSetter setSheetState,
  ) {
    final isSelected = _filterTypes.contains(type);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (s) {
        setSheetState(() {
          if (s) {
            _filterTypes.add(type);
          } else {
            _filterTypes.remove(type);
          }
        });
        setState(() {});
      },
      backgroundColor: Colors.white.withOpacity(0.05),
      selectedColor: const Color(0xFF3A86FF),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter =
        _filterTypes.isNotEmpty || _filterBuckets.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Investment Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () async {
                  final buckets = await _service.getUniqueBuckets();
                  _showFilterSheet(buckets);
                },
              ),
              if (hasActiveFilter)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9F1C),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _service.refreshAllPrices();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Updating Prices...")),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          _searchFocusNode.unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  hintText: "Search portfolio...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

            Expanded(
              child: StreamBuilder<List<InvestmentRecord>>(
                stream: _service.getInvestments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: ModernLoader());
                  }

                  var records = snapshot.data ?? [];

                  // --- 1. FILTER LOGIC ---
                  if (_searchQuery.isNotEmpty) {
                    records = records
                        .where(
                          (r) => r.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();
                  }
                  if (_filterTypes.isNotEmpty) {
                    records = records
                        .where((r) => _filterTypes.contains(r.type))
                        .toList();
                  }
                  if (_filterBuckets.isNotEmpty) {
                    records = records
                        .where((r) => _filterBuckets.contains(r.bucket))
                        .toList();
                  }

                  // --- 2. CALCULATE TOTALS ---
                  final totalInvested = records.fold(
                    0.0,
                    (sum, item) => sum + item.totalInvested,
                  );
                  final totalCurrent = records.fold(
                    0.0,
                    (sum, item) => sum + item.currentValue,
                  );
                  final totalDayGain = records.fold(
                    0.0,
                    (sum, item) => sum + item.dayReturn,
                  );

                  // --- 3. SORT ---
                  records.sort((a, b) {
                    switch (_currentSort) {
                      case SortOption.valueHighLow:
                        return b.currentValue.compareTo(a.currentValue);
                      case SortOption.valueLowHigh:
                        return a.currentValue.compareTo(b.currentValue);
                      case SortOption.nameAZ:
                        return a.name.compareTo(b.name);
                      case SortOption.returnHighLow:
                        return b.returnPercentage.compareTo(a.returnPercentage);
                      case SortOption.returnLowHigh:
                        return a.returnPercentage.compareTo(b.returnPercentage);
                    }
                  });

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: InvestmentSummaryCard(
                          invested: totalInvested,
                          current: totalCurrent,
                          dayGain: totalDayGain,
                          currencyFormat: _currencyFormat,
                          records: records, // Pass filtered records
                          onRecordData: _handleRecordSnapshot, // New Handler
                        ),
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: records.isEmpty
                            ? Center(
                                child: Text(
                                  "No Assets Found",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  100,
                                ),
                                itemCount: records.length,
                                itemBuilder: (context, index) {
                                  final item = records[index];
                                  return InvestmentListItem(
                                    key: ValueKey(item.id),
                                    item: item,
                                    currencyFormat: _currencyFormat,
                                    preciseFormat: _preciseFormat,
                                    onOptions: () => _showOptionsSheet(item),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(),
        backgroundColor: const Color(0xFF3A86FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

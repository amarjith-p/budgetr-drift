import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/calculator_keyboard.dart';
import '../models/investment_model.dart';
import '../models/search_result_model.dart';
import '../services/investment_service.dart';

class AddInvestmentSheet extends StatefulWidget {
  final InvestmentRecord? recordToEdit;
  const AddInvestmentSheet({super.key, this.recordToEdit});

  @override
  State<AddInvestmentSheet> createState() => _AddInvestmentSheetState();
}

class _AddInvestmentSheetState extends State<AddInvestmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _service = InvestmentService();
  Timer? _debounce;

  // Data State
  late InvestmentType _selectedType;
  DateTime _purchaseDate = DateTime.now();
  InvestmentSearchResult? _selectedAsset;
  bool _isSelectionValid = false;
  double _capturedPreviousClose = 0.0; // Day Gain Logic

  // UI State
  bool _isSearching = false;
  List<InvestmentSearchResult> _searchResults = [];
  bool _showResults = false;

  // Keyboard State
  bool _showCustomKeyboard = false;
  bool _systemKeyboardActive = false;
  TextEditingController? _activeMathController;
  FocusNode? _activeFocusNode;

  // Controllers
  final _searchController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalController = TextEditingController();
  final _currentPriceController = TextEditingController();
  final _bucketController = TextEditingController();

  // Focus Nodes
  final _searchFocus = FocusNode(); // ADDED: To navigate back to search
  final _qtyFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _totalFocus = FocusNode();
  final _currentPriceFocus = FocusNode();
  FocusNode? _bucketFocusNode; // For transition

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      final r = widget.recordToEdit!;
      _selectedType = r.type;
      _purchaseDate = r.lastPurchasedDate;
      _searchController.text = r.name;
      _qtyController.text = r.quantity.toString();
      _priceController.text = r.averagePrice.toString();
      _totalController.text = (r.quantity * r.averagePrice).toStringAsFixed(2);
      _currentPriceController.text = r.currentPrice.toString();
      _bucketController.text = r.bucket;
      _capturedPreviousClose = r.previousClose;

      _selectedAsset = InvestmentSearchResult(
        symbol: r.symbol,
        name: r.name,
        type: "",
        exchange: "",
      );
      _isSelectionValid = true;
    } else {
      _selectedType = InvestmentType.stock;
    }

    _qtyController.addListener(_calcTotal);
    _priceController.addListener(_calcTotal);
    _totalController.addListener(_calcReverse);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _qtyController.removeListener(_calcTotal);
    _priceController.removeListener(_calcTotal);
    _totalController.removeListener(_calcReverse);

    _searchController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    _currentPriceController.dispose();
    _bucketController.dispose();

    _searchFocus.dispose();
    _qtyFocus.dispose();
    _priceFocus.dispose();
    _totalFocus.dispose();
    _currentPriceFocus.dispose();
    super.dispose();
  }

  // --- 1. KEYBOARD & SCROLL LOGIC ---

  void _scrollToInput(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null && mounted) {
        Scrollable.ensureVisible(
          node.context!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onFieldTap(TextEditingController controller, FocusNode node) {
    if (_systemKeyboardActive) return;

    FocusScope.of(context).requestFocus(node);

    setState(() {
      _activeMathController = controller;
      _activeFocusNode = node;
      _showCustomKeyboard = true;
    });

    _scrollToInput(node);
  }

  void _handleKeyboardClose() {
    setState(() {
      _showCustomKeyboard = false;
      _activeMathController = null;
      _activeFocusNode = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _switchToSystem() {
    setState(() {
      _showCustomKeyboard = false;
      _systemKeyboardActive = true;
    });

    if (_activeFocusNode != null) {
      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(_activeFocusNode);
      });
    }
  }

  void _handleNextField() {
    if (_activeMathController == _qtyController) {
      _onFieldTap(_priceController, _priceFocus);
    } else if (_activeMathController == _priceController) {
      _onFieldTap(_totalController, _totalFocus);
    } else if (_activeMathController == _totalController) {
      _onFieldTap(_currentPriceController, _currentPriceFocus);
    } else if (_activeMathController == _currentPriceController) {
      // Transition to Bucket (System Keyboard)
      setState(() {
        _showCustomKeyboard = false;
        _activeMathController = null;
        _activeFocusNode = null;
      });

      if (_bucketFocusNode != null) {
        FocusScope.of(context).requestFocus(_bucketFocusNode);
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  // --- ADDED: Previous Field Logic ---
  void _handlePreviousField() {
    if (_activeMathController == _currentPriceController) {
      _onFieldTap(_totalController, _totalFocus);
    } else if (_activeMathController == _totalController) {
      _onFieldTap(_priceController, _priceFocus);
    } else if (_activeMathController == _priceController) {
      _onFieldTap(_qtyController, _qtyFocus);
    } else if (_activeMathController == _qtyController) {
      // Transition back to Search (System Keyboard)
      if (widget.recordToEdit == null) {
        // Only if not editing, as search is disabled in edit mode
        setState(() {
          _showCustomKeyboard = false;
          _activeMathController = null;
          _activeFocusNode = null;
        });
        FocusScope.of(context).requestFocus(_searchFocus);
        _scrollToInput(_searchFocus);
      } else {
        // If editing, just close keyboard or do nothing
        _handleKeyboardClose();
      }
    }
  }

  // --- 2. MATH LOGIC ---
  void _calcTotal() {
    if (_qtyFocus.hasFocus || _priceFocus.hasFocus) {
      double qty = double.tryParse(_qtyController.text) ?? 0;
      double price = double.tryParse(_priceController.text) ?? 0;
      if (qty > 0 && price > 0) {
        String total = (qty * price).toStringAsFixed(2);
        if (_totalController.text != total) {
          _totalController.value = TextEditingValue(
            text: total,
            selection: TextSelection.collapsed(offset: total.length),
          );
        }
      }
    }
  }

  void _calcReverse() {
    if (_totalFocus.hasFocus) {
      double total = double.tryParse(_totalController.text) ?? 0;
      double qty = double.tryParse(_qtyController.text) ?? 0;
      double price = double.tryParse(_priceController.text) ?? 0;

      if (qty > 0) {
        String newPrice = (total / qty).toStringAsFixed(2);
        if (_priceController.text != newPrice) {
          _priceController.value = TextEditingValue(text: newPrice);
        }
      } else if (price > 0) {
        String newQty = (total / price).toStringAsFixed(4);
        if (_qtyController.text != newQty) {
          _qtyController.value = TextEditingValue(text: newQty);
        }
      }
    }
  }

  // --- 3. SEARCH & SAVE ---
  void _onSearchChanged(String query) {
    if (widget.recordToEdit != null) return;

    if (_showCustomKeyboard) setState(() => _showCustomKeyboard = false);

    if (_selectedType == InvestmentType.other) {
      _isSelectionValid = query.isNotEmpty;
    } else {
      if (_isSelectionValid && query != _selectedAsset?.name) {
        setState(() => _isSelectionValid = false);
      }
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 2) {
        if (mounted) setState(() => _showResults = false);
        return;
      }

      setState(() => _isSearching = true);
      final results = await _service.searchSymbols(query, _selectedType);

      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = results;
          _showResults = results.isNotEmpty;
        });
      }
    });
  }

  Future<void> _selectResult(InvestmentSearchResult item) async {
    setState(() {
      _selectedAsset = item;
      _searchController.text = item.name;
      _showResults = false;
      _isSelectionValid = true;
      if (_selectedType != InvestmentType.other) {
        _onFieldTap(_qtyController, _qtyFocus);
      }
    });

    if (_selectedType != InvestmentType.other) {
      final data = await _service.fetchPriceData(item.symbol, _selectedType);
      if (mounted) {
        setState(() {
          _isSearching = false;
          _currentPriceController.text = data['price'].toString();
          _capturedPreviousClose = data['prev']!;
          if (_priceController.text.isEmpty)
            _priceController.text = data['price'].toString();
        });
      }
    } else {
      final existing = await _service.findExactMatch(item.symbol, 'General');
      if (existing != null && mounted) {
        _currentPriceController.text = existing.currentPrice.toString();
        _capturedPreviousClose = existing.previousClose;
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == InvestmentType.other && _selectedAsset == null) {
      _selectedAsset = InvestmentSearchResult(
        symbol: _searchController.text.toUpperCase(),
        name: _searchController.text,
        type: "OTHER",
        exchange: "MANUAL",
      );
    }

    if (_selectedType == InvestmentType.other && _capturedPreviousClose == 0) {
      _capturedPreviousClose =
          double.tryParse(_currentPriceController.text) ?? 0;
    }

    final bucket = _bucketController.text.isEmpty
        ? 'General'
        : _bucketController.text;

    final newRecord = InvestmentRecord(
      id: widget.recordToEdit?.id ?? '',
      symbol: _selectedAsset!.symbol,
      name: _selectedAsset!.name,
      type: _selectedType,
      quantity: double.parse(_qtyController.text),
      averagePrice: double.parse(_priceController.text),
      currentPrice: double.parse(_currentPriceController.text),
      previousClose: _capturedPreviousClose,
      bucket: bucket,
      lastPurchasedDate: _purchaseDate,
      lastUpdated: DateTime.now(),
    );

    if (widget.recordToEdit != null) {
      await _service.updateInvestment(newRecord);
    } else {
      final existing = await _service.findExactMatch(newRecord.symbol, bucket);
      if (existing != null) {
        await _service.mergeInvestment(existing, newRecord);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Merged with existing ${existing.name}")),
          );
      } else {
        await _service.addInvestment(newRecord);
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        top: 20,
        bottom: _showCustomKeyboard
            ? 0
            : MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff0D1B2A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    if (widget.recordToEdit == null)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTypeSegment("Stocks", InvestmentType.stock),
                            _buildTypeSegment("MF", InvestmentType.mutualFund),
                            _buildTypeSegment("Others", InvestmentType.other),
                          ],
                        ),
                      ),
                    if (widget.recordToEdit == null) const SizedBox(height: 24),

                    _buildLabel(
                      _selectedType == InvestmentType.other
                          ? "Asset Name"
                          : "Search Asset",
                    ),
                    TextFormField(
                      controller: _searchController,
                      focusNode: _searchFocus, // ADDED: Assigned FocusNode
                      enabled: widget.recordToEdit == null,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("eg. Gold, Bitcoin...")
                          .copyWith(
                            suffixIcon: _isSearching
                                ? Transform.scale(
                                    scale: 0.4,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : (_isSelectionValid
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.greenAccent,
                                        )
                                      : const Icon(
                                          Icons.search,
                                          color: Colors.white54,
                                        )),
                            focusedBorder: _isSelectionValid
                                ? OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.greenAccent,
                                    ),
                                  )
                                : null,
                          ),
                      onTap: () {
                        if (_showCustomKeyboard) _handleKeyboardClose();
                      },
                      onChanged: _onSearchChanged,
                      validator: (v) => v!.isEmpty ? "Name is required" : null,
                    ),

                    if (_showResults && _searchResults.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B263B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.white.withOpacity(0.05),
                          ),
                          itemBuilder: (ctx, i) {
                            final item = _searchResults[i];
                            return ListTile(
                              dense: true,
                              title: Text(
                                item.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                item.type == "OTHER"
                                    ? "Local Asset"
                                    : "${item.exchange} • ${item.symbol}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              onTap: () => _selectResult(item),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),

                    _buildLabel("Purchase Date"),
                    GestureDetector(
                      onTap: () async {
                        _handleKeyboardClose();
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _purchaseDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) =>
                              Theme(data: ThemeData.dark(), child: child!),
                        );
                        if (d != null) setState(() => _purchaseDate = d);
                      },
                      child: Container(
                        width: double.infinity,
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
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_purchaseDate),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- NUMERIC FIELDS ---
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Qty"),
                              TextFormField(
                                controller: _qtyController,
                                focusNode: _qtyFocus,
                                readOnly: !_systemKeyboardActive,
                                showCursor: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onTap: () =>
                                    _onFieldTap(_qtyController, _qtyFocus),
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration("0"),
                                validator: (v) => v!.isEmpty ? "Req" : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Avg Price"),
                              TextFormField(
                                controller: _priceController,
                                focusNode: _priceFocus,
                                readOnly: !_systemKeyboardActive,
                                showCursor: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onTap: () =>
                                    _onFieldTap(_priceController, _priceFocus),
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration("₹ 0.0"),
                                validator: (v) => v!.isEmpty ? "Req" : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Total Buy Value"),
                              TextFormField(
                                controller: _totalController,
                                focusNode: _totalFocus,
                                readOnly: !_systemKeyboardActive,
                                showCursor: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onTap: () =>
                                    _onFieldTap(_totalController, _totalFocus),
                                style: const TextStyle(
                                  color: Color(0xFF4CC9F0),
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: _inputDecoration("₹ 0.0"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Current Price/Unit"),
                              TextFormField(
                                controller: _currentPriceController,
                                focusNode: _currentPriceFocus,
                                readOnly: !_systemKeyboardActive,
                                showCursor: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onTap: () => _onFieldTap(
                                  _currentPriceController,
                                  _currentPriceFocus,
                                ),
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration("₹ 0.0"),
                                validator: (v) =>
                                    (double.tryParse(v ?? '') ?? 0) > 0
                                    ? null
                                    : "Invalid",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Bucket (Goal)"),
                    Autocomplete<String>(
                      optionsBuilder: (textEditingValue) async {
                        final buckets = await _service.getUniqueBuckets();
                        return buckets.where(
                          (b) => b.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                        );
                      },
                      onSelected: (val) => _bucketController.text = val,
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmitted) {
                            _bucketFocusNode = focusNode; // CAPTURE
                            if (_bucketController.text.isNotEmpty &&
                                controller.text.isEmpty) {
                              controller.text = _bucketController.text;
                            }
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration("e.g. Retirement"),
                              onTap: () => _handleKeyboardClose(),
                              onChanged: (v) => _bucketController.text = v,
                            );
                          },
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSelectionValid
                              ? const Color(0xFF3A86FF)
                              : Colors.grey.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isSelectionValid ? _handleSave : null,
                        child: Text(
                          widget.recordToEdit != null
                              ? "UPDATE"
                              : "ADD TO PORTFOLIO",
                          style: TextStyle(
                            color: _isSelectionValid
                                ? Colors.white
                                : Colors.white38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // --- CUSTOM KEYBOARD ---
          if (_showCustomKeyboard && _activeMathController != null)
            CalculatorKeyboard(
              onKeyPress: (val) {
                CalculatorKeyboard.handleKeyPress(_activeMathController!, val);
              },
              onBackspace: () =>
                  CalculatorKeyboard.handleBackspace(_activeMathController!),
              onClear: () => _activeMathController!.clear(),
              onEquals: () =>
                  CalculatorKeyboard.handleEquals(_activeMathController!),
              onClose: _handleKeyboardClose,
              onSwitchToSystem: _switchToSystem,
              onNext: _handleNextField,
              onPrevious: _handlePreviousField, // ADDED
            ),
        ],
      ),
    );
  }

  Widget _buildTypeSegment(String title, InvestmentType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedType = type;
          _isSelectionValid = false;
          _searchController.clear();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3A86FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

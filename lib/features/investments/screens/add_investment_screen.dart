import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class AddInvestmentScreen extends StatefulWidget {
  final InvestmentDto? investmentToEdit;

  const AddInvestmentScreen({super.key, this.investmentToEdit});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  late TextEditingController _nameController;
  late TextEditingController _providerController;
  late TextEditingController _websiteController;
  late TextEditingController _amountController;
  late TextEditingController _returnController;
  late TextEditingController _otherTypeController;
  late TextEditingController _folioController;
  late TextEditingController _unitsController;
  late TextEditingController _brokerController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountController;
  late TextEditingController _purposeController;
  late TextEditingController _notesController;
  late TextEditingController _specialIdController;
  late TextEditingController _targetAmountController;

  // --- Focus Nodes (For 'Next' Keyboard Action) ---
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _otherTypeFocus = FocusNode();
  final FocusNode _providerFocus = FocusNode();
  final FocusNode _websiteFocus = FocusNode();
  final FocusNode _specialIdFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _targetFocus = FocusNode();
  final FocusNode _returnFocus = FocusNode();
  final FocusNode _folioFocus = FocusNode();
  final FocusNode _unitsFocus = FocusNode();
  final FocusNode _brokerFocus = FocusNode();
  final FocusNode _bankNameFocus = FocusNode();
  final FocusNode _bankAccFocus = FocusNode();
  final FocusNode _purposeFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  // --- State ---
  InvestmentType? _selectedType;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isEditMode = false;

  // [NEW] Smart Warning State
  bool _userDismissedWarning = false;
  bool _isProjectionReady = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.investmentToEdit != null;

    final item = widget.investmentToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _providerController = TextEditingController(text: item?.providerName ?? '');
    _websiteController =
        TextEditingController(text: item?.providerWebsite ?? '');
    _amountController = TextEditingController(text: item != null ? '0.00' : '');
    _returnController =
        TextEditingController(text: item?.expectedReturn?.toString() ?? '');
    _otherTypeController = TextEditingController(text: item?.subType ?? '');
    _folioController = TextEditingController(text: item?.folioNumber ?? '');
    _unitsController = TextEditingController(text: item?.units ?? '');
    _brokerController = TextEditingController(text: item?.brokerName ?? '');
    _bankNameController =
        TextEditingController(text: item?.linkedBankName ?? '');
    _bankAccountController =
        TextEditingController(text: item?.linkedBankAccount ?? '');
    _purposeController = TextEditingController(text: item?.purpose ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _specialIdController = TextEditingController(text: item?.specialId ?? '');
    _targetAmountController = TextEditingController(
        text: item?.targetAmount?.toStringAsFixed(2) ?? '');

    if (_isEditMode) {
      _selectedType = item!.type;
      _startDate = item.startDate;
      _endDate = item.endDate;
    }

    // [NEW] Attach listeners to instantly check if AI fields are filled
    _targetAmountController.addListener(_checkProjectionStatus);
    _returnController.addListener(_checkProjectionStatus);

    // Initial check on load
    _checkProjectionStatus();
  }

  // [NEW] Real-time logic to hide/show the warning
  void _checkProjectionStatus() {
    bool isReady = _targetAmountController.text.trim().isNotEmpty &&
        _returnController.text.trim().isNotEmpty &&
        _endDate != null;

    // Only rebuild the UI if the state actually changes
    if (isReady != _isProjectionReady) {
      setState(() {
        _isProjectionReady = isReady;
      });
    }
  }

  @override
  void dispose() {
    _targetAmountController.removeListener(_checkProjectionStatus);
    _returnController.removeListener(_checkProjectionStatus);

    _nameController.dispose();
    _providerController.dispose();
    _websiteController.dispose();
    _amountController.dispose();
    _returnController.dispose();
    _otherTypeController.dispose();
    _folioController.dispose();
    _unitsController.dispose();
    _brokerController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _purposeController.dispose();
    _notesController.dispose();
    _specialIdController.dispose();
    _targetAmountController.dispose();

    _nameFocus.dispose();
    _otherTypeFocus.dispose();
    _providerFocus.dispose();
    _websiteFocus.dispose();
    _specialIdFocus.dispose();
    _amountFocus.dispose();
    _targetFocus.dispose();
    _returnFocus.dispose();
    _folioFocus.dispose();
    _unitsFocus.dispose();
    _brokerFocus.dispose();
    _bankNameFocus.dispose();
    _bankAccFocus.dispose();
    _purposeFocus.dispose();
    _notesFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show warning only if user hasn't dismissed it AND the fields aren't ready yet
    final showWarningBox = !_userDismissedWarning && !_isProjectionReady;

    return Scaffold(
      backgroundColor: BudgetrColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ModernAppBar(
              title: _isEditMode ? "Edit Asset" : "New Asset",
              subtitle: "PORTFOLIO TRACKER",
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Section 1: Basic Info ---
                      _buildSectionHeader("BASIC DETAILS"),
                      GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              nextFocusNode:
                                  _selectedType == InvestmentType.others
                                      ? _otherTypeFocus
                                      : _providerFocus,
                              label: "Investment Name",
                              icon: Icons.title,
                              hint: "e.g. Nifty 50 Index Fund",
                            ),
                            const SizedBox(height: 16),
                            _buildTypeSelector(),
                            if (_selectedType == InvestmentType.others) ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _otherTypeController,
                                focusNode: _otherTypeFocus,
                                nextFocusNode: _providerFocus,
                                label: "Specify Type",
                                icon: Icons.category,
                                hint: "e.g. Crypto, Real Estate",
                              ),
                            ],
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _providerController,
                              focusNode: _providerFocus,
                              nextFocusNode: _websiteFocus,
                              label: "Provider / Platform",
                              icon: Icons.business,
                              hint: "e.g. HDFC Mutual Funds",
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _websiteController,
                              focusNode: _websiteFocus,
                              nextFocusNode: _specialIdFocus,
                              label: "Provider Website",
                              icon: Icons.language,
                              hint: "e.g. www.hdfcfund.com",
                              isOptional: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _specialIdController,
                              focusNode: _specialIdFocus,
                              nextFocusNode:
                                  _isEditMode ? _targetFocus : _amountFocus,
                              label: "Special ID / Tag",
                              icon: Icons.tag,
                              hint: "e.g. Retirement",
                              isOptional: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Section 2: Financials & AI Setup ---
                      _buildSectionHeader("FINANCIALS & PROJECTIONS"),

                      if (showWarningBox) _buildProjectionWarningBox(),

                      GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (!_isEditMode) ...[
                              _buildTextField(
                                controller: _amountController,
                                focusNode: _amountFocus,
                                nextFocusNode: _targetFocus,
                                label: "Initial Amount",
                                icon: Icons.currency_rupee,
                                hint: "0.00",
                                isNumeric: true,
                              ),
                              const SizedBox(height: 16),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.08)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.lock_outline_rounded,
                                          size: 16,
                                          color: Colors.white54),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        "Initial amount is locked. Use 'Log Transaction' on the dashboard to add or withdraw funds.",
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                            height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildTextField(
                              controller: _targetAmountController,
                              focusNode: _targetFocus,
                              nextFocusNode: _returnFocus,
                              label: "Target Amount",
                              icon: Icons.track_changes_rounded,
                              hint: "e.g. 1000000.00",
                              isNumeric: true,
                              isOptional: true,
                              isAiPowered: true,
                            ),
                            const SizedBox(height: 16),
                            _buildDatePicker(
                              label: "Start Date",
                              selectedDate: _startDate,
                              onTap: () => _pickDate(true),
                            ),
                            const SizedBox(height: 16),
                            _buildDatePicker(
                              label: "End Date",
                              selectedDate: _endDate,
                              isOptional: true,
                              isAiPowered: true,
                              onTap: () => _pickDate(false),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _returnController,
                              focusNode: _returnFocus,
                              nextFocusNode: _folioFocus,
                              label: "Expected Return %",
                              icon: Icons.percent_rounded,
                              hint: "e.g. 12",
                              isNumeric: true,
                              isOptional: true,
                              isAiPowered: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Section 3: Additional Info ---
                      _buildSectionHeader("ADDITIONAL DETAILS"),
                      GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _folioController,
                              focusNode: _folioFocus,
                              nextFocusNode: _unitsFocus,
                              label: "Folio / Account No",
                              icon: Icons.numbers_rounded,
                              hint: "",
                              isOptional: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _unitsController,
                              focusNode: _unitsFocus,
                              nextFocusNode: _brokerFocus,
                              label: "Units / Quantity",
                              icon: Icons.scale_rounded,
                              hint: "",
                              isOptional: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _brokerController,
                              focusNode: _brokerFocus,
                              nextFocusNode: _bankNameFocus,
                              label: "Broker Name",
                              icon: Icons.person_outline_rounded,
                              hint: "e.g. Zerodha,Groww,ICICI Direct",
                              isOptional: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _bankNameController,
                              focusNode: _bankNameFocus,
                              nextFocusNode: _bankAccFocus,
                              label: "Linked Bank Name",
                              icon: Icons.account_balance_rounded,
                              hint: "e.g. HDFC Bank,Axis Bank",
                              isOptional: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _bankAccountController,
                              focusNode: _bankAccFocus,
                              nextFocusNode: _purposeFocus,
                              label: "Linked Account No",
                              icon: Icons.credit_card_rounded,
                              hint: "xxxx1234",
                              isOptional: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _purposeController,
                              focusNode: _purposeFocus,
                              nextFocusNode: _notesFocus,
                              label: "Purpose / Goal",
                              icon: Icons.flag_outlined,
                              hint: "e.g. Retirement",
                              isOptional: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _notesController,
                              focusNode: _notesFocus,
                              isLast: true,
                              label: "Other Notes",
                              icon: Icons.note_alt_outlined,
                              hint: "Tap to add notes...",
                              isOptional: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BudgetrColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: BudgetrColors.accent.withOpacity(0.4),
                          ),
                          onPressed: _isLoading ? null : _saveInvestment,
                          child: _isLoading
                              ? const FuturisticLoader(size: 24)
                              : Text(
                                  _isEditMode
                                      ? "UPDATE ASSET"
                                      : "ADD TO PORTFOLIO",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildProjectionWarningBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CC9F0).withOpacity(0.15),
            const Color(0xFF4CC9F0).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CC9F0).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CC9F0).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFF4CC9F0), size: 18),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Unlock Smart Projections",
                  style: TextStyle(
                      color: Color(0xFF4CC9F0),
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  "Fill out the Target Amount, End Date, and Exp. Return below to let AI analyze your wealth trajectory.",
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _userDismissedWarning = true),
            child: const Icon(Icons.close_rounded,
                color: Colors.white38, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    bool isNumeric = false,
    bool isOptional = false,
    bool isLast = false,
    bool isAiPowered = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onEditingComplete: () {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return "This field is required";
        }
        return null;
      },
      decoration: InputDecoration(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label + (isOptional ? "" : " *")),
            if (isAiPowered) ...[
              const SizedBox(width: 6),
              const Icon(Icons.auto_awesome_rounded,
                  size: 14, color: Color(0xFF4CC9F0)),
            ]
          ],
        ),
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon:
            Icon(icon, color: BudgetrColors.accent.withOpacity(0.7), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: BudgetrColors.accent.withOpacity(0.6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.redAccent.withOpacity(0.6), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _showTypePicker();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _selectedType == null
                      ? Colors.white.withOpacity(0.08)
                      : BudgetrColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.pie_chart_rounded,
                    color: BudgetrColors.accent.withOpacity(0.7), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedType == null
                        ? "Select Investment Type *"
                        : _formatType(_selectedType!),
                    style: TextStyle(
                      color:
                          _selectedType == null ? Colors.white54 : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded,
                    color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ),
        ),
        FormField<InvestmentType>(
          validator: (val) {
            if (_selectedType == null) return "Please select a type";
            return null;
          },
          builder: (state) {
            if (state.hasError) {
              return Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(state.errorText!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 12)),
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }

  void _showTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Select Type",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: InvestmentType.values.map((type) {
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      leading: Icon(Icons.circle,
                          size: 12,
                          color: _selectedType == type
                              ? BudgetrColors.accent
                              : Colors.white24),
                      title: Text(_formatType(type),
                          style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() => _selectedType = type);
                        Navigator.pop(ctx);
                        if (type == InvestmentType.others) {
                          FocusScope.of(context).requestFocus(_otherTypeFocus);
                        } else {
                          FocusScope.of(context).requestFocus(_providerFocus);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatType(InvestmentType type) {
    String label = type.toString().split('.').last;
    label = label[0].toUpperCase() + label.substring(1);
    if (type == InvestmentType.mutualFund) return "Mutual Fund";
    if (type == InvestmentType.fixedDeposit) return "Fixed Deposit";
    if (type == InvestmentType.recurringDeposit) return "Recurring Deposit";
    if (type == InvestmentType.p2pLending) return "P2P Lending";
    if (type == InvestmentType.savingsAccount) return "Savings Account";
    return label;
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    bool isOptional = false,
    bool isAiPowered = false,
  }) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: BudgetrColors.accent.withOpacity(0.7), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label + (isOptional ? "" : " *"),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      if (isAiPowered) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.auto_awesome_rounded,
                            size: 12, color: Color(0xFF4CC9F0)),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate == null
                        ? "Not Set"
                        : DateFormat('dd MMM yyyy').format(selectedDate),
                    style: TextStyle(
                      color:
                          selectedDate == null ? Colors.white38 : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: BudgetrColors.accent,
              surface: Color(0xFF1B263B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      // [NEW] Check projection readiness when date changes
      _checkProjectionStatus();
    }
  }

  Future<void> _saveInvestment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select an Investment Type"),
          backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double? expectedReturn = _returnController.text.isNotEmpty
          ? double.tryParse(_returnController.text)
          : null;

      final double? targetAmount = _targetAmountController.text.isNotEmpty
          ? double.tryParse(_targetAmountController.text)
          : null;

      final dto = InvestmentDto(
        id: widget.investmentToEdit?.id,
        name: _nameController.text.trim(),
        type: _selectedType!,
        subType: _selectedType == InvestmentType.others
            ? _otherTypeController.text.trim()
            : null,
        providerName: _providerController.text.trim(),
        providerWebsite: _websiteController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        expectedReturn: expectedReturn,
        folioNumber: _folioController.text.trim(),
        units: _unitsController.text.trim(),
        brokerName: _brokerController.text.trim(),
        linkedBankName: _bankNameController.text.trim(),
        linkedBankAccount: _bankAccountController.text.trim(),
        purpose: _purposeController.text.trim(),
        notes: _notesController.text.trim(),
        specialId: _specialIdController.text.trim(),
        targetAmount: targetAmount,
      );

      if (_isEditMode) {
        await GetIt.I<PortfolioService>().updateInvestment(dto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Asset Updated Successfully")),
          );
        }
      } else {
        final double amount = double.parse(_amountController.text);
        await GetIt.I<PortfolioService>().addNewInvestment(dto, amount);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Asset Added to Portfolio")),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: $e"), backgroundColor: Colors.redAccent),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}

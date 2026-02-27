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

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _providerController;
  late TextEditingController _websiteController;
  late TextEditingController _amountController;
  late TextEditingController _returnController;
  late TextEditingController _otherTypeController;

  // Additional Info Controllers
  late TextEditingController _folioController;
  late TextEditingController _unitsController;
  late TextEditingController _brokerController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountController;
  late TextEditingController _purposeController;
  late TextEditingController _notesController;
  late TextEditingController _specialIdController;
  late TextEditingController _targetAmountController; // [NEW]

  // State
  InvestmentType? _selectedType;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isEditMode = false;

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
        text: item?.targetAmount?.toStringAsFixed(2) ?? ''); // [NEW]

    if (_isEditMode) {
      _selectedType = item!.type;
      _startDate = item.startDate;
      _endDate = item.endDate;
    }
  }

  @override
  void dispose() {
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
    _targetAmountController.dispose(); // [NEW]
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Basic Info
                      _buildSectionHeader("BASIC DETAILS"),
                      GlassCard(
                        borderRadius: 12,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
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
                                label: "Specify Type",
                                icon: Icons.category,
                                hint: "e.g. Crypto, Real Estate",
                              ),
                            ],
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _providerController,
                              label: "Provider / Platform",
                              icon: Icons.business,
                              hint: "e.g. Zerodha, Groww, SBI",
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _websiteController,
                              label: "Provider Website (Optional)",
                              icon: Icons.language,
                              hint: "e.g. zerodha.com (for icon)",
                              isOptional: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _specialIdController,
                              label: "Special ID",
                              icon: Icons.tag,
                              hint: "e.g. Group A, Personal, Retirement",
                              isOptional: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Financials
                      _buildSectionHeader("FINANCIALS & DATES"),
                      GlassCard(
                        borderRadius: 12,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            if (!_isEditMode) ...[
                              _buildTextField(
                                controller: _amountController,
                                label: "Initial Amount (Current Value)",
                                icon: Icons.currency_rupee,
                                hint: "0.00",
                                isNumeric: true,
                              ),
                              const SizedBox(height: 16),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock,
                                        size: 16, color: Colors.white38),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                        child: Text(
                                            "Initial Amount cannot be edited. Use 'Log Transaction' to adjust value.",
                                            style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: 12))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // [NEW] Target Amount Field
                            _buildTextField(
                              controller: _targetAmountController,
                              label: "Target Amount",
                              icon: Icons.track_changes_rounded,
                              hint: "e.g. 1000000",
                              isNumeric: true,
                              isOptional: true,
                            ),
                            const SizedBox(height: 16),

                            _buildDatePicker(
                              label: "Start Date",
                              selectedDate: _startDate,
                              onTap: () => _pickDate(true),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _returnController,
                                    label: "Exp. Return %",
                                    icon: Icons.percent,
                                    hint: "12",
                                    isNumeric: true,
                                    isOptional: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDatePicker(
                                    label: "End Date",
                                    selectedDate: _endDate,
                                    isOptional: true,
                                    onTap: () => _pickDate(false),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Additional Info
                      _buildSectionHeader("ADDITIONAL DETAILS"),
                      GlassCard(
                        borderRadius: 12,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: _buildTextField(
                                        controller: _folioController,
                                        label: "Folio No",
                                        icon: Icons.numbers,
                                        hint: "",
                                        isOptional: true)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _buildTextField(
                                        controller: _unitsController,
                                        label: "Units / Qty",
                                        icon: Icons.scale,
                                        hint: "",
                                        isOptional: true)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                                controller: _brokerController,
                                label: "Broker Name",
                                icon: Icons.person_outline,
                                hint: "e.g. Zerodha",
                                isOptional: true),
                            const SizedBox(height: 16),
                            _buildTextField(
                                controller: _bankNameController,
                                label: "Linked Bank Name",
                                icon: Icons.account_balance,
                                hint: "e.g. HDFC Bank",
                                isOptional: true),
                            const SizedBox(height: 16),
                            _buildTextField(
                                controller: _bankAccountController,
                                label: "Linked Account No",
                                icon: Icons.numbers,
                                hint: "xxxx1234",
                                isOptional: true),
                            const SizedBox(height: 16),
                            _buildTextField(
                                controller: _purposeController,
                                label: "Purpose / Goal",
                                icon: Icons.flag_outlined,
                                hint: "e.g. Retirement",
                                isOptional: true),
                            const SizedBox(height: 16),
                            _buildTextField(
                                controller: _notesController,
                                label: "Other Notes",
                                icon: Icons.note_alt_outlined,
                                hint: "Notes...",
                                isOptional: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BudgetrColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: BudgetrColors.accent.withOpacity(0.5),
                          ),
                          onPressed: _isLoading ? null : _saveInvestment,
                          child: _isLoading
                              ? const FuturisticLoader(
                                  size: 20,
                                )
                              : Text(
                                  _isEditMode
                                      ? "UPDATE ASSET"
                                      : "ADD TO PORTFOLIO",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
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
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isNumeric = false,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return "Required field";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label + (isOptional ? "" : " *"),
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon:
            Icon(icon, color: BudgetrColors.accent.withOpacity(0.7), size: 20),
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BudgetrColors.accent.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showTypePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _selectedType == null
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.pie_chart,
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
                      fontWeight: _selectedType == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down,
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
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
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
                      leading: Icon(Icons.circle,
                          size: 10,
                          color: _selectedType == type
                              ? BudgetrColors.accent
                              : Colors.white24),
                      title: Text(_formatType(type),
                          style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() => _selectedType = type);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: BudgetrColors.accent.withOpacity(0.7), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label + (isOptional ? "" : " *"),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate == null
                        ? "Not Set"
                        : DateFormat('dd MMM yyyy').format(selectedDate),
                    style: TextStyle(
                      color:
                          selectedDate == null ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    }
  }

  Future<void> _saveInvestment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select an Investment Type"),
          backgroundColor: Colors.red));
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
        name: _nameController.text,
        type: _selectedType!,
        subType: _selectedType == InvestmentType.others
            ? _otherTypeController.text
            : null,
        providerName: _providerController.text,
        providerWebsite: _websiteController.text,
        startDate: _startDate,
        endDate: _endDate,
        expectedReturn: expectedReturn,
        folioNumber: _folioController.text,
        units: _unitsController.text,
        brokerName: _brokerController.text,
        linkedBankName: _bankNameController.text,
        linkedBankAccount: _bankAccountController.text,
        purpose: _purposeController.text,
        notes: _notesController.text,
        specialId: _specialIdController.text,
        targetAmount: targetAmount, // [NEW]
      );

      if (_isEditMode) {
        await GetIt.I<PortfolioService>().updateInvestment(dto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Investment Updated Successfully")),
          );
        }
      } else {
        final double amount = double.parse(_amountController.text);
        await GetIt.I<PortfolioService>().addNewInvestment(dto, amount);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Investment Added to Portfolio")),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}

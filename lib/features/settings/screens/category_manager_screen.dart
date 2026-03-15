import 'dart:ui';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/constants/icon_constants.dart';

// --- DESIGN SYSTEM IMPORTS ---
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/design/budgetr_components.dart';
import '../../../core/widgets/glass_card.dart';

class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CategoryService _service = CategoryService();
  int _selectedTabIndex = 0;

  late Stream<List<TransactionCategoryModel>> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream = _service.getCategories();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Logic to Restore Defaults (Factory Reset) ---
  Future<void> _handleRestoreDefaults() async {
    showStatusSheet(
      context: context,
      title: "Reset to Defaults?",
      message:
          "This will DELETE all your custom categories and revert any changes made to default ones.\n\nAre you sure you want to start fresh?",
      icon: Icons.restore,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Reset All",
      onDismiss: () async {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(
                child: FuturisticLoader(
                    size: 80, label: "RESTORING SYSTEM DEFAULTS...")),
          );
        }

        try {
          await _service.resetToDefaults();
          if (mounted) {
            Navigator.pop(context); // Close Loader
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("All categories reset to system defaults."),
                backgroundColor: BudgetrColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: $e"),
                backgroundColor: BudgetrColors.error,
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BudgetrScaffold(
      // [FIX] Removed standard AppBar
      // Switched to SafeArea > Column layout for Modern Header
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. MODERN HEADER
                _buildModernHeader(),

                // 2. TABS & CONTENT
                // Adjusted spacing to 20px
                const SizedBox(height: 20),

                _buildSyncedSlidingToggle(),

                const SizedBox(height: 24),

                Expanded(
                  child: StreamBuilder<List<TransactionCategoryModel>>(
                    stream: _categoriesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: FuturisticLoader(
                                size: 80, label: "LOADING CATEGORIES..."));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      final allCategories = snapshot.data!;
                      final expenses = allCategories
                          .where((c) => c.type == 'Expense')
                          .toList();
                      final income = allCategories
                          .where((c) => c.type == 'Income')
                          .toList();

                      return TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildCategoryList(expenses, BudgetrColors.error),
                          _buildCategoryList(income, BudgetrColors.success),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),

            // Explicitly styled button for Main Screen
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _showAddEditSheet(context, null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: BudgetrColors.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: BudgetrStyles.glowBoxShadow(
                        BudgetrColors.accent,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          "Add Category",
                          style: TextStyle(
                            color: Colors.white, // Forces bright white text
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            inherit: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW: Modern Header Implementation ---
  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),

          const SizedBox(width: 16),

          // Title Section
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "SETTINGS",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Categories & Subcategories",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Restore Defaults Button
          // [FIX] Removed 'icon' property because 'child' is used
          PopupMenuButton<String>(
            color: BudgetrColors.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BudgetrStyles.radiusS,
              side: BudgetrStyles.glassBorder.top,
            ),
            onSelected: (val) {
              if (val == 'restore') _handleRestoreDefaults();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: BudgetrColors.error, size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Reset to Defaults",
                      style: TextStyle(color: BudgetrColors.error),
                    ),
                  ],
                ),
              ),
            ],
            // Use GlassCard container for the button trigger to match style
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.more_horiz_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // --- METHODS ---

  void _showAddEditSheet(
    BuildContext context,
    TransactionCategoryModel? category,
  ) {
    final initialType =
        category?.type ?? (_tabController.index == 0 ? 'Expense' : 'Income');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModernAddEditCategorySheet(
        category: category,
        initialType: initialType,
        service: _service,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showStatusSheet(
      context: context,
      title: "Delete Category?",
      message:
          "This will remove the category from selection.\nExisting transactions will remain unaffected.",
      icon: Icons.delete_forever,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        _service.deleteCategory(id);
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildSyncedSlidingToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: BudgetrColors.cardSurface.withOpacity(0.5),
        borderRadius: BudgetrStyles.radiusS,
        border: BudgetrStyles.glassBorder,
      ),
      child: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          final double value = _tabController.animation!.value;
          final double alignmentX = (value * 2) - 1;

          final Color indicatorColor = Color.lerp(
            BudgetrColors.error, // Red for Expense
            BudgetrColors.success, // Green for Income
            value,
          )!;

          return Stack(
            children: [
              Align(
                alignment: Alignment(alignmentX, 0),
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: indicatorColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildAnimatedText("EXPENSE", 0, value),
                  _buildAnimatedText("INCOME", 1, value),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedText(String label, int index, double animationValue) {
    final double dist = (animationValue - index).abs();
    final bool isActive = dist < 0.5;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: BudgetrStyles.caption.copyWith(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: isActive ? Colors.white : Colors.white54,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 60,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            "No categories found",
            style: BudgetrStyles.body.copyWith(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    List<TransactionCategoryModel> categories,
    Color themeColor,
  ) {
    if (categories.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _CategoryCard(
          category: categories[index],
          themeColor: themeColor,
          onEdit: () => _showAddEditSheet(context, categories[index]),
          onDelete: () => _confirmDelete(context, categories[index].id),
        );
      },
    );
  }
}

class _ModernAddEditCategorySheet extends StatefulWidget {
  final TransactionCategoryModel? category;
  final String initialType;
  final CategoryService service;

  const _ModernAddEditCategorySheet({
    this.category,
    required this.initialType,
    required this.service,
  });

  @override
  State<_ModernAddEditCategorySheet> createState() =>
      _ModernAddEditCategorySheetState();
}

class _ModernAddEditCategorySheetState
    extends State<_ModernAddEditCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _subCtrl;

  final FocusNode _nameNode = FocusNode();
  final FocusNode _subNode = FocusNode();
  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _subFieldKey = GlobalKey();

  late List<String> _currentSubs;
  late int _selectedIconCode;
  late String _type;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _subCtrl = TextEditingController();
    _currentSubs = widget.category != null
        ? List.from(widget.category!.subCategories)
        : [];
    _currentSubs.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    _selectedIconCode = widget.category?.iconCode ?? Icons.category.codePoint;
    _type = widget.initialType;

    _nameNode.addListener(() {
      if (_nameNode.hasFocus) _scrollToField(_nameFieldKey);
    });
    _subNode.addListener(() {
      if (_subNode.hasFocus) _scrollToField(_subFieldKey);
    });
  }

  @override
  void dispose() {
    _nameNode.dispose();
    _subNode.dispose();
    _nameCtrl.dispose();
    _subCtrl.dispose();
    super.dispose();
  }

  void _scrollToField(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: BudgetrColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      widget.category == null
                          ? "Create New Category"
                          : "Edit Category",
                      style: BudgetrStyles.h2,
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () async {
                        _nameNode.unfocus();
                        _subNode.unfocus();
                        final code = await showModalBottomSheet<int>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (c) => const _IconPickerSheet(),
                        );
                        if (code != null)
                          setState(() => _selectedIconCode = code);
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: BudgetrColors.cardSurface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: BudgetrColors.accent.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BudgetrColors.accent.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              IconConstants.getIconByCode(_selectedIconCode),
                              color: Colors.white,
                              size: 40,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: BudgetrColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      key: _nameFieldKey,
                      focusNode: _nameNode,
                      controller: _nameCtrl,
                      textAlign: TextAlign.center,
                      style: BudgetrStyles.h2,
                      decoration: InputDecoration(
                        hintText: "Category Name",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.03),
                        border: OutlineInputBorder(
                          borderRadius: BudgetrStyles.radiusM,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_subNode);
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (widget.category == null) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BudgetrStyles.radiusM,
                        ),
                        child: Row(
                          children: [
                            _buildTypeOption("Expense", BudgetrColors.error),
                            _buildTypeOption("Income", BudgetrColors.success),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "SUB-CATEGORIES",
                        style: BudgetrStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: _subFieldKey,
                      focusNode: _subNode,
                      controller: _subCtrl,
                      style: BudgetrStyles.body.copyWith(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Add sub-category (e.g. Uber, Groceries)",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        filled: true,
                        fillColor: BudgetrColors.cardSurface,
                        border: OutlineInputBorder(
                          borderRadius: BudgetrStyles.radiusS,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: BudgetrColors.accent,
                          ),
                          onPressed: _addSubCategory,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _addSubCategory(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentSubs
                            .map(
                              (s) => Chip(
                                label: Text(
                                  s,
                                  style: BudgetrStyles.caption.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.08),
                                deleteIcon: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: Colors.white54,
                                ),
                                onDeleted: () =>
                                    setState(() => _currentSubs.remove(s)),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.all(4),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // FIX: Updated Bottom Sheet Button to Custom Gradient to Fix Fading
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              color: BudgetrColors.background,
            ),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _isLoading ? null : _save,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: BudgetrColors.primaryGradient,
                    borderRadius: BudgetrStyles.radiusM,
                    boxShadow: BudgetrStyles.glowBoxShadow(
                      BudgetrColors.accent,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.category == null
                              ? "Create Category"
                              : "Save Changes",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSubCategory() {
    final val = _subCtrl.text.trim();
    if (val.isEmpty) return;

    if (_currentSubs.any((s) => s.toLowerCase() == val.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'$val' already added!"),
          backgroundColor: BudgetrColors.warning,
        ),
      );
      _subNode.requestFocus();
      return;
    }

    setState(() {
      _currentSubs.add(val);
      _currentSubs.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      _subCtrl.clear();
    });

    _subNode.requestFocus();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameCtrl.text.trim();

      final isDuplicate = await widget.service.checkDuplicate(
        name,
        _type,
        excludeId: widget.category?.id,
      );

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Category '$name' already exists in $_type."),
              backgroundColor: BudgetrColors.error,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      if (widget.category == null) {
        await widget.service.addCategory(
          name,
          _type,
          _currentSubs,
          _selectedIconCode,
        );
      } else {
        await widget.service.updateCategory(
          TransactionCategoryModel(
            id: widget.category!.id,
            name: name,
            type: _type,
            subCategories: _currentSubs,
            iconCode: _selectedIconCode,
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: BudgetrColors.error,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTypeOption(String label, Color color) {
    final isSelected = _type == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final TransactionCategoryModel category;
  final Color themeColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.themeColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.category_outlined;
    if (widget.category.iconCode != null) {
      icon = IconConstants.getIconByCode(widget.category.iconCode!);
    }

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BudgetrColors.cardSurface.withOpacity(_isExpanded ? 0.8 : 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isExpanded
                ? widget.themeColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: _isExpanded
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: widget.themeColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.category.name, style: BudgetrStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.category.subCategories.length} sub-categories",
                        style: BudgetrStyles.caption,
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white10, height: 1),
                          const SizedBox(height: 16),
                          if (widget.category.subCategories.isEmpty)
                            Text(
                              "No sub-categories defined.",
                              style: BudgetrStyles.caption.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.category.subCategories
                                  .map(
                                    (sub) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.08),
                                            Colors.white.withOpacity(0.04),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Text(
                                        sub,
                                        style: BudgetrStyles.caption.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _ActionButton(
                                icon: Icons.edit_outlined,
                                label: "Edit",
                                color: Colors.white,
                                onTap: widget.onEdit,
                              ),
                              const SizedBox(width: 12),
                              _ActionButton(
                                icon: Icons.delete_outline,
                                label: "Delete",
                                color: BudgetrColors.error,
                                onTap: widget.onDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPickerSheet extends StatefulWidget {
  const _IconPickerSheet();

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<IconGroup> filteredGroups = [];
    List<IconMetadata> flatSearchResults = [];

    if (_searchQuery.isEmpty) {
      filteredGroups = IconConstants.iconGroups;
    } else {
      for (var group in IconConstants.iconGroups) {
        for (var meta in group.icons) {
          if (meta.tags.any((t) => t.contains(_searchQuery.toLowerCase()))) {
            flatSearchResults.add(meta);
          }
        }
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: BudgetrColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
          Text("Select Icon", style: BudgetrStyles.h2),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search icons (e.g. food, car, bank)",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BudgetrStyles.radiusM,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildGroupedList(filteredGroups)
                : _buildSearchResults(flatSearchResults),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<IconGroup> groups) {
    return ListView.separated(
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.title.toUpperCase(),
              style: BudgetrStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: group.icons.length,
              itemBuilder: (context, i) => _buildIconTile(group.icons[i]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(List<IconMetadata> results) {
    if (results.isEmpty)
      return Center(
        child: Text(
          "No icons found for '$_searchQuery'",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) => _buildIconTile(results[index]),
    );
  }

  Widget _buildIconTile(IconMetadata meta) {
    return InkWell(
      onTap: () => Navigator.pop(context, meta.icon.codePoint),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Icon(meta.icon, color: Colors.white70, size: 24),
      ),
    );
  }
}

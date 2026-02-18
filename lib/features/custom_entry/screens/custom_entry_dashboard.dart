import 'dart:ui'; // Required for ImageFilter
import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/core/widgets/modern_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/custom_entry/screens/template_editor_screen.dart';
import 'package:budget/features/custom_entry/widgets/custom_data_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/models/custom_data_models.dart';
import '../services/custom_entry_service.dart';

class CustomEntryDashboard extends StatefulWidget {
  const CustomEntryDashboard({super.key});

  @override
  State<CustomEntryDashboard> createState() => _CustomEntryDashboardState();
}

class _CustomEntryDashboardState extends State<CustomEntryDashboard> {
  final CustomEntryService _service = GetIt.I<CustomEntryService>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xff0D1B2A);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Elements (FIXED)
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3A86FF).withOpacity(0.1),
                  backgroundBlendMode: BlendMode.plus,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. MODERN HEADER (Replaces _buildHeader)
                _buildModernHeader(),

                // 2. SEARCH BAR
                _buildSearchBar(),

                // 3. GRID CONTENT
                Expanded(
                  child: StreamBuilder<List<CustomTemplate>>(
                    stream: _service.getCustomTemplates(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: FuturisticLoader(
                                size: 80, label: "LOADING..."));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Filter logic
                      final allTemplates = snapshot.data!;
                      final templates = _searchQuery.isEmpty
                          ? allTemplates
                          : allTemplates
                              .where((t) => t.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                              .toList();

                      return MasonryGridView.count(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemCount:
                            templates.length + 1, // +1 for "Add New" card
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildAddNewCard();
                          }
                          return _TrackerCard(
                            template: templates[index - 1],
                            onTap: () => _openTracker(templates[index - 1]),
                            onEdit: () => _editTracker(templates[index - 1]),
                            onDelete: () =>
                                _deleteTracker(templates[index - 1]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  "DASHBOARD",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "BudGetR Sheets",
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
        ],
      ),
    );
  }

  // --- EXISTING WIDGETS ---

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: "Search your sheets...",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: Icon(CupertinoIcons.search,
                color: Colors.white.withOpacity(0.3)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TemplateEditorScreen()),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF3A86FF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF3A86FF).withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 106, 155, 235),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_to_photos_outlined,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              "Create New",
              style: TextStyle(
                color: Color(0xFF3A86FF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_customize_outlined,
              size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "No Sheets Yet",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TemplateEditorScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Create First Sheet"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A86FF),
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  void _openTracker(CustomTemplate template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(template.name,
                style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xff0D1B2A),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: CustomDataPage(template: template),
        ),
      ),
    );
  }

  void _editTracker(CustomTemplate template) {
    if (template.name == "Investment Portfolio") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("System templates cannot be edited directly.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TemplateEditorScreen(templateToEdit: template)),
    );
  }

  Future<void> _deleteTracker(CustomTemplate template) async {
    if (template.name == "Investment Portfolio") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("System templates cannot be deleted.")),
      );
      return;
    }

    showStatusSheet(
      context: context,
      title: "Delete Sheet?",
      message:
          "Are you sure you want to delete '${template.name}'?\nThis will permanently delete the sheet structure and all its entered data.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        await _service.deleteCustomTemplate(template.id);
      },
    );
  }
}

class _TrackerCard extends StatelessWidget {
  final CustomTemplate template;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TrackerCard({
    required this.template,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final int hash = template.name.codeUnits.reduce((a, b) => a + b);

    // FIX: Changed List<Color> to List<List<Color>>
    final List<List<Color>> gradients = [
      [const Color(0xFF4361EE), const Color(0xFF4CC9F0)], // Blue
      [const Color(0xFFF72585), const Color(0xFF7209B7)], // Pink/Purple
      [const Color(0xFFFF9F1C), const Color(0xFFFFBF69)], // Orange
      [const Color(0xFF2EC4B6), const Color(0xFFCBF3F0)], // Teal
      [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], // Electric Violet
      [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Emerald Green
      [const Color(0xFFFF5F6D), const Color(0xFFFFC371)], // Sunset Peach
      [const Color(0xFF2193B0), const Color(0xFF6DD5ED)], // Cool Sky
      [const Color(0xFF7028E4), const Color(0xFFE5B2CA)], // Deep Orchid
      [const Color(0xFF00B4DB), const Color(0xFF0083B0)], // Deep Blue Sea
    ];

    // Select color pair
    final colorPair = gradients[hash % gradients.length];
    final bool isSystem = template.name == "Investment Portfolio";

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showOptions(context);
      },
      child: Container(
        height: (hash % 2 == 0) ? 180 : 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              colorPair[0].withOpacity(0.2),
              colorPair[1].withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: colorPair[0].withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorPair[0].withOpacity(0.15),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSystem
                              ? Icons.show_chart
                              : Icons.table_chart_outlined,
                          color: colorPair[1],
                          size: 20,
                        ),
                      ),
                      if (isSystem)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text(
                            "SYS",
                            style: TextStyle(
                                fontSize: 8,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                    ],
                  ),

                  // Middle Section: Stats
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<int>(
                        future: GetIt.I<CustomEntryService>()
                            .getRecordCount(template.id),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Text(
                            "$count Records",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Bottom Section
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d,yyyy').format(template.createdAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text("Edit Structure",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text("Delete Sheet",
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

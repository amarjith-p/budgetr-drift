import 'package:budget/core/widgets/modern_loader.dart';
import 'package:budget/features/custom_entry/services/custom_entry_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/custom_data_models.dart';
import 'template_editor_screen.dart';
import '../widgets/custom_data_page.dart';

class CustomEntryDashboard extends StatefulWidget {
  const CustomEntryDashboard({super.key});

  @override
  State<CustomEntryDashboard> createState() => _CustomEntryDashboardState();
}

class _CustomEntryDashboardState extends State<CustomEntryDashboard>
    with TickerProviderStateMixin {
  // Theme Constants
  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF3A86FF);

  late Stream<List<CustomTemplate>> _templatesStream;
  TabController? _tabController;

  // Track the ID of the currently viewed template to persist selection across updates
  String? _activeTemplateId;

  @override
  void initState() {
    super.initState();
    // Initialize stream once
    _templatesStream = CustomEntryService().getCustomTemplates();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CustomTemplate>>(
      stream: _templatesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: _bgColor,
            body: const Center(child: ModernLoader()),
          );
        }

        var templates = snapshot.data ?? [];

        // --- 1. STABLE SORTING ---
        // Explicitly sort client-side to ensure stability regardless of Firestore quirks
        templates = List.from(templates);
        templates.sort((a, b) {
          int res = a.createdAt.compareTo(b.createdAt);
          if (res == 0) return a.name.compareTo(b.name);
          return res;
        });

        // --- 2. EMPTY STATE ---
        if (templates.isEmpty) {
          return _buildEmptyState();
        }

        // --- 3. SYNC ACTIVE ID ---
        // Find where our active template has moved to
        int initialIndex = 0;
        if (_activeTemplateId != null) {
          final foundIndex = templates.indexWhere(
            (t) => t.id == _activeTemplateId,
          );
          if (foundIndex != -1) {
            initialIndex = foundIndex;
          } else if (templates.isNotEmpty) {
            // ID lost (deleted?), default to first
            _activeTemplateId = templates.first.id;
          }
        } else {
          // First load
          _activeTemplateId = templates.first.id;
        }

        // --- 4. MANAGE CONTROLLER ---
        bool recreateController =
            _tabController == null ||
            _tabController!.length != templates.length;

        if (recreateController) {
          _tabController?.dispose();
          _tabController = TabController(
            length: templates.length,
            vsync: this,
            initialIndex: initialIndex,
          );

          // Update tracker when user swipes manually
          _tabController!.addListener(() {
            if (!_tabController!.indexIsChanging &&
                _tabController!.index < templates.length) {
              _activeTemplateId = templates[_tabController!.index].id;
            }
          });
        } else {
          // If controller exists, ensure it is on the correct tab
          if (_tabController!.index != initialIndex) {
            _tabController!.animateTo(initialIndex, duration: Duration.zero);
          }
        }

        // --- MAIN DASHBOARD ---
        return Scaffold(
          backgroundColor: _bgColor,
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            backgroundColor: _bgColor,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Custom Trackers',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const TemplateEditorScreen(),
                  ),
                ),
                tooltip: 'Create New Tracker',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // --- MODERN TAB BAR ---
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                height: 55,
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  physics: const BouncingScrollPhysics(),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  padding: const EdgeInsets.all(4),
                  indicator: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  tabs: templates.map((t) {
                    return Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.dataset_outlined, size: 16),
                            const SizedBox(width: 8),
                            Text(t.name.toUpperCase()),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              _buildAmbientGlow(_accentColor),

              // --- BODY ---
              TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: templates.map((t) {
                  return CustomDataPage(key: ValueKey(t.id), template: t);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Custom Trackers',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          _buildAmbientGlow(_accentColor),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B).withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _accentColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.dashboard_customize_outlined,
                      size: 40,
                      color: _accentColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'No Data Trackers',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create custom forms to track specific\nfinancial goals or habits.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const TemplateEditorScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Create New Tracker',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow(Color accentColor) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [accentColor.withOpacity(0.15), Colors.transparent],
                center: Alignment.center,
                radius: 0.6,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFF72585).withOpacity(0.1),
                  Colors.transparent,
                ],
                center: Alignment.center,
                radius: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

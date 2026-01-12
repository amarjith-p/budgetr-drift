import 'package:budget/core/widgets/modern_loader.dart';
import 'package:budget/features/custom_entry/services/custom_entry_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import '../../../core/models/custom_data_models.dart';
import 'template_editor_screen.dart';
import '../widgets/custom_data_page.dart';
import '../widgets/dashboard/empty_tracker_state.dart';

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
  String? _activeTemplateId;

  @override
  void initState() {
    super.initState();
    _templatesStream = GetIt.I<CustomEntryService>().getCustomTemplates();
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

        // Stable Sorting
        templates = List.from(templates);
        templates.sort((a, b) {
          int res = a.createdAt.compareTo(b.createdAt);
          if (res == 0) return a.name.compareTo(b.name);
          return res;
        });

        if (templates.isEmpty) {
          return EmptyTrackerState(
            accentColor: _accentColor,
            bgColor: _bgColor,
          );
        }

        // Sync Active ID
        int initialIndex = 0;
        if (_activeTemplateId != null) {
          final foundIndex = templates.indexWhere(
            (t) => t.id == _activeTemplateId,
          );
          if (foundIndex != -1) {
            initialIndex = foundIndex;
          } else if (templates.isNotEmpty) {
            _activeTemplateId = templates.first.id;
          }
        } else {
          _activeTemplateId = templates.first.id;
        }

        // Manage Controller
        bool recreateController = _tabController == null ||
            _tabController!.length != templates.length;

        if (recreateController) {
          _tabController?.dispose();
          _tabController = TabController(
            length: templates.length,
            vsync: this,
            initialIndex: initialIndex,
          );

          _tabController!.addListener(() {
            if (!_tabController!.indexIsChanging &&
                _tabController!.index < templates.length) {
              _activeTemplateId = templates[_tabController!.index].id;
            }
          });
        } else {
          if (_tabController!.index != initialIndex) {
            _tabController!.animateTo(initialIndex, duration: Duration.zero);
          }
        }

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

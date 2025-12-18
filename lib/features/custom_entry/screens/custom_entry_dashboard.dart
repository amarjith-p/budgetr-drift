import 'package:flutter/material.dart';
import '../../../core/models/custom_data_models.dart';
import '../../../core/services/firestore_service.dart';
import 'template_editor_screen.dart';
import '../widgets/custom_data_page.dart';

class CustomEntryDashboard extends StatelessWidget {
  const CustomEntryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Data Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos_outlined),
            tooltip: 'Create New Screen',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const TemplateEditorScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<CustomTemplate>>(
        stream: FirestoreService().getCustomTemplates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final templates = snapshot.data ?? [];

          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.dashboard_customize_outlined,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No custom forms yet.',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const TemplateEditorScreen(),
                      ),
                    ),
                    child: const Text('Create Your First Form'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _TemplateHeader(templates: templates),
              Expanded(
                child: PageView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    return CustomDataPage(template: templates[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TemplateHeader extends StatelessWidget {
  final List<CustomTemplate> templates;
  const _TemplateHeader({required this.templates});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Center(
              child: Text(
                templates[index].name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

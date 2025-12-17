import 'dart:ui';
import 'package:flutter/material.dart';

class ModernDropdownPill<T> extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  const ModernDropdownPill({
    super.key,
    required this.label,
    required this.isActive,
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        // Reduced horizontal padding slightly (16 -> 12) to save space
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest
                    .withOpacity(isEnabled ? 0.3 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                : Colors.white.withOpacity(isEnabled ? 0.1 : 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isEnabled
                  ? (isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white70)
                  : Colors.white24,
            ),
            const SizedBox(width: 8),
            // FIX: Use Flexible to prevent overflow
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? (isActive
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white)
                      : Colors.white24,
                ),
                overflow: TextOverflow.ellipsis, // Add ellipsis
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            if (isEnabled)
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white54,
              ),
          ],
        ),
      ),
    );
  }
}

void showSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelBuilder,
  required Function(T?) onSelect,
  T? selectedItem,
  bool showReset = false,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff0D1B2A).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  if (showReset)
                    TextButton(
                      onPressed: () {
                        onSelect(null);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == selectedItem;
                  return ListTile(
                    title: Text(
                      labelBuilder(item),
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      onSelect(item);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

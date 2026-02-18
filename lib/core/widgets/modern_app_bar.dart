import 'package:flutter/material.dart';
import 'glass_card.dart';

class ModernAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final VoidCallback? onLeadingPressed;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;

  const ModernAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingIcon = Icons.arrow_back_rounded,
    this.onLeadingPressed,
    this.trailingIcon = Icons.more_horiz_rounded,
    this.onTrailingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Leading Button (Back by default)
          GestureDetector(
            onTap: onLeadingPressed ?? () => Navigator.maybePop(context),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: Icon(leadingIcon, color: Colors.white70, size: 20),
            ),
          ),

          const SizedBox(width: 16),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Trailing Button (Action)
          if (trailingIcon != null)
            GestureDetector(
              onTap: onTrailingPressed,
              child: GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.all(10),
                margin: EdgeInsets.zero,
                color: Colors.white.withOpacity(0.05),
                child: Icon(trailingIcon, color: Colors.white70, size: 20),
              ),
            )
          else
            const SizedBox(width: 40), // Balance the row if no icon
        ],
      ),
    );
  }
}

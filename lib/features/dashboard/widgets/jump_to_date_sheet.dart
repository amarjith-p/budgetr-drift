import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_dropdown.dart';

class JumpToDateSheet extends StatelessWidget {
  final DateTime currentDate;
  final Function(int year, int month) onDateSelected;

  const JumpToDateSheet({
    super.key,
    required this.currentDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Local constants
    final Color bgColor = const Color(0xff0D1B2A);
    final Color accentColor = const Color(0xFF3A86FF);

    final years = List.generate(
      85,
      (index) => DateTime.now().year - 10 + index,
    );
    final months = List.generate(12, (index) => index + 1);

    int selectedYear = currentDate.year;
    int selectedMonth = currentDate.month;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
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

              const Text(
                "Jump to Month",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Selectors
              Row(
                children: [
                  // Year
                  Expanded(
                    child: ModernDropdownPill<int>(
                      label: selectedYear.toString(),
                      isActive: true,
                      icon: Icons.calendar_today,
                      onTap: () => showSelectionSheet<int>(
                        context: context,
                        title: 'Select Year',
                        items: years,
                        labelBuilder: (y) => y.toString(),
                        onSelect: (val) {
                          if (val != null) {
                            setModalState(() => selectedYear = val);
                          }
                        },
                        selectedItem: selectedYear,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Month
                  Expanded(
                    child: ModernDropdownPill<int>(
                      label: DateFormat(
                        'MMM',
                      ).format(DateTime(0, selectedMonth)),
                      isActive: true,
                      icon: Icons.calendar_view_month,
                      onTap: () => showSelectionSheet<int>(
                        context: context,
                        title: 'Select Month',
                        items: months,
                        labelBuilder: (m) =>
                            DateFormat('MMMM').format(DateTime(0, m)),
                        onSelect: (val) {
                          if (val != null) {
                            setModalState(() => selectedMonth = val);
                          }
                        },
                        selectedItem: selectedMonth,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Go Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onDateSelected(selectedYear, selectedMonth);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Go to Month",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

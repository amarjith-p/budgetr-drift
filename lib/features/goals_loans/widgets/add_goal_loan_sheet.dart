// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:intl/intl.dart';
// import '../../../core/design/budgetr_colors.dart';
// import '../../../core/design/budgetr_styles.dart';
// import '../models/goal_loan_models.dart';
// import '../services/goal_loan_service.dart';

// class AddGoalLoanSheet extends StatefulWidget {
//   final int initialIndex; // 0 for Goal, 1 for Loan

//   const AddGoalLoanSheet({super.key, this.initialIndex = 0});

//   @override
//   State<AddGoalLoanSheet> createState() => _AddGoalLoanSheetState();
// }

// class _AddGoalLoanSheetState extends State<AddGoalLoanSheet>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   // Controllers (Same as before)
//   final _goalNameCtrl = TextEditingController();
//   final _goalTargetCtrl = TextEditingController();
//   DateTime? _goalDeadline;

//   final _loanTitleCtrl = TextEditingController();
//   final _loanProviderCtrl = TextEditingController();
//   final _loanAmountCtrl = TextEditingController();
//   final _loanInterestCtrl = TextEditingController();
//   String _loanType = 'BORROWED';

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with the requested index
//     _tabController = TabController(
//         length: 2, vsync: this, initialIndex: widget.initialIndex);
//   }

//   // ... (Rest of the build method and logic remains exactly the same as the previous "Enhanced" version I provided)
//   // Re-pasting the Build and Logic for completeness to ensure no missing context:

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.85,
//       decoration: const BoxDecoration(
//         color: BudgetrColors.background,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 20),
//           // Tab Switcher
//           Container(
//             height: 48,
//             margin: const EdgeInsets.symmetric(horizontal: 24),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: TabBar(
//               controller: _tabController,
//               indicator: BoxDecoration(
//                 color: BudgetrColors.accent,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               labelColor: Colors.white,
//               unselectedLabelColor: Colors.white54,
//               tabs: const [Tab(text: "New Goal"), Tab(text: "New Loan")],
//             ),
//           ),

//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [_buildGoalForm(), _buildLoanForm()],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGoalForm() {
//     return ListView(
//       padding: const EdgeInsets.all(24),
//       children: [
//         _buildInput("Goal Name", _goalNameCtrl, Icons.flag_outlined),
//         const SizedBox(height: 16),
//         _buildInput("Target Amount", _goalTargetCtrl, Icons.currency_rupee,
//             isNumber: true),
//         const SizedBox(height: 16),
//         _buildDateSelector("Target Date", _goalDeadline,
//             (d) => setState(() => _goalDeadline = d)),
//         const SizedBox(height: 32),
//         ElevatedButton(
//           onPressed: _saveGoal,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: BudgetrColors.accent,
//             minimumSize: const Size(double.infinity, 56),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           ),
//           child: const Text("CREATE GOAL",
//               style:
//                   TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         )
//       ],
//     );
//   }

//   Widget _buildLoanForm() {
//     return ListView(
//       padding: const EdgeInsets.all(24),
//       children: [
//         Row(
//           children: [
//             Expanded(child: _buildRadioBtn("I Borrowed", 'BORROWED')),
//             const SizedBox(width: 12),
//             Expanded(child: _buildRadioBtn("I Lent", 'LENT')),
//           ],
//         ),
//         const SizedBox(height: 24),
//         _buildInput("Title (e.g. Home Loan)", _loanTitleCtrl, Icons.title),
//         const SizedBox(height: 16),
//         _buildInput(
//             "Provider / Person", _loanProviderCtrl, Icons.person_outline),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//                 child: _buildInput(
//                     "Amount", _loanAmountCtrl, Icons.currency_rupee,
//                     isNumber: true)),
//             const SizedBox(width: 16),
//             Expanded(
//                 child: _buildInput(
//                     "Interest %", _loanInterestCtrl, Icons.percent,
//                     isNumber: true)),
//           ],
//         ),
//         const SizedBox(height: 32),
//         ElevatedButton(
//           onPressed: _saveLoan,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _loanType == 'BORROWED'
//                 ? BudgetrColors.error
//                 : BudgetrColors.success,
//             minimumSize: const Size(double.infinity, 56),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           ),
//           child: const Text("CREATE RECORD",
//               style:
//                   TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         )
//       ],
//     );
//   }

//   Widget _buildInput(String label, TextEditingController ctrl, IconData icon,
//       {bool isNumber = false}) {
//     return TextField(
//       controller: ctrl,
//       keyboardType: isNumber
//           ? const TextInputType.numberWithOptions(decimal: true)
//           : TextInputType.text,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.white54),
//         prefixIcon: Icon(icon, color: Colors.white24),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.05),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none),
//       ),
//     );
//   }

//   Widget _buildDateSelector(
//       String label, DateTime? date, Function(DateTime) onPick) {
//     return InkWell(
//       onTap: () async {
//         final d = await showDatePicker(
//             context: context,
//             initialDate: DateTime.now(),
//             firstDate: DateTime.now(),
//             lastDate: DateTime(2050),
//             builder: (c, child) =>
//                 Theme(data: ThemeData.dark(), child: child!));
//         if (d != null) onPick(d);
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//         decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.05),
//             borderRadius: BorderRadius.circular(12)),
//         child: Row(
//           children: [
//             const Icon(Icons.calendar_today, color: Colors.white24),
//             const SizedBox(width: 12),
//             Text(date == null ? label : DateFormat('dd MMM yyyy').format(date),
//                 style: const TextStyle(color: Colors.white)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRadioBtn(String label, String val) {
//     final isSelected = _loanType == val;
//     final color =
//         val == 'BORROWED' ? BudgetrColors.error : BudgetrColors.success;
//     return GestureDetector(
//       onTap: () => setState(() => _loanType = val),
//       child: Container(
//         height: 50,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: isSelected ? color : Colors.white24),
//         ),
//         child: Text(label,
//             style: TextStyle(
//                 color: isSelected ? color : Colors.white54,
//                 fontWeight: FontWeight.bold)),
//       ),
//     );
//   }

//   Future<void> _saveGoal() async {
//     final target = double.tryParse(_goalTargetCtrl.text) ?? 0;
//     if (_goalNameCtrl.text.isEmpty || target <= 0) return;

//     final goal = GoalModel(
//         id: '',
//         name: _goalNameCtrl.text,
//         targetAmount: target,
//         currentAmount: 0,
//         deadline: _goalDeadline,
//         color: Colors.blue.value,
//         isCompleted: false);
//     await GetIt.I<GoalLoanService>().createGoal(goal);
//     if (mounted) Navigator.pop(context);
//   }

//   Future<void> _saveLoan() async {
//     final amount = double.tryParse(_loanAmountCtrl.text) ?? 0;
//     if (_loanTitleCtrl.text.isEmpty || amount <= 0) return;

//     final loan = LoanModel(
//         id: '',
//         title: _loanTitleCtrl.text,
//         provider: _loanProviderCtrl.text,
//         totalAmount: amount,
//         paidAmount: 0,
//         interestRate: double.tryParse(_loanInterestCtrl.text) ?? 0,
//         type: _loanType,
//         startDate: DateTime.now(),
//         isClosed: false);
//     await GetIt.I<GoalLoanService>().createLoan(loan);
//     if (mounted) Navigator.pop(context);
//   }
// }

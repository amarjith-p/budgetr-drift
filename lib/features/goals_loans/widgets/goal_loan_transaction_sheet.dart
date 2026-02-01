// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:intl/intl.dart';
// import '../../../core/design/budgetr_colors.dart';
// import '../../../core/design/budgetr_styles.dart';
// import '../services/goal_loan_service.dart';

// class GoalLoanTransactionSheet extends StatefulWidget {
//   final String parentId;
//   final String type; // 'GOAL' or 'LOAN'
//   final bool isLoanPayment;

//   const GoalLoanTransactionSheet({
//     super.key,
//     required this.parentId,
//     required this.type,
//     this.isLoanPayment = false,
//   });

//   @override
//   State<GoalLoanTransactionSheet> createState() =>
//       _GoalLoanTransactionSheetState();
// }

// class _GoalLoanTransactionSheetState extends State<GoalLoanTransactionSheet> {
//   final _principalCtrl = TextEditingController();
//   final _interestCtrl = TextEditingController();
//   final _notesCtrl = TextEditingController();
//   DateTime _date = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//           top: 24,
//           left: 24,
//           right: 24,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 24),
//       decoration: const BoxDecoration(
//         color: BudgetrColors.cardSurface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.type == 'GOAL' ? "Add Savings" : "Add Payment",
//               style: BudgetrStyles.h2),
//           const SizedBox(height: 24),

//           // Principal Input
//           _buildLabel("Principal Amount"),
//           TextField(
//             controller: _principalCtrl,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             style: const TextStyle(color: Colors.white, fontSize: 18),
//             decoration: _inputDeco("e.g. 5000"),
//           ),

//           const SizedBox(height: 16),

//           // Interest/Profit Input
//           _buildLabel(widget.type == 'GOAL'
//               ? "Interest/Returns (Optional)"
//               : "Interest Component (Optional)"),
//           TextField(
//             controller: _interestCtrl,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             style: const TextStyle(color: Colors.white, fontSize: 18),
//             decoration: _inputDeco("e.g. 200"),
//           ),

//           const SizedBox(height: 16),

//           // Date & Note Row
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildLabel("Date"),
//                     GestureDetector(
//                       onTap: () async {
//                         final d = await showDatePicker(
//                             context: context,
//                             initialDate: _date,
//                             firstDate: DateTime(2000),
//                             lastDate: DateTime(2100),
//                             builder: (c, child) =>
//                                 Theme(data: ThemeData.dark(), child: child!));
//                         if (d != null) setState(() => _date = d);
//                       },
//                       child: Container(
//                         height: 50,
//                         alignment: Alignment.centerLeft,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.white10),
//                         ),
//                         child: Text(DateFormat('dd/MM/yyyy').format(_date),
//                             style: const TextStyle(color: Colors.white)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildLabel("Note"),
//                     TextField(
//                       controller: _notesCtrl,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: _inputDeco("Optional"),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 32),

//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton(
//               onPressed: _submit,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: BudgetrColors.accent,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//               ),
//               child: const Text("SAVE RECORD",
//                   style: TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(text,
//           style: const TextStyle(color: Colors.white54, fontSize: 12)),
//     );
//   }

//   InputDecoration _inputDeco(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.white24),
//       filled: true,
//       fillColor: Colors.white.withOpacity(0.05),
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//     );
//   }

//   void _submit() {
//     final principal = double.tryParse(_principalCtrl.text) ?? 0;
//     final interest = double.tryParse(_interestCtrl.text) ?? 0;

//     if (principal <= 0 && interest <= 0) return;

//     if (widget.type == 'GOAL') {
//       // GetIt.I<GoalLoanService>().addGoalContribution(
//       //     widget.parentId, principal, interest, _notesCtrl.text);
//     } else {
//       GetIt.I<GoalLoanService>().addLoanPayment(
//           widget.parentId, principal, interest, _notesCtrl.text);
//     }
//     Navigator.pop(context);
//   }
// }

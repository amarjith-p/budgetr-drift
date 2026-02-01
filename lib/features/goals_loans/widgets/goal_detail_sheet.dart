// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:intl/intl.dart';
// import '../../../core/design/budgetr_colors.dart';
// import '../../../core/design/budgetr_styles.dart';
// import '../services/goal_loan_service.dart';
// import '../models/goal_loan_models.dart';
// import '../widgets/goal_loan_transaction_sheet.dart';

// class GoalDetailScreen extends StatelessWidget {
//   final GoalModel goal;
//   const GoalDetailScreen({super.key, required this.goal});

//   @override
//   Widget build(BuildContext context) {
//     final color = Color(goal.color);

//     return Scaffold(
//       backgroundColor: BudgetrColors.background,
//       appBar: AppBar(
//         backgroundColor: BudgetrColors.background,
//         elevation: 0,
//         title: Text(goal.name,
//             style: const TextStyle(color: Colors.white, fontSize: 18)),
//       ),
//       body: Column(
//         children: [
//           // 1. Status Card
//           Container(
//             width: double.infinity,
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: BudgetrColors.cardSurface,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.white.withOpacity(0.05)),
//             ),
//             child: Column(
//               children: [
//                 Text("Current Savings",
//                     style: TextStyle(
//                         color: Colors.white.withOpacity(0.5), fontSize: 12)),
//                 const SizedBox(height: 8),
//                 Text("₹${NumberFormat('#,##0.00').format(goal.currentAmount)}",
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 20),
//                 LinearProgressIndicator(
//                   value: goal.progress,
//                   backgroundColor: Colors.white10,
//                   color: color,
//                   minHeight: 8,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("0%",
//                         style: const TextStyle(
//                             color: Colors.white38, fontSize: 10)),
//                     Text(
//                         "Target: ₹${NumberFormat.compact().format(goal.targetAmount)}",
//                         style: const TextStyle(
//                             color: Colors.white70, fontSize: 12)),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // 2. Add Button
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton.icon(
//                 onPressed: () => showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   backgroundColor: Colors.transparent,
//                   builder: (_) =>
//                       GoalLoanTransactionSheet(parentId: goal.id, type: 'GOAL'),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: BudgetrColors.accent,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                 ),
//                 icon: const Icon(Icons.arrow_upward, color: Colors.white),
//                 label: const Text("ADD CONTRIBUTION",
//                     style: TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("CONTRIBUTIONS",
//                     style: TextStyle(
//                         color: Colors.white54,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1))),
//           ),
//           const SizedBox(height: 8),

//           // 3. Ledger
//           Expanded(
//             child: StreamBuilder<List<AssetLogModel>>(
//               stream: GetIt.I<GoalLoanService>().getLogsForParent(goal.id),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                       child: Text("No contributions yet.",
//                           style: TextStyle(color: Colors.white24)));
//                 }

//                 final logs = snapshot.data!;
//                 return ListView.separated(
//                   itemCount: logs.length,
//                   separatorBuilder: (_, __) =>
//                       const Divider(height: 1, color: Colors.white10),
//                   itemBuilder: (context, index) {
//                     final log = logs[index];
//                     return ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 4),
//                       title: Text(log.notes.isEmpty ? "Deposit" : log.notes,
//                           style: const TextStyle(color: Colors.white)),
//                       subtitle: Text(DateFormat('dd MMM yyyy').format(log.date),
//                           style: const TextStyle(
//                               color: Colors.white38, fontSize: 12)),
//                       trailing: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text("+ ₹${NumberFormat('#,##0').format(log.amount)}",
//                               style: const TextStyle(
//                                   color: Colors.greenAccent,
//                                   fontWeight: FontWeight.bold)),
//                           if (log.interestComponent > 0)
//                             Text(
//                                 "Inc. Interest: ₹${NumberFormat.compact().format(log.interestComponent)}",
//                                 style: const TextStyle(
//                                     color: Colors.white38, fontSize: 10)),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

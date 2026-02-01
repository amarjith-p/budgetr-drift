// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:intl/intl.dart';
// import '../../../core/design/budgetr_colors.dart';
// import '../../../core/design/budgetr_styles.dart';
// import '../services/goal_loan_service.dart';
// import '../models/goal_loan_models.dart';
// import '../widgets/goal_loan_transaction_sheet.dart';

// class LoanDetailScreen extends StatelessWidget {
//   final LoanModel loan;
//   const LoanDetailScreen({super.key, required this.loan});

//   @override
//   Widget build(BuildContext context) {
//     final isBorrowed = loan.type == 'BORROWED';
//     final statusColor = isBorrowed ? Colors.redAccent : Colors.greenAccent;

//     return Scaffold(
//       backgroundColor: BudgetrColors.background,
//       appBar: AppBar(
//         backgroundColor: BudgetrColors.background,
//         elevation: 0,
//         title: Text(loan.title,
//             style: const TextStyle(color: Colors.white, fontSize: 18)),
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.edit, color: Colors.white),
//               onPressed: () {}),
//         ],
//       ),
//       body: Column(
//         children: [
//           // 1. Primary Status Card
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
//                 Text("Outstanding Balance",
//                     style: TextStyle(
//                         color: Colors.white.withOpacity(0.5), fontSize: 12)),
//                 const SizedBox(height: 8),
//                 Text("₹${NumberFormat('#,##0.00').format(loan.remaining)}",
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 20),
//                 const Divider(color: Colors.white10),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildDetailRow("Principal",
//                         "₹${NumberFormat.compact().format(loan.totalAmount)}"),
//                     _buildDetailRow("Rate", "${loan.interestRate}%"),
//                     _buildDetailRow("Paid",
//                         "₹${NumberFormat.compact().format(loan.paidAmount)}"),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // 2. Action Buttons
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
//                   builder: (_) => GoalLoanTransactionSheet(
//                       parentId: loan.id, type: 'LOAN', isLoanPayment: true),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: statusColor,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                 ),
//                 icon: const Icon(Icons.add, color: Colors.white),
//                 label: Text(isBorrowed ? "ADD REPAYMENT" : "ADD COLLECTION",
//                     style: const TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("LEDGER",
//                     style: TextStyle(
//                         color: Colors.white54,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1))),
//           ),
//           const SizedBox(height: 8),

//           // 3. Ledger List (Feature Rich Breakdown)
//           Expanded(
//             child: StreamBuilder<List<AssetLogModel>>(
//               stream: GetIt.I<GoalLoanService>().getLogsForParent(loan.id),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                       child: Text("No transactions recorded.",
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
//                       title: Text(log.notes.isEmpty ? "Payment" : log.notes,
//                           style: const TextStyle(color: Colors.white)),
//                       subtitle: Text(DateFormat('dd MMM yyyy').format(log.date),
//                           style: const TextStyle(
//                               color: Colors.white38, fontSize: 12)),
//                       trailing: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text("₹${NumberFormat('#,##0').format(log.amount)}",
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                           Text(
//                               "P: ${NumberFormat.compact().format(log.principalComponent)}  I: ${NumberFormat.compact().format(log.interestComponent)}",
//                               style: const TextStyle(
//                                   color: Colors.white38, fontSize: 10)),
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

//   Widget _buildDetailRow(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(color: Colors.white38, fontSize: 11)),
//         const SizedBox(height: 2),
//         Text(value,
//             style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600)),
//       ],
//     );
//   }
// }

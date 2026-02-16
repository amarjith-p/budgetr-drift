import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../screens/category_breakdown_screen.dart';
import '../models/expense_models.dart';
import '../../credit_tracker/models/credit_models.dart';

class CategoryExportSheet extends StatelessWidget {
  final List<CategoryBreakdownItem> incomeItems;
  final List<CategoryBreakdownItem> expenseItems;
  final String dateRangeName;
  final String filterAccountName;
  final String groupingType; // [NEW] "Bucket" or "Category"
  final Map<String, String> accountNameMap;
  final double totalIncome;
  final double totalExpense;

  const CategoryExportSheet({
    super.key,
    required this.incomeItems,
    required this.expenseItems,
    required this.dateRangeName,
    required this.filterAccountName,
    required this.groupingType, // [NEW]
    required this.accountNameMap,
    required this.totalIncome,
    required this.totalExpense,
  });

  // --- SAVE HELPER ---
  Future<String?> _saveFileToDevice(
      String defaultFileName, List<int> bytes) async {
    String? outputFile;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Open Directory Picker
        String? directory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select Folder to Save Report',
        );

        if (directory != null) {
          final String dateFolderName =
              DateFormat('dd-MM-yyyy').format(DateTime.now());
          final String folderPath = p.join(directory, dateFolderName);
          final Directory dateDir = Directory(folderPath);
          if (!await dateDir.exists()) {
            await dateDir.create(recursive: true);
          }
          outputFile = p.join(folderPath, defaultFileName);
        }
      } else {
        // Desktop Fallback
        outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Export',
          fileName: defaultFileName,
        );
      }

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
        return outputFile;
      }
    } catch (e) {
      debugPrint("Save Error: $e");
      return null;
    }
    return null;
  }

  // --- HELPER: Generate Safe Filename ---
  String _generateSafeFileName(String extension) {
    // 1. Sanitize Account Name
    String safeAccount = filterAccountName
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '');

    // 2. Sanitize Date Range
    String safeDate =
        dateRangeName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '');

    // 3. [NEW] Add Grouping Type (Bucket/Category)
    String type = groupingType.replaceAll(' ', '');

    // 4. [NEW] Add Timestamp (HHmm) to ensure uniqueness
    String timestamp = DateFormat('HHmm').format(DateTime.now());

    return "BudgetR_${safeAccount}_${safeDate}_${type}_$timestamp.$extension";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1B263B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.save_as_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                "Save Report",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildExportOption(
            context,
            icon: Icons.table_chart_outlined,
            title: "Save as CSV",
            subtitle: "Save spreadsheet ($groupingType View)",
            color: const Color(0xFF2E7D32),
            onTap: () => _generateAndSaveCSV(context),
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            context,
            icon: Icons.picture_as_pdf_outlined,
            title: "Save as PDF",
            subtitle: "Save formatted report ($groupingType View)",
            color: const Color(0xFFC62828),
            onTap: () => _generateAndSavePDF(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExportOption(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CSV GENERATION & SAVE ---
  Future<void> _generateAndSaveCSV(BuildContext context) async {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final List<_CsvRowData> flatList = [];

      void collectItems(List<CategoryBreakdownItem> items) {
        for (var catItem in items) {
          for (var subItem in catItem.subcategories) {
            for (var txn in subItem.transactions) {
              DateTime date;
              String category;
              String subCategory;
              String notes;
              double amount;
              String type;
              String accountName = "Unknown";
              String bucket = "General";

              if (txn is ExpenseTransactionModel) {
                date = txn.date;
                category = txn.category;
                subCategory = txn.subCategory;
                notes = txn.notes;
                amount = txn.amount;
                type = txn.type;
                accountName = accountNameMap[txn.accountId] ?? "Unknown Bank";
                if (txn.bucket.isNotEmpty) bucket = txn.bucket;
              } else if (txn is CreditTransactionModel) {
                date = txn.date;
                category = txn.category;
                subCategory = txn.subCategory;
                notes = txn.notes;
                amount = txn.amount;
                type = txn.type;
                accountName = accountNameMap[txn.cardId] ?? "Unknown Card";
                if (txn.bucket.isNotEmpty) bucket = txn.bucket;
              } else {
                continue;
              }

              flatList.add(_CsvRowData(
                date: date,
                bucket: bucket,
                category: category,
                subCategory: subCategory,
                notes: notes,
                amount: amount,
                type: type,
                account: accountName,
              ));
            }
          }
        }
      }

      collectItems(incomeItems);
      collectItems(expenseItems);

      flatList.sort((a, b) => b.date.compareTo(a.date));

      List<List<dynamic>> rows = [
        [
          "Date",
          "Account",
          "Bucket",
          "Category",
          "Subcategory",
          "Notes",
          "Amount",
          "Type"
        ]
      ];

      for (var row in flatList) {
        rows.add([
          dateFormat.format(row.date),
          row.account,
          row.bucket,
          row.category,
          row.subCategory,
          row.notes,
          row.amount,
          row.type,
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      final List<int> bytes = utf8.encode(csvData);

      // [UPDATED] Use safer filename
      final fileName = _generateSafeFileName("csv");

      if (context.mounted) Navigator.pop(context);

      final savedPath = await _saveFileToDevice(fileName, bytes);

      if (savedPath != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Saved to $savedPath"),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () => Share.shareXFiles([XFile(savedPath)],
                    text: 'Opening Report'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("CSV Export Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Export Failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- PDF GENERATION & SAVE ---
  Future<void> _generateAndSavePDF(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final currency = NumberFormat.currency(
          locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 2);
      final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      final bool hasBudgetLimits =
          expenseItems.any((i) => i.budgetLimit != null);
      double totalBudget = 0.0;
      if (hasBudgetLimits) {
        for (var item in expenseItems) {
          if (item.budgetLimit != null) totalBudget += item.budgetLimit!;
        }
      }

      pdf.addPage(
        pw.MultiPage(
          theme: pw.ThemeData.withFont(base: ttf),
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("BudgetR Report",
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(dateRangeName,
                          style: const pw.TextStyle(
                              fontSize: 14, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Filter: $filterAccountName",
                            style: pw.TextStyle(
                                fontSize: 12, color: PdfColors.grey600)),
                        pw.Text("View: $groupingType",
                            style: pw.TextStyle(
                                fontSize: 12,
                                color:
                                    PdfColors.grey600)), // [NEW] Show View Type
                      ])
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(children: [
                    pw.Text("Total Income",
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700)),
                    pw.Text(currency.format(totalIncome),
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700)),
                  ]),
                  pw.Container(width: 1, height: 30, color: PdfColors.grey300),
                  pw.Column(children: [
                    pw.Text("Total Expense",
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700)),
                    pw.Text(currency.format(totalExpense),
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red700)),
                  ]),
                  if (hasBudgetLimits) ...[
                    pw.Container(
                        width: 1, height: 30, color: PdfColors.grey300),
                    pw.Column(children: [
                      pw.Text("Total Budget",
                          style: const pw.TextStyle(
                              fontSize: 12, color: PdfColors.grey700)),
                      pw.Text(currency.format(totalBudget),
                          style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey700)),
                    ]),
                  ] else ...[
                    pw.Container(
                        width: 1, height: 30, color: PdfColors.grey300),
                    pw.Column(children: [
                      pw.Text("Net Balance",
                          style: const pw.TextStyle(
                              fontSize: 12, color: PdfColors.grey700)),
                      pw.Text(currency.format(totalIncome - totalExpense),
                          style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey700)),
                    ]),
                  ]
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            if (incomeItems.isNotEmpty) ...[
              pw.Text("Income Breakdown",
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800)),
              pw.SizedBox(height: 10),
              _buildStandardPdfTable(
                  context, incomeItems, totalIncome, currency),
              pw.SizedBox(height: 20),
            ],

            if (expenseItems.isNotEmpty) ...[
              pw.Text("Expense Breakdown",
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800)),
              pw.SizedBox(height: 10),
              hasBudgetLimits
                  ? _buildBudgetPdfTable(context, expenseItems, currency)
                  : _buildStandardPdfTable(
                      context, expenseItems, totalExpense, currency),
            ],

            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey300),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Generated by BudGetR",
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey500)),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();

      // [UPDATED] Use safer filename
      final fileName = _generateSafeFileName("pdf");

      if (context.mounted) Navigator.pop(context);

      final savedPath = await _saveFileToDevice(fileName, bytes);

      if (savedPath != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Saved to $savedPath"),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () => Share.shareXFiles([XFile(savedPath)],
                    text: 'Opening Report'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("PDF Export Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Export Failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  pw.Widget _buildStandardPdfTable(pw.Context context,
      List<CategoryBreakdownItem> items, double total, NumberFormat currency) {
    return pw.Table.fromTextArray(
      context: context,
      border: null,
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      rowDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      data: <List<String>>[
        <String>['Group / Category', '% Share', 'Amount'],
        ...items.map((item) {
          final percent = total > 0
              ? (item.totalAmount / total * 100).toStringAsFixed(1)
              : "0.0";
          return [item.name, "$percent%", currency.format(item.totalAmount)];
        }),
      ],
    );
  }

  pw.Widget _buildBudgetPdfTable(pw.Context context,
      List<CategoryBreakdownItem> items, NumberFormat currency) {
    final headers = ['Bucket', 'Spent', 'Limit', 'Util %', 'Balance'];

    return pw.Table(
      border: null,
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
          children: headers
              .map((h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(h,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          fontSize: 10))))
              .toList(),
        ),
        ...items.map((item) {
          final limit = item.budgetLimit ?? 0;
          final spent = item.totalAmount;
          final balance = limit - spent;
          final util =
              limit > 0 ? (spent / limit * 100).toStringAsFixed(1) : "-";
          final limitText = limit > 0 ? currency.format(limit) : "Unbudgeted";

          final balanceColor = limit == 0
              ? PdfColors.grey700
              : (balance >= 0 ? PdfColors.green700 : PdfColors.red700);
          final balancePrefix =
              limit == 0 ? "" : (balance >= 0 ? "Left: " : "Over: ");

          return pw.TableRow(
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey200))),
              children: [
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(item.name,
                        style: const pw.TextStyle(fontSize: 10))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(currency.format(spent),
                        style: const pw.TextStyle(fontSize: 10))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(limitText,
                        style: const pw.TextStyle(fontSize: 10))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text("$util%",
                        style: const pw.TextStyle(fontSize: 10))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                        "$balancePrefix${currency.format(balance.abs())}",
                        style: pw.TextStyle(
                            fontSize: 10,
                            color: balanceColor,
                            fontWeight: pw.FontWeight.bold))),
              ]);
        })
      ],
    );
  }
}

class _CsvRowData {
  final DateTime date;
  final String bucket;
  final String category;
  final String subCategory;
  final String notes;
  final double amount;
  final String type;
  final String account;

  _CsvRowData({
    required this.date,
    required this.bucket,
    required this.category,
    required this.subCategory,
    required this.notes,
    required this.amount,
    required this.type,
    required this.account,
  });
}

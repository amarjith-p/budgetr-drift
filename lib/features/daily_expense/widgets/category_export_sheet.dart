import 'dart:io';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;

import '../screens/category_breakdown_screen.dart';
import '../models/expense_models.dart';
import '../../credit_tracker/models/credit_models.dart';

/// [NEW] Holds both the public storage path and the safe cache path
class ExportResult {
  final String publicPath;
  final String safeCachePath;

  ExportResult({required this.publicPath, required this.safeCachePath});
}

class CategoryExportSheet extends StatefulWidget {
  final List<CategoryBreakdownItem> incomeItems;
  final List<CategoryBreakdownItem> expenseItems;
  final String dateRangeName;
  final String filterAccountName;
  final String groupingType;
  final Map<String, String> accountNameMap;
  final double totalIncome;
  final double totalExpense;

  const CategoryExportSheet({
    super.key,
    required this.incomeItems,
    required this.expenseItems,
    required this.dateRangeName,
    required this.filterAccountName,
    required this.groupingType,
    required this.accountNameMap,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  State<CategoryExportSheet> createState() => _CategoryExportSheetState();
}

class _CategoryExportSheetState extends State<CategoryExportSheet> {
  bool _isExporting = false;
  String _exportMessage = "";

  // --- SAVE HELPER (TWO-PATH SYSTEM FOR BYPASSING SCOPED STORAGE) ---
  Future<ExportResult> _saveFileToDevice(
      String defaultFileName, dynamic content, String formatFolder) async {
    try {
      // 1. PUBLIC PATH: FinStack 360/Transactions/{MMM yyyy}/{format}
      final folderDate = DateFormat('dd MMM yyyy').format(DateTime.now());
      final folderPath = 'FinStack 360/Transactions/$folderDate/$formatFolder';

      Directory publicDir;
      if (Platform.isAndroid) {
        publicDir = Directory('/storage/emulated/0/Download/$folderPath');
      } else {
        final baseDir = await getApplicationDocumentsDirectory();
        publicDir = Directory(p.join(baseDir.path, folderPath));
      }

      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final publicPath = p.join(publicDir.path, defaultFileName);
      final publicFile = File(publicPath);

      // 2. SAFE CACHE PATH (For bypassing Android Scoped Storage to open safely)
      final tempDir = await getTemporaryDirectory();
      final safeCachePath = p.join(tempDir.path, defaultFileName);
      final tempFile = File(safeCachePath);

      // Write natively based on content type to prevent encoding corruption
      if (content is String) {
        await publicFile.writeAsString(content, flush: true);
        await tempFile.writeAsString(content, flush: true);
      } else if (content is Uint8List || content is List<int>) {
        await publicFile.writeAsBytes(content as List<int>, flush: true);
        await tempFile.writeAsBytes(content as List<int>, flush: true);
      }

      return ExportResult(publicPath: publicPath, safeCachePath: safeCachePath);
    } catch (e) {
      throw Exception("Storage Permission Error: $e");
    }
  }

  // --- HELPER: Generate Safe Filename ---
  String _generateSafeFileName(String extension) {
    String safeAccount = widget.filterAccountName
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '');
    String safeDate = widget.dateRangeName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '');
    String type = widget.groupingType.replaceAll(' ', '');
    String timestamp = DateFormat('HHmm').format(DateTime.now());

    return "FinStack 360_${safeAccount}_${safeDate}_${type}_$timestamp.$extension";
  }

  void _showError(BuildContext parentContext, String errorMsg) {
    showStatusSheet(
      context: parentContext,
      title: "Error",
      message: errorMsg,
      icon: Icons.error_outline_rounded,
      color: Colors.redAccent,
    );
  }

  // ============================================================================
  // EXPORT SUCCESS SHEET
  // ============================================================================
  void _showExportSuccessSheet(BuildContext parentContext, ExportResult result,
      Color themeColor, String format) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: const Color(0xff0D1B2A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15), shape: BoxShape.circle),
              child:
                  Icon(Icons.check_circle_rounded, color: themeColor, size: 48),
            ),
            const SizedBox(height: 16),
            Text("$format Export Successful",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("File Saved to:",
                      style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(result.publicPath,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: themeColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: Icon(Icons.ios_share_rounded, color: themeColor),
                    label: Text("Share",
                        style: TextStyle(
                            color: themeColor, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Share.shareXFiles([XFile(result.safeCachePath)],
                          text: "FinStack 360 $format Export");
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.file_open_rounded),
                    label: const Text("Open File",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final String mimeType =
                          format == "PDF" ? "application/pdf" : "text/csv";
                      final openResult = await OpenFile.open(
                          result.safeCachePath,
                          type: mimeType);

                      if (openResult.type != ResultType.done &&
                          parentContext.mounted) {
                        _showError(parentContext,
                            "Cannot open directly due to Android security. Please use the 'Share / Action' button instead.");
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Dismiss",
                  style: TextStyle(color: Colors.white54)),
            )
          ],
        ),
      ),
    );
  }

  // --- CSV GENERATION ---
  Future<void> _generateAndSaveCSV(BuildContext parentContext) async {
    setState(() {
      _isExporting = true;
      _exportMessage = "PREPARING SPREADSHEET...";
    });

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
                accountName =
                    widget.accountNameMap[txn.accountId] ?? "Unknown Bank";
                if (txn.bucket.isNotEmpty) bucket = txn.bucket;
              } else if (txn is CreditTransactionModel) {
                date = txn.date;
                category = txn.category;
                subCategory = txn.subCategory;
                notes = txn.notes;
                amount = txn.amount;
                type = txn.type;
                accountName =
                    widget.accountNameMap[txn.cardId] ?? "Unknown Card";
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

      collectItems(widget.incomeItems);
      collectItems(widget.expenseItems);

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

      // [FIXED] Pure UTF-8 String, no BOM. Google Sheets prefers this.
      String csvData = const ListToCsvConverter().convert(rows);
      final fileName = _generateSafeFileName("csv");

      final result = await _saveFileToDevice(fileName, csvData, "CSV");

      if (mounted) {
        setState(() => _isExporting = false);
        Navigator.pop(context); // Pop the export menu
        _showExportSuccessSheet(
            parentContext, result, const Color(0xFF2E7D32), "CSV");
      }
    } catch (e) {
      debugPrint("CSV Export Error: $e");
      if (mounted) {
        setState(() => _isExporting = false);
        Navigator.pop(context);
        _showError(parentContext, "Export Failed: $e");
      }
    }
  }

  // --- PDF GENERATION ---
  Future<void> _generateAndSavePDF(BuildContext parentContext) async {
    setState(() {
      _isExporting = true;
      _exportMessage = "GENERATING PDF DOCUMENT...";
    });

    try {
      final pdf = pw.Document();
      final currency = NumberFormat.currency(
          locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 2);
      final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final ttf = pw.Font.ttf(font);

      final bool hasBudgetLimits =
          widget.expenseItems.any((i) => i.budgetLimit != null);
      double totalBudget = 0.0;
      if (hasBudgetLimits) {
        for (var item in widget.expenseItems) {
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
                      pw.Text("FinStack 360 Report",
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.dateRangeName,
                          style: const pw.TextStyle(
                              fontSize: 14, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Filter: ${widget.filterAccountName}",
                            style: pw.TextStyle(
                                fontSize: 12, color: PdfColors.grey600)),
                        pw.Text("View: ${widget.groupingType}",
                            style: pw.TextStyle(
                                fontSize: 12, color: PdfColors.grey600)),
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
                    pw.Text(currency.format(widget.totalIncome),
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
                    pw.Text(currency.format(widget.totalExpense),
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
                      pw.Text(
                          currency
                              .format(widget.totalIncome - widget.totalExpense),
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

            if (widget.incomeItems.isNotEmpty) ...[
              pw.Text("Income Breakdown",
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800)),
              pw.SizedBox(height: 10),
              _buildStandardPdfTable(
                  context, widget.incomeItems, widget.totalIncome, currency),
              pw.SizedBox(height: 20),
            ],

            if (widget.expenseItems.isNotEmpty) ...[
              pw.Text("Expense Breakdown",
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800)),
              pw.SizedBox(height: 10),
              hasBudgetLimits
                  ? _buildBudgetPdfTable(context, widget.expenseItems, currency)
                  : _buildStandardPdfTable(context, widget.expenseItems,
                      widget.totalExpense, currency),
            ],

            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey300),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Generated by FinStack 360",
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey500)),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final fileName = _generateSafeFileName("pdf");

      final result = await _saveFileToDevice(fileName, bytes, "PDF");

      if (mounted) {
        setState(() => _isExporting = false);
        Navigator.pop(context);
        _showExportSuccessSheet(
            parentContext, result, const Color(0xFFC62828), "PDF");
      }
    } catch (e) {
      debugPrint("PDF Export Error: $e");
      if (mounted) {
        setState(() => _isExporting = false);
        Navigator.pop(context);
        _showError(parentContext, "Export Failed: $e");
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

  @override
  Widget build(BuildContext context) {
    // Capture the parent context to pass to the success sheet after popping this modal
    final parentContext = context;

    return Stack(
      children: [
        Container(
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
                  const Icon(Icons.save_as_rounded,
                      color: Colors.white, size: 24),
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
                icon: Icons.table_chart_outlined,
                title: "Save as CSV",
                subtitle: "Save spreadsheet (${widget.groupingType} View)",
                color: const Color(0xFF2E7D32),
                onTap: () => _generateAndSaveCSV(parentContext),
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                icon: Icons.picture_as_pdf_outlined,
                title: "Save as PDF",
                subtitle: "Save formatted report (${widget.groupingType} View)",
                color: const Color(0xFFC62828),
                onTap: () => _generateAndSavePDF(parentContext),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // 2. Futuristic Overlay
        if (_isExporting)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.90),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FuturisticLoader(),
                      const SizedBox(height: 32),
                      Text(
                        _exportMessage,
                        style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExportOption(
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
              Expanded(
                child: Column(
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
              ),
            ],
          ),
        ),
      ),
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

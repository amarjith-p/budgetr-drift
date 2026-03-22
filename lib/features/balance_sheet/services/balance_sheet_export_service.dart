import 'dart:io';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import '../models/balance_sheet_model.dart';

class BalanceSheetExportResult {
  final String publicPath;
  final String safeCachePath;

  BalanceSheetExportResult(
      {required this.publicPath, required this.safeCachePath});
}

class BalanceSheetExportService {
  // [FIXED] Changed the symbol from '₹' to 'Rs ' to prevent font missing glyph crashes in the PDF engine.
  final NumberFormat _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ');

  Future<BalanceSheetExportResult> _saveFile(
      String defaultFileName, dynamic content, String formatFolder) async {
    try {
      final folderDate = DateFormat('MMM yyyy').format(DateTime.now());
      final folderPath = 'FinStack 360/Balance Sheet/$folderDate/$formatFolder';

      Directory publicDir;
      if (Platform.isAndroid) {
        publicDir = Directory('/storage/emulated/0/Download/$folderPath');
      } else {
        final baseDir = await getApplicationDocumentsDirectory();
        publicDir = Directory(p.join(baseDir.path, folderPath));
      }

      if (!await publicDir.exists()) await publicDir.create(recursive: true);
      final publicPath = p.join(publicDir.path, defaultFileName);
      final publicFile = File(publicPath);

      final tempDir = await getTemporaryDirectory();
      final safeCachePath = p.join(tempDir.path, defaultFileName);
      final tempFile = File(safeCachePath);

      if (content is String) {
        await publicFile.writeAsString(content, flush: true);
        await tempFile.writeAsString(content, flush: true);
      } else if (content is Uint8List || content is List<int>) {
        await publicFile.writeAsBytes(content as List<int>, flush: true);
        await tempFile.writeAsBytes(content as List<int>, flush: true);
      }

      return BalanceSheetExportResult(
          publicPath: publicPath, safeCachePath: safeCachePath);
    } catch (e) {
      throw Exception("Storage Permission Error: $e");
    }
  }

  // --- CSV EXPORT ---
  Future<BalanceSheetExportResult> exportToCsv(
      List<BalanceSheetModel> entries) async {
    List<List<dynamic>> rows = [];

    // Headers
    rows.add([
      'DATE',
      'TITLE',
      'TYPE',
      'CATEGORY',
      'CONTACT',
      'DUE DATE',
      'TOTAL AMOUNT',
      'SETTLED',
      'REMAINING',
      'STATUS',
      'NOTES'
    ]);

    for (var e in entries) {
      double remaining = e.isSettled ? 0 : (e.amount - e.settledAmount);
      String status = e.isSettled
          ? "CLEARED"
          : ((e.dueDate != null && e.dueDate!.isBefore(DateTime.now()))
              ? "OVERDUE"
              : "PENDING");

      rows.add([
        DateFormat('yyyy-MM-dd').format(e.date),
        e.title,
        e.entryType,
        e.category,
        e.contactName ?? '',
        e.dueDate != null ? DateFormat('yyyy-MM-dd').format(e.dueDate!) : '',
        e.amount.toStringAsFixed(2),
        e.settledAmount.toStringAsFixed(2),
        remaining.toStringAsFixed(2),
        status,
        e.notes ?? ''
      ]);
    }

    String csvString = const ListToCsvConverter().convert(rows);
    String defaultName =
        "Balance_Sheet_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv";
    return await _saveFile(defaultName, csvString, 'CSV');
  }

  // --- PDF EXPORT ---
  Future<BalanceSheetExportResult> exportToPdf(
      List<BalanceSheetModel> entries) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    double totalAssets = entries
        .where((e) => e.entryType == 'ASSET')
        .fold(0, (s, e) => s + e.amount);
    double totalLiabilities = entries
        .where((e) => e.entryType == 'LIABILITY')
        .fold(0, (s, e) => s + e.amount);
    double netEquity = totalAssets - totalLiabilities;

    final headers = [
      'Date',
      'Title',
      'Type',
      'Contact/Cat',
      'Amount',
      'Remaining',
      'Status'
    ];
    final data = entries.map((e) {
      double remaining = e.isSettled ? 0 : (e.amount - e.settledAmount);
      String status = e.isSettled
          ? "CLEARED"
          : ((e.dueDate != null && e.dueDate!.isBefore(DateTime.now()))
              ? "OVERDUE"
              : "PENDING");
      return [
        DateFormat('dd MMM yyyy').format(e.date),
        e.title,
        e.entryType == 'ASSET' ? 'DR' : 'CR',
        e.contactName?.isNotEmpty == true ? e.contactName! : e.category,
        _currency.format(e.amount),
        _currency.format(remaining),
        status
      ];
    }).toList();

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4.landscape,
      theme: pw.ThemeData.withFont(base: ttf),
      margin: const pw.EdgeInsets.all(40),
      buildBackground: (pw.Context context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Transform.rotate(
              angle: -0.5,
              child: pw.Opacity(
                  opacity: 0.05,
                  child: pw.Text("FinStack 360",
                      style: pw.TextStyle(
                          fontSize: 100,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey))),
            ),
          ),
        );
      },
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        header: (pw.Context context) {
          return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 20),
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColors.grey300, width: 1))),
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("FinStack 360",
                              style: pw.TextStyle(
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(0xFF0D1B2A))),
                          pw.Text("Balance Sheet & IOUs",
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey600)),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Net Equity: ${_currency.format(netEquity)}",
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: netEquity >= 0
                                      ? PdfColors.green700
                                      : PdfColors.red700)),
                          pw.Text(
                              "Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}",
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey600)),
                        ])
                  ]));
        },
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text("Page ${context.pageNumber} of ${context.pagesCount}",
              style:
                  const pw.TextStyle(color: PdfColors.grey500, fontSize: 10)),
        ),
        build: (pw.Context context) {
          return [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total Assets: ${_currency.format(totalAssets)}",
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      "Total Liabilities: ${_currency.format(totalLiabilities)}",
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ]),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              border: null,
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0D1B2A)),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellHeight: 30,
              oddRowDecoration:
                  const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
              rowDecoration:
                  const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFFFFF)),
            ),
          ];
        },
      ),
    );

    String defaultName =
        "Balance_Sheet_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf";
    return await _saveFile(defaultName, await pdf.save(), 'PDF');
  }
}

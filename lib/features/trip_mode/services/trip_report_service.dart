import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;

import 'trip_service.dart';
import '../../../core/database/app_database.dart';

class TripReportService {
  Future<String> generatePdf(
      TripRecord trip, List<TripTransactionDto> transactions) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ');

    // Separate Transactions
    final expenses = transactions.where((t) => t.type == 'Expense').toList();
    final incomes = transactions
        .where((t) => t.type == 'Income' || t.type == 'Refund')
        .toList();

    final totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final totalIncome = incomes.fold(0.0, (sum, item) => sum + item.amount);
    final netSpend = totalExpense - totalIncome;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Original Clean Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('FinStack 360 Trip Report',
                      style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800)),
                  pw.Text('Generated: ${dateFormat.format(DateTime.now())}',
                      style: const pw.TextStyle(
                          fontSize: 12, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Trip Details
            pw.Text('Trip Name: ${trip.tripName}',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(
                'Duration: ${dateFormat.format(trip.startDate)} - ${trip.endDate != null ? dateFormat.format(trip.endDate!) : 'Ongoing'}'),
            if (trip.budget != null && trip.budget! > 0)
              pw.Text(
                  'Assigned Budget: Rs. ${trip.budget!.toStringAsFixed(2)}'),
            pw.SizedBox(height: 20),

            // Original Summary Boxes
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryBox('Net Spend', netSpend, PdfColors.blue800),
                _buildSummaryBox(
                    'Total Expense', totalExpense, PdfColors.red700),
                _buildSummaryBox(
                    'Total Income/Refunds', totalIncome, PdfColors.green700),
              ],
            ),
            pw.SizedBox(height: 30),

            // Expense Table
            if (expenses.isNotEmpty) ...[
              pw.Text('Expense Transactions',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildTransactionTable(expenses, currencyFormat),
              pw.SizedBox(height: 30),
            ],

            // Income Table
            if (incomes.isNotEmpty) ...[
              pw.Text('Income & Refund Transactions',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildTransactionTable(incomes, currencyFormat),
              pw.SizedBox(height: 30),
            ],
          ];
        },
      ),
    );

    // Save Logic matching CustomExportService
    final folderDate = DateFormat('MMM yyyy').format(DateTime.now());
    final folderPath = 'FinStack 360/Trips/$folderDate/PDF';

    Directory publicDir;
    if (Platform.isAndroid) {
      publicDir = Directory('/storage/emulated/0/Download/$folderPath');
    } else {
      final baseDir = await getApplicationDocumentsDirectory();
      publicDir = Directory(p.join(baseDir.path, folderPath));
    }

    if (!await publicDir.exists()) await publicDir.create(recursive: true);
    final sanitizedName =
        trip.tripName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final defaultFileName =
        "Trip_${sanitizedName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf";
    final publicPath = p.join(publicDir.path, defaultFileName);

    final publicFile = File(publicPath);
    await publicFile.writeAsBytes(await pdf.save(), flush: true);

    return publicPath;
  }

  // Original UI for Summary Box
  pw.Widget _buildSummaryBox(String title, double amount, PdfColor color) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style:
                  const pw.TextStyle(fontSize: 12, color: PdfColors.grey800)),
          pw.SizedBox(height: 4),
          pw.Text('Rs. ${amount.toStringAsFixed(2)}',
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // Original UI for Table
  pw.Widget _buildTransactionTable(
      List<TripTransactionDto> txns, NumberFormat currencyFormat) {
    return pw.TableHelper.fromTextArray(
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      rowDecoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
      cellAlignment: pw.Alignment.centerLeft,
      data: <List<String>>[
        ['Date', 'Category', 'Subcategory', 'Source', 'Notes', 'Amount'],
        ...txns.map((t) => [
              DateFormat('dd MMM yy').format(t.date),
              t.category,
              t.subCategory.isNotEmpty && t.subCategory != 'General'
                  ? t.subCategory
                  : '-',
              t.source == 'Credit'
                  ? 'Credit Card'
                  : 'Bank/Wallet', // <-- UPDATED SOURCE LABELS
              t.notes.isNotEmpty ? t.notes : '-',
              currencyFormat.format(t.amount)
            ]),
      ],
    );
  }
}

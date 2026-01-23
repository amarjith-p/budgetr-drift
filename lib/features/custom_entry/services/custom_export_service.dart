import 'dart:io';
import 'package:budget/core/models/custom_data_models.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;

class CustomExportService {
  // --- FORMATTING HELPER ---
  String _formatValue(dynamic val, CustomFieldConfig field) {
    if (val == null) return '';

    if (field.type == CustomFieldType.date && val is DateTime) {
      return DateFormat('dd MMM yyyy').format(val);
    } else if (field.type == CustomFieldType.currency) {
      double numVal = 0.0;
      if (val is num) {
        numVal = val.toDouble();
      } else if (val is String) {
        numVal = double.tryParse(val) ?? 0.0;
      }
      return '${field.currencySymbol ?? '₹'}${numVal.toStringAsFixed(2)}';
    } else if (field.type == CustomFieldType.serial) {
      return '${field.serialPrefix ?? ''}$val${field.serialSuffix ?? ''}';
    } else if (field.type == CustomFieldType.number) {
      String res = val.toString();
      if (field.serialSuffix != null) res += field.serialSuffix!;
      return res;
    }

    return val.toString();
  }

  // --- SAVE HELPER ---
  Future<String?> _saveFile(String defaultFileName, List<int> bytes) async {
    String? outputFile;

    if (Platform.isAndroid || Platform.isIOS) {
      String? directory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Folder to Save File',
      );

      if (directory != null) {
        outputFile = p.join(directory, defaultFileName);
      }
    } else {
      outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Export',
        fileName: defaultFileName,
      );
    }

    if (outputFile != null) {
      try {
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
        return outputFile;
      } catch (e) {
        throw Exception(
            "Permission denied. Ensure Storage Permission is enabled.");
      }
    }
    return null;
  }

  // --- CSV EXPORT (UPDATED) ---
  // Added 'totals' parameter
  Future<String?> exportToCsv(CustomTemplate template,
      List<CustomRecord> records, Map<String, double> totals) async {
    List<List<dynamic>> rows = [];

    // 1. Headers
    rows.add(template.fields.map((f) => f.name.toUpperCase()).toList());

    // 2. Data Rows
    for (var record in records) {
      List<dynamic> row = [];
      for (var field in template.fields) {
        row.add(_formatValue(record.data[field.name], field));
      }
      rows.add(row);
    }

    // 3. Totals Row (FIXED: Added this block)
    if (totals.isNotEmpty) {
      List<dynamic> totalRow = [];
      bool firstLabelSet = false;

      for (var field in template.fields) {
        if (totals.containsKey(field.name)) {
          String val = totals[field.name]!.toStringAsFixed(2);
          if (field.type == CustomFieldType.currency) {
            val = '${field.currencySymbol ?? '₹'}$val';
          }
          totalRow.add(val);
        } else if (!firstLabelSet) {
          // Place 'TOTAL' in the first non-numeric column usually
          totalRow.add('TOTAL');
          firstLabelSet = true;
        } else {
          totalRow.add('');
        }
      }
      rows.add(totalRow);
    }

    // 4. Generate CSV Data
    String csvString = const ListToCsvConverter().convert(rows);
    List<int> csvBytes = csvString.codeUnits;

    // 5. Save
    String defaultName =
        "${template.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv";
    return await _saveFile(defaultName, csvBytes);
  }

  // --- PDF EXPORT ---
  Future<String?> exportToPdf(CustomTemplate template,
      List<CustomRecord> records, Map<String, double> totals) async {
    final pdf = pw.Document();

    final headers = template.fields.map((f) => f.name.toUpperCase()).toList();
    final data = records.map((record) {
      return template.fields.map((field) {
        return _formatValue(record.data[field.name], field);
      }).toList();
    }).toList();

    final List<String> totalsRow = [];
    if (totals.isNotEmpty) {
      bool firstLabelSet = false;
      for (var field in template.fields) {
        if (totals.containsKey(field.name)) {
          String val = totals[field.name]!.toStringAsFixed(2);
          if (field.type == CustomFieldType.currency) {
            val = '${field.currencySymbol ?? '₹'}$val';
          }
          totalsRow.add(val);
        } else if (!firstLabelSet) {
          totalsRow.add('TOTAL');
          firstLabelSet = true;
        } else {
          totalsRow.add('');
        }
      }
      data.add(totalsRow);
    }

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4.landscape,
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
                child: pw.Text(
                  "BudGetR",
                  style: pw.TextStyle(
                    fontSize: 100,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey,
                  ),
                ),
              ),
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
                          pw.Text("BudGetR",
                              style: pw.TextStyle(
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(0xFF0D1B2A))),
                          pw.Text("Financial Tracker Export",
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey600)),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(template.name.toUpperCase(),
                              style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}",
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey600)),
                        ])
                  ]));
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              "Page ${context.pageNumber} of ${context.pagesCount}",
              style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10),
            ),
          );
        },
        build: (pw.Context context) {
          return [
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
              cellAlignments: {
                for (int i = 0; i < headers.length; i++)
                  i: pw.Alignment.centerLeft,
              },
              oddRowDecoration:
                  const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
              rowDecoration:
                  const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFFFFF)),
            ),
            if (totals.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("* Totals calculated based on current view",
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey)))
            ]
          ];
        },
      ),
    );

    String defaultName =
        "${template.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf";
    return await _saveFile(defaultName, await pdf.save());
  }
}

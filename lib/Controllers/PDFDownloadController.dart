import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class PDFDownloadController {
  Future<void> generatePDF({required tableData,required String tableName}) async {
    final pdf = pw.Document();

    // Define the table data
    // final tableData = [
    //   ['Name', 'Age', 'City'],
    //   ['John Doe', '28', 'New York'],
    //   ['Jane Smith', '34', 'London'],
    //   ['Sam Brown', '22', 'Sydney'],
    // ];

    // Add table to the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            context: context,
            data: tableData,
            border: pw.TableBorder.all(width: 1, color: PdfColors.black),
            cellAlignment: pw.Alignment.center,
          );
        },
      ),
    );

    // Save the PDF document
    await Printing.sharePdf(bytes: await pdf.save(), filename: '${tableName}.pdf');
  }
}

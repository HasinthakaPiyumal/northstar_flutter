import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

Future<void> generateAndDownloadPdf(List<Map<String, dynamic>> dataList) async {
  try {
    // Create a PDF document
    final PdfDocument document = PdfDocument();

    // Add a page
    final PdfPage page = document.pages.add();

    // Create a PDF grid
    final PdfGrid grid = PdfGrid();

    // Set grid columns count
    grid.columns.add(count: dataList[0].keys.length);

    // Add headers to the grid
    grid.headers.add(dataList[0].keys.toList().length);
    final PdfGridRow headerRow = grid.headers.add(1)[0];

    // Add data rows
    for (int i = 0; i < dataList.length; i++) {
      // grid.rows.add(dataList[i].values.toList());
    }

    // Set grid format
    grid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2),
    );

    // Draw the grid
    // grid.draw(page: page, bounds: const Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height));

    // Save the document
    // final List<int> bytes = document.save();
    document.dispose(); // Dispose the document

    // Get the storage directory
    final directory = await (Platform.isAndroid
        ? getExternalStorageDirectory()
        : getApplicationDocumentsDirectory());

    if (directory != null) {
      // Create a file in the directory
      final file = File('${directory.path}/data_table.pdf');

      // Write the PDF bytes to the file
      // await file.writeAsBytes(bytes, flush: true);

      // Open the PDF file
      await OpenFile.open(file.path);
    } else {
      print('Error: Directory is null');
    }
  } catch (error) {
    print('Error generating and downloading PDF: $error');
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/PDFDownloadController.dart';
import 'package:north_star/components/Buttons.dart';

class   PdfDownloadButton extends StatelessWidget {
  PdfDownloadButton({required this.tableData,required this.tableName,this.label = "Share"});
  
  final tableData;
  final String tableName;
  final String label;
  RxBool isProcessing = false.obs;

  @override
  Widget build(BuildContext context) {
    void onPress()async{
      isProcessing.value = true;
      await PDFDownloadController().generatePDF(tableData: tableData,tableName:tableName);
      isProcessing.value = false;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Align(alignment: Alignment.topRight,child: Obx(()=> Buttons.yellowFlatButton(onPressed: onPress,label: label,isLoading: isProcessing.value,width: 80,height: 36))),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:north_star/Models/HttpClient.dart';

class ViewPDF extends StatelessWidget {
  final String url;
  const ViewPDF({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News Letter PDF Attachment"),

      ),
        body:      PDF().cachedFromUrl(
          HttpClient.s3ResourcesBaseUrl+url,
          placeholder: (progress) => Center(child: Text('$progress %')),
          errorWidget: (error) => Center(child: Text(error.toString())),
        )
    );
  }
}

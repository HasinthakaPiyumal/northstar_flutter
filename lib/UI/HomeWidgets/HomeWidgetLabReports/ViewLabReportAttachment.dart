import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewLabReportAttachment extends StatelessWidget {
  const ViewLabReportAttachment({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Report Attachment'),
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(url),
      ),
    );
  }
}

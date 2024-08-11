import 'package:flutter/material.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DoorQRView extends StatelessWidget {
  const DoorQRView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Door Unlock"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: QrImageView(
              data: '206:al1lq78roigc',
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

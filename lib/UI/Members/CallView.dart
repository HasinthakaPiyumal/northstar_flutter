import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/AgoraCallController.dart';

import './InCall.dart';

class CallView extends StatefulWidget {
  const CallView({Key? key, this.callData}) : super(key: key);
  final callData;

  @override
  State<CallView> createState() => _CallView();
}

class _CallView extends State<CallView> {
  @override
  void dispose() {
    // Ensure that the ringtone and vibration are stopped when the screen is disposed
    print("Disposing incoming call");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AgoraCallController.accepted.value = false;
    AgoraCallController.callStatus.value = "Incoming";
    print(AgoraCallController.callStatus);
    void agoraInIt() async {
      await AgoraCallController.initIncoming(widget.callData);
      AgoraCallController.joinCall(widget.callData['channel']);
    }

    agoraInIt();
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backgrounds/call.png"),
            // Replace with your image path
            fit: BoxFit.cover, // You can adjust the fit as needed
          ),
        ),
        child: Obx(() => AgoraCallController.accepted.value
            ? InCall(
                callData: widget.callData,
              )
            : InCall(
          callData: widget.callData,
        )),
      ),
    ));
  }
}

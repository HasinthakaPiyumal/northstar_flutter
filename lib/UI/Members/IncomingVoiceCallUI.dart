import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/Controllers/AgoraCallController.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import './InCall.dart';
import '../../Models/HttpClient.dart';
import '../../Styles/TypographyStyles.dart';
import 'package:vibration/vibration.dart';
class IncomingVoiceCallUI extends StatefulWidget {
  const IncomingVoiceCallUI({Key? key, this.callData}) : super(key: key);
  final callData;

  @override
  State<IncomingVoiceCallUI> createState() => _IncomingVoiceCallUIState();
}

class _IncomingVoiceCallUIState extends State<IncomingVoiceCallUI> {

  bool isPlaying = false;

  // Function to play the ringtone and vibration
  void playRingtoneWithVibration() async {
    if (!isPlaying) {
      // Play the ringtone
      FlutterRingtonePlayer.playRingtone();

      // Vibrate the device
      if (await Vibration.hasVibrator()??false) {
        await Vibration.vibrate(duration: 10000,pattern: [1000, 700, 1400, 700], repeat: 1);
      }

      setState(() {
        isPlaying = true;
      });
    }
  }

  // Function to stop the ringtone and vibration
  void stopRingtoneWithVibration() {
    if (isPlaying) {
      FlutterRingtonePlayer.stop();
      Vibration.cancel();

      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    // Ensure that the ringtone and vibration are stopped when the screen is disposed
    print("Disposing incoming call");
    stopRingtoneWithVibration();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AgoraCallController.accepted.value = false;
    AgoraCallController.callStatus.value = "Incoming";
    print(AgoraCallController.callStatus);
    AgoraCallController.initIncoming(widget.callData);
    playRingtoneWithVibration();

    Future<void> leaveCall() async {
      AgoraCallController.leaveCall();
      Get.back();
    }

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
            : Column(
                children: [
                  SizedBox(
                    height: Get.height / 10,
                  ),
                  Container(
                    width: 124,
                    height: 124,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: NetworkImage(HttpClient.s3BaseUrl +
                            widget.callData['from']['avatar_url']),
                        fit: BoxFit.cover,
                      ),
                      shape: OvalBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.callData['from']['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontFamily: 'Bebas Neue',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    AgoraCallController.callStatus.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                AgoraCallController.rejectCall();
                              },
                              child: Lottie.asset(
                                'assets/lotties/call_reject.json',
                                // Replace with your animation file path
                                width: 96,
                                height: 96,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Text(
                              'Declined',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                FlutterRingtonePlayer.stop();
                                Vibration.cancel();
                                AgoraCallController.joinCall();
                              },
                              child: Lottie.asset(
                                'assets/lotties/call_answer.json',
                                // Replace with your animation file path
                                width: 96,
                                height: 96,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Text(
                              'Answer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )),
      ),
    ));
  }
}

class IncomingVoiceCallUIs extends StatelessWidget {
  const IncomingVoiceCallUIs({Key? key, this.callData}) : super(key: key);
  final callData;

  @override
  Widget build(BuildContext context) {
    // AgoraCallController.accepted.value = false;
    AgoraCallController.accepted.value = true;
    AgoraCallController.initIncoming(callData);

    Future<void> leaveCall() async {
      AgoraCallController.leaveCall();
      Get.back();
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(HttpClient.s3BaseUrl +
                          callData['from']['avatar_url']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: Get.height / 1.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.0, 0.1),
                    end: Alignment.topCenter,
                    colors: <Color>[
                      Colors.black,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: Get.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  callData['from']['name'],
                  style: TypographyStyles.title(26),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 20,
                ),
                Obx(
                  () => Visibility(
                      visible:
                          AgoraCallController.callStatus.value == 'Connected',
                      child: Text(
                          '${AgoraCallController.duration.value.inMinutes.toString().padLeft(2, '0')}:${AgoraCallController.duration.value.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 18))),
                ),
                SizedBox(height: 16),
                Obx(
                  () => Text(AgoraCallController.callStatus.value + "sss",
                      style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 80),
                Padding(
                  padding: EdgeInsets.only(bottom: 30, left: 30, right: 30),
                  child: Obx(
                    () => AgoraCallController.accepted.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: MaterialButton(
                                  onPressed: () async {
                                    AgoraCallController.switchSpeaker();
                                  },
                                  shape: CircleBorder(),
                                  color: AgoraCallController.speakerPhone.value
                                      ? Colors.white
                                      : Colors.grey,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    child: Icon(Icons.volume_up,
                                        color: AgoraCallController
                                                .speakerPhone.value
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                child: MaterialButton(
                                  onPressed: () async {
                                    leaveCall();
                                  },
                                  shape: CircleBorder(),
                                  color: Colors.red,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 25,
                                    ),
                                    child: Icon(
                                      Icons.call_end,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: MaterialButton(
                                  onPressed: () async {
                                    AgoraCallController.switchMute();
                                  },
                                  shape: CircleBorder(),
                                  color: AgoraCallController.mute.value
                                      ? Colors.white
                                      : Colors.grey,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    child: AgoraCallController.mute.value
                                        ? Icon(
                                            Icons.mic_off,
                                            color: Colors.black,
                                          )
                                        : Icon(
                                            Icons.mic,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : AgoraCallController.isJoined
                            ? Container()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: MaterialButton(
                                      onPressed: () {
                                        AgoraCallController.rejectCall();
                                      },
                                      shape: CircleBorder(),
                                      color: Colors.red,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 25,
                                        ),
                                        child: Icon(Icons.call_end,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: MaterialButton(
                                      onPressed: () {
                                        AgoraCallController.joinCall();
                                      },
                                      shape: CircleBorder(),
                                      color: Colors.green,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 25,
                                        ),
                                        child: Icon(
                                          Icons.call,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

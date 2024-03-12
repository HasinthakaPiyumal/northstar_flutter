import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';

import '../../Controllers/AgoraCallController.dart';
import '../../Models/HttpClient.dart';

class InCall extends StatelessWidget {
  const InCall({Key? key, this.callData}) : super(key: key);
  final callData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backgrounds/call.png"),
            // Replace with your image path
            fit: BoxFit.cover, // You can adjust the fit as needed
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: Get.height / 10,
            ),
            Container(
              width: 124,
              height: 124,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      HttpClient.s3BaseUrl + callData['from']['avatar_url']),
                  fit: BoxFit.cover,
                ),
                shape: OvalBorder(),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              callData['from']['name'],
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
            Obx(
              () => Text(
                AgoraCallController.callStatus.value == 'Connected'
                    ? '${AgoraCallController.duration.value.inMinutes.toString().padLeft(2, '0')}:${AgoraCallController.duration.value.inSeconds.remainder(60).toString().padLeft(2, '0')}'
                    : AgoraCallController.callStatus.value == 'Disconnected'
                        ? 'Disconnected'
                        : 'Connecting...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
            Container(
              color: AppColors.primary2Color,
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Obx(() => MaterialButton(
                        onPressed: () async {
                          AgoraCallController.switchSpeaker();
                        },
                        shape: CircleBorder(),
                        elevation: 0,
                        color: AgoraCallController.speakerPhone.value
                            ? Color(0x11FFFFFF)
                            : Color(0x00FFFFFF),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.volume_up_outlined, size: 32),
                        ),
                      )),
                  // MaterialButton(
                  //   onPressed: () async {
                  //     // AgoraCallController.switchMute();
                  //   },
                  //   shape: CircleBorder(),
                  //   elevation: 0,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Icon(Icons.video_call_rounded, size: 32),
                  //   ),
                  // ),
                  Obx(() => MaterialButton(
                        onPressed: () async {
                          AgoraCallController.switchMute();
                        },
                        shape: CircleBorder(),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            AgoraCallController.mute.value
                                ? Icons.mic_none_outlined
                                : Icons.mic_off_outlined,
                            size: 32,
                          ),
                        ),
                      )),
                  MaterialButton(
                    onPressed: () async {
                      AgoraCallController.leaveCall(back: true);
                    },
                    shape: CircleBorder(),
                    elevation: 0,
                    color: Color(0xFFFF4040),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.call_end,
                          size: 32, color: AppColors.primary2Color),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/CallData.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';

import '../../Controllers/AgoraCallController.dart';
import '../../Controllers/CallConrtoller.dart';
import '../../Models/HttpClient.dart';

void afterSeconds(int seconds) {
  Future.delayed(Duration(seconds: seconds), () {
    print('AgoraCallController.callStatus.value ${AgoraCallController.callStatus.value}');
    if(AgoraCallController.callStatus.value == 'Calling...'){
      endCall(callData.id,callData.channelName);
      AgoraCallController.leaveCall();
      // Get.back();
    }
  });
}

class VoiceCallUI extends StatelessWidget {
  VoiceCallUI({Key? key, this.user}) : super(key: key);
  final user;



  @override
  Widget build(BuildContext context) {
    AgoraCallController.init(user);
    afterSeconds(45);
    Future<bool> _onWillPop() async {
      bool canPop = false;
      bool confirmed = await CommonConfirmDialog.confirm('End Call');
      if (confirmed) {
        AgoraCallController.leaveCall();
        canPop = true;
      } else {
        canPop = false;
      }
      return canPop;
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                        HttpClient.s3BaseUrl + user['avatar_url']),
                    fit: BoxFit.cover,
                  ),
                  shape: OvalBorder(),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                user['name'],
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
                      : AgoraCallController.callStatus.value == 'Declined'?"Declined":AgoraCallController.callStatus.value=="Disconnected"?"Disconnected":'Calling...',
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
                            size: 28, color: AppColors.primary2Color),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );

  }
}

/*
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/AgoraCallController.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class VoiceCallUI extends StatelessWidget {
  const VoiceCallUI({Key? key, this.user}) : super(key: key);
  final user;

  @override
  Widget build(BuildContext context) {

    AgoraCallController.init(user);

    return Scaffold(
      body: Obx(()=> AgoraCallController.ready.value ? Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          HttpClient.s3BaseUrl + user['avatar_url']
                      ),
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
                height: Get.height/1.4,
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
                Text(user['name'],
                  style: TypographyStyles.title(26),
                ),
                SizedBox(height: 2,),
                Obx(()=>Visibility(
                    visible: AgoraCallController.callStatus.value == 'Connected',
                    child: Text('${AgoraCallController.duration.value.inMinutes.toString().padLeft(2, '0')}:${AgoraCallController.duration.value.inSeconds.remainder(60).toString().padLeft(2, '0')}', style: TextStyle(fontSize: 18))),
                ),
                SizedBox(height: 16),
                Obx(()=>Text(AgoraCallController.callStatus.value, style: TextStyle(fontSize: 18)),),
                SizedBox(height: 72),
                Padding(
                  padding: EdgeInsets.only(bottom: 30, left: 30, right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Obx(()=>MaterialButton(
                          onPressed: () async {
                            AgoraCallController.switchSpeaker();
                          },
                          shape: CircleBorder(),
                          color: AgoraCallController.speakerPhone.value ? Colors.white : colors.Colors().deepGrey(1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 15,),
                            child: Icon(Icons.volume_up, color: AgoraCallController.speakerPhone.value ? Colors.black : Colors.white ),
                          ),
                        ),),
                      ),
                      Container(
                        child:MaterialButton(
                          onPressed: () async {
                            AgoraCallController.leaveCall();
                          },
                          shape: CircleBorder(),
                          color: Colors.red,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 25,),
                            child: Icon(Icons.call_end, size: 40,),
                          ),
                        ),
                      ),
                      Container(
                        child: Obx(()=>MaterialButton(
                          onPressed: () async {
                            AgoraCallController.switchMute();
                          },
                          shape: CircleBorder(),
                          color: AgoraCallController.mute.value ? Colors.white : colors.Colors().deepGrey(1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 15,),
                            child: AgoraCallController.mute.value ? Icon(Icons.mic_off,color: Colors.black,) : Icon(Icons.mic,color: Colors.white),
                          ),
                        ),),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ): Center(
        child: CircularProgressIndicator(),
      ))
    );
  }
}
*/
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
                SizedBox(height: 20,),
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

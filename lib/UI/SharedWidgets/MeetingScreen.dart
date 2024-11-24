// import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/UI/Layout.dart' as ScreenLayout;
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:pip_view/pip_view.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../Controllers/ZegoCloudController.dart';
import '../../Styles/AppColors.dart';

class MeetingScreen extends StatefulWidget {
  late bool isMulti = false;
  late String channelName;

  MeetingScreen(this.channelName, {Key? key, this.isMulti = false})
      : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen>
    with WidgetsBindingObserver {
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _initForegroundTask();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onWillPop() async {
      bool canPop = false;
      bool confirmed = await CommonConfirmDialog.confirm('End Call');
      if (confirmed) {
        canPop = true;
      } else {
        canPop = false;
      }
      return canPop;
    }

    return WillPopScope(
        onWillPop: _onWillPop,
        child: PIPView(builder: (BuildContext context, bool isFloating) {
          return Stack(
            children: [
              Scaffold(
                resizeToAvoidBottomInset: !isFloating,
                body: ZegoUIKitPrebuiltCall(
                  appID: ZegoCloudController.appID, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
                  appSign: ZegoCloudController.appSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
                  userID: 'user_id',
                  userName: 'user_name',
                  callID: widget.channelName,
                  // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
                  config: widget.isMulti?ZegoUIKitPrebuiltCallConfig.groupVideoCall():ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
                ),
              ),

            ],
          );
        }));
  }
}

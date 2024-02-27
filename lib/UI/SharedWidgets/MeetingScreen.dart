import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/UI/Layout.dart' as ScreenLayout;
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:pip_view/pip_view.dart';

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
  late AgoraClient _client;
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAgora();
    WidgetsBinding.instance.addObserver(this);
    // _initForegroundTask();
  }

  void initAgora() async {
    // LocalNotificationsController.showNonRemovableNotification();
    print(HttpClient.baseURL+"/rtcToken");
    _client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
            appId: 'ed79caa1142a4a71846177dbf737e29e',
            channelName: widget.channelName,
            uid: authUser.id,
            tokenUrl: "https://token.northstar.mv",
            // tokenUrl: "https://4050bade-f098-48ad-8e62-690a7885b77a-00-19wik6yvqe8gh.sisko.replit.dev",
            // tokenUrl: HttpClient.baseURL+"/rtcToken",
            username: authUser.name),
        enabledPermission: [
          Permission.camera,
          Permission.microphone,
        ]);
    await _client.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget agoraStack() {
    return Stack(children: [
      AgoraVideoViewer(
        client: _client,
        layoutType: widget.isMulti ? Layout.floating : Layout.oneToOne,
        showAVState: true,
        floatingLayoutContainerHeight: 230,
        showNumberOfUsers: widget.isMulti,
      ),
      AgoraVideoButtons(
        client: _client,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onWillPop() async {
      bool canPop = false;
      bool confirmed = await CommonConfirmDialog.confirm('End Call');
      if (confirmed) {
        _client.release();
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
                body:
                    !isFloating ? SafeArea(child: agoraStack()) : agoraStack(),
              ),
              !isFloating
                  ? SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            margin: EdgeInsets.only(top:50,right: 10),
                            child: Material(
                              borderRadius: BorderRadius.circular(100),
                              color: AppColors.primary2Color.withOpacity(0.6),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () {
                                  PIPView.of(context)!
                                      .presentBelow(ScreenLayout.Layout());
                                },
                                child: Ink(
                                  padding: EdgeInsets.only(bottom: 10),
                                  decoration: ShapeDecoration(
                                    shape: CircleBorder(),
                                    color: AppColors.primary2Color.withOpacity(0.6),
                                  ),
                                  child: Icon(
                                    Icons.minimize,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox()
            ],
          );
        }));
  }
}

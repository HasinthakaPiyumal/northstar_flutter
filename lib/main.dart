import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/UI/SplashScreen.dart';
import 'package:north_star/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'Controllers/FirebaseMessageController.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'UI/Chats/ChatHome.dart';

/// define a navigator key
final navigatorKey = GlobalKey<NavigatorState>();

bool isLoggedIn = false;
bool isDarkMode = true;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Background Message ===> 1 ${message.messageId}');
  firebaseMessagingHandler(message, Uuid().v4());
  print('Background Message ===> 2 ${message.messageId}');
}


// void _handleMessage(RemoteMessage message) {
//   print(message.data);
//   if (message.data['notification_type'] == 'chat-notify') {
//     Get.to(()=>ChatHome());
//   }
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);

  /// set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  String preferenceName = "homeViewTabIndex";
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(preferenceName, 0);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   print("click notification 01");
  //   _handleMessage(message);
  // });
  // FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
  //   print("click notification 02");
  //   if (message != null) {
  //     _handleMessage(message);
  //   }
  // });

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await checkAuth();



  final currentTheme =
      isDarkMode ? ThemeAll().darkTheme : ThemeAll().lightTheme;


  // call the useSystemCallingUI
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(currentTheme), // Initial theme
        child: NorthStar(navigatorKey: navigatorKey,),
      ),
    );
  });

}

Future checkAuth() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? '';
  print("Token found -----> $token");
  isDarkMode = prefs.getBool('darkMode') ?? true;

  if (token.isEmpty) {
    isLoggedIn = false;
  } else {
    httpClient.setToken(token);
    Map res = await httpClient.authCheck();

    if (res['code'] == 200) {
      print('Printing token inner 1');
      isLoggedIn = true;
      httpClient.setToken(token);
      print(res['data']['token']);
      client.changeToken(res['data']['token']);
      print('Printing token inner 2');
      Map<String, dynamic> userData = res['data']['user'];
      if (res['data']['user']['subscription'] != null) {
        DateTime expDate =
            DateTime.parse(res['data']['user']['subscription']['valid_till']);
        if (expDate.isBefore(DateTime.now())) {
          print('Subscription is expired');
          userData.remove('subscription');
        } else {
          print('Subscription is valid');
        }
      }
      authUser.saveUser(userData);
      print('Printing token inner 3');

      // client.changeToken(res['data']['token']);
      httpClient.setToken(res['data']['token']);
    } else {
      isLoggedIn = false;
    }
  }
}

class NorthStar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  NorthStar({  required this.navigatorKey});

  @override
  State<NorthStar> createState() => _NorthStarState();
}

class _NorthStarState extends State<NorthStar> {
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    print('initialMessage====');
    print(initialMessage);
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print(message.data);
    print('Message Click Handling');
    if (message.data['notification_type'] == 'chat-notify') {
      Get.to(()=>ChatHome(selectedChatId: message.data['chat_id'],));
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupInteractedMessage();
  }
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/appicons/Northstar.png"), context);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.getTheme();

    print("Primary Color: ${ThemeAll().lightTheme.primaryColor}");
    print(
        "Scaffold Background Color: ${ThemeAll().lightTheme.scaffoldBackgroundColor}");

    return GetMaterialApp(
        title: 'North Star',
        navigatorKey: widget.navigatorKey,
        defaultTransition: Transition.rightToLeftWithFade,
        transitionDuration: Duration(milliseconds: 200),
        debugShowCheckedModeBanner: false,
        theme: themeData.copyWith(
          colorScheme: themeData.colorScheme.copyWith(
            primary: AppColors.accentColor,
          ),
        ),
        supportedLocales: [
          const Locale('en'),
        ],
        home: SplashScreen(isLoggedIn: isLoggedIn));
  }
}

class ThemeAll {
  final lightTheme = ThemeData(
    useMaterial3: false,
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(Colors.white),
      checkColor: MaterialStateProperty.all(Colors.black),
      /// Change to your desired color
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(1),
        borderSide: BorderSide(color: Colors.black),
      ),
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
      labelStyle: TextStyle(color: Colors.black),
      // focusedBorder: OutlineInputBorder(
      //   borderRadius: BorderRadius.circular(5),
      //   borderSide: BorderSide(color: AppColors.accentColor, width: 1),
      // ),

      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    ),
    buttonTheme: ButtonThemeData(buttonColor: AppColors.accentColor),
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF2F2F2),
    appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFFF2F2F2),
        iconTheme: IconThemeData(size: 30,color: AppColors.primary1Color),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          height: 0,
        )),
    dialogBackgroundColor: Colors.white,
    cardColor: Colors.white,
    primaryColor: AppColors.accentColor,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
    ),
    listTileTheme: ListTileThemeData(tileColor: Colors.white),
  );

  final darkTheme = ThemeData(
      useMaterial3: false,
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(Colors.white),
        // Change to your desired color
        checkColor: MaterialStateProperty.all(
            Colors.black), // Change to your desired color
      ),
      brightness: Brightness.dark,
      // primarySwatch: Themes.mainThemeColor,
      scaffoldBackgroundColor: AppColors.primary1Color,
      appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.primary1Color,
          iconTheme: IconThemeData(size: 30),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            height: 0,
          )),
      inputDecorationTheme: InputDecorationTheme(
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(5),
          //   borderSide: BorderSide(color: AppColors.accentColor, width: 1),
          // ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          activeIndicatorBorder:
              BorderSide(color: AppColors.accentColor, width: 1),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          labelStyle: TextStyle(color: Colors.white),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
      dialogBackgroundColor: AppColors.primary2Color,
      cardColor: AppColors.primary2Color,
      cardTheme: CardTheme(
        color: AppColors.primary2Color,
      ),
      primaryColor: AppColors.accentColor,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.primary2Color,
      ),
      focusColor: AppColors.accentColor,
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
      ),
      buttonTheme: ButtonThemeData(buttonColor: AppColors.accentColor),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: AppColors.accentColor),
      listTileTheme: ListTileThemeData(tileColor: AppColors.primary2Color));
}
// class ThemeAll {
//   final lightTheme = ThemeData(
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(),
//     ),
//     brightness: Brightness.light,
//     primarySwatch: Themes.mainThemeColor,
//     scaffoldBackgroundColor: Color(0xFFF2F2F2),
//     appBarTheme: AppBarTheme(
//       elevation: 0,
//       backgroundColor: Color(0xFFF2F2F2),
//     ),
//   );
//   final darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     primarySwatch: Themes.mainThemeColor,
//     scaffoldBackgroundColor: Color(0xFF232323),
//     appBarTheme: AppBarTheme(
//       elevation: 0,
//       backgroundColor: Color(0xFF232323),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//     ),
//   );
// }

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  ThemeData getTheme() => _themeData;

  void toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('darkMode') ?? true;
    isDarkMode = !isDarkMode;
    prefs.setBool('darkMode', isDarkMode);
    _themeData = isDarkMode ? ThemeAll().darkTheme : ThemeAll().lightTheme;
    notifyListeners();
  }
}

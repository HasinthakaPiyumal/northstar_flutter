import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/UI/Members/IncomingVoiceCallUI.dart';
import 'package:north_star/UI/SplashScreen.dart';
import 'package:north_star/firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Plugins/HttpClient.dart';
import 'Styles/AppColors.dart';

bool isLoggedIn = false;
bool isDarkMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await checkAuth();

  await OneSignal.shared.setLogLevel(OSLogLevel.none, OSLogLevel.none);

  await OneSignal.shared.setAppId("813517cd-7999-4c5b-92c5-8a1554ae9984");

  await OneSignal.shared
      .promptUserForPushNotificationPermission()
      .then((accepted) {
    print("Accepted permission: $accepted");
  });

  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    if (event.notification.body == 'Incoming Call!') {
      print("======= Incoming call ==========");
      print(event.notification.additionalData);
      Get.to(() =>
          IncomingVoiceCallUI(callData: event.notification.additionalData));
    } else {
      print('Incoming Call! Else');
      event.complete(event.notification);
    }
  });

  final currentTheme =
      isDarkMode ? ThemeAll().darkTheme : ThemeAll().lightTheme;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(currentTheme), // Initial theme
      child: NorthStar(),
    ),
  );
}

Future checkAuth() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? '';
  isDarkMode = prefs.getBool('darkMode') ?? true;

  if (token.isEmpty) {
    isLoggedIn = false;
  } else {
    httpClient.setToken(token);
    Map res = await httpClient.authCheck();

    if (res['code'] == 200) {
      isLoggedIn = true;
      httpClient.setToken(token);
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

      client.changeToken(res['data']['token']);
    } else {
      isLoggedIn = false;
    }
  }
}

class NorthStar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/appicons/Northstar.png"), context);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.getTheme();

    return GetMaterialApp(
        title: 'North Star',
        defaultTransition: Transition.fade,
        transitionDuration: Duration(milliseconds: 512),
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: SplashScreen(isLoggedIn: isLoggedIn));
  }
}

class ThemeAll {
  final lightTheme = ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
          borderSide: BorderSide(color: Colors.black),
        ),
        hintStyle: TextStyle(color: Colors.black),
        labelStyle: TextStyle(color: Colors.black),
      ),
      brightness: Brightness.light,
      primarySwatch: Themes.mainThemeColor,
      scaffoldBackgroundColor: Color(0xFFF2F2F2),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFFF2F2F2),
      ),
      dialogBackgroundColor: Colors.white,
      cardColor: Colors.white,
      primaryColor: AppColors.accentColor);

  final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Themes.mainThemeColor,
      scaffoldBackgroundColor: AppColors.primary1Color,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary1Color,
        iconTheme: IconThemeData(size: 30),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
          borderSide: BorderSide(color: Colors.white),
        ),
        hintStyle: TextStyle(color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
      ),
      dialogBackgroundColor: AppColors.primary2Color,
      cardColor: AppColors.primary2Color,
      primaryColor: AppColors.accentColor);
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/AuthHome.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/ExitWidget.dart';

class WelcomeThree extends StatelessWidget {
  const WelcomeThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    bool shouldPop = false;

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => ExitWidget(),
        );
        return shouldPop;
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/front.png"),
            fit: BoxFit.fitHeight,
            alignment: Alignment(0.4,5),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [

            ],
          ),
          bottomNavigationBar: Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: Get.height/100*6,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25, bottom: 20),
                  child: Container(
                    width: double.infinity,
                    child: RichText(
                      text: TextSpan(
                        text: 'Welcome to\n',
                        style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade100),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'NORTHSTAR FITNESS CLUB',
                            style: TypographyStyles.title(22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25, bottom: 25, right: 40,),
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                      style: TypographyStyles.normalText(14, Themes.mainThemeColorAccent.shade100),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MaterialButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>AuthHome()));
                        },
                        shape: CircleBorder(),
                        color: Themes.mainThemeColor.shade500,
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_forward_ios_outlined, color: Theme.of(context).primaryColor,),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Get.height/100*2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

class LoadingAndEmptyWidgets {
  static Widget emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                height: Get.width / 1.8,
                child: Lottie.asset(
                  Get.isDarkMode
                      ? 'assets/lotties/empty_v2.json'
                      : 'assets/lotties/empty_v2.json',
                ),
              ),

              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Text('Empty for now',
                    textAlign: TextAlign.center,
                    style: TypographyStyles.title(20)),
              )
            ],
          ),
        ],
      ),
    );
  }

  static Widget loadingWidget() {
    return Center(
      child: Container(
        height: 96,
        width: 96,
        child: Lottie.asset('assets/lotties/loading.json'),
      ),
    );
  }
}

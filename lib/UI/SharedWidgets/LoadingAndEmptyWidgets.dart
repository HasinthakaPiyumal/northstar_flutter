import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoadingAndEmptyWidgets {

  static Widget emptyWidget(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                height: Get.width / 1.5,
                child: Lottie.asset(
                  Get.isDarkMode ? 'assets/lotties/empty_dark.json' : 'assets/lotties/empty_white.json',
                ),
              ),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Text('Nothing here Yet!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    color: Color(0xFF9B9B9B),
                    fontSize: 18
                )),
              )
            ],
          ),

        ],
      ),
    );
  }

  static Widget loadingWidget(){
    return Center(
      child: Container(
        height: 96,
        width: 96,
        child: Lottie.asset('assets/lotties/loading.json'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

class ListItem extends StatelessWidget {
  Function onTap;
  String text;

  ListItem({Key? key, required this.onTap, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            onTap();
          },
          borderRadius: BorderRadius.circular(5),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset("assets/svgs/help_support.svg"),
                      SizedBox(
                        width: 12,
                      ),
                      Container(
                        width: Get.width - 125,
                        child: Text(
                          text.capitalizeFirst as String,
                          // overflow: TextOverflow.ellipsis,
                          // maxLines: 2,
                          style: TypographyStyles.text(16),
                        ),
                      )
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios_rounded)
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}

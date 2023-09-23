import 'package:flutter/material.dart';

import '../Styles/AppColors.dart';

class ImageUploader{
  Widget getImageUploader({required Function handler}){
    return InkWell(
      onTap: () {
        handler();
      },
      customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child: Ink(
        decoration: ShapeDecoration(
          color: Color(0xFF1E2630),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Container(
          width: 398,
          height: 124,
          child: Icon(Icons.add_photo_alternate_outlined,
              color: AppColors
                  .accentColor),
        ),
      ),
    );
  }
}
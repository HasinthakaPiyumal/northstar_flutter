import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../Styles/AppColors.dart';

class ImageUploader extends StatefulWidget {
  Function handler;

  ImageUploader({Key? key, required this.handler}) : super(key: key);

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  dynamic _imageFile;

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      widget.handler(pickedFile);
    } else {
      // _handleError(response.exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        getImage();
      },
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Ink(
        decoration: ShapeDecoration(
          color: Color(0xFF1E2630),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Container(
          width: Get.width,
          height: 124,
          child: _imageFile != null
              ? Stack(

                children: [
                  Container(
                    width: Get.width,
                    child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Opacity(
                            opacity: 0.4,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_imageFile.path),
                                  fit: BoxFit.cover,
                                ))),
                      ),
                  ),
                  Positioned(
                      child: Center(
                        child: Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.accentColor),
                      ))
                ],
              )
              : Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.accentColor),
        ),
      ),
    );
  }
// Widget getImageUploader({required Function handler,required dynamic image}){
//   return ;
// }
}

/*
* ToDo: Usage Example
  ImageUploader(handler: (img) {
    setState(() {
      _imageFile = img;
    });
  }),
* */

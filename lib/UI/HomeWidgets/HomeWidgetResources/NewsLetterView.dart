import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetResources/ViewPDF.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/components/Buttons.dart';

class NewsLetterView extends StatelessWidget {
  const NewsLetterView({Key? key, required this.newsLetter}) : super(key: key);
  final Map newsLetter;

  @override
  Widget build(BuildContext context) {

    print('newsLetter');
    print(newsLetter);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Get.height / 3,
              width: Get.width,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: HttpClient.s3ResourcesBaseUrl + newsLetter['image'],
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(newsLetter['title'],
                style: TypographyStyles.title(25),
              ),
            ),
            SizedBox(height: 15,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Html(data: newsLetter['article'],
                style: {
                  "p": Style(color: Get.isDarkMode?Colors.white:Colors.black, fontSize: FontSize(16)),
                  "li": Style(padding: HtmlPaddings.only(left:5, right: 5)),
                },
              ),
            ),
            SizedBox(height: 15,),
            Visibility(
              visible: newsLetter['pdf']!=null && newsLetter['pdf']!='',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Buttons.outlineButton(onPressed: (){
                  Get.to(()=>ViewPDF(url: newsLetter['pdf']));
                },label: 'View PDF'),
              ),
            )

          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:cached_network_image/cached_network_image.dart';

class Step {
  Step(
    this.title,
    this.body,
    this.isExpanded
  );
  String title;
  String body;
  RxBool isExpanded;
}

class ViewResourceDoc extends StatelessWidget {
  const ViewResourceDoc({Key? key, this.data, this.image, this.index}) : super(key: key);

  final data;
  final image;
  final index;

  @override
  Widget build(BuildContext context) {

    late RxList steps = [].obs;

    void articleBuilder(){

      List article = data['article'].toString().split(RegExp("<h[1-7]>"));

      if(article.length > 1){
        article.forEach((element) {
          if(element.length > 0) {
            List tElement = element.split(RegExp('</h[1-7]>'));
            steps.add(Step(tElement[0].toString().trim(), tElement[1].toString().trim(),false.obs));
          }
        });
      }

      steps.forEach((element) {
        print('element: ${element.title}');
      });
    }

    articleBuilder();

    return Scaffold(
      appBar: AppBar(
        title: Text("${data['title']}",
          style: TypographyStyles.title(20),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'image$index',
                  child: Container(
                    height: Get.width - 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(HttpClient.s3ResourcesBaseUrl + image),
                        fit: BoxFit.cover
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Text("${data['title']}",
                  style: TypographyStyles.title(20),
                ),
                SizedBox(height: 10),
                Text("${data['description']}",
                  style: TypographyStyles.normalText(16, Colors.white),
                ),
                SizedBox(height: 25),
                Obx(() => ExpansionPanelList(
                  expansionCallback: (panelIndex, isExpanded){
                    steps[panelIndex].isExpanded.value= isExpanded;
                  },
                  expandedHeaderPadding: EdgeInsets.zero,
                  children: steps.map<ExpansionPanel>((step) {
                    print('step.body');
                    print(step.body);
                    return ExpansionPanel(
                      canTapOnHeader: true,
                      backgroundColor: Get.isDarkMode? AppColors.primary2Color:Colors.white,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text(step.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                      body: Html(data: step.body,
                        style: {
                          "*": Style(color: Colors.white, fontSize: FontSize(16)),
                          "li": Style(padding: HtmlPaddings.only(left:5, right: 5)),
                        },
                      ),
                      isExpanded: step.isExpanded.value,
                    );
                  }).toList(),
                )),
                SizedBox(height: 32),
                data['courtesy_notes']!=null? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                          minRadius: 25,
                          backgroundImage: CachedNetworkImageProvider(HttpClient.s3ResourcesBaseUrl+data['courtesy_notes']['image'])
                      ),
                      SizedBox(width: 10,),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['courtesy_notes']['title'].toString().capitalizeFirst.toString()+'. '+data['courtesy_notes']['name'].toString().capitalizeFirst.toString(),
                            style: TypographyStyles.title(18),
                          ),
                          SizedBox(height: 5,),
                          Text(data['courtesy_notes']['description'].toString().capitalizeFirst.toString(),
                            style: TextStyle(
                              color: colors.Colors().selectedCardBG.withOpacity(0.8),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ):Container(),
                SizedBox(height: 32),
              ],
            ),
          ),
      ),
    );
  }
}

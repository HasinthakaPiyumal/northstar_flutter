import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetResources/NewsLetterView.dart';

class ViewNewsLetters extends StatelessWidget {
  const ViewNewsLetters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList newsLetters = [].obs;
    RxBool ready = false.obs;

    void getNewsLetters() async {
      Map res = await httpClient.getNewsLetters();
      if (res['code'] == 200) {
        newsLetters.value = res['data'];
        print(newsLetters);
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    getNewsLetters();

    return Scaffold(
      appBar: AppBar(title: Text('Newsletters')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Obx(() => ready.value
            ? ListView.builder(
                itemCount: newsLetters.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: (){
                        Get.to(()=>NewsLetterView(newsLetter: newsLetters[index]));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        children: [
                          Container(
                            height: Get.height / 4,
                            width: Get.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: HttpClient.s3ResourcesBaseUrl + newsLetters[index]['image'],
                              ),
                            ),
                          ),
                          ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            title: Text(newsLetters[index]['title'],style: TypographyStyles.text(16),),
                            subtitle: Text(newsLetters[index]['created_at'].split('T').first),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              )),
      ),
    );
  }
}

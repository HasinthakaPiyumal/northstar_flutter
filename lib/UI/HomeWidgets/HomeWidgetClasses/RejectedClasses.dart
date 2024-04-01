import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClasses/CreateClass.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/components/Buttons.dart';

class RejectedClasses extends StatelessWidget {
  const RejectedClasses();

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList classes = [].obs;

    void getData()async{
      ready.value = false;
      Map res = await httpClient.getRejectedClasses();
      if(res['code']==200){
        print(res['data']);
        classes.value = res['data'];
        ready.value = true;
      }else{
        ready.value = true;
        print(res);
      }
    }
    getData();
    return Obx(()=> ready.value?SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          classes.length>0?ListView.builder(
            itemCount: classes.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              Map cls = classes[index];
              return Container(
                margin: EdgeInsets.only( bottom: index!=classes.length-1?0:16,top: 16,left: 16,right: 16),
                padding: EdgeInsets.all( 16),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                  borderRadius: BorderRadius.circular(10),),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(cls['class_name'].toString().capitalizeFirst.toString(),style: TypographyStyles.title(18),overflow: TextOverflow.ellipsis,)),
                        Container(decoration: BoxDecoration(
                          color: Color(0xFFFFB8B8),
                          borderRadius: BorderRadius.circular(100),
                        ),
                          padding:EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                          child: Text("Admin Rejected",style: TypographyStyles.text(12).copyWith(color: AppColors.textOnAccentColor),),
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Text(cls['description'].toString().capitalizeFirst.toString(),style: TypographyStyles.text(14),),
                    SizedBox(height: 10,)
                    ,Row(
                        children:[
                          Icon(Icons.watch_later_outlined),
                          SizedBox(width: 10,),
                          Text(DateFormat("yyyy-MM-dd HH:mm a").format(DateTime.parse(cls['shedule_time'])).toString(),style: TypographyStyles.text(16),),
                        ]
                    ),
                    SizedBox(height: 10,),
                    Row(
                        children:[
                          Icon(Icons.location_on_outlined),
                          SizedBox(width: 10,),
                          Text(cls['location'].toString(),style: TypographyStyles.text(16),),
                        ]
                    ),
                  ],
                ),
              );
            },
          ):Center(child: Container(height: 100,child: Center(child: Text('No class found')),)),

        ],
      ),
    ):LoadingAndEmptyWidgets.loadingWidget(),
    );
  }
}

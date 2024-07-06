import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClasses/CreateClass.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClasses/EditClass.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/components/Buttons.dart';

class ActiveClasses extends StatelessWidget {
  const ActiveClasses();

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList classes = [].obs;

    void getData()async{
      ready.value = false;
      Map res = await httpClient.getActiveClasses();
      if(res['code']==200){
        print(res['data']);
        classes.value = res['data'];
        ready.value = true;
      }else{
        ready.value = true;
        print(res);
      }
    }

    void deleteClass(int classId){
      CommonConfirmDialog.confirm("Remove").then((value)async{
        if(value){
          await httpClient.deleteClass(classId);
          getData();
        }

      }
      );
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
                      Text(cls['class_name'].toString().capitalizeFirst.toString(),style: TypographyStyles.title(18),),
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
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Buttons.yellowFlatButton(onPressed: (){
                            Get.to(()=>EditClass(classData: cls))?.then((value) => getData());
                          },label:'Edit Details',width: 120),
                          SizedBox(width: 8,),
                          Buttons.outlineButton(onPressed: (){
                            deleteClass(cls['id']);
                          },label:'Remove',width: 120)
                        ],
                      )
                    ],
                  ),
                );
              },
          ):Center(child: Container(height: 100,child: Center(child: Text('No class found')),)),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Buttons.yellowTextIconButton(icon:Icons.add,onPressed: (){Get.to(CreateClass())?.then((value) => getData());},label: "Create Class",width: 160),
          )
        ],
      ),
    ):LoadingAndEmptyWidgets.loadingWidget(),
    );
  }
}

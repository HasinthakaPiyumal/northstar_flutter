import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/PrivateDoctor/PrescriptionsManager/CreatePrescription.dart';

class PrescriptionManager extends StatelessWidget {
  const PrescriptionManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Manager'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              child: Column(
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      CircleAvatar(
                        radius: 30,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Blake Alexandar', style: TypographyStyles.title(16),),
                          SizedBox(
                            height: 8,
                          ),
                          Text('24 Yrs'),
                        ],
                      )
                    ],
                  ),

                  Divider(),

                  Row(

                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date'),
                          Text('12/12/2020', style: TypographyStyles.title(14),),
                        ],
                      ),
                      SizedBox(
                        width: Get.width * 0.2,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time'),
                          Text('2.30 PM', style: TypographyStyles.title(14),),
                        ],
                      ),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 16,
                  ),
                  Visibility(
                    visible: index.isOdd,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      width: Get.width,
                      child: ElevatedButton(
                        style: ButtonStyles.bigFlatBlackButton(),
                        onPressed: (){
                          Get.to(()=> CreatePrescription());
                        },
                        child: Text('Create Prescription'),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: index.isEven,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      width: Get.width,
                      child: ElevatedButton(
                        style: ButtonStyles.bigFlatGreyButton(),
                        onPressed: (){
                          //Get.to(()=>ViewPrescription());
                        },
                        child: Text('View Prescription'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          );

        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

class FoodCalView extends StatelessWidget {
  const FoodCalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 128,
              width: Get.width,
              child: Card(
                child: Padding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Calories 260', style: TypographyStyles.boldText(24,Colors.white),),
                      Text('(Based on 1 Serving)', style: TypographyStyles.normalText(16,Colors.white),)
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.black,
              ),
            ),
            SizedBox(height: 32),
            Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 16),
                    Text('Nutrition Facts', style: TypographyStyles.boldText(18,Colors.black),),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  width: Get.width,
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Energy', style: TypographyStyles.title(16),),
                              Text('260 Cal', style: TypographyStyles.title(16),),
                              Text('10%', style: TypographyStyles.title(16),)
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Fat', style: TypographyStyles.title(16),),
                              Text('3.6 g', style: TypographyStyles.title(16),),
                              Text('10%', style: TypographyStyles.title(16),)
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Other', style: TypographyStyles.title(16),),
                              Text('50g', style: TypographyStyles.title(16),),
                              Text('80%', style: TypographyStyles.title(16),)
                            ],
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Color(0xffF2F2F2),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Material(
                          borderRadius: BorderRadius.circular(16),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Quantity',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: Material(
                          borderRadius: BorderRadius.circular(16),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Serving Size',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Total'),
                      SizedBox(width: 16),
                      Text('260g', style: TypographyStyles.title(21),),
                      Spacer(),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(64)
                              )
                          ),
                          onPressed: (){}, child: Text('Add'))
                    ],
                  )
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Color(0xffF2F2F2),
              ),
            )
          ],
        ),
      ),
    );
  }
}

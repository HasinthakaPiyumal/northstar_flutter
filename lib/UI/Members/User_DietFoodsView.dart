import 'package:flutter/material.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../SharedWidgets/RingsWidget.dart';

class UserDietFoodsView extends StatelessWidget {

  const UserDietFoodsView({Key? key, required this.mealData, required this.eatenCarbs, required this.eatenFat, required this.eatenProteins, required this.targetCarbs, required this.targetFat, required this.targetProteins, required this.eatenCal, required this.targetCal}) : super(key: key);
  final Map mealData;

  final int eatenCarbs, eatenFat, eatenProteins, targetCarbs, targetFat, targetProteins;
  final int eatenCal, targetCal;

  @override
  Widget build(BuildContext context) {

    print(mealData['meals']);

    return Scaffold(
      appBar: AppBar(
        title: Text('User Diet Foods'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Eaten'),
                                  Text(eatenCal.ceil().toString() +' Cal', style: TypographyStyles.title(24),),
                                  SizedBox(height: 16),
                                  Text('Remaining'),
                                  Text((targetCal - eatenCal).round().toString() + ' Cal', style: TypographyStyles.title(24),),
                                ],
                              ),
                              Container(
                                height: 150,
                                width: 150,
                                child: SafeArea(
                                  child: SfCircularChart(
                                      margin: EdgeInsets.zero,
                                      series:  <RadialBarSeries<ChartData, int>>[
                                        RadialBarSeries<ChartData, int>(
                                          useSeriesColor: true,
                                          trackOpacity: 0.175,
                                          maximumValue: 100,
                                          radius: "70",
                                          innerRadius: "15",
                                          gap: "3",
                                          cornerStyle: CornerStyle.bothCurve,
                                          dataSource: [
                                            ChartData(radius: 3, value: eatenFat / targetFat*100, color : const Color(0xFF1FC52A)),
                                            ChartData(radius: 2, value: eatenProteins / targetProteins*100, color : const Color(0xFFEC2F2F)),
                                            ChartData(radius: 1, value: eatenCarbs / targetCarbs*100, color : const Color(0xFFF5BB1D)),
                                            ChartData(radius: 0, value: eatenCal / targetCal*100, color : const Color(0xFF5576E3)),
                                          ],
                                          //pointRadiusMapper: (ChartData data, _) => data.radius.toString(),
                                          pointColorMapper: (ChartData data, _) => data.color,
                                          xValueMapper: (ChartData sales, _) => 0,
                                          yValueMapper: (ChartData sales, _) => sales.value,
                                        )
                                      ]
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 16),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 4,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Carbs', style: TypographyStyles.title(14)),
                                    SizedBox(height: 4),
                                    Text(eatenCarbs.toStringAsFixed(1) +' / '+ targetCarbs.toStringAsFixed(1)+'g'),
                                  ],
                                ),
                                VerticalDivider(width: 1),
                                Container(
                                  width: 4,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Fat', style: TypographyStyles.title(14)),
                                    SizedBox(height: 4),
                                    Text(eatenFat.toStringAsFixed(1) +' / '+ targetFat.toStringAsFixed(1)+'g'),
                                  ],
                                ),
                                VerticalDivider(width: 1),
                                Container(
                                  width: 4,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Proteins', style: TypographyStyles.title(14)),
                                    SizedBox(height: 4),
                                    Text(eatenProteins.toStringAsFixed(1) +' / '+ targetProteins.toStringAsFixed(1)+'g'),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                ),
            ),
            ListView.builder(
              itemCount: mealData['meals'].length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Meal '+ (index+1).toString(), style: TypographyStyles.title(16),),
                          trailing: Text(mealData['meals'][index]['calories'].toString() + ' Cal'),
                        ),
                        SizedBox(height: 8),
                        Divider(height: 1),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: mealData['meals'][index]['food_data'].length,
                          itemBuilder: (_,index2){
                            return ListTile(
                              dense: true,
                              title: Text(mealData['meals'][index]['food_data'][index2]['name'], style: TypographyStyles.title(16),),
                                trailing: Text(mealData['meals'][index]['food_data'][index2]['calories'].toString() + ' Cal'),
                                subtitle: Text(mealData['meals'][index]['food_data'][index2]['potion'].toString() + 'g'),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {

  final double radius,value;
  final Color color;

  ChartData({required this.radius, required this.value, required this.color});

}

Widget ringsChart(Map homeData){
  return SfCircularChart(
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
            ChartData(radius: 3, value: homeData['macros']['daily_fat'] / homeData['macros']['target_fat']*100, color : const Color(0xFF1FC52A)),
            ChartData(radius: 2, value: homeData['macros']['daily_protein'] / homeData['macros']['target_protein']*100, color : const Color(0xFFEC2F2F)),
            ChartData(radius: 1, value: homeData['macros']['daily_carbs'] / homeData['macros']['target_carbs']*100, color : const Color(0xFFF5BB1D)),
            ChartData(radius: 0, value: homeData['macros']['daily_calories'] / homeData['macros']['target_calories']*100, color : const Color(0xFF5576E3)),
          ],
          //pointRadiusMapper: (ChartData data, _) => data.radius.toString(),
          pointColorMapper: (ChartData data, _) => data.color,
          xValueMapper: (ChartData sales, _) => 0,
          yValueMapper: (ChartData sales, _) => sales.value,
        )
      ]
  );
}

Widget ringsWidget(Map homeData){
  return Container(
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 128,
          width: 128,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 128,
          height: 128,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: homeData['macros']['daily_calories'] / homeData['macros']['target_calories'],
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 128,
          height: 128,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: 1,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue.withOpacity(0.125)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 104,
          height: 104,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: homeData['macros']['daily_carbs'] / homeData['macros']['target_carbs'],
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 104,
          height: 104,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: 1,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange.withOpacity(0.125)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: homeData['macros']['daily_protein'] / homeData['macros']['target_protein'],
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: 1,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red.withOpacity(0.125)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: homeData['macros']['daily_fat'] / homeData['macros']['target_fat'],
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: 1,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green.withOpacity(0.125)),
          ),
        ),
      ],
    ),
  );
}


Widget ringsChartCalories(Map macrosData){
  return SfCircularChart(
      margin: EdgeInsets.zero,
      series:  <RadialBarSeries<ChartData, int>>[
        RadialBarSeries<ChartData, int>(
          useSeriesColor: true,
          trackOpacity: 0.175,
          maximumValue: 100,
          radius: "63",
          innerRadius: "15",
          gap: "3",
          cornerStyle: CornerStyle.bothCurve,
          dataSource: [
            ChartData(radius: 3, value: macrosData['daily_fat'] / macrosData['target_fat']*100, color : const Color(0xFF1FC52A)),
            ChartData(radius: 2, value: macrosData['daily_protein'] / macrosData['target_protein']*100, color : const Color(0xFFEC2F2F)),
            ChartData(radius: 1, value: macrosData['daily_carbs'] / macrosData['target_carbs']*100, color : const Color(0xFFF5BB1D)),
            ChartData(radius: 0, value: macrosData['daily_calories'] / macrosData['target_calories']*100, color : const Color(0xFF5576E3)),
          ],
          //pointRadiusMapper: (ChartData data, _) => data.radius.toString(),
          pointColorMapper: (ChartData data, _) => data.color,
          xValueMapper: (ChartData sales, _) => 0,
          yValueMapper: (ChartData sales, _) => sales.value,
        )
      ]
  );
}

Widget ringsWidgetCalories(Map macrosData){
  return Container(
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 128,
          width: 128,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 128,
          height: 128,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: macrosData['daily_calories'] / macrosData['target_calories'],
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 128,
          height: 128,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: 1,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue.withOpacity(0.125)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 104,
          height: 104,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: macrosData['daily_carbs'] / macrosData['target_carbs'],
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 104,
          height: 104,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: 1,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange.withOpacity(0.125)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: macrosData['daily_protein'] / macrosData['target_protein'],
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: 1,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red.withOpacity(0.125)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: macrosData['daily_fat'] / macrosData['target_fat'],
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            value: 1,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green.withOpacity(0.125)),
          ),
        ),
      ],
    ),
  );
}

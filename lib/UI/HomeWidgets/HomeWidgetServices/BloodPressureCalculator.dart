import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../../components/Buttons.dart';

class BloodPressureCalculator extends StatefulWidget {
  const BloodPressureCalculator({Key? key}) : super(key: key);

  @override
  _BloodPressureCalculatorState createState() => _BloodPressureCalculatorState();
}

class _BloodPressureCalculatorState extends State<BloodPressureCalculator> {
  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxMap result = {}.obs;
    TextEditingController systolicController = TextEditingController();
    TextEditingController diastolicController = TextEditingController();

    void getBP() async {
      ready.value = true;
      Map res = await httpClient.healthServicesBP({
        'systolic': systolicController.text,
        'diastolic': diastolicController.text,
      });

      if (res['code'] == 200) {
        result.value = res['data'];
        ready.value = true;
      } else {
        showSnack('Incorrect Values!', res['data']['info'].toString());
        ready.value = true;
      }
    }

    Widget cardHealth(value, category, unit) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Utils.colorBMI(category)[0],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit,
                    style: TypographyStyles.normalText(
                        14, Utils.colorBMI(category)[1])),
                Text(category,
                    style: TypographyStyles.boldText(
                        16, Utils.colorBMI(category)[1]))
              ],
            ),
            Text(value.toString() + " mmHg",
                style:
                TypographyStyles.boldText(24, Utils.colorBMI(category)[1])),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Pressure Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 40,),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: systolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Systolic',
                      suffix: Text("mmHg",
                        style: TypographyStyles.normalText(14, Themes.mainThemeColor.shade500),
                      ),
                      hintText: '120',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Transform.scale(
                    scale: 2,
                    child: Text("/",
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: diastolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Diastolic',
                      suffix: Text("mmHg",
                        style: TypographyStyles.normalText(14, Themes.mainThemeColor.shade500),
                      ),
                      hintText: '80',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            Container(
              width: Get.width,
                child: Buttons.yellowFlatButton(onPressed:  (){getBP();},label: "calculae")),

            SizedBox(height: 16),
            Obx(()=>result['success'] != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                cardHealth(
                    result['Systolic']
                        .toString() +
                        '/' +
                        result['Diastolic']
                            .toString(),
                    result['BloodPressureCategory'],
                    'Blood Pressure'),
                SizedBox(height: 8),
              ],
            )
                : Container()),
          ],
        ),
      ),
    );
  }
}

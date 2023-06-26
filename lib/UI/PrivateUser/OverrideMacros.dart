import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

class OverrideMacros extends StatelessWidget {
  const OverrideMacros({Key? key, required this.macroPlanId}) : super(key: key);

  final int macroPlanId;

  @override
  Widget build(BuildContext context) {
    RxBool readyButton = false.obs;
    RxBool advanced = true.obs;

    TextEditingController carbs = new TextEditingController();
    TextEditingController proteins = new TextEditingController();
    TextEditingController fats = new TextEditingController();


    //ADV.
    RxString selectedFitCategory = 'Loss'.obs;
    RxString selectedFitProgram = 'Moderate'.obs;
    RxString selectedFitMode = 'Controlled'.obs;

    RxList<String> fitCategories = ['Loss', 'Gain'].obs;
    RxList<String> fitPrograms = ['Moderate', 'Intense'].obs;
    RxList<String> fitModes = ['Controlled', 'Accelerated', 'SuperAccelerated'].obs;

    TextEditingController weightController = new TextEditingController();

    TextEditingController frontUA = new TextEditingController();
    TextEditingController backUA = new TextEditingController();
    TextEditingController sideW = new TextEditingController();
    TextEditingController backBS = new TextEditingController();

    void saveMacros() async {
      readyButton.value = true;
      Map res = await httpClient.overrideMacros({
        'trainer_id': authUser.id,
        'id': macroPlanId,
        'target_carbs': carbs.text,
        'target_protein': proteins.text,
        'target_fat': fats.text,
      });

      if (res['code'] == 200) {
        print(res);
        Get.back();
        showSnack('Success!', 'Macro profile overridden.');
        readyButton.value = true;
      } else {
        showSnack('Error!', 'Something went wrong.');
        readyButton.value = true;
      }
    }

    void saveAdvMacros() async {
      readyButton.value = true;
      var diff = DateTime.now().difference(DateTime.parse(authUser.user['birthday']));
      int age = diff.inDays ~/ 365;

      Map res = await httpClient.overrideAdvMacros({
        'trainer_id': authUser.id,
        'id': macroPlanId,
        'selectedFitCategory': selectedFitCategory.value,
        'selectedFitProgram': selectedFitProgram.value,
        'selectedFitMode': selectedFitMode.value,
        'front_upper_arm': frontUA.text,
        'back_upper_arm': backUA.text,
        'side_of_waist': sideW.text,
        'back_below_shoulder': backBS.text,
        'age': age,
        'gender': authUser.user['gender'],
        'weight': weightController.text,
      });

      if (res['code'] == 200) {
        Get.back();
        showSnack('Success!', 'Macro profile overridden.');
        readyButton.value = true;
      } else {
        showSnack('Error!', 'Something went wrong.');
        readyButton.value = true;
      }
    }

    print(macroPlanId);

    return Scaffold(
        appBar: AppBar(
          title: Text('Override Macros'),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Obx(()=>Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: Get.width * 0.4,
                        height: 40,
                        child: ElevatedButton(
                          style: advanced.value ? SignUpStyles.notSelectedButton():SignUpStyles.selectedButton(),
                          child: Text('Basic'),
                          onPressed: (){
                            advanced.value = !advanced.value;
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: Get.width * 0.4,
                        height: 40,
                        child: ElevatedButton(
                          style: !advanced.value ? SignUpStyles.notSelectedButton():SignUpStyles.selectedButton(),
                          child: Text('Advanced'),
                          onPressed: (){
                            advanced.value = !advanced.value;
                          },
                        ),
                      ),
                    ],
                  ),),
                  SizedBox(height: 16),

                  Obx(() => !advanced.value ?Column(
                    children: [
                      TextField(
                        controller: carbs,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Target Carbs (g)',
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: proteins,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Target Proteins (g)',
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: fats,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Target Fats (g)',
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ):Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fitness Category'),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Material(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedFitCategory.value,
                                      onChanged: (String? newValue) {
                                        if (newValue == 'Gain') {
                                          fitModes.value = ['CalBoost', 'ProteinBoost'];
                                          fitPrograms.value = [
                                            'Moderate',
                                            'Intense',
                                            'HighActive'
                                          ];
                                          selectedFitProgram.value = 'Moderate';
                                          selectedFitMode.value = 'CalBoost';
                                        } else {
                                          fitModes.value = [
                                            'Controlled',
                                            'Accelerated',
                                            'SuperAccelerated'
                                          ].obs;
                                          fitPrograms.value = ['Moderate', 'Intense'];
                                          selectedFitProgram.value = 'Moderate';
                                          selectedFitMode.value = 'Controlled';
                                        }

                                        selectedFitCategory.value = newValue!;
                                      },
                                      items: fitCategories
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value.toString()),
                                            );
                                          }).toList(),
                                    )),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Fitness Program'),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedFitProgram.value,
                                      onChanged: (String? newValue) {
                                        selectedFitProgram.value = newValue!;
                                      },
                                      items: fitPrograms.map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value.toString()),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Fitness Mode'),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedFitMode.value,
                                      onChanged: (String? newValue) {
                                        selectedFitMode.value = newValue!;
                                      },
                                      items: fitModes
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value.toString(),
                                            textAlign: TextAlign.end,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              controller: frontUA,
                              decoration: InputDecoration(
                                labelText: 'Front of Upper Arm (mm)',
                                hintText: 'Front of Upper Arm in millimeters',
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              controller: backUA,
                              decoration: InputDecoration(
                                labelText: 'Back of Upper Arm (mm)',
                                hintText: 'Back of Upper Arm in millimeters',
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              controller: sideW,
                              decoration: InputDecoration(
                                labelText: 'Side of Waist (mm)',
                                hintText: 'Side of Waist in millimeters',
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              controller: backBS,
                              decoration: InputDecoration(
                                labelText: 'Back Below Shoulder (mm)',
                                hintText: 'Back Below Shoulder in millimeters',
                              ),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          hintText: 'Weight in Kilograms',
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),),

                  Container(
                    width: Get.width,
                    height: 56,
                    child: ElevatedButton(
                      style: ButtonStyles.bigBlackButton(),
                      onPressed: (){
                        if(advanced.value){
                          saveAdvMacros();
                        } else{
                          saveMacros();
                        }
                      },
                      child: Text('Save'),
                    ),
                  )
                ],
              )),
        ));
  }
}

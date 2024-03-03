import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDietaryConsultation.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetLabReports.dart';
import 'package:north_star/UI/SharedWidgets/RingsWidget.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';

class UserViewHealth extends StatelessWidget {
late Map data = {};
  UserViewHealth({Key? key, required this.userID, required this.data}) : super(key: key);
  final int userID;

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxBool readyButton = false.obs;
    RxMap healthData = {}.obs;
    RxBool canIEditP = false.obs;
    RxBool canIEditD = false.obs;
    RxBool canIEditAsAClient = false.obs;

    RxString selectedFitCategory = 'Loss'.obs;
    RxString selectedFitProgram = 'Moderate'.obs;
    RxString selectedFitMode = 'Controlled'.obs;

    RxList<String> fitCategories = ['Loss', 'Gain'].obs;
    RxList<String> fitPrograms = ['Moderate', 'Intense'].obs;
    RxList<String> fitModes =
        ['Controlled', 'Accelerated', 'SuperAccelerated'].obs;

    TextEditingController weightController = new TextEditingController();
    TextEditingController heightController = new TextEditingController();

    TextEditingController frontUA = new TextEditingController();
    TextEditingController backUA = new TextEditingController();
    TextEditingController sideW = new TextEditingController();
    TextEditingController backBS = new TextEditingController();

    TextEditingController fbs = new TextEditingController();
    TextEditingController rbs = new TextEditingController();

    TextEditingController systolic = new TextEditingController();
    TextEditingController diastolic = new TextEditingController();

    TextEditingController bust = new TextEditingController();
    TextEditingController stomach = new TextEditingController();
    TextEditingController chest = new TextEditingController();
    TextEditingController calves = new TextEditingController();
    TextEditingController hips = new TextEditingController();
    TextEditingController thighs = new TextEditingController();
    TextEditingController lArm = new TextEditingController();
    TextEditingController rArm = new TextEditingController();

    void sendNotificationAfterChangingClientDataByTrainer(int clientId) {
      print("Client updated");
      if (clientId != authUser.id) {
        print("Sending notification");
        httpClient.sendNotification(
            clientId,
            'Your health profile updated!',
            'Your Trainer ${authUser.name} has updated your profile.',
            NSNotificationTypes.ClientProfileUpdated, {
          'trainer_id': authUser.id,
          'trainer_name': authUser.name,
        });
      }
    }

    void getUserHealthData() async {
      Map res = await httpClient.getClientHealthData(userID);
      try {
        if (res['code'] == 200) {
          healthData.value = res['data'];
          if (authUser.role == 'trainer') {
            if (healthData['user_data']['diet_trainer_id'] == null) {
              canIEditP.value = true;
              canIEditD.value = true;
              print('I Can Edit');
            } else {
              if (healthData['user_data']['diet_trainer_id'] == authUser.id) {
                canIEditD.value = true;
                canIEditP.value = false;
                print('I Can Edit');
              } else if (healthData['user_data']['physical_trainer_id'] ==
                  authUser.id) {
                canIEditD.value = false;
                canIEditP.value = true;
                print('I Can Edit');
              }
            }
          } else if (authUser.id == userID) {
            if (healthData['user_data']['diet_trainer_id'] == null &&
                healthData['user_data']['physical_trainer_id'] == null) {
              print('I Can Edit');
              canIEditD.value = true;
              canIEditP.value = true;
            }
          } else {
            canIEditD.value = canIEditAsAClient.value;
            canIEditP.value = canIEditAsAClient.value;
            print('I Can Not Edit');
          }
          if (authUser.role == "client") {
            canIEditAsAClient.value =
                healthData['user_data']['physical_trainer_id'] == null &&
                    healthData['user_data']['physical_trainer_id'] == null;
            canIEditD.value = canIEditAsAClient.value;
            canIEditP.value = canIEditAsAClient.value;
            print('I Can All and I am a Client');
          }
          ready.value = true;
          print(res['data']);
        } else {
          print(res);
          ready.value = true;
        }
      } on Exception catch (e) {
        // TODO
        print("Error");
        ready.value = true;
        print(e);
      }
      print('Healthdata 01 -->$healthData');
    }

    void refreshAndClose(res) {
      if (res['code'] == 200) {
        //print(res);
        getUserHealthData();
        readyButton.value = true;
        Get.back();
      } else {
        //print(res);
        readyButton.value = true;
        Get.back();
        showSnack('Something Went Wrong!', res['data']['error']);
      }
    }

    void saveBMIPI() async {
      readyButton.value = true;
      Map res = await httpClient.saveHealthData(
          {'weight': weightController.text, 'height': heightController.text},
          userID,
          'bmi-pi');
      print(res);
      if(res['code']==200){
        sendNotificationAfterChangingClientDataByTrainer(userID);
      }
      refreshAndClose(res);
    }

    void saveFATMM() async {
      readyButton.value = true;
      var diff =
          DateTime.now().difference(DateTime.parse(authUser.user['birthday']));
      int age = diff.inDays ~/ 365;

      Map res = await httpClient.saveHealthData({
        'front_upper_arm': frontUA.text,
        'back_upper_arm': backUA.text,
        'side_of_waist': sideW.text,
        'back_below_shoulder': backBS.text,
        'age': age,
        'gender': authUser.user['gender'],
        'weight': weightController.text,
      }, userID, 'fat-mm');
      if(res['code']==200){
        sendNotificationAfterChangingClientDataByTrainer(userID);
      }
      refreshAndClose(res);
    }

    void saveBS() async {
      readyButton.value = true;
      Map res = await httpClient.saveHealthData({
        'fbs': fbs.text,
        'rbs': rbs.text,
      }, userID, 'blood-sugar');
      if(res['code']==200){
        sendNotificationAfterChangingClientDataByTrainer(userID);
      }
      refreshAndClose(res);
    }

    void saveBP() async {
      readyButton.value = true;
      Map res = await httpClient.saveHealthData({
        'systolic': systolic.text,
        'diastolic': diastolic.text,
      }, userID, 'blood-pressure');
      if(res['code']==200){
        sendNotificationAfterChangingClientDataByTrainer(userID);
      }
      refreshAndClose(res);
    }

    void saveBM() async {
      readyButton.value = true;

      readyButton.value = true;
      Map res = await httpClient.saveHealthData({
        'bust': bust.text,
        'stomach': stomach.text,
        'chest': chest.text,
        'calves': calves.text,
        'hips': hips.text,
        'thighs': thighs.text,
        'l_arm': lArm.text,
        'r_arm': rArm.text,
      }, userID, 'misc');
      if(res['code']==200){
        sendNotificationAfterChangingClientDataByTrainer(userID);
      }
      refreshAndClose(res);
    }

    void saveMacros() async {
      readyButton.value = true;

      Map res = await httpClient.saveHealthData({
        'trainer_id': authUser.id,
        'selectedFitCategory': selectedFitCategory.value,
        'selectedFitProgram': selectedFitProgram.value,
        'selectedFitMode': selectedFitMode.value,
      }, userID, 'macros');

      print(res);

      if (res['code'] == 200) {
        if (authUser.role == "trainer") {
          httpClient.sendNotification(
              userID,
              'Macro Profile Updated!',
              'Your Macro profile has been updated by your trainer.',
              NSNotificationTypes.MarcoProfileUpdated, {
            'trainer_id': authUser.id,
            'trainer_name': authUser.name,
          });
        }
        refreshAndClose(res);
      } else {
        showSnack('Error!', res['data']['info']['error']);
      }
    }

    void updateBMIPI() {
      Get.defaultDialog(
        radius: 8.0,
        title: 'Update BMI & PI',
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  hintText: 'Height in Centimeters',
                ),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              saveBMIPI();
            },
          ),
        ],
      );
    }

    void updateFATMM() {
      Get.defaultDialog(
        radius: 8.0,
        title: 'Update BodyFat',
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
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
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: backUA,
                    decoration: InputDecoration(
                      labelText: 'Back of Upper Arm (mm)',
                      hintText: 'Back of Upper Arm in millimeters',
                    ),
                  )),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: sideW,
                    decoration: InputDecoration(
                      labelText: 'Side of Waist (mm)',
                      hintText: 'Side of Waist in millimeters',
                    ),
                  )),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              saveFATMM();
            },
          ),
        ],
      );
    }

    void updateBS() {
      Get.defaultDialog(
        radius: 8.0,
        title: 'Update Blood Sugar',
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: fbs,
                decoration: InputDecoration(
                  labelText: 'Fasting Blood Sugar (mg/dl)',
                  hintText: 'Fasting Blood Sugar in milligrams per decilitre',
                ),
              ),
              SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: rbs,
                decoration: InputDecoration(
                  labelText: 'Post Blood Sugar (mg/dl)',
                  hintText: 'Post Blood Sugar in milligrams per decilitre',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              saveBS();
            },
          ),
        ],
      );
    }

    void updateBP() {
      Get.defaultDialog(
        radius: 8.0,
        title: 'Update Blood Pressure',
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: systolic,
                decoration: InputDecoration(
                  labelText: 'Systolic (mmHg)',
                  hintText: 'Systolic in millimeters of mercury',
                ),
              ),
              SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: diastolic,
                decoration: InputDecoration(
                  labelText: 'Diastolic (mmHg)',
                  hintText: 'Diastolic in millimeters of mercury',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              if (double.parse(systolic.text.toString()) < 0 ||
                  double.parse(systolic.text.toString()) < 0) {
                showSnack('Invalid Range',
                    'Blood Pressure values must be more than 0 mmHg');
              } else {
                saveBP();
              }
            },
          ),
        ],
      );
    }

    void updateBM() {
      Get.defaultDialog(
        radius: 8.0,
        title: 'Update Body Measurements',
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: bust,
                    decoration: InputDecoration(
                      labelText: 'Bust (cm)',
                      hintText: 'Bust in centimeters',
                    ),
                  )),
                  SizedBox(width: 4),
                  Expanded(
                      child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: stomach,
                    decoration: InputDecoration(
                      labelText: 'Stomach (cm)',
                      hintText: 'Stomach in centimeters',
                    ),
                  ))
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: chest,
                    decoration: InputDecoration(
                      labelText: 'Chest (cm)',
                      hintText: 'Chest in centimeters',
                    ),
                  )),
                  SizedBox(width: 4),
                  Expanded(
                      child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: calves,
                    decoration: InputDecoration(
                      labelText: 'Calves (cm)',
                      hintText: 'Calves in centimeters',
                    ),
                  ))
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      controller: hips,
                      decoration: InputDecoration(
                        labelText: 'Hips (cm)',
                        hintText: 'Hips in centimeters',
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      controller: thighs,
                      decoration: InputDecoration(
                        labelText: 'Thighs (cm)',
                        hintText: 'Thighs in centimeters',
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
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: lArm,
                    decoration: InputDecoration(
                      labelText: 'Left Arm (cm)',
                      hintText: 'left Arm in centimeters',
                    ),
                  )),
                  SizedBox(width: 4),
                  Expanded(
                      child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: rArm,
                    decoration: InputDecoration(
                      labelText: 'Right Arm (cm)',
                      hintText: 'Right Arm in centimeters',
                    ),
                  ))
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              saveBM();
            },
          ),
        ],
      );
    }

    void updateMacros() {
      Get.defaultDialog(
        radius: 8.0,
        title: 'Update Macros',
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Obx(() => Column(
                children: <Widget>[
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
                      ))
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
                              items: fitModes.map<DropdownMenuItem<String>>(
                                  (String value) {
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
                      ))
                    ],
                  )
                ],
              )),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              saveMacros();
            },
          ),
        ],
      );
    }

    getUserHealthData();
    print('Health data printing--->$healthData');
    Widget cardHealth(value, category, unit, color) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit,
                  style: TextStyle(
                    color: Color(0xFF1B1F24),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    color: Color(0xFF1B1F24),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: Color(0xFF1E2630),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(value.toString(),
                  style: TypographyStyles.boldText(24, Colors.white)),
            ),
          ],
        ),
      );
    }

    String bodyFatImage(String bodyFatType) {

      dynamic gender = healthData.isNotEmpty && data['gender']!=null?data['gender']:authUser.user['gender'];
      print('==gender');
      print(authUser.user);
      print(authUser.user);
      if ( gender== 'male') {
        if (bodyFatType == 'Above Average') {
          return 'assets/images/men-body-type-3.png';
        } else if (bodyFatType == 'Good') {
          return 'assets/images/men-body-type-2.png';
        } else {
          return 'assets/images/men-body-type-1.png';
        }
      } else {
        if (bodyFatType == 'Above Average') {
          return 'assets/images/women-body-type-3.png';
        } else if (bodyFatType == 'Good') {
          return 'assets/images/women-body-type-2.png';
        } else {
          return 'assets/images/women-body-type-1.png';
        }
      }
    }

    return Scaffold(
      body: Obx(() => ready.value
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      width: Get.width,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => HomeWidgetLabReports(userID: userID));
                        },
                        style: ButtonStyles.bigPrimaryButton(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 16),
                            Text(
                              "View Lab Reports",
                              style: TypographyStyles.title(20),
                            ),
                            Spacer(),
                            Icon(
                              Icons.arrow_forward_outlined,
                              size: 20,
                              color: Get.isDarkMode
                                  ? Themes.mainThemeColorAccent.shade100
                                  : colors.Colors().lightBlack(1),
                            ),
                            SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      width: Get.width,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() =>
                              HomeWidgetDietaryConsultation(userId: userID));
                        },
                        style: ButtonStyles.bigPrimaryButton(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 16),
                            Text(
                              "Dietary Consultation",
                              style: TypographyStyles.title(20),
                            ),
                            Spacer(),
                            Icon(
                              Icons.arrow_forward_outlined,
                              size: 20,
                              color: Get.isDarkMode
                                  ? Themes.mainThemeColorAccent.shade100
                                  : colors.Colors().lightBlack(1),
                            ),
                            SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Macros',
                                          style: TypographyStyles.title(20)),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      healthData['macros'] != null
                                          ? healthData['macros']['override']
                                              ? Text('( Override Profile )')
                                              : Text(
                                                  'Weight ' +
                                                      healthData['macros']
                                                          ['fit_category'] +
                                                      ' | ' +
                                                      healthData['macros']
                                                          ['fit_program'],
                                                  style:
                                                      TypographyStyles.text(16))
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                                healthData['macros'] != null
                                    ? Container(
                                        height: 135,
                                        width: 135,
                                        child: ringsChartCalories(
                                            healthData['macros']),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                healthData['macros'] != null
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30),
                                                    height: 98,
                                                    decoration: BoxDecoration(
                                                        color: healthData[
                                                                        'macros']
                                                                    [
                                                                    'daily_calories'] >
                                                                healthData[
                                                                        'macros']
                                                                    [
                                                                    'target_calories']
                                                            ? Colors.red
                                                            : Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text('Current',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            )),
                                                        Text(
                                                            healthData['macros']
                                                                    [
                                                                    'daily_calories']
                                                                .toString(),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30),
                                                    height: 98,
                                                    decoration: BoxDecoration(
                                                        color: Get.isDarkMode
                                                            ? AppColors
                                                                .primary1Color
                                                            : AppColors
                                                                .baseColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text('Target',
                                                            style:
                                                                TypographyStyles
                                                                    .text(16)),
                                                        Text(
                                                          healthData['macros'][
                                                                  'target_calories']
                                                              .toString(),
                                                          style:
                                                              TypographyStyles
                                                                  .title(20),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                                healthData['macros'] != null
                                    ? SizedBox(height: 12)
                                    : SizedBox(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    healthData['macros'] != null
                                        ? Text(
                                            'Updated on : ' +
                                                DateFormat("MMM dd,yyyy HH:mm")
                                                    .format(DateTime.parse(
                                                        healthData['macros'][
                                                                'updated_at'] ??
                                                            "")),
                                            style: TypographyStyles.text(14),
                                          )
                                        : Text(
                                            'No data found',
                                            style: TypographyStyles.text(14),
                                          ),
                                    Visibility(
                                      visible: authUser.role == 'trainer' ||
                                          (authUser.role == 'client' &&
                                              canIEditAsAClient.value),
                                      child: canIEditD.value
                                          ? ElevatedButton(
                                              style: ButtonStyles
                                                  .bigFlatYellowButton(),
                                              onPressed: () {
                                                updateMacros();
                                              },
                                              child: Text(
                                                'Update',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textOnAccentColor,
                                                  fontSize: 20,
                                                  fontFamily: 'Bebas Neue',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                showSnack(
                                                    'Client Has a Secondary Trainer!',
                                                    'If a client has a secondary trainer, only they can edit the client\'s macros.');
                                              },
                                              icon: Icon(
                                                Icons.info_outline,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('BMI', style: TypographyStyles.title(20)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                healthData['bmi_pi'] != null
                                    ? SizedBox(height: 10)
                                    : SizedBox(),
                                healthData['bmi_pi'] != null
                                    ? cardHealth(
                                        healthData['bmi_pi']['bmi'],
                                        healthData['bmi_pi']['bmi_category'],
                                        'Body Mass Index (BMI)',
                                        Color(0xFFC3FB67))
                                    : SizedBox(),
                                healthData['bmi_pi'] != null
                                    ? SizedBox(height: 8)
                                    : SizedBox(),
                                healthData['bmi_pi'] != null
                                    ? cardHealth(
                                        healthData['bmi_pi']['pi'],
                                        healthData['bmi_pi']['pi_category'],
                                        'Ponderal Index (PI)',
                                        Color(0xFFC3FB67))
                                    : SizedBox(),
                                healthData['bmi_pi'] != null
                                    ? SizedBox(height: 12)
                                    : SizedBox(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    healthData['bmi_pi'] != null
                                        ? Expanded(
                                            child: Text(
                                                'Updated on : ' +
                                                    DateFormat("MMM dd,yyyy HH:mm")
                                                        .format(DateTime.parse(
                                                            healthData['bmi_pi'][
                                                                    'updated_at'] ??
                                                                "")),
                                                style: TypographyStyles.textWithWeight(
                                                    14, FontWeight.w300)))
                                        : Text("No data found",
                                            style:
                                                TypographyStyles.textWithWeight(
                                                    14, FontWeight.w300)),
                                    Visibility(
                                      visible: authUser.role == 'trainer' ||
                                          (authUser.role == 'client' &&
                                              canIEditAsAClient.value),
                                      child: canIEditP.value
                                          ? ElevatedButton(
                                              style: ButtonStyles
                                                  .bigFlatYellowButton(),
                                              onPressed: () {
                                                updateBMIPI();
                                              },
                                              child: Text(
                                                'Update',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textOnAccentColor,
                                                  fontSize: 20,
                                                  fontFamily: 'Bebas Neue',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                showSnack(
                                                    'Client Has a Secondary Trainer!',
                                                    'If a client has a secondary trainer, only they can edit the client\'s macros.');
                                              },
                                              icon: Icon(
                                                Icons.info_outline,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Body Fat',
                                    style: TypographyStyles.title(21)),
                              ],
                            ),
                            healthData['body_fat'] != null
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 10),
                                            cardHealth(
                                                healthData['body_fat']
                                                            ['body_fat']
                                                        .toString() +
                                                    '%',
                                                healthData['body_fat']
                                                    ['body_fat_category'],
                                                'Body Fat',
                                                Color(0xFFFFC149)),
                                            SizedBox(height: 8),
                                            cardHealth(
                                                healthData['body_fat']
                                                            ['muscle_mass']
                                                        .toString() +
                                                    '%',
                                                healthData['body_fat']
                                                    ['body_fat_category'],
                                                'Muscle Mass',
                                                Color(0xFFFFC149)),
                                            SizedBox(height: 12),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 180,
                                        child: Image.asset(
                                          bodyFatImage(healthData['body_fat']
                                              ['body_fat_category']),
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    ],
                                  )
                                : SizedBox(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                healthData['body_fat'] != null
                                    ? Expanded(
                                        child: Text(
                                          (healthData['body_fat'] != null
                                              ? 'Updated on : ' +
                                                  DateFormat(
                                                          "MMM dd, yyyy HH:mm")
                                                      .format(DateTime.parse(
                                                          healthData['body_fat']
                                                              ['updated_at']))
                                              : ""),
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w300),
                                        ),
                                      )
                                    : Text("No data found",
                                        style: TypographyStyles.textWithWeight(
                                            14, FontWeight.w300)),
                                Visibility(
                                  visible: authUser.role == 'trainer' ||
                                      (authUser.role == 'client' &&
                                          canIEditAsAClient.value),
                                  child: canIEditP.value
                                      ? ElevatedButton(
                                          style: ButtonStyles
                                              .bigFlatYellowButton(),
                                          onPressed: () {
                                            updateFATMM();
                                          },
                                          child: Text(
                                            'Update',
                                            style: TextStyle(
                                              color:
                                                  AppColors.textOnAccentColor,
                                              fontSize: 20,
                                              fontFamily: 'Bebas Neue',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () {
                                            showSnack(
                                                'Client Has a Secondary Trainer!',
                                                'If a client has a secondary trainer, only they can edit the client\'s macros.');
                                          },
                                          icon: Icon(
                                            Icons.info_outline,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Blood Sugar',
                                    style: TypographyStyles.title(21)),
                                // Visibility(
                                //   visible: authUser.role == 'trainer',
                                //   child: canIEditP.value ? OutlinedButton(
                                //     onPressed: () {
                                //       updateBS();
                                //     },
                                //     child: Text('Update',
                                //       style: TextStyle(
                                //         color: Get.isDarkMode ? Themes.mainThemeColor.shade500 : colors.Colors().lightBlack(1),
                                //       ),),
                                //   ) : Tooltip(
                                //     message: "Client Has a Secondary Trainer!\n\nIf a client has a secondary trainer,\nonly they can edit the client\'s macros.",
                                //     padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                //     textStyle: TypographyStyles.normalText(14, Themes.mainThemeColorAccent.shade100),
                                //     triggerMode: TooltipTriggerMode.tap,
                                //     waitDuration: Duration(seconds: 2),
                                //     showDuration: Duration(seconds: 2),
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(12),
                                //       color: Colors.black,
                                //     ),
                                //     child: Padding(
                                //       padding: EdgeInsets.symmetric(vertical: 10),
                                //       child: Icon(Icons.info_outline),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                healthData['blood_sugar'] != null
                                    ? cardHealth(
                                        healthData['blood_sugar']
                                                    ['fasting_blood_sugar']
                                                .toString() +
                                            'mg/dl',
                                        healthData['blood_sugar']
                                            ['fbs_category'],
                                        'Fasting Blood Sugar',
                                        Color(0xFF67A3FB))
                                    : SizedBox(),
                                SizedBox(height: 8),
                                healthData['blood_sugar'] != null
                                    ? cardHealth(
                                        healthData['blood_sugar']
                                                    ['random_blood_sugar']
                                                .toString() +
                                            'mg/dl',
                                        healthData['blood_sugar']
                                            ['rbs_category'],
                                        'Post Blood Sugar',
                                        Color(0xFF67A3FB))
                                    : SizedBox(),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    healthData['blood_sugar'] != null
                                        ? Expanded(
                                            child: Text(
                                              'Updated on : ' +
                                                  DateFormat(
                                                          "MMM dd,yyyy HH:mm")
                                                      .format(DateTime.parse(
                                                          healthData['blood_sugar']
                                                                  [
                                                                  'updated_at'] ??
                                                              "")),
                                              style: TypographyStyles
                                                  .textWithWeight(
                                                      14, FontWeight.w300),
                                            ),
                                          )
                                        : Text("No data found",
                                            style:
                                                TypographyStyles.textWithWeight(
                                                    14, FontWeight.w300)),
                                    Visibility(
                                      visible: authUser.role == 'trainer' ||
                                          (authUser.role == 'client' &&
                                              canIEditAsAClient.value),
                                      child: canIEditP.value
                                          ? ElevatedButton(
                                              style: ButtonStyles
                                                  .bigFlatYellowButton(),
                                              onPressed: () {
                                                updateBS();
                                              },
                                              child: Text(
                                                'Update',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textOnAccentColor,
                                                  fontSize: 20,
                                                  fontFamily: 'Bebas Neue',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                showSnack(
                                                    'Client Has a Secondary Trainer!',
                                                    'If a client has a secondary trainer, only they can edit the client\'s macros.');
                                              },
                                              icon: Icon(
                                                Icons.info_outline,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Blood Pressure',
                                    style: TypographyStyles.title(21)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                healthData['blood_pressure'] != null
                                    ? cardHealth(
                                        healthData['blood_pressure']['systolic']
                                                .toString() +
                                            '/' +
                                            healthData['blood_pressure']
                                                    ['diastolic']
                                                .toString(),
                                        healthData['blood_pressure']
                                            ['blood_pressure_category'],
                                        'Blood Pressure',
                                        Color(0xFFFF4242))
                                    : SizedBox(),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    healthData['blood_pressure'] != null
                                        ? Expanded(
                                            child: Text(
                                              'Updated on : ' +
                                                  DateFormat(
                                                          "MMM dd,yyyy HH:mm")
                                                      .format(DateTime.parse(
                                                          healthData['blood_pressure']
                                                                  [
                                                                  'updated_at'] ??
                                                              "")),
                                              style: TypographyStyles
                                                  .textWithWeight(
                                                      14, FontWeight.w300),
                                            ),
                                          )
                                        : Text("No data found",
                                            style:
                                                TypographyStyles.textWithWeight(
                                                    14, FontWeight.w300)),
                                    Visibility(
                                      visible: authUser.role == 'trainer' ||
                                          (authUser.role == 'client' &&
                                              canIEditAsAClient.value),
                                      child: canIEditP.value
                                          ? ElevatedButton(
                                              style: ButtonStyles
                                                  .bigFlatYellowButton(),
                                              onPressed: () {
                                                updateBP();
                                              },
                                              child: Text(
                                                'Update',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textOnAccentColor,
                                                  fontSize: 20,
                                                  fontFamily: 'Bebas Neue',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                showSnack(
                                                    'Client Has a Secondary Trainer!',
                                                    'If a client has a secondary trainer, only they can edit the client\'s macros.');
                                              },
                                              icon: Icon(
                                                Icons.info_outline,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Body Measurements',
                                  style: TypographyStyles.title(21),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                healthData['misc'] != null
                                    ? SizedBox(height: 10)
                                    : SizedBox(),
                                healthData['misc'] != null
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Bust'),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Chest'),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Hips'),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Left Arm'),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  healthData['misc']
                                                                  ['misc_data']
                                                              ['bust']
                                                          .toString() +
                                                      'mm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  healthData['misc']
                                                                  ['misc_data']
                                                              ['chest']
                                                          .toString() +
                                                      'mm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  healthData['misc']
                                                                  ['misc_data']
                                                              ['hips']
                                                          .toString() +
                                                      'mm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  healthData['misc']
                                                                  ['misc_data']
                                                              ['l_arm']
                                                          .toString() +
                                                      'mm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Container(
                                              height: 100,
                                              width: 1,
                                              color: Themes
                                                  .mainThemeColorAccent.shade100
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Stomach'),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Calves'),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Thighs'),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Right Arm'),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  healthData['misc']
                                                                  ['misc_data']
                                                              ['stomach']
                                                          .toString() +
                                                      'mm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  healthData['misc']
                                                                  ['misc_data']
                                                              ['calves']
                                                          .toString() +
                                                      'mm',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  healthData['misc']
                                                                  ['misc_data']
                                                              ['thighs']
                                                          .toString() +
                                                      'mm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  healthData['misc']
                                                                  ['misc_data']
                                                              ['r_arm']
                                                          .toString() +
                                                      'mm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                                healthData['misc'] != null
                                    ? SizedBox(height: 12)
                                    : SizedBox(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    healthData['misc'] != null
                                        ? Expanded(
                                            child: Text(
                                              'Updated on : ' +
                                                  DateFormat(
                                                          "MMM dd,yyyy HH:mm")
                                                      .format(DateTime.parse(
                                                          healthData['misc'][
                                                                  'updated_at'] ??
                                                              "")),
                                              style: TypographyStyles
                                                  .textWithWeight(
                                                      14, FontWeight.w300),
                                            ),
                                          )
                                        : Text("No data found",
                                            style:
                                                TypographyStyles.textWithWeight(
                                                    14, FontWeight.w300)),
                                    Visibility(
                                      visible: authUser.role == 'trainer' ||
                                          (authUser.role == 'client' &&
                                              canIEditAsAClient.value),
                                      child: canIEditP.value
                                          ? ElevatedButton(
                                              style: ButtonStyles
                                                  .bigFlatYellowButton(),
                                              onPressed: () {
                                                updateBM();
                                              },
                                              child: Text(
                                                'Update',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textOnAccentColor,
                                                  fontSize: 20,
                                                  fontFamily: 'Bebas Neue',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                showSnack(
                                                    'Client Has a Secondary Trainer!',
                                                    'If a client has a secondary trainer, only they can edit the client\'s macros.');
                                              },
                                              icon: Icon(
                                                Icons.info_outline,
                                              ),
                                            ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            )),
    );
  }
}

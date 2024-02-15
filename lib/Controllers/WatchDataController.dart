import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HealthDataModels.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:intl/intl.dart';
import 'package:health/health.dart';

class WatchDataController {
  int userId;

  WatchDataController(this.userId);

  bool enabled = authUser.user['health_data'];

  HealthFactory health = HealthFactory();
  int daysToGet = 3;
  RxBool ready = false.obs;

  RxList<HeartData> heartData = <HeartData>[].obs;
  RxList<TempData> tempData = <TempData>[].obs;
  RxList<StepsData> stepsData = <StepsData>[].obs;

  RxString heartDataStatus = 'waiting...'.obs;
  RxString stepsDataStatus = 'waiting...'.obs;
  RxString tempDataStatus = 'waiting...'.obs;

  RxString statusText = 'connecting...'.obs;

  RxList<HealthDataPoint> healthData = <HealthDataPoint>[].obs;
  RxList<Map> jsonData = <Map>[].obs;

  RxDouble lastBodyTemp = 0.0.obs;
  RxInt lastHeartRate = 0.obs;
  RxInt lastSteps = 0.obs;

  static List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];
  static var permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];
  emptyAll(){
    heartData.clear();
    tempData.clear();
    stepsData.clear();
    healthData.clear();
    jsonData.clear();

    heartDataStatus.value = 'waiting...';
    stepsDataStatus.value = 'waiting...';
    tempDataStatus.value = 'waiting...';
    statusText.value = 'connecting...';

    lastBodyTemp.value = 0.0;
    lastHeartRate.value = 0;
    lastSteps.value = 0;
  }

  void formatData() async {
    Map<dynamic, dynamic>? hasHeartElement =
        jsonData.firstWhereOrNull((element) => element['type'] == 'HEART_RATE');

    if (hasHeartElement == null) {
      heartDataStatus.value = 'No Heart Rate Data Found.';
    } else {
      try {
      jsonData
          .lastWhere((element) => element['type'] == 'HEART_RATE')
          .forEach((key, value) {
        if (key == 'value') {
          lastHeartRate.value = int.parse(value.toString().split('.')[0]);
        }

        if (key == 'timestamp') {
          heartDataStatus.value = formatLastSyncDate(value);
        }
      });
    } catch (e) {
      print('Heart Sync Error occured: ' + e.toString());
      FirebaseCrashlytics.instance.log("Heart Sync Error occured.");
      FirebaseCrashlytics.instance.log(e.toString());
      heartDataStatus.value = 'Heart Sync Error occured.';
    }
    }


    Map<dynamic, dynamic>? hasStepsElement =
        jsonData.firstWhereOrNull((element) => element['type'] == 'STEPS');
    if (hasStepsElement == null) {
      stepsDataStatus.value = 'No Steps Data Found.';
    } else {
      try {

        jsonData
            .where((element) => element['type'] == 'STEPS').forEach((element) {
              DateTime date = DateTime.parse(element['timestamp'].toString());
              print(element);
              if(date.day == DateTime.now().day){
                lastSteps.value += double.parse(element['value'].toString()).round();
              }


        });

        jsonData
            .lastWhere((element) => element['type'] == 'STEPS')
            .forEach((key, value) {
          if (key == 'timestamp') {
            stepsDataStatus.value =
                'Synced at ${DateFormat('dd MMM, hh:mm a').format(DateTime.parse(value.toString()))}';
          }
        });
      } catch (e) {
        print('Steps Sync Error occured: ' + e.toString());
        FirebaseCrashlytics.instance.log("Steps Sync Error occured.");
        FirebaseCrashlytics.instance.log(e.toString());
        stepsDataStatus.value = 'Steps Sync Error occured.';
      }
    }
    Map<dynamic, dynamic>? hasTempElement = jsonData
        .firstWhereOrNull((element) => element['type'] == 'BODY_TEMPERATURE');
    print("===========hasTempElement");
    print(jsonData);
    if (hasTempElement == null) {
      tempDataStatus.value = 'No Temperature Data Found.';
    } else {
      try {
        jsonData
            .lastWhere((element) => element['type'] == 'BODY_TEMPERATURE')
            .forEach((key, value) {
          if (key == 'value') {
            lastBodyTemp.value = double.parse(value.toString()).roundToDouble();
          }

          if (key == 'timestamp') {
            tempDataStatus.value = formatLastSyncDate(value);
          }
        });
      } catch (e) {
        print('Temperature Sync Error occured: ' + e.toString());
        FirebaseCrashlytics.instance.log("Temperature Sync Error occured.");
        FirebaseCrashlytics.instance.log(e.toString());
        tempDataStatus.value = 'Temperature Sync Error occured.';
      }
    }

    ready.value = true;
  }

  void startSync() async {
    int counter = 0;

    healthData.forEach((HealthDataPoint element) {
      counter++;
      if (counter > 30) {
        return;
      }

      jsonData.add({
        'type': element.type.name,
        'value': double.parse(element.value.toString()),
        'timestamp': element.dateFrom.toLocal().toString()
      });

      switch (element.type.name) {
        case 'HEART_RATE':
          heartData.add(createHeartData(element, healthData.indexOf(element)));
          break;
        case 'BODY_TEMPERATURE':
          tempData.add(createTempData(element, healthData.indexOf(element)));
          break;
        case 'STEPS':
          stepsData.add(createStepsData(element, healthData.indexOf(element)));
          break;
      }
    });
    await httpClient.saveUserWatchData(jsonData).then((value) => print(value));
    statusText.value = 'Syncing Complete';
    formatData();
  }

  void setupSync() async {
    print("=====setup inner");
    if (authUser.id == userId) {
      print("Fetching new Data...");
      statusText.value = 'Fetching New Data...';
      DateTime to = DateTime.now();
      DateTime from = to.subtract(Duration(days: daysToGet));
      healthData.value = await health.getHealthDataFromTypes(from, to, types);
      print(healthData.value);
      if (healthData.isEmpty) {
        statusText.value = 'Connected: No Data Found.';
        heartDataStatus.value = 'No Data Found.';
        stepsDataStatus.value = 'No Data Found.';
        tempDataStatus.value = 'No Data Found.';

        ready.value = true;
      } else {
        statusText.value = 'Connected: Syncing...';
        startSync();
      }
    } else {
      print("Fetching Saved Data...");
      statusText.value = 'Fetching Saved Data...';
      print(statusText.value);

      Map res = await httpClient.getUserWatchData(userId);
      print("=====userId");
      print(userId);

      if (res['code'] == 200) {
        List resData = res['data']['data'];

        resData.forEach((element) {
          jsonData.add(element);
          switch (element['type']) {
            case 'HEART_RATE':
              heartData.add(HeartData(
                  resData.indexOf(element),
                  DateTime.parse(element['timestamp']),
                  double.parse(element['value'].toString())));
              break;
            case 'BODY_TEMPERATURE':
              tempData.add(TempData(
                  resData.indexOf(element),
                  DateTime.parse(element['timestamp']),
                  double.parse(element['value'].toString())));
              break;
            case 'STEPS':
              stepsData.add(StepsData(
                  resData.indexOf(element),
                  DateTime.parse(element['timestamp']),
                  double.parse(element['value'].toString())));
              break;
          }
        });
        formatData();
      } else {
        FirebaseCrashlytics.instance.log("Syncing From Server Error occurred.");
        FirebaseCrashlytics.instance.log(res.toString());
        statusText.value = 'Syncing From Server Failed';
      }
    }
  }

  void init() async {
    ready.value = false;

    emptyAll();

    if(authUser.id == userId){
      enabled = authUser.user['health_data'] && (authUser.id == userId);
    } else {
      enabled = true;
    }

    statusText.value = 'connecting...';

    healthData.value = [];
    stepsData.value = [];
    tempData.value = [];
    heartData.value = [];
    bool connectionStatus = false;

    /*if(authUser.user['health_data'] && (authUser.id == userId)){
      print('Requesting Health Data Permission...');
      connectionStatus = await health.requestAuthorization(types);
    }*/

    if(enabled){
      if (connectionStatus == false) {
        statusText.value = 'Health Data Permission Denied';
        FirebaseCrashlytics.instance.log("Health Data Permission Denied");
      } else {
        statusText.value = 'Health Data Permission Granted';
        FirebaseCrashlytics.instance.log("Health Data Permission Granted");
      }
      print("====syncing health data");
      setupSync();
    } else {
      ready.value = true;
    }
  }

  HeartData createHeartData(HealthDataPoint data, int index) {
    return HeartData(
        index,
        data.dateFrom.toLocal(),
        data.type.name == 'HEART_RATE'
            ? double.parse(data.value.toString())
            : 0.0);
  }

  TempData createTempData(HealthDataPoint data, int index) {
    return TempData(
        index,
        data.dateFrom.toLocal(),
        data.type.name == 'BODY_TEMPERATURE'
            ? double.parse(data.value.toString())
            : 0.0);
  }

  StepsData createStepsData(HealthDataPoint data, int index) {
    return StepsData(index, data.dateFrom.toLocal(),
        data.type.name == 'STEPS' ? double.parse(data.value.toString()) : 0.0);
  }

  String formatLastSyncDate(element) {
    return 'Synced at ${DateFormat('dd MMM, hh:mm a').format(DateTime.parse(element.toString()))}';
  }

  static Future<bool> requestPermission() async {
     var state = await HealthFactory().requestAuthorization(types,permissions: permissions);
     print('Printing health data state ---> $state');
     return state;
  }
}

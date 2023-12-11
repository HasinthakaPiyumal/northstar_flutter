import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class HttpClient {
  Dio dio = Dio();

  // static String baseURL = 'https://api.northstar.mv/api';
  static String baseURL = 'http://175.41.184.146:8081/api';

  static String buildInfo = '9.0.0 Build 1';

  static String s3BaseUrl =
      'https://north-star-storage.s3.ap-southeast-1.amazonaws.com/avatars/';
  static String s3DocSealBaseUrl =
      'https://north-star-storage.s3.ap-southeast-1.amazonaws.com/seals/';
  static String s3DocSignatureBaseUrl =
      'https://north-star-storage.s3.ap-southeast-1.amazonaws.com/signatures/';
  static String s3LabReportsBaseUrl =
      'https://north-star-storage.s3.ap-southeast-1.amazonaws.com/lab-reports/';
  static String s3GymGalleriesBaseUrl =
      'https://north-star-storage.s3.ap-southeast-1.amazonaws.com/gym-galleries/';
  // static String s3ResourcesBaseUrl =
  //     'https://north-star-storage.s3.ap-southeast-1.amazonaws.com/';
      static String s3ResourcesBaseUrl =
      'https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/';

  Map<String, dynamic> headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "",
  };

  HttpClient() {
    dio.options.baseUrl = baseURL;
    dio.options.connectTimeout = Duration(seconds: 10);
    dio.options.receiveTimeout = Duration(seconds: 10);
    dio.options.headers = headers;
  }

  void setToken(String token) async {
    headers["Authorization"] = "Bearer $token";
    dio.options.headers = headers;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future post(String url, Map data) async {
    try {
      return await dio.post(url, data: data);
    } on DioError catch (e) {
      print(e);
      return e.response;
    }
  }

  Future fileUpload(String url, XFile file) async {
    try {
      FormData form = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: file.name),
      });
      return await dio.post(url, data: form);
    } on DioError catch (e) {
      return e.response;
    }
  }

  Future get(String url) async {
    try {
      return await dio.get(url);
    } on DioError catch (e) {
      return e.response;
    }
  }

  //AuthCheck
  Future<Map> authCheck() async {
    try {
      Response response = await post('/users/check', {});

      if (response.statusCode != 200) {
        await authUser.clearUser();
        return {
          "code": response.statusCode,
          "data": {},
        };
      } else {
        return {
          "code": response.statusCode,
          "data": response.data,
        };
      }
    } catch (e) {
      await authUser.clearUser();
      return {
        "code": 401,
        "data": {},
      };
    }
  }

  //AuthCheck
  Future<Map> authCheckWithoutTokenRefresh() async {
    Response response = await post('/users/check-without-token-refresh', {});

    if (response.statusCode != 200) {
      await authUser.clearUser();
      return {
        "code": response.statusCode,
        "data": {},
      };
    } else {
      return {
        "code": response.statusCode,
        "data": response.data,
      };
    }
  }

  //SignIn
  Future<Map> signIn(Map data) async {
    Response response = await post('/login', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //SignUp
  Future<Map> signUp(Map data) async {
    Response response = await post('/register', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //SignUpDataCheck
  Future<Map> signUpDataCheck(Map data) async {
    Response response = await post('/checks/checkAccountInfo', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //GetMyNotifications
  Future<Map> getMyNotifications() async {
    Response response = await get(
        '/meeting/notifications/actions/get-my-notifications/' +
            authUser.id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getAllMyNotifications() async {
    Response response = await get(
        '/meeting/notifications/actions/get-all-my-notifications/' +
            authUser.id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Health Services
  Future<Map> healthServicesBP(Map data) async {
    Response response =
        await post('/fitness/static/health-services/blood-pressure', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Notifications Channels

  //Create Notification
  Future<Map> createNotification(Map data) async {
    Response response =
        await post('/meeting/notifications/actions/create-notifications', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Get Notifications
  Future<Map> getNotifications() async {
    Response response = await get(
        '/meeting/notifications/actions/get-my-notifications/' +
            authUser.id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //GetHomeData
  Future<Map> getHomeData(String day) async {
    Response response = await get(
        '/fitness/' + authUser.id.toString() + '/home/fitness-data/' + day);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getClientMealData(int clientId) async {
    Response response =
        await get('/fitness/' + clientId.toString() + '/weekly-meals');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //EditMeals
  Future<Map> editMeals(Map data) async {
    Response response =
        await post('/fitness/' + authUser.id.toString() + '/meals', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //SearchFoods
  Future<Map> searchFoods(String pattern) async {
    Response response = await get('/fitness/foods/' + pattern.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //GetHomeData
  Future<Map> getHomeTrainerData() async {
    Response response = await get('/trainer/notifications/home');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //GetMyProfile
  Future<Map> getMyProfile() async {
    Response response = await get('/users/me');
    print('Printing headers ---> $headers');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Check if already sent a request.
  Future<Map> checkIfAlreadyHasARequest(trainerID) async {
    Response response = await post('/clients/actions/verify-request', {
      'trainer_id': trainerID,
    });

    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //AcceptTrainer
  Future<Map> acceptTrainer(requestID, trainerID) async {
    Response response =
        await post('/clients/requests/' + requestID.toString() + '/accept', {});

    this.sendNotification(
        trainerID,
        'Client Has Accepted Your Request',
        'Client ' + authUser.name + ' has Accepted Your Request',
        NSNotificationTypes.TrainerRequestAccepted, {
      'trainer_id': trainerID,
      'client_id': authUser.id,
    });

    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //RejectTrainer
  Future<Map> rejectTrainer(requestID, trainerID) async {
    Response response =
        await post('/clients/requests/' + requestID.toString() + '/reject', {});

    this.sendNotification(
        trainerID,
        'Client Has Rejected Your Request',
        'Client ' + authUser.name + ' has Rejected Your Request',
        NSNotificationTypes.TrainerRequestAccepted, {
      'trainer_id': trainerID,
      'client_id': authUser.id,
    });

    await post('/meeting/notifications/actions/delete-requests', {});

    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Remove Trainer
  Future<Map> removeTrainer(Map data, trainerID) async {
    Response response = await post('/clients/actions/remove-trainer', data);

    this.sendNotification(
      trainerID,
      'Client Has Removed You as their Trainer',
      'Client ' + authUser.name + ' has removed you as their Trainer',
      NSNotificationTypes.TrainerRemoved,
      {
        'trainer_id': trainerID,
        'client_name': authUser.name,
        'client_id': authUser.id,
      },
    );

    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Upload Avatar
  Future<Map> uploadAvatar(XFile avatar) async {
    print(avatar);
    Response response = await fileUpload('/users/file-uploads/avatar', avatar);
    print(response);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Upload Signature
  Future<Map> uploadSignature(XFile avatar) async {
    Response response =
        await fileUpload('/users/file-uploads/signature', avatar);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Upload Seal
  Future<Map> uploadSeal(XFile avatar) async {
    Response response = await fileUpload('/users/file-uploads/seal', avatar);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> inviteMember(Map data) async {
    Response response = await post('/trainer/clients/invite', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> updateProfile(Map data) async {
    Response response = await post('/users/update-profile', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> updateClientSubProfile(Map data) async {
    Response response = await post('/users/update-sub-profile', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> updateTrainer(Map data) async {
    Response response = await post('/users/update-trainer', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> updateDoctor(Map data) async {
    Response response = await post('/users/update-doctor', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //SaveOrEdit Qualification
  Future<Map> saveOrEditQualification(Map data) async {
    Response response =
        await post('/qualifications/' + authUser.id.toString(), data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Home Widgets

  //Calories
  Future<Map> getHomeWidgetCalories() async {
    Response response =
        await get('/fitness/' + authUser.id.toString() + '/all-macros-data');
    print(response.data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //OverrideMacros
  Future<Map> overrideMacros(Map data) async {
    Response response = await post(
        '/fitness/' + authUser.id.toString() + '/override-macros', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> overrideAdvMacros(Map data) async {
    Response response = await post(
        '/fitness/' + authUser.id.toString() + '/override-adv-macros', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //OverrideMacros
  Future<Map> saveAdditionalData(Map data) async {
    Response response =
        await post('/clients/actions/save-additional-data', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Ecommerce
  Future<Map> searchStore(pattern) async {
    Response response =
        await post('/ecom/products/search', {"search_key": pattern});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Ecommerce
  Future<Map> getCategories() async {
    Response response = await get('/ecom/categories/actions/list');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Gyms

  //Search
  Future<Map> searchGyms(String pattern, String endPoint) async {
    if (pattern.isEmpty) {
      pattern = "ALL";
    }
    Response response =
        await post('/gyms/' + endPoint + '/search', {'search_key': pattern});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> searchGymServices(data) async {
    Response response =
        await post('/gyms/exclusive-services/search', {"search": ''});
    print(response);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Get Exclusive Gym Availability
  Future<Map> getAvailability(gymID, DateTime dateTime) async {
    Response response = await post(
        '/fitness/exclusive-gyms/actions/get-availability',
        {"gym_id": gymID, "date": dateTime.toString()});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Get Exclusive Gym Unconfirmed Bookings
  Future<Map> getUnconfirmedBookings(gymID) async {
    Response response =
        await post('/fitness/exclusive-gyms/actions/get-unconfirmed-schedule', {
      "user_id": authUser.id,
      "gym_id": gymID,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> deleteUnconfirmedBookings(id) async {
    Response response = await post(
        '/fitness/exclusive-gyms/actions/delete-unconfirmed-schedule',
        {"id": id});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> deleteAllUnconfirmedBookings() async {
    Response response = await post(
        '/fitness/exclusive-gyms/actions/delete-all-unconfirmed-schedule',
        {"user_id": authUser.id});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Make a Exclusive Gym Schedule
  Future<Map> makeASchedule(
      gymID, clientIDs, DateTime startTime, endTime, int amount) async {
    print({
      "gym_id": gymID,
      "trainer_id": authUser.id,
      "client_ids": clientIDs,
      "start_time": startTime.toString(),
      "end_time": endTime.toString()
    });
    Response response =
        await post('/fitness/exclusive-gyms/actions/new-schedule', {
      "gym_id": gymID,
      "trainer_id": authUser.id,
      "client_ids": clientIDs,
      "start_time": startTime.toString(),
      "end_time": endTime.toString()
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> confirmSchedules(scheduleIds, num amount, int gymID) async {
    Response response = await post('/exclusive-gyms/pay-now', {
      "amount": amount,
      "trainer_id": authUser.id,
      "gym_id": gymID,
      "schedule_ids": scheduleIds
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> newComGymBooking(Map data) async {
    Response response = await post('/commercial-gyms/pay-now', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }
  Future<Map> serviceBooking(Map data) async {
    Response response = await post('/commercial-gyms/pay-now', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> couponApply(Map data) async {
    Response response = await post('/coupon/actions/apply', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Get Exclusive Gym Schedule
  Future<Map> getExclusiveGymSchedules() async {
    Response response = await get(
        '/fitness/exclusive-gyms/actions/get-my-schedules/' +
            authUser.id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Get Commercial Gym Schedule
  Future<Map> getComGymSchedules() async {
    Response response = await get(
        '/fitness/commercial-gyms/actions/get-my-schedules/' +
            authUser.id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Search Doctors
  Future<Map> searchDoctors(String pattern) async {
    if (pattern.isEmpty) {
      pattern = "ALL";
    }
    Response response = await post('/doctors/search', {'search_key': pattern});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Search Doctors
  Future<Map> searchTherapy(String pattern) async {
    if (pattern.isEmpty) {
      pattern = "";
    }
    Response response = await post('/therapy/search', {'search': pattern});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Search Members
  Future<Map> searchMembers(String pattern) async {
    if (pattern.isEmpty) {
      pattern = "ALL";
    }
    Response response =
        await post('/trainer/clients/search', {'search_key': pattern});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //GetOneUser
  Future<Map> getOneUser(String userID) async {
    Response response = await get('/users/one/' + userID);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  // Client Health Data
  Future<Map> getClientHealthData(userID) async {
    Response response =
        await get('/fitness/' + userID.toString() + '/fitness-data');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Save Client Health Data
  Future<Map> saveHealthData(Map data, userID, endPoint) async {
    Response response =
        await post('/fitness/' + userID.toString() + '/' + endPoint, data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Save To-do
  Future<Map> saveTodo(dynamic data, XFile? file) async {
    late FormData form;
    if (file != null) {
      form = FormData.fromMap({
        'user_id': data['user_id'],
        'todo': data['todo'],
        'notes': data['notes'],
        'endDate': data['endDate'],
        "image": await MultipartFile.fromFile(file.path, filename: file.name),
      });
    } else {
      form = FormData.fromMap({
        'user_id': data['user_id'],
        'todo': data['todo'],
        'notes': data['notes'],
        'endDate': data['endDate'],
      });
    }

    try {
      var response = await dio.post('/meeting/todos/actions/add', data: form);
      return {"code": response.statusCode, "data": response.data};
    } on DioError catch (e) {
      print(e.response);
      return {"code": -1, "data": "Something went wrong"};
    }
  }

  //Save Meeting
  Future<Map> saveMeeting(Map data) async {
    Response response = await post('/meeting/new-trainer-client-meeting', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Get To-dos
  Future<Map> getTodo() async {
    Response response = await post('/meeting/todos/actions/get', {
      'user_id': authUser.id.toString(),
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Complete To-dos
  Future<Map> completeTodo(id) async {
    Response response = await post('/meeting/todos/actions/complete', {
      'id': id.toString(),
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Delete To-dos
  Future<Map> deleteTodo(id) async {
    Response response = await post('/meeting/todos/actions/delete', {
      'id': id.toString(),
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Payments.
  Future<Map> subscribeNow(Map data) async {
    Response response = await post('/payments/subscribe-now', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> activateFreeTrail() async {
    Response response = await post('/payments/activate-free-trial', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Wallet.
  Future<Map> getWallet() async {
    Response response = await get('/wallet/get-balance');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getTransactions() async {
    Response response = await get('/wallet/get-history');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> topUpWallet(Map data) async {
    Response response = await post('/wallet/top-up-now', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> commonPayments(Map data) async {
    Response response = await post('/wallet/common-payments', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> unlockDoor(Map data) async {
    Response response = await post('/fitness/lock/actions/unlock', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> invokeCall(var data) async {
    Response response = await post('/meeting/voice-call/actions/invoke', data);
    print('Headers ----> $headers');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getRtcToken(data) async {
    // Response response = await post('/meeting/voice-call/actions/rtcToken',data);

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://nodejs--hasinthakapiyum.repl.co/generateToken'));
    request.body = json.encode(data);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    print('response.data');
    return {
      "code": response.statusCode,
      "data": await response.stream.bytesToString(),
    };
  }

  Future<Map> getClientNotes(var data) async {
    Response response = await post('/fitness/client-notes/actions/get', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> saveClientNotes(var data) async {
    Response response = await post('/fitness/client-notes/actions/save', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> toggleClientNotes(var data) async {
    Response response =
        await post('/fitness/client-notes/actions/toggle', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> deleteClientNotes(var data) async {
    Response response =
        await post('/fitness/client-notes/actions/delete', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> newLabReport(XFile file, var data) async {
    Response response =
        await fileUpload('/users/file-uploads/lab-report', file);
    data['report_url'] = response.data['file'];
    Response dataResponse =
        await post('/fitness/lab-reports/actions/save', data);
    return {
      "code": response.statusCode,
      "data": dataResponse.data,
    };
  }

  Future<Map> getLabReports(var data) async {
    Response response = await post('/fitness/lab-reports/actions/get', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> deleteLabReports(var data) async {
    Response response = await post('/fitness/lab-reports/actions/delete', data);
    response = await post('/users/file-uploads/delete-file', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> saveCustomFood(var data) async {
    Response response = await post('/fitness/foods/actions/new', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getCallHistory() async {
    Response response = await get('/calls/actions/all');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> saveCallLog(var data) async {
    Response response = await post('/calls/actions/new', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Workouts
  Future<Map> addWorkout(Map data) async {
    Response response = await post('/fitness/workouts/add-new', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> deleteWorkout(int id) async {
    Response response = await post('/fitness/workouts/delete/$id', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Get Workouts
  Future<Map> getWorkout() async {
    Response response =
        await get('/fitness/workouts/${authUser.role}/${authUser.id}');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Get Workouts by ID
  Future<Map> getWorkoutByID(int id) async {
    Response response =
        await get('/fitness/workouts/common/get/' + id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getWorkoutsClient(int clientID) async {
    Response response = await get('/fitness/workouts/client/$clientID');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Search Workouts
  Future<Map> searchWorkouts(String pattern) async {
    Response response = await get('/fitness/workouts/' + pattern.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Save Workouts By User
  Future<Map> markWorkoutAsCompleted(Map data) async {
    Response response = await post('/fitness/workouts/complete', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> markWorkoutAsFinished(Map data) async {
    Response response = await post('/fitness/workouts/finish', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> toggleOnlineStatus() async {
    Response response = await post('/doctors/actions/toggle-online', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getDoctorHome() async {
    Response response =
        await get('/meeting/doctor-meetings/home/' + authUser.id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> newDoctorMeeting(Map data) async {
    print(data);
    Response response = await post('/meeting/new-client-doctor-meeting', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Workout Presets
  Future<Map> addOrEditWorkoutPresets(Map data) async {
    Response response =
        await post('/fitness/workout-presets/add-or-update', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getWorkoutPresets() async {
    Response response = await post('/fitness/workout-presets/get', {
      'trainer_id': authUser.id,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> deleteWorkoutPresets(workoutId) async {
    Response response = await post('/fitness/workout-presets/delete', {
      'workout_id': workoutId.toString(),
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> searchWorkoutPresets(String pattern) async {
    Response response =
        await get('/fitness/workout-presets/search/' + pattern.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> newReview(Map data) async {
    Response response = await post('/ratings/actions/new', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getReviews(int id) async {
    Response response = await post('/ratings/actions/get/' + id.toString(), {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> updateAbout(Map data) async {
    Response response = await post('/trainer/actions/update', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> deleteQualification(int id) async {
    Response response =
        await post('/qualifications/delete/' + id.toString(), {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> switchTrainers() async {
    Response response = await post('/clients/actions/switch-trainers', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> newTrainerDoctorMeeting(Map data) async {
    Response response = await post('/meeting/new-trainer-doctor-meeting', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getMyDocMeetings() async {
    Response response = await get('/meeting/doctor-meetings/my-meetings/' +
        authUser.role.toString() +
        '/' +
        authUser.id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getMyTherapyMeetings() async {
    Response response = await get('/meeting/my-meetings');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getLast30DayMeals(int id) async {
    Response response =
        await get('/fitness/user-meals/last-thirty-days/' + id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> deleteMeal(int mealId) async {
    Response response =
        await post('/fitness/' + authUser.id.toString() + '/delete-meals', {
      'id': mealId.toString(),
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getChartData(int id) async {
    Response response = await post('/fitness/charts/health-charts', {
      'user_id': id,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getDoctorPending() async {
    Response response =
        await get('/meeting/doctor-meetings/pending/' + authUser.id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getDoctorUpcoming() async {
    Response response = await get(
        '/meeting/doctor-meetings/approved/' + authUser.id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> finishDoctorMeeting(id) async {
    Response response = await post('/meeting/doctor-meeting-finish/$id', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> payForDocMeetingNow(Map data) async {
    Response response =
        await post('/payments/doctor-meeting-payment/pay-now', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getMyPaymentHistories() async {
    Response response = await get('/doctors/actions/get-payment-history');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getPrescriptions(int id) async {
    Response response =
        await get('/fitness/prescriptions/actions/get/' + id.toString());
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> archivePrescriptions(int id) async {
    Response response = await post(
        '/fitness/prescriptions/actions/archive/' + id.toString(), {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> forgotPasswordStepOne(String email) async {
    Response response = await post('/forgot-password', {
      'email': email,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> forgotPasswordStepTwo(
      String code, String password, String rPassword) async {
    Response response = await post('/forgot-password-step-two', {
      'code': code.toString(),
      'password': password,
      'r_password': rPassword,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> rejectDocMeetings(int id) async {
    Response response = await post('/meeting/doctor-meeting-reject/$id', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> acceptDocMeetings(int id) async {
    Response response = await post('/meeting/doctor-meeting-accept/$id', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> sendNotification(int receiverID, String title, String description,
      NSNotificationTypes type, Map<String, dynamic> data) async {
    print({
      'sender_id': authUser.id,
      'receiver_id': receiverID,
      'title': title,
      'description': description,
      'type': type.name,
      'data': data,
    }.toString());
    Map res = await httpClient.createNotification({
      'sender_id': authUser.id,
      'receiver_id': receiverID,
      'title': title,
      'description': description,
      'type': type.name,
      'data': data,
    });
    return res;
  }

  //Chat Module
  Future<Map> getMyChats() async {
    Response response =
        await get('/meeting/chats/${authUser.role}-my-chats/${authUser.id}');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getChatData(String chatID) async {
    Response response = await post('/meeting/chats/get-chat', {
      'chat_id': chatID,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> newChat(Map data) async {
    Response response = await post('/meeting/chats/new-chat', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> editChat(Map data) async {
    Response response = await post('/meeting/chats/edit-chat', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> deleteChat(String chatID) async {
    Response response = await post('/meeting/chats/delete-chat', {
      'chat_id': chatID,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> addOrRemoveClientFromChat(Map data) async {
    Response response =
        await post('/meeting/chats/add-remove-chat-client', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> newChatNotification(Map data) async {
    Response response =
        await post('/meeting/chats/chat-notifications/new-message', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //ECOM Related
  Future<Map> getMyCart() async {
    Response response = await get('/ecom/cart/actions/get');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> addToCart(int productID, int quantity) async {
    Response response = await post('/ecom/cart/actions/add', {
      'product_id': productID,
      'quantity': quantity,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> removeFromCart(int cartItemID) async {
    Response response = await post('/ecom/cart/actions/delete', {
      'cart_item_id': cartItemID,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getAllEvents() async {
    Response response = await post(
        '/meeting/common-events/get-all/${authUser.role}/${authUser.id}', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getAllEventsInFitnessService() async {
    Response response = await post(
        '/fitness/common-events/get-all/${authUser.role}/${authUser.id}', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> saveUserWatchData(List<Map> watchData) async {
    Response response = await post('/fitness/watch-data/actions/save', {
      'user_id': authUser.id,
      'data': watchData,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getUserWatchData(int userId) async {
    Response response =
        await post('/fitness/watch-data/actions/get', {'user_id': userId});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> toggleHealthDataConsent() async {
    Response response = await post('/users/health-data-consent', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> resourceSearch(String pattern) async {
    Response response = await post('/fitness/resources/actions/search', {
      'search_key': pattern,
    });
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> workoutsSearch(String pattern) async {
    Response response = await get('/fitness/workouts/' + pattern);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getPlansList() async {
    Response response = await get('/common/subscriptions/get-all');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> readAllNotifications() async {
    Response response = await post(
        '/meeting/notifications/actions/mark-all-as-read-notifications/' +
            authUser.id.toString(),
        {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Mark one Notification as read
  Future<Map> readOneNotification(int id) async {
    Response response = await post(
        '/meeting/notifications/actions/mark-one-as-read-notifications/$id',
        {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Delete one Notification
  Future<Map> deleteOneNotification(int id) async {
    Response response = await post(
        '/meeting/notifications/actions/delete-one-notification/$id', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Delete one Notification
  Future<Map> deleteAllNotifications() async {
    Response response = await post(
        '/meeting/notifications/actions/delete-all-notifications/${authUser.id}',
        {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getCarouselItems() async {
    Response response = await post('/users/ads/get-all', {});
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getNewsLetters() async {
    Response response = await get('/fitness/newsletters/actions/get');
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  //Diet Consultation
  Future<Map> addDietConsult(Map data) async {
    Response response =
        await post('/fitness/diet-consultation/actions/save', data);
    return {
      "code": response.statusCode,
      "data": response.data,
    };
  }

  Future<Map> getDietConsults(int userId) async {
    Response response =
        await get('/fitness/diet-consultation/actions/get/$userId');
    return response.data;
  }

  Future<Map> checkReservedTherapy(dynamic data) async {
    Response response = await post('/meeting/reserved-times', data);
    print('printing reserved time data--->$data');
    if (response.statusCode == 200) {
      return {"code": 200, "data": response.data};
    }
    return response.data;
  }

  Future<Map> addTherapyMeetingOld(dynamic data) async {
    Response response = await post('/meeting/new-client-therapy-meeting', data);
    if (response.statusCode == 200) {
      return {"code": 200, "data": response.data};
    }
    return {"code": 401, "data": response.data};
  }

  Future<Map> addTherapyMeeting(dynamic data, XFile? file) async {
    late FormData form;
    if (file != null) {
      form = FormData.fromMap({
        'therapy_id': data['therapy_id'],
        'amount': data['amount'],
        'reason': data['reason'],
        'additional': data['additional'],
        'apt_date': data['apt_date'],
        'start_time': data['start_time'],
        'end_time': data['end_time'],
        "image": await MultipartFile.fromFile(file.path, filename: file.name),
      });
    } else {
      print("object");
      form = FormData.fromMap({
        'therapy_id': data['therapy_id'],
        'amount': data['amount'],
        'reason': data['reason'],
        'additional': data['additional'],
        'apt_date': data['apt_date'],
        'start_time': data['start_time'],
        'end_time': data['end_time']
      });
    }
    print(form.fields);
    try {
      var response =
          await dio.post('/meeting/new-client-therapy-meeting', data: form);
      return {"code": response.statusCode, "data": response.data};
    } on DioError catch (e) {
      print(e.response);
      return {"code": -1, "data": "Something went wrong"};
    }
  }

  Future<Map> getFamiliLinks(dynamic data) async {
    Response response = await post('/family-link/actions/search', data);
    return {"code": response.statusCode, "data": response.data};
  }

  Future<Map> createFamilyLink(dynamic data) async {
    Response response = await post('/family-link/actions/add', data);
    return {"code": response.statusCode, "data": response.data};
  }
}

HttpClient httpClient = HttpClient();

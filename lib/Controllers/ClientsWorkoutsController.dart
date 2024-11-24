import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';

class ClientsWorkoutsController{
  static List workouts = [];

  static getClientsWorkouts()async{
    Map res = await httpClient.getWorkout();
    if (authUser.role == 'trainer')
      workouts = res['data'];
  }
}
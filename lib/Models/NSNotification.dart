import 'package:north_star/Controllers/NotificationsController.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';

enum NSNotificationTypes {
  Common,
  ClientRequest,
  ClientRequestWeb,
  TrainerRequest,
  TrainerRequestAccepted,
  TrainerRequestDeclined,
  TrainerRemoved,
  MarcoProfileUpdated,
  GymAppointment,
  WorkoutsAssigned,
  WorkoutCompleted,
  WorkoutScheduleFeedback,
  DoctorAppointmentAccepted,
  DoctorAppointmentDeclined,
  DietConsultationRequest,
  Payments,
  ClientProfileUpdated,
}

class NSNotification {
  int id;
  int senderId;
  int receiverId;

  bool hasSeen;

  String title;
  String description;
  NSNotificationTypes type;
  // Map<String, dynamic> data;
  dynamic data;

  DateTime createdAt;

  NSNotification({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.hasSeen,
    required this.title,
    required this.description,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  factory NSNotification.fromJson(Map<String, dynamic> json) {
    print("json data ${json['data'].runtimeType}");

    return NSNotification(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      hasSeen: json['has_seen'],
      title: json['title'],
      description: json['description'],
      type: NSNotificationTypes.values.byName(json['type']),
      data: json['data'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }

  Future readNotification() async {
    CommonConfirmDialog.confirm('Mark as Read').then((value) async {
      if (value == true) {
        Map res = await httpClient.readOneNotification(this.id);
        if (res['code'] == 200) {
          NotificationsController.notifications
              .firstWhere((notification) => notification.id == this.id)
              .hasSeen = true;
          NotificationsController.notifications.refresh();
        }
      }
    });
  }

  Future deleteNotification() async {
    CommonConfirmDialog.confirm('Delete').then((value) async {
      if (value == true) {
        Map res = await httpClient.deleteOneNotification(this.id);
        if (res['code'] == 200) {
          NotificationsController.notifications
              .removeWhere((notification) => notification.id == this.id);
          NotificationsController.notifications.refresh();
        }
      }
    });
  }

  Future deleteSelectedNotification() async {
    Map res = await httpClient.deleteOneNotification(this.id);
    if (res['code'] == 200) {
      NotificationsController.notifications
          .removeWhere((notification) => notification.id == this.id);
      NotificationsController.notifications.refresh();
    }
  }
}

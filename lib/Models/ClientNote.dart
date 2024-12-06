import 'package:north_star/Controllers/ClientNotesController.dart';
import 'package:north_star/Controllers/LocalNotificationsController.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';

class ClientNote{

  int id;
  int clientId;
  int trainerId;
  String note;
  String service;
  double amount;
  String paymentTerm;
  DateTime startDate;
  bool active;
  Map<String,dynamic> client;

  ClientNote({
    required this.id,
    required this.clientId,
    required this.trainerId,
    required this.note,
    required this.service,
    required this.amount,
    required this.paymentTerm,
    required this.startDate,
    required this.active,
    required this.client,
  });

  factory ClientNote.fromJson(Map<String,dynamic> json){
    return ClientNote(
      id: json['id'],
      clientId: json['client_id'],
      trainerId: json['trainer_id'],
      note: json['note'],
      service: json['service'],
      amount: double.parse(json['amount'].toString()),
      paymentTerm: json['payment_term'],
      startDate: DateTime.parse(json['start_date']),
      active: json['active'],
      client: json['client'] ?? json['trainer'],
    );
  }

  Future deactivateClientNote() async {
    Map res = await httpClient.toggleClientNotes({
      'id': this.id,
    });
    if (res['code'] == 200) {
      this.notifyClientOnToggle();
      ClientNotesController.getClientNotes();
    }
  }

  Future deleteClientNote() async {
    Map res = await httpClient.deleteClientNotes({
      'id': this.id,
    });
    if (res['code'] == 200) {
      ClientNotesController.getClientNotes();
      this.notifyClientOnDelete();
    }
  }

  Future notifyClientOnToggle() async{
    Map res = await httpClient.sendNotification(
      this.clientId,
      'Payment Status Changed',
      'Your trainer has marked your payment for ${this.service} as ${this.active ? 'Completed.':'Pending'}.',
      NSNotificationTypes.Common,
      {
        'client_id': this.clientId,
        'trainer_id': this.trainerId,
      }
    );

    DateTime dtx = DateTime(
      DateTime.now().year,
      this.startDate.month + 1,
      this.startDate.day,
      DateTime.now().hour + 3,
      DateTime.now().minute,
    );

    LocalNotificationsController.showLocalNotification(
      id: this.id,
      title: 'Member Note Reminder!',
      body: this.note,
      scheduledDate: dtx,
    );

    if (res['code'] == 200) {
      ClientNotesController.getClientNotes();
    }
  }

  Future notifyClientOnDelete() async{
    Map res = await httpClient.sendNotification(
        this.clientId,
        'Payment Status Removed',
        'Your trainer has removed ${this.service}.',
        NSNotificationTypes.Common,
        {
          'client_note_id': this.id,
          'client_id': this.clientId,
          'trainer_id': this.trainerId,
        }
    );
    if (res['code'] == 200) {
      ClientNotesController.getClientNotes();
    }
  }
}

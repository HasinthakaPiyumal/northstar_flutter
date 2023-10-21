import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/ClientNote.dart';
import 'package:north_star/Models/HttpClient.dart';

class ClientNotesController {
  static RxList<ClientNote> clientNotes = <ClientNote>[].obs;

  static Future getClientNotes() async {
    Map res = await httpClient.getClientNotes({
      'trainer_id': authUser.id,
    });
    if (res['code'] == 200) {
      clientNotes.value = res['data'].map<ClientNote>((e) => ClientNote.fromJson(e)).toList();
      print(res['data']);
      clientNotes.refresh();
      print(clientNotes);
    } else {
      print(res);
    }
  }

  static List<ClientNote> getClientNotesByClientId(int id) {
    if(authUser.role == 'trainer'){
      return clientNotes.where((element) => element.clientId == id).toList();
    } else {
      return clientNotes.where((element) => element.trainerId == id).toList();
    }

  }

  static int getUniqueClientsCount() {
    if(authUser.role == 'trainer'){
      return clientNotes.map((e) => e.clientId).toSet().toList().length;
    } else {
      return clientNotes.map((e) => e.trainerId).toSet().toList().length;
    }

  }

  static List<Map<String, dynamic>> getUniqueClientsWithIncome() {
    if(authUser.role == 'trainer'){
      List<int> uniqueClients = clientNotes.map((e) => e.clientId).toSet().toList();
      List<Map<String,dynamic>> uniqueClientsWithIncome = [];
      uniqueClients.forEach((element) {
        List<ClientNote> clients = clientNotes.where((e) => e.clientId == element).toList();
        double income = 0;
        clients.forEach((e) {
          income +=  e.active ? e.amount:0;
        });
        uniqueClientsWithIncome.add({
          'client': clients[0].client,
          'income': income,
        });
      });
      uniqueClientsWithIncome.sort((a,b) => b['income'].compareTo(a['income']));
      return uniqueClientsWithIncome;
    } else {
      List<int> uniqueClients = clientNotes.map((e) => e.trainerId).toSet().toList();
      List<Map<String,dynamic>> uniqueClientsWithIncome = [];
      uniqueClients.forEach((element) {
        List<ClientNote> clients = clientNotes.where((e) => e.trainerId == element).toList();
        double income = 0;
        clients.forEach((e) {
          income +=  e.active ? e.amount:0;
        });
        uniqueClientsWithIncome.add({
          'client': clients[0].client,
          'income': income,
        });
      });
      uniqueClientsWithIncome.sort((a,b) => b['income'].compareTo(a['income']));
      return uniqueClientsWithIncome;
    }


  }
}

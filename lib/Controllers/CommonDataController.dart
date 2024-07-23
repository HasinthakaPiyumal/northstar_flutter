import 'package:north_star/Models/HttpClient.dart';

class CommonDataController{
  static int weight = 0;
  static int height = 0;

  Future<void> getData()async{
    Map data = await httpClient.getCommonData();
    print("getting common data");
    if(data['code']==200){
      print(data);
      if(data['data']['weight']!=null){
        weight = data['data']['weight'];
      }
      if(data['data']['height']!=null){
        height = data['data']['height'];
      }
    }else{
      print(data);
    }
  }

  void updateCommonData()async{
    await httpClient.updateCommonData({'weight':weight,'height':height});
  }
}
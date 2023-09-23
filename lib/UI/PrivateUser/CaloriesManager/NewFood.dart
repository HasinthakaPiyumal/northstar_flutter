import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../../Styles/ButtonStyles.dart';

class NewFood extends StatelessWidget {
  const NewFood({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     RxBool ready = true.obs;

    TextEditingController nameController = TextEditingController();
    TextEditingController potionController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();
    TextEditingController carbsController = TextEditingController();
    TextEditingController proteinsController = TextEditingController();
    TextEditingController fatController = TextEditingController();
    TextEditingController satFatController = TextEditingController();
    TextEditingController fibersController = TextEditingController();

    void saveFood() async{
      Map res = await httpClient.saveCustomFood({
        'name': nameController.text,
        'potion': potionController.text,
        'calories': double.parse(caloriesController.text),
        'carbs': double.parse(carbsController.text),
        'proteins': double.parse(proteinsController.text),
        'fat': double.parse(fatController.text),
        'sat_fat': double.parse(satFatController.text),
        'fibers': double.parse(fibersController.text),
        'ingredients':[]
      });
      print(res);
      if(res['code'] == 200){
        if (res['code'] == 200) {
          Map backData = res['data']['food'];
          backData['no_of_potions'] = 1;
          Get.back(result: [backData]);
          showSnack('Food Submitted!', 'Food Submitted for admin Approval');
        }
      } else {
        showSnack('Error', 'Error Submitting Food');
      }
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('New Food via Nutrients'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: potionController,
                decoration: InputDecoration(
                  labelText: 'Potion Size (eg: 1 Cup)',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Calories',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: carbsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Carbs',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: proteinsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Proteins',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: fatController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Fat',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: satFatController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Sat Fat',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: fibersController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Fibers',
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 44,
                child: ElevatedButton(
                  style: ButtonStyles.bigBlackButton(),
                  child:  Obx(()=>ready.value ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Save Food')
                    ],
                  ) : Center(
                    child: CircularProgressIndicator(),
                  )),
                  onPressed: (){
                    if(nameController.text.isNotEmpty &&
                    potionController.text.isNotEmpty &&
                    carbsController.text.isNotEmpty &&
                    caloriesController.text.isNotEmpty &&
                    proteinsController.text.isNotEmpty &&
                    fatController.text.isNotEmpty &&
                    satFatController.text.isNotEmpty &&
                    fibersController.text.isNotEmpty){
                      saveFood();
                    } else {
                      showSnack('Fill All The Fields!', 'All the fields are required!');
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

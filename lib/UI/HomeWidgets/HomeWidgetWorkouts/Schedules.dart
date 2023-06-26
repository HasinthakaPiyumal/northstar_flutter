import 'package:flutter/material.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

class Schedules extends StatelessWidget {
  const Schedules({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedules'),),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          //Get.to(()=>AddWorkouts(foodList: [], mealID: 1));
        },
        backgroundColor: Colors.black,
        icon: Icon(Icons.add, color: Colors.white,),
        label: Text("Create Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Material(
              color: Color(0xFFF6F6F6),
              child: TextField(
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    hintText: 'Search Schedules...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (_,index){
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color(0xffF8F8F8),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), offset: Offset(0, 7), blurRadius: 10),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Schedule $index',style: TypographyStyles.title(18),),
                          SizedBox(height: 8),
                          Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
                          SizedBox(height: 8),
                          Text('Oct 25 2021 | Trainer Name',
                            style: TextStyle(
                                color: Colors.grey
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

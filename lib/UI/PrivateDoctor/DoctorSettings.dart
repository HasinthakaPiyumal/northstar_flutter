import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

class DoctorSettings extends StatelessWidget {
  const DoctorSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Rx<DateTime> date = new DateTime.now().add(Duration(days: 5)).obs;
    Rx<TimeOfDay> time = new TimeOfDay.now().obs;
    RxList list = [].obs;
    TextEditingController dateController = new TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    TextEditingController timeController = new TextEditingController(
        text: TimeOfDay.now().hour.toString() + ':' + TimeOfDay.now().minute.toString()
    );

    void pickDateDialog() {
      showDatePicker(
          context: context,
          initialDate: date.value,
          firstDate: DateTime.now().add(Duration(days: 2)),
          lastDate: DateTime(2100),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: const Color(0xFFF1AB56),
                colorScheme:
                ColorScheme.light(primary: const Color(0xFFF1AB56)),
                buttonTheme:
                ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
              child: child!,
            );
          }).then((pickedDate) {
        if (pickedDate == null) {
          return;
        }
        date.value = pickedDate;
        dateController.text = pickedDate.toString().split(' ')[0];
      });
    }
    void pickTimeDialog() {
      showTimePicker(
          context: context,
          initialTime: time.value,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: const Color(0xFFF1AB56),
                colorScheme:
                ColorScheme.light(primary: const Color(0xFFF1AB56)),
                buttonTheme:
                ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
              child: child!,
            );
          }).then((pickedTime) {
        if (pickedTime == null) {
          return;
        }
        time.value = pickedTime;
        timeController.text = pickedTime.hour.toString() + ':' + pickedTime.minute.toString();
      });
    }

    void addDays(){
      Get.defaultDialog(
          radius: 12,
          title: 'Add Availability',
          titlePadding: const EdgeInsets.only(top: 32, bottom: 0),
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('Time'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        onTap: pickTimeDialog,
                        controller: timeController,
                        decoration: InputDecoration(
                          hintText: 'Time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('Date'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        onTap: pickDateDialog,
                        controller: dateController,
                        decoration: InputDecoration(
                          hintText: 'Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Container(
              height: 52,
              width: Get.width,
              child: ElevatedButton(
                  style: ButtonStyles.primaryButton(),
                  onPressed: (){
                    list.add({
                      'date': date.value,
                      'time': time.value,
                    });
                    Get.back();
                  }, child: Text('Save'.toUpperCase())),
            ),
            Container(
              width: Get.width,
              height: 52,
              child: ElevatedButton(
                  style: ButtonStyles.bigGreyButton(),
                  onPressed: (){
                    Get.back();
                  }, child: Text('Cancel'.toUpperCase(),)),
            ),
          ]
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available days', style: TypographyStyles.title(18)),
                Container(
                  height: 58,
                  child: TextButton(
                    onPressed: () {
                      addDays();
                    },
                    child: Text('+ Add Days'),
                  ),
                )
              ],
            ),
            Expanded(
              child: Obx(()=>ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(list[index]['date'].toString().substring(0,10)),
                    subtitle: Text(list[index]['time'].format(context)),
                    trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: (){
                        list.removeAt(index);
                      },
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}

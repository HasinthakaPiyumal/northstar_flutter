import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/country_picker_dialog.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/ThemeBdayaStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';

import '../../Styles/TypographyStyles.dart';
import '../../components/CheckButton.dart';
import '../../components/Radios.dart';
import '../../components/Buttons.dart';

class CommonProfileUpdate extends StatelessWidget {
  const CommonProfileUpdate({Key? key, this.userObj}) : super(key: key);

  final userObj;

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxString gender = 'male'.obs;
    RxString countryCode = ''.obs;
    String tempPhone = userObj['phone'];
    Country userCountry =
        CountryPickerUtils.getCountryByIsoCode(userObj['country_code']);
    TextEditingController birthday = new TextEditingController();
    TextEditingController country = new TextEditingController();
    TextEditingController fName = new TextEditingController();
    TextEditingController lName = new TextEditingController();
    TextEditingController phone = new TextEditingController();
    TextEditingController email = new TextEditingController();
    TextEditingController nic = new TextEditingController();

    RxBool isInsured = false.obs;

    void setData() {
      gender.value = userObj['gender'];
      country.text = userCountry.name!;
      countryCode.value = userObj['country_code'];
      birthday.text = userObj['birthday'];
      fName.text = userObj['name'].split(' ')[0];
      lName.text = userObj['name'].split(' ')[1];
      phone.text = userObj['phone'];
      email.text = userObj['email'];
      nic.text = userObj['nic'];

      if (authUser.role == 'trainer') {
        isInsured.value = userObj['trainer']['is_insured'];
      }
    }

    void saveProfile() async {
      ready.value = false;
      Map res = await httpClient.updateProfile({
        "name": fName.text + ' ' + lName.text,
        "email": email.text,
        "phone": phone.text,
        "nic": nic.text,
        "gender": gender.value,
        "birthday": birthday.text,
        "country_code": countryCode.value,
      });

      if (res['code'] == 200) {
        if (authUser.role == 'trainer') {
          Map res2 =
              await httpClient.updateTrainer({'is_insured': isInsured.value});

          if (res2['code'] == 200) {
            print(res);
            Get.back();
            showSnack('Profile Updated', 'Profile updated successfully');
          } else {
            ready.value = true;
            showSnack('Something went wrong!', 'please try again');
          }
        }else{
          showSnack('Profile Updated', 'Profile updated successfully');
        }
      } else {
        ready.value = true;
        showSnack('Something went wrong!', 'please try again');
      }
    }

    Widget _buildDropdownItem(Country country) => Container(
          child: Row(
            children: <Widget>[
              CountryPickerUtils.getDefaultFlagImage(country),
              SizedBox(
                width: 8.0,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text("${country.name}  (${country.iso3Code})"),
                ),
              ),
            ],
          ),
        );

    setData();
    print(userObj);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Profile Update',
            style: TypographyStyles.title(20),
          ),
          // actions: [
          //   TextButton(
          //       onPressed: () {
          //         print(countryCode.value);
          //         if (email.text == '' ||
          //             fName.text == '' ||
          //             lName.text == '' ||
          //             phone.text == '' ||
          //             nic.text == '' ||
          //             birthday.text == '' ||
          //             countryCode.value == '') {
          //           showSnack('Please fill all the fields', 'to continue');
          //         } else {
          //           if (email.text.isEmail) {
          //             saveProfile();
          //           } else {
          //             showSnack('Please enter a valid email', 'to continue');
          //           }
          //         }
          //       },
          //       child: Row(
          //         children: [
          //           Text('Save'),
          //         ],
          //       ))
          // ],
        ),
        body: Obx(() => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  // runSpacing: 16,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fName,
                            decoration: InputDecoration(
                                labelText: 'First Name',
                                prefixIcon: Icon(Icons.person_2_rounded),
                                border: UnderlineInputBorder()),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextField(
                            controller: lName,
                            decoration: InputDecoration(
                                labelText: 'Last Name',
                                prefixIcon: Icon(Icons.person_2_rounded),
                                border: UnderlineInputBorder()),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      readOnly: true,
                      controller: phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.call_outlined),
                        border: UnderlineInputBorder(),
                      ),
                      onTap: () {
                        Get.defaultDialog(
                          radius: 5,
                          titlePadding: EdgeInsets.only(top: 20),
                          contentPadding: EdgeInsets.fromLTRB(20, 25, 20, 20),
                          title: 'Change Phone Number',
                          backgroundColor: Get.isDarkMode
                              ? AppColors.primary2Color
                              : Colors.white,
                          content: Container(
                            width: Get.width,
                            child: IntlPhoneField(
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                border: UnderlineInputBorder(),
                              ),
                              initialCountryCode: userCountry.isoCode,
                              onChanged: (PhoneNumber value) {
                                tempPhone = value.completeNumber.toString();
                              },
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ButtonStyles.bigFlatYellowButton(),
                              child: Container(
                                width: Get.width / 4,
                                child: Center(
                                    child: Text('Save',
                                        style: TextStyle(
                                          color: AppColors.textOnAccentColor,
                                          fontSize: 20,
                                          fontFamily: 'Bebas Neue',
                                          fontWeight: FontWeight.w400,
                                        ))),
                              ),
                              onPressed: () {
                                phone.text = tempPhone;
                                Get.back();
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: AppColors.accentColor),
                                      borderRadius: BorderRadius.circular(5))),
                              child: Container(
                                  width: Get.width / 4,
                                  child: Center(
                                      child: Text(
                                    'Cancel',
                                    style: TypographyStyles.smallBoldTitle(20),
                                  ))),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: nic,
                      decoration: InputDecoration(
                        labelText: 'NIC/Passport',
                        prefixIcon: Icon(Icons.contact_mail_rounded),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    // Row(children: [
                    //   Text('Gender'),
                    //   Spacer(),
                    //   Container(
                    //     width: Get.width / 3,
                    //     child: ElevatedButton(
                    //       style: gender.value == 'male'
                    //           ? SignUpStyles.selectedButton()
                    //           : SignUpStyles.notSelectedButton(),
                    //       onPressed: () {
                    //         gender.value = 'male';
                    //       },
                    //       child: Text(
                    //         'Male',
                    //         style: TextStyle(
                    //           color: Get.isDarkMode
                    //               ? Themes.mainThemeColorAccent.shade100
                    //               : colors.Colors().lightBlack(1),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    //   SizedBox(width: 8),
                    //   Container(
                    //     width: Get.width / 3,
                    //     child: ElevatedButton(
                    //       style: gender.value == 'female'
                    //           ? SignUpStyles.selectedButton()
                    //           : SignUpStyles.notSelectedButton(),
                    //       onPressed: () {
                    //         gender.value = 'female';
                    //       },
                    //       child: Text('Female'),
                    //     ),
                    //   ),
                    // ]),

                    Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            gender.value = 'male';
                          },
                          child: Row(
                            children: [
                              gender.value == 'male'
                                  ? Radios.radioChecked()
                                  : Radios.radio(),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Male",
                                  style: TypographyStyles.textWithWeight(
                                      16, FontWeight.w500))
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        GestureDetector(
                          onTap: () {
                            gender.value = 'female';
                          },
                          child: Row(
                            children: [
                              gender.value == 'female'
                                  ? Radios.radioChecked()
                                  : Radios.radio(),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Female",
                                  style: TypographyStyles.textWithWeight(
                                      16, FontWeight.w500))
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: Get.width,
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          DatePickerBdaya.showDatePicker(
                            context,
                            theme: ThemeBdayaStyles.main(),
                            showTitleActions: true,
                            onChanged: (date) {
                              print('change $date');
                            },
                            onConfirm: (date) {
                              print('confirm $date');
                              birthday.text =
                                  date.toLocal().toString().split(' ')[0];
                            },
                          );
                        },
                        controller: birthday,
                        decoration: InputDecoration(
                          labelText: 'Birthday',
                          prefixIcon: Icon(Icons.today_rounded),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: Get.width,
                      child: TextField(
                          readOnly: true,
                          controller: country,
                          decoration: InputDecoration(
                            labelText: 'Country of Residence',
                            prefixIcon: Icon(Icons.home_outlined),
                            border: UnderlineInputBorder(),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Theme(
                                data: Theme.of(context).copyWith(
                                    primaryColor:
                                        colors.Colors().deepYellow(1)),
                                child: CountryPickerDialog(
                                  titlePadding: EdgeInsets.all(8.0),
                                  searchCursorColor:
                                      colors.Colors().deepYellow(1),
                                  searchInputDecoration:
                                      InputDecoration(hintText: 'Search...'),
                                  isSearchable: true,
                                  title: Text('Country of Residence'),
                                  onValuePicked: (Country c) {
                                    country.text = c.name!;
                                    countryCode.value = c.isoCode!;
                                  },
                                  itemBuilder: _buildDropdownItem,
                                ),
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    Visibility(
                      visible: userObj['role'] == "trainer",
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            isInsured.value = !isInsured.value;
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Is Insured",
                                  style: TypographyStyles.textWithWeight(
                                      16, FontWeight.w400),
                                ),
                                CheckButton(
                                  isChecked: isInsured.value,
                                ),
                              ]),
                        ),
                      ),
                    ),
                    SizedBox(height:20),
                    Buttons.yellowFlatButton(label:"Update",  onPressed: () {
                      print(countryCode.value);
                      if (email.text == '' ||
                          fName.text == '' ||
                          lName.text == '' ||
                          phone.text == '' ||
                          nic.text == '' ||
                          birthday.text == '' ||
                          countryCode.value == '') {
                        showSnack('Please fill all the fields', 'to continue');
                      } else {
                        if (email.text.isEmail) {
                          saveProfile();
                        } else {
                          showSnack('Please enter a valid email', 'to continue');
                        }
                      }
                    },width: Get.width*.7)
                  ],
                ),
              ),
            )));
  }
}

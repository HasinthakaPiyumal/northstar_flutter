import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/country_picker_dialog.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:north_star/Styles/PickerDialogStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../../Models/HttpClient.dart';
import '../../../components/Buttons.dart';
import '../../CommonAuthUtils.dart';
import '../../SteppingSignUp/SignUpData.dart';

class ClientRegisterSecond extends StatefulWidget {
  @override
  State<ClientRegisterSecond> createState() => _ClientRegisterSecondState();
}

class _ClientRegisterSecondState extends State<ClientRegisterSecond> {
  RxBool isLoading = false.obs;

  int genderType = 1;
  bool showPass1 = false;
  bool showPass2 = false;

  TextEditingController _countryController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _contactPersonController = TextEditingController();
  TextEditingController _emergencyContactController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String emergencyContact = "";

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
                child: Text("${country.name}  (${country.isoCode})"),
              ),
            ),
          ],
        ),
      );
  Widget _buildDropdownItemWithCountryCode(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 8.0,
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("${country.name}  (${country.isoCode})",overflow: TextOverflow.ellipsis,)),
                    Text("${country.phoneCode}"),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  void signUp() async {

    if (_countryController.text.isEmpty ||
        _addressController.text.isEmpty ||
        // _contactPersonController.text.isEmpty ||
        // _emergencyContactController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      showSnack('Incomplete information', 'Please enter correct information');
    } else {
      // signUpData.countryCode = _countryController.text;
      signUpData.address = _addressController.text;
      // signUpData.eContactName = _contactPersonController.text;
      // signUpData.eContactPhone = emergencyContact;
      signUpData.password = _passwordController.text;
      signUpData.passwordConfirmation = _confirmPasswordController.text;

      isLoading.value = true;
      Map res = await httpClient.signUp(signUpData.toClientJson());
      print(signUpData.countryCode);
      if (res['code'] == 200) {
        isLoading.value = false;
        CommonAuthUtils.signIn(res);
        showSnack(
            'Welcome to NorthStar!', 'Your personal fitness Application!');
        CommonAuthUtils.showWelcomeDialog();
      } else {
        print(res.toString());
        isLoading.value = false;
        showSnack('Something went wrong!', res['data']['message'],status: PopupNotificationStatus.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double contentHeight = 25.0;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/appicons/logo_black_white.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      width: 66,
                      height: 29,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(isDark
                              ? "assets/appicons/mini_logo_text_white.png"
                              : "assets/appicons/mini_logo_text_black.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Container(
                  width: 85,
                  height: 50,
                  padding: const EdgeInsets.all(3.0),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              padding: const EdgeInsets.all(2),
                              decoration: ShapeDecoration(
                                color: Color(0xFFFFB700),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '02',
                                    style: TextStyle(
                                      color: Color(0xFF1B1F24),
                                      fontSize: 20,
                                      fontFamily: 'Bebas Neue',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '/ 02',
                              style: TextStyle(
                                color: Color(0xFF1B1F24),
                                fontSize: 20,
                                fontFamily: 'Bebas Neue',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _countryController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.home_outlined,
                        color: isDark ? Colors.white : Colors.black, size: 18),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    label: Row(children: [Text(
                      "Country Of Residence",
                      style:  TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),),
                      Text(" *",style: TextStyle(color: Colors.red),)
                    ],),
                    contentPadding: EdgeInsets.only(bottom: 0),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Theme(
                        data: Theme.of(context).copyWith(
                          dialogBackgroundColor:
                              isDark ? Color(0xFF1B1F24) : Colors.white,
                          primaryColor: Color(0xFFFFB700),
                        ),
                        child: CountryPickerDialog(
                          titlePadding: EdgeInsets.all(8.0),
                          searchCursorColor: Color(0xFFFFB700),
                          searchInputDecoration: InputDecoration(
                            hintText: 'Search...',
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            contentPadding: EdgeInsets.only(bottom: 0),
                          ),
                          isSearchable: true,
                          title: Text('Country of Residence'),
                          onValuePicked: (Country country) {
                            print('country printing');
                            print(country);
                            signUpData.countryCode = country.isoCode.toString();
                            signUpData.currency =
                                country.currencyCode.toString();
                            _countryController.text =
                                "${country.name} (${country.currencyCode})";
                          },
                          itemBuilder: _buildDropdownItem,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: contentHeight),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined,
                        color: isDark ? Colors.white : Colors.black, size: 18),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    label: Row(children: [Text(
                      "Shipping Address",
                      style:  TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),),
                      Text(" *",style: TextStyle(color: Colors.red),)
                    ],),
                    contentPadding: EdgeInsets.only(bottom: 0),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                SizedBox(height: contentHeight),
                // TextFormField(
                //   controller: _contactPersonController,
                //   decoration: InputDecoration(
                //     prefixIcon: Icon(Icons.person_2_outlined,
                //         color: isDark ? Colors.white : Colors.black, size: 18),
                //     border: UnderlineInputBorder(
                //       borderSide: BorderSide(color: Colors.white),
                //     ),
                //     label: Row(children: [Text(
                //       "Contact Person",
                //       style:  TextStyle(
                //         color: isDark ? Colors.white70 : Colors.black54,
                //         fontWeight: FontWeight.w500,
                //         fontFamily: 'Poppins',
                //         fontSize: 16,
                //       ),),
                //       Text(" *",style: TextStyle(color: Colors.red),)
                //     ],),
                //     contentPadding: EdgeInsets.only(bottom: 0),
                //   ),
                //   style: TextStyle(color: isDark ? Colors.white : Colors.black),
                // ),
                // SizedBox(height: contentHeight),
                // Theme(
                //   data: Theme.of(context).copyWith(
                //     listTileTheme: ListTileThemeData()
                //   ),
                //   child: IntlPhoneField(
                //     controller: _emergencyContactController,
                //     decoration: InputDecoration(
                //       prefixIcon: Icon(Icons.call_outlined,
                //           color: isDark ? Colors.white : Colors.black, size: 18),
                //       border: UnderlineInputBorder(
                //         borderSide: BorderSide(color: Colors.white),
                //       ),
                //       label: Row(children: [Text(
                //         "Emergency Contact",
                //         style:  TextStyle(
                //           color: isDark ? Colors.white70 : Colors.black54,
                //           fontWeight: FontWeight.w500,
                //           fontFamily: 'Poppins',
                //           fontSize: 16,
                //         ),),
                //         Text(" *",style: TextStyle(color: Colors.red),)
                //       ],),
                //       contentPadding: EdgeInsets.only(bottom: 0),
                //     ),
                //     style: TextStyle(color: isDark ? Colors.white : Colors.black),
                //     pickerDialogStyle: PickerDialogStyles.main(),
                //     initialCountryCode: 'MV',
                //     onChanged: (phone) {
                //       setState(() {
                //         emergencyContact = "${phone.completeNumber}";
                //       });
                //     },
                //   ),
                // ),
                // TextFormField(
                //   controller: _emergencyContactController,
                //   decoration: InputDecoration(
                //     prefixIcon: Icon(Icons.call_outlined,
                //         color: isDark?Colors.white:Colors.black, size: 18),
                //     border: UnderlineInputBorder(
                //       borderSide: BorderSide(color: Colors.white),
                //     ),
                //     labelText: 'Emergency Contact',
                //     labelStyle: TextStyle(
                //       color: isDark?Colors.white70:Colors.black54,
                //       fontWeight: FontWeight.w500,
                //       fontFamily: 'Poppins',
                //       fontSize: 16,
                //     ),
                //     contentPadding: EdgeInsets.only(bottom: 0),
                //   ),
                //   style: TextStyle(color: isDark? Colors.white:Colors.black),
                // ),
                SizedBox(height: contentHeight),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !showPass1,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: isDark ? Colors.white : Colors.black,
                      size: 18,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPass1 ? Icons.visibility : Icons.visibility_off,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          showPass1 = !showPass1;
                        });
                      },
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    label: Row(children: [Text(
                      "Password",
                      style:  TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),),
                      Text(" *",style: TextStyle(color: Colors.red),)
                    ],),
                    contentPadding: EdgeInsets.only(bottom: 0),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                SizedBox(height: contentHeight),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !showPass2,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: isDark ? Colors.white : Colors.black,
                      size: 18,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPass2 ? Icons.visibility : Icons.visibility_off,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          showPass2 = !showPass2;
                        });
                      },
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    label: Row(children: [Text(
                      "Confirm Password",
                      style:  TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),),
                      Text(" *",style: TextStyle(color: Colors.red),)
                    ],),
                    contentPadding: EdgeInsets.only(bottom: 0),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                SizedBox(height: contentHeight),
                Obx(()=> Center(
                  child: Buttons.yellowFlatButton(
                    label: "Signup",
                    isLoading: isLoading.value,
                    width: Get.width - 40,
                    onPressed: () {
                      signUp();
                    },
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

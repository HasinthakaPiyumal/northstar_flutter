import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/country_picker_dialog.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpCommonDataThree.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpData.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SignUpCommonDataTwo extends StatelessWidget {
  const SignUpCommonDataTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    TextEditingController _nameController = TextEditingController();
    TextEditingController _surnameController = TextEditingController();
    TextEditingController _addressController = TextEditingController();
    TextEditingController _countryController = TextEditingController();

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
              child: Text(
                  "${country.name}  (${country.isoCode})"
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Information',
                            style: TypographyStyles.title(24)),
                        Hero(
                          tag: 'progress',
                          child: CircularStepProgressIndicator(
                            totalSteps: 100,
                            currentStep: 50,
                            stepSize: 5,
                            selectedColor: colors.Colors().deepYellow(1),
                            unselectedColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[300],
                            padding: 0,
                            width: 100,
                            height: 100,
                            selectedStepSize: 7,
                            roundedCap: (_, __) => true,
                            child: Center(child: Text("2 of 4", style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1),),)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _surnameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextField(
                      readOnly: true,
                      controller: _countryController,
                      decoration: InputDecoration(
                        labelText: 'Country of Residence',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              Theme(
                                data: Theme.of(context).copyWith(
                                    primaryColor: colors.Colors().deepYellow(
                                        1)),
                                child: CountryPickerDialog(
                                  titlePadding: EdgeInsets.all(8.0),
                                  searchCursorColor: colors.Colors().deepYellow(
                                      1),
                                  searchInputDecoration: InputDecoration(
                                      hintText: 'Search...'),
                                  isSearchable: true,
                                  title: Text('Country of Residence'),
                                  onValuePicked: (Country country) {
                                    signUpData.countryCode =
                                        country.isoCode.toString();
                                    signUpData.currency =
                                        country.currencyCode.toString();
                                    _countryController.text =
                                    "${country.name} (${country.currencyCode})";
                                  },
                                  itemBuilder: _buildDropdownItem,
                                ),
                              ),
                        );
                      }
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Shipping Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Container(
          width: Get.width,
          height: 72,
          child: ElevatedButton(
            style: ButtonStyles.bigBlackButton(),
            child: Text('Continue'),
            onPressed: () {
              print(signUpData);
              signUpData.name = _nameController.text+ ' ' + _surnameController.text;
              signUpData.address = _addressController.text;
              if (_nameController.text.isNotEmpty && _countryController.text.isNotEmpty &&  _surnameController.text.isNotEmpty) {
                Get.to(()=>SignUpCommonDataThree());
              } else {
                showSnack('Incomplete information', 'Please enter correct information');
              }
            },
          ),
        ),
      ),
    );
  }
}

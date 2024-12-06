class SignUpData {
  late String userType;

  late String email;
  late String name;
  late String password;
  late String passwordConfirmation;
  late String phone;

  late String gender;
  late String birthday = '1999-01-01';

  late String address;
  late String countryCode;
  late String currency;

  //Trainer
  late String type;
  late String about;
  late String idNumber;
  late bool isInsured;
  late String trainerType;

  //Client
  late String eContactName;
  late String eContactPhone;

  //Doctor
  late String speciality;
  late String hourlyRate;
  late bool canPrescribe;
  late String title = 'Dr';

  toClientJson(){
    return {
      "role": this.userType,
      "name": this.name,
      "email": this.email,
      "password": this.password,
      "password_confirmation": this.passwordConfirmation,
      "phone": this.phone,
      "nic": this.idNumber,
      "gender": this.gender,
      "birthday":this.birthday,
      "address": this.address,
      "country_code": this.countryCode,
      "currency": this.currency,

      // //Client
      // "emergency_contact_name": this.eContactName,
      // "emergency_contact_phone": this.eContactPhone,
    };
  }

  toTrainerJson(){
    return {
      "role": this.userType,
      "name": this.name,
      "email": this.email,
      "password": this.password,
      "password_confirmation": this.passwordConfirmation,
      "phone": this.phone,
      "nic": this.idNumber,
      "gender": this.gender,
      "birthday":this.birthday,
      "address": this.address,
      "country_code": this.countryCode,
      "currency": this.currency,

      //Trainer
      "type": 'physical',
      "about": this.about,
      "is_insured": this.isInsured,
      "trainer_type": this.trainerType,
    };
  }

  toDoctorJson(){

    return {
      "role": this.userType,
      "name": this.name,
      "email": this.email,
      "password": this.password,
      "password_confirmation": this.passwordConfirmation,
      "phone": this.phone,
      "nic": this.idNumber,
      "gender": this.gender,
      "birthday":this.birthday,
      "address": this.address,
      "country_code": this.countryCode,
      "currency": this.currency,

      //Doctor
      "speciality": this.speciality,
      "hourly_rate": this.hourlyRate,
      "can_prescribe": this.canPrescribe,
      "title": this.title,
    };
  }

}

SignUpData signUpData = new SignUpData();

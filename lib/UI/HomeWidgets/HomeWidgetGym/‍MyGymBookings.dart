import 'package:flutter/material.dart';

class MyGymBookings extends StatelessWidget {
  const MyGymBookings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Gym Bookings'),
      ),
      body: Center(
        child: Text('My Gym Bookings'),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentFailed extends StatelessWidget {
  const PaymentFailed();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Unsuccessful"),
      ),
    );
  }
}

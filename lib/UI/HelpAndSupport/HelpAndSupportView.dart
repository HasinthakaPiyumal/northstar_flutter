import 'package:flutter/material.dart';

class HelpAndSupportView extends StatelessWidget {
  const HelpAndSupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Method"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Text(
            "Payment methods are the channels through which customers can make transactions and complete purchases. In today's digital age, various payment options are available to cater to diverse preferences and needs. Common payment methods include credit and debit cards, bank transfers, mobile wallets, and digital payment platforms like PayPal and Venmo.\n\nThese methods offer flexibility and security, allowing users to choose the most convenient way to pay for products and services. Users can also store payment information securely for quicker and more efficient future transactions. Choosing the right payment method ensures a seamless and hassle-free shopping experience, making it essential for both businesses and consumers.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
          ),
        ),
      ),
    );
  }
}

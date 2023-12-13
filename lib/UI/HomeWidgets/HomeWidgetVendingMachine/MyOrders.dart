import 'package:flutter/material.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

class HomeWidgetVendingMachineMyOrders extends StatelessWidget {
  const HomeWidgetVendingMachineMyOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: LoadingAndEmptyWidgets.emptyWidget(),
    );
  }
}

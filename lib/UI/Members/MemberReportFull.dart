import 'package:flutter/material.dart';
import 'package:north_star/UI/Members/UserView_Progress.dart';

class MemberReportFull extends StatelessWidget {
  const MemberReportFull({required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Report"),
      ),
      body: UserViewProgress(userId: userId)
    );
  }
}

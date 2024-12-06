import 'package:flutter/material.dart';

class AdminQuestions extends StatelessWidget {
  final Function(Map) onChange;
  const AdminQuestions({required this.onChange});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: MockList.list.length,
            shrinkWrap: true,
            itemBuilder: (_,index){
                return Column(
                  children: [
                    Text(MockList.list[index]['question']),

                  ],
                );
            },
    );
  }
}

class MockList{
  static List<Map> list = [
    {
      'key':'First',
      'question':'',
      'answers':["A","B","C"],
      'other':''
    }
  ];
}
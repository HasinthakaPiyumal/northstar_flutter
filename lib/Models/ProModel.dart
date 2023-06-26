class Pro {
  String image, description, feature;

  Pro({required this.feature, required this.description, required this.image});
}

class ProList {

  late List<Pro> _list;

  List<Pro> get list => _list;

  ProList(){
    _list = proItems;
  }
}

List<Pro> proItems = [
  Pro(feature: "Workout", description: "Lorem Ipsum Dolor", image: "assets/proItems/step1.png"),
  Pro(feature: "Dashboard", description: "Lorem Ipsum Dolor", image: "assets/proItems/step1.png"),
  Pro(feature: "Dashboard", description: "Lorem Ipsum Dolor", image: "assets/proItems/step1.png"),
];
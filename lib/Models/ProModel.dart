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
  Pro(feature: "Activate", description: "Pro Plan", image: "assets/proItems/ad_01.png"),
  Pro(feature: "Virtual Sessions", description: "Consultation / Training", image: "assets/proItems/ad_02.png"),
  Pro(feature: "Meet Professionals", description: "Trainers / Dietitians", image: "assets/proItems/ad_03.png"),
];
class HeartData {
  HeartData(this.index,this.dateTime, this.heart);

  final int index;
  final DateTime dateTime;
  final double heart;
}

class TempData{
  TempData(this.index,this.dateTime, this.temp);

  final int index;
  final DateTime dateTime;
  final double temp;
}

class StepsData {
  StepsData(this.index,this.dateTime, this.steps);

  final int index;
  final DateTime dateTime;
  final double steps;
}
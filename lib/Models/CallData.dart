class CallData {
  int id;
  String callerName;
  String avatar;
  String channelName;

  CallData({this.id=0,this.callerName = "", this.avatar = "default.png",this.channelName = "defaultChannel"});

  void setCallData({required dynamic id,required String callerName, required String avatar, required channelName}) {
    this.id = int.parse(id);
    this.callerName = callerName;
    this.avatar = avatar;
    this.channelName = channelName;
  }
}

CallData callData = new CallData();

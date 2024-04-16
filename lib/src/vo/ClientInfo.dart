/// clientId : ""
/// clientSecret : ""

class ClientInfo {
  final String clientId;
  final String clientSecret;

  ClientInfo({
      required this.clientId,
      required this.clientSecret}){
}

  factory ClientInfo.fromJson(dynamic json) {
    return ClientInfo(clientId: json['clientId'], clientSecret: json['clientSecret']);
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['clientId'] = clientId;
    map['clientSecret'] = clientSecret;
    return map;
  }

}
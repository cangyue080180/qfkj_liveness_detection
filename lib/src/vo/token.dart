

class Token{
  final String msg;
  final String accessToken;
  final int code;
  final String scope;
  final String jti;
  Token({
  required this.msg,
  required this.accessToken,
  required this.code,
  required this.scope,
  required this.jti
}) {
assert(
accessToken.isNotEmpty,
'''
Cannot pass an empty accessToken.
      ''',
);}

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      msg: json['msg'],
      accessToken: json['access_token'],
      code: json['code'],
        scope: json['scope'],
        jti: json['jti']
    );
  }
}
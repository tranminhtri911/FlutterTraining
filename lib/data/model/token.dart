import 'package:untitled/data/source/remote/remote.dart';

import 'base_model.dart';

class Token extends BaseModel {
  final String token;
  final String expiresDate;

  Token({
    required this.token,
    required this.expiresDate,
  });

  factory Token.fromJson(Map<String, dynamic> json) => Token(
        token: json.decode("request_token"),
        expiresDate: json.decode("expires_at"),
      );
}

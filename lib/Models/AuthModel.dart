import 'package:firebase_auth/firebase_auth.dart';

class AuthModel {
  final String message;
  final UserCredential userCredential;

  AuthModel(this.message, this.userCredential);
}

class LoginSuccessRespond {
  final int responseCode;
  final String responseToken;
  final String responeUsername;
  final String responseEmail;
  final List responseRoles;
  final int expiration;

  LoginSuccessRespond(
    this.responseCode,
    this.responseToken,
    this.responeUsername,
    this.expiration,
    this.responseRoles,
    this.responseEmail,
  );
}

class LoginFailRespond {
  final int responseCode;
  final String errorMsg;

  LoginFailRespond(this.responseCode, this.errorMsg);
}

class RegisterSuccessResponse {
  final int responseCode;

  RegisterSuccessResponse(this.responseCode);
}

class RegisterFailResponse {
  final int responseCode;
  final String errorMsg;

  RegisterFailResponse(this.responseCode, this.errorMsg);
}

class VerifyResponse {
  final int responseCode;

  VerifyResponse(this.responseCode);
}

class User {
  String userName;
  String userEmail;
  List userRoles;
  int userExpiration;

  User();

  User.fromJson(Map<String, dynamic> json)
      : userName = json['userName'],
        userRoles = json['userRoles'],
        userEmail = json['userEmail'],
      userExpiration = json['userExpiration'];

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'userEmail': userEmail,
        'userRoles': userRoles,
        'userExpiration': userExpiration,
      };
}

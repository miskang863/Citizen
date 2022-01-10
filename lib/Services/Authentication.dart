import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Models/AuthModel.dart';


class Authentication {
  final String authURL = "https://mykuopio-gateway.azurewebsites.net/auth/";

  // Register
  Future register(
      String email, String username, String password) async {
    final response = await http.post(
      Uri.parse(authURL + 'signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "email": email,
        "name": username,
        "password": password
      }),
    );
    Map<String, dynamic> data = new Map<String, dynamic>.from(json.decode(response.body));

    if(response.statusCode == 200){
      return RegisterSuccessResponse(
        response.statusCode
      );
    }
    else{
      return RegisterFailResponse(
        response.statusCode,
          data["errors"][0]["msg"]
      );
    }
  }

  // LOGIN
  Future login(String email, String password) async {
    final http.Response response = await http.post(
      Uri.parse(authURL + 'login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"email": email, "password": password}),
    );

    print("response:: ${response.statusCode}");
    Map<String, dynamic> data = new Map<String, dynamic>.from(json.decode(response.body));
    if(response.statusCode == 200){

      return LoginSuccessRespond(
        response.statusCode,
        data["token"],
        data["username"],
        data["exp"],
        data["roles"],
        data["email"]
      );
    } else{
      print("err : ${data["errors"][0]["msg"]}");
      return LoginFailRespond(
          response.statusCode,
          data["errors"][0]["msg"]
      );
    }
  }

  // Onload check token
  Future<VerifyResponse> checkToken(String token) async {
    final http.Response response = await http.get(
      Uri.parse(authURL + 'verify'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': token
      },
    );
    return VerifyResponse(response.statusCode);
  }
}

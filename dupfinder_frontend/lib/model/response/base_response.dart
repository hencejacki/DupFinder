import 'dart:convert';

class BaseResponse {
  int? code;
  String? msg;
  dynamic data;

  BaseResponse({this.code, this.msg, this.data});

  BaseResponse.fromJson(Map<String, dynamic> json)
      : code = json["code"],
        msg = json["msg"],
        data = json["data"];

  Map<String, dynamic> get serializeData => jsonDecode(jsonEncode(data));
}

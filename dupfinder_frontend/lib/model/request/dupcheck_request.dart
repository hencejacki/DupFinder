import 'package:dio/dio.dart';

// 文件比较请求
class DupCheckFileRequest {
  final String lang;
  final MultipartFile originalDoc;
  final MultipartFile compareDoc;

  DupCheckFileRequest(
      {required this.lang,
      required this.originalDoc,
      required this.compareDoc});

  Map<String, dynamic> toJson() =>
      {"lang": lang, "original_doc": originalDoc, "compare_doc": compareDoc};
}

// 文本比较请求
class DupCheckTxtRequest {
  final String lang;
  final String originalTxt;
  final String compareTxt;

  DupCheckTxtRequest(
      {required this.lang,
      required this.originalTxt,
      required this.compareTxt});

  Map<String, dynamic> toJson() =>
      {"lang": lang, "original_txt": originalTxt, "compare_txt": compareTxt};
}

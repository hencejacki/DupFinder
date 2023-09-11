// 查重返回结果
class DupCheckResponse {
  String? similarity;
  String? conclusion;

  DupCheckResponse({this.conclusion, this.similarity});

  DupCheckResponse.fromJson(Map<String, dynamic> json)
      : similarity = json["similarity"],
        conclusion = json["conclusion"];
}

class GPTResponse {
  String? reply;

  GPTResponse({this.reply});

  GPTResponse.fromJson(Map<String, dynamic> json) : reply = json["answer"];
}

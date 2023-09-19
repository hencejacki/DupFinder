class GPTRequest {
  final String prompt;
  final String model;
  final int sessionIdx;

  GPTRequest(
      {required this.prompt, this.model = "cc", this.sessionIdx = 0});

  Map<String, dynamic> toJson() =>
      {'question': prompt, 'model': model, 'sessionIdx': sessionIdx};
}

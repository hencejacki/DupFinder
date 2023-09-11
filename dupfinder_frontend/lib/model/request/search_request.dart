
class SearchRequest {
  final String keyword;
  int from;
  int size;
  final String lang;
  final String type;

  SearchRequest({required this.keyword, this.from = 0, this.size = 10,  required this.lang, required this.type});

  Map<String, dynamic> toJson() => {
    'keyword' : keyword,
    'from' : from,
    'size' : size,
    'lang' : lang,
    'type' : type
  };
}
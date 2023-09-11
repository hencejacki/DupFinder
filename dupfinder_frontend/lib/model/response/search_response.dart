import 'package:dupfinder/model/home_data.dart';

class SearchResponse {
  int? total;
  int? current;
  int? size;
  late List<SearchResultModel> records;

  SearchResponse({this.total, this.current, this.size, required this.records});

  SearchResponse.fromJson(Map<String, dynamic> json)
      : total = json["total"],
        current = json["current"],
        size = json["size"],
        records = json["records"].map((ele) => SearchResultModel(ele["id"], ele["title"], ele["content"])).toList().cast<SearchResultModel>();
}

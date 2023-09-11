import 'package:dupfinder/model/cluster_result_data.dart';

class ClusterResponse {
  List<ClusterResultModel>? clusters;

  ClusterResponse({this.clusters});

  ClusterResponse.fromJson(Map<String, dynamic> json)
      : clusters = json["clusters"]
            .map((ele) => ClusterResultModel(
                docCount: ele["doc_count"], nearestDocs: ele["nearest_docs"].cast<String>()))
            .toList()
            .cast<ClusterResultModel>();
}

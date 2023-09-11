
class ClusterRequest {
  String? langSelect;
  int? clusterSelect;

  ClusterRequest({this.langSelect = "zh", this.clusterSelect = 20});

  Map<String, dynamic> toJson() => {
    "lang" : langSelect,
    "cluster_kinds": clusterSelect
  };
}
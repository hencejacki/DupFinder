
import 'package:fluent_ui/fluent_ui.dart';

class ClusterModel extends ChangeNotifier {
  
  // 聚类语言选择
  String _langSelect = "zh";
  String get langSelect => _langSelect;
  set langSelect(String v) {
    _langSelect = v;
    notifyListeners();
  }

  // 聚类类数选择
  int _clusterSelect = 2;
  int get clusterSelect => _clusterSelect;
  set clusterSelect(int v) {
    _clusterSelect = v;
    notifyListeners();
  }

  // 聚类结果
  List<ClusterResultModel> _clusters = [];
  List<ClusterResultModel> get clusters => _clusters;
  set clusters(List<ClusterResultModel> v) {
    _clusters = v;
    notifyListeners();
  }
}

class ClusterResultModel {
  int docCount;
  List<String> nearestDocs;

  ClusterResultModel({required this.docCount, required this.nearestDocs});

  ClusterResultModel.fromJson(Map<String, dynamic> json) : docCount = json["doc_count"], nearestDocs = json["nearest_docs"];

}
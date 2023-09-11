
import 'package:fluent_ui/fluent_ui.dart';

class HomeModel extends ChangeNotifier{

  // 搜索关键词
  String _keyword = "";
  String get keyword => _keyword;
  set keyword(String v) {
    _keyword = v;
    notifyListeners();
  }

  // 搜索框是否置顶
  bool _isTop = false;
  bool get isTop => _isTop;
  set isTop(bool v) {
    _isTop = v;
    notifyListeners();
  }

  // 搜索语言选择: zh_docs or en_docs
  bool _lang = false;
  bool get lang => _lang;
  set lang(bool v) {
    _lang = v;
    notifyListeners();
  }
  
  // 搜索类型选择: key or full
  bool _sType = false;
  bool get sType => _sType;
  set sType(bool v) {
    _sType = v;
    notifyListeners();
  }

  // 搜索列表
  List<SearchResultModel> _searchList = [];
  List<SearchResultModel> get searchList => _searchList;
  set searchList(List<SearchResultModel> v) {
    _searchList = v;
    notifyListeners();
  }
  void push (SearchResultModel model) {
    _searchList.add(model);
    notifyListeners();
  }

  // 当前搜索页数
  int _current = 0;
  int get current => _current;
  set current(int v) {
    _current = v;
    notifyListeners();
  }
}

class SearchResultModel {

  final int id;
  final String title;
  final String content;

  SearchResultModel(this.id,this.title, this.content);

  SearchResultModel.fromJson(Map<String, dynamic> json): id = json["id"], title = json['title'], content = json['content'];

  Map<String, dynamic> toJson() => {
    'id' : id,
    'title': title,
    'content': content
  };
}
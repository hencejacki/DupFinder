
import 'package:fluent_ui/fluent_ui.dart';

class DuplicateCheckModel extends ChangeNotifier{

  // 原文档是否上传
  bool _originalDocUploaded = false;
  bool get originalDocUploaded => _originalDocUploaded;
  set originalDocUploaded(bool v) {
    _originalDocUploaded = v;
    notifyListeners();
  }

  // 原文档路径
  String _originalDocFile = "";
  String get originalDocFile => _originalDocFile;
  set originalDocFile(String v) {
    _originalDocFile = v;
    notifyListeners();
  }

  // 原文档内容
  String _originalDocContent = "";
  String get originalDocContent => _originalDocContent;
  set originalDocContent(String v) {
    _originalDocContent = v;
    notifyListeners();
  }

  // 比较文档是否上传
  bool _compareDocUploaded = false;
  bool get compareDocUploaded => _compareDocUploaded;
  set compareDocUploaded(bool v) {
    _compareDocUploaded = v;
    notifyListeners();
  }

  // 比较文档路径
  String _compareDocFile = "";
  String get compareDocFile => _compareDocFile;
  set compareDocFile(String v) {
    _compareDocFile = v;
    notifyListeners();
  }

  // 比较文档内容
  String _compareDocContent = "";
  String get compareDocContent => _compareDocContent;
  set compareDocContent(String v) {
    _compareDocContent = v;
    notifyListeners();
  }

  // 上传文档语言选择;默认中文
  int _langSelect = 0;
  int get langSelect => _langSelect;
  set langSelect(int v) {
    _langSelect = v;
    notifyListeners();
  }

  // 上传模式选择;默认文件模式
  bool _uploadMode = false;
  bool get uploadMode => _uploadMode;
  set uploadMode(bool v) {
    _uploadMode = v;
    notifyListeners();
  }

  // 文档比对相似度
  String _docSimilarity = "";
  String get docSimilarity => _docSimilarity;
  set docSimilarity(String v) {
    _docSimilarity = v;
    notifyListeners();
  }

  // 文档比对结论
  String _conclusion = "";
  String get conclusion => _conclusion;
  set conclusion(String v) {
    _conclusion = v;
    notifyListeners();
  }

  // 比对是否完成
  bool _isCompleted = true;
  bool get isCompleted => _isCompleted;
  set isCompleted(bool v) {
    _isCompleted = v;
    notifyListeners();
  }
}
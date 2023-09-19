
import 'package:dupfinder/constant/global_constant.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../widgets/chat_message.dart';

class GPTModel extends ChangeNotifier {

  // 文本框内容
  String _question = "";
  String get question => _question;
  set question(String v) {
    _question = v;
    notifyListeners();
  }

  // 滑动位置
  double _savedScrollPosition = 0.0;
  double get savedScrollPosition => _savedScrollPosition;
  set savedScrollPosition(double v) {
    _savedScrollPosition = v;
    notifyListeners();
  }

  // 聊天内容
  List<ChatMessage> _messages = [
   ChatMessage(text: "你好,很高兴认识你!", chatMessageType: ChatMessageType.bot, isFinished: true,),
  ];
  List<ChatMessage> get messages => _messages;
  set messages(List<ChatMessage> v) {
    _messages = v;
    notifyListeners();
  }

}
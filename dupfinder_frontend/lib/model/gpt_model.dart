
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
    const ChatMessage(text: "你好", chatMessageType: ChatMessageType.user),
    const ChatMessage(text: "你好,很高兴认识你!", chatMessageType: ChatMessageType.bot),
    const ChatMessage(text: "Hello,World", chatMessageType: ChatMessageType.user),
    const ChatMessage(text: "通过以上方式,你可以在initState方法中使用状态管理库来获取数据或执行其他初始化操作。请注意,在initState方法中使用context.watch()时要确保在合适的时机使用，以避免可能的错误和副作用。", chatMessageType: ChatMessageType.bot)
  ];
  List<ChatMessage> get messages => _messages;
  set messages(List<ChatMessage> v) {
    _messages = v;
    notifyListeners();
  }

}
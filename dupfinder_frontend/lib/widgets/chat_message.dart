import 'package:dupfinder/constant/global_constant.dart';
import 'package:dupfinder/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

const userEndBackgroundColor = Color.fromARGB(122, 52, 53, 65);
const botEndBackgroundColor = Color.fromARGB(122, 68, 70, 84);

const userStartBackgroundColor = Color.fromARGB(151, 253, 253, 253);
const botStartBackgroundColor = Color.fromARGB(164, 243, 243, 243);

class ChatMessage extends StatefulWidget {
  const ChatMessage(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  State<StatefulWidget> createState() => ChatMessageState();
}

class ChatMessageState extends State<ChatMessage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  late Color _currentUserColor;
  late Color _currentBotColor;

  ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 500),
    );
    _currentBotColor = userStartBackgroundColor;
    _currentUserColor = userStartBackgroundColor;
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentBotColor = !FluentTheme.of(context).brightness.isLight
        ? botEndBackgroundColor
        : botStartBackgroundColor;
    _currentUserColor = !FluentTheme.of(context).brightness.isLight
        ? userEndBackgroundColor
        : userStartBackgroundColor;
    // 改变颜色
    context.watch<AppTheme>().addListener(() {
      _currentBotColor = FluentTheme.of(context).brightness.isLight
          ? botEndBackgroundColor
          : botStartBackgroundColor;
      _currentUserColor = FluentTheme.of(context).brightness.isLight
          ? userEndBackgroundColor
          : userStartBackgroundColor;
    });

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          padding: const EdgeInsets.all(16),
          color: widget.chatMessageType == ChatMessageType.bot
              ? _currentBotColor
              : _currentUserColor,
          child: child,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 15.0),
                  child: const CircleAvatar(
                    child: Icon(
                      FluentIcons.robot,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 15.0),
                  child: const CircleAvatar(
                    child: Icon(FluentIcons.reminder_person),
                  ),
                ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Text(widget.text),
              )
            ],
          ))
        ],
      ),
    );
  }
}

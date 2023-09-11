import 'package:dupfinder/constant/global_constant.dart';
import 'package:dupfinder/model/gpt_model.dart';
import 'package:dupfinder/widgets/chat_message.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GPT问答界面

class QAGptPage extends StatefulWidget {
  const QAGptPage({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  State<StatefulWidget> createState() => _QAGptPage();
}

class _QAGptPage extends State<QAGptPage> {
  // 滑动控制
  final ScrollController _scrollController = ScrollController();

  // 文本框控制
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // double savedScrollPosition =
    //     widget.preferences.getDouble("QA-scrollPosition") ?? -1.0;
    // if (savedScrollPosition > 0) {
    //   print("savedScrollPosition: $savedScrollPosition");
    //   _scrollController.jumpTo(savedScrollPosition);
    // }
    _scrollController.addListener(() {
      print("1!5!");
      // 保存当前位置到本地
      widget.preferences
          .setDouble("QA-scrollPosition", _scrollController.position.pixels);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // double savedScrollPosition =
    //     widget.preferences.getDouble("QA-scrollPosition") ?? -1.0;
    // if (savedScrollPosition > 0) {
    //   print("savedScrollPosition: $savedScrollPosition");
    //   if (_scrollController.hasClients) {
    //     print("Jumping");
    //     _scrollController.jumpTo(savedScrollPosition);
    //   }
    // }
  }

  @override
  void dispose() {
    // 释放资源
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gptModel = context.watch<GPTModel>();

    return Scaffold(
      body: Column(
        children: <Widget>[
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Conversations With ChatGPT",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  itemCount: gptModel.messages.length,
                  itemBuilder: (context, index) {
                    var message = gptModel.messages[index];
                    return ChatMessage(
                        text: message.text,
                        chatMessageType: message.chatMessageType);
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      padding:
                          const EdgeInsets.only(left: 16, bottom: 16, top: 10),
                      height: 80,
                      width: double.infinity,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                                color: fluent.FluentTheme.of(context)
                                        .brightness
                                        .isDark
                                    ? const fluent.Color.fromARGB(
                                        185, 64, 65, 79)
                                    : const fluent.Color.fromARGB(
                                        158, 243, 243, 243)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _textEditingController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      hintText: "Send a message",
                                    ),
                                    onSubmitted: (v) {
                                      setState(() {
                                        gptModel.messages.addAll([
                                          ChatMessage(
                                              text: v,
                                              chatMessageType:
                                                  ChatMessageType.user),
                                          const ChatMessage(
                                              text:
                                                  "是的,Android可以被归类为嵌入式系统的一种。嵌入式系统是指被嵌入到其他设备或系统中的计算机系统,通常用于特定的任务或功能。Android是一个开放源代码的移动操作系统,广泛应用于智能手机、平板电脑和其他移动设备中。它被设计用于在资源有限的嵌入式环境中运行,并提供了丰富的功能和开发工具,以支持移动应用程序的开发和执行。由于Android在嵌入式系统中的应用范围广泛,并且与硬件密切相关,因此它可以被认为是一种嵌入式系统。",
                                              chatMessageType:
                                                  ChatMessageType.bot)
                                        ]);
                                      });
                                      _textEditingController.clear();
                                      _scrollController.animateTo(
                                          _scrollController
                                              .position.maxScrollExtent,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeOut);
                                    },
                                  ),
                                ),
                                fluent.IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                          ))),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dupfinder/constant/global_constant.dart';
import 'package:dupfinder/http/request.dart';
import 'package:dupfinder/model/gpt_model.dart';
import 'package:dupfinder/model/request/gpt_request.dart';
import 'package:dupfinder/model/response/gpt_response.dart';
import 'package:dupfinder/widgets/chat_message.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/response/base_response.dart';

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
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  /// Get Response from backend
  Future<String> getResponse(String prompt) async {
    GPTRequest req = GPTRequest(prompt: prompt);

    try {
      Response? res = await httpInstance?.post("/GPT",
          data: FormData.fromMap(req.toJson()));

      Map<String, dynamic> result = jsonDecode(res.toString());
      BaseResponse baseResponse = BaseResponse.fromJson(result);

      GPTResponse gptResponse =
          GPTResponse.fromJson(baseResponse.serializeData);

      return gptResponse.reply ?? "";
    } on DioException {
      return "";
    }
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
            flex: 7,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: gptModel.messages.length,
              itemBuilder: (context, index) {
                // if (kDebugMode) {
                //   print(gptModel.messages[index].isFinished);
                //   print("isPlayed?: ${gptModel.messages[index].isPlayed}");
                // }
                gptModel.messages[index] = ChatMessage(
                  text: gptModel.messages[index].text,
                  chatMessageType: gptModel.messages[index].chatMessageType,
                  isFinished: gptModel.messages[index].isFinished,
                  isPlayed: gptModel.messages[index].isPlayed,
                );
                return gptModel.messages[index];
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
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
                                      List<ChatMessage> newMessages = [
                                        ChatMessage(
                                          text: v,
                                          chatMessageType: ChatMessageType.user,
                                          isPlayed: true,
                                        ),
                                        ChatMessage(
                                          key: UniqueKey(),
                                          text: "",
                                          chatMessageType: ChatMessageType.bot,
                                          isFinished: false,
                                        )
                                      ];
                                      setState(() {
                                        gptModel.messages.addAll(newMessages);
                                      });

                                      // 请求API
                                      getResponse(v).then(
                                        (value) {
                                          if (value.isNotEmpty) {
                                            setState(() {
                                              gptModel.messages.last.text =
                                                  value;
                                              gptModel.messages.last
                                                  .isFinished = true;
                                            });
                                          } else {
                                            gptModel.messages.last.text =
                                                "网络出现错误!";
                                            gptModel.messages.last.isFinished =
                                                true;
                                          }
                                        },
                                      );

                                      _textEditingController.clear();
                                      _scrollController.animateTo(
                                          _scrollController
                                                  .position.maxScrollExtent *
                                              10,
                                          duration: const Duration(seconds: 3),
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
                                ),
                                fluent.IconButton(
                                  onPressed: () {
                                    setState(() {
                                      gptModel.messages.clear();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.cleaning_services_rounded,
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

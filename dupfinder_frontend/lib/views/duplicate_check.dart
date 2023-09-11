import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dupfinder/http/request.dart';
import 'package:dupfinder/model/duplicate_check_data.dart';
import 'package:dupfinder/model/request/dupcheck_request.dart';
import 'package:dupfinder/model/response/base_response.dart';
import 'package:dupfinder/model/response/dupcheck_response.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

/// 查重界面

// 底部提示
void showshowSnackbar(BuildContext context, String info) {
  showSnackbar(
    context,
    Snackbar(
      content: RichText(
        text: TextSpan(
          text: 'Attention ',
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: info,
              style: TextStyle(
                color: Colors.red.defaultBrushFor(
                  FluentTheme.of(context).brightness,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      extended: true,
    ),
  );
}

class DuplicateCheck extends StatefulWidget {
  const DuplicateCheck({super.key});

  @override
  State<StatefulWidget> createState() => _DuplicateCheck();
}

class _DuplicateCheck extends State<DuplicateCheck> {
  // 获取文件内容
  String getFileContent(File file) {
    String ret = "";
    if (file.existsSync()) {
      ret = file.readAsStringSync();
    }
    return ret;
  }

  // 查重文件执行
  Future<DupCheckResponse> startFileDupCheck(
      int langSelect, String originalDocPath, String compareDocPath) async {
    // 1. 构造请求
    DupCheckFileRequest req = DupCheckFileRequest(
        lang: langSelect == 0 ? "zh" : "en",
        originalDoc: MultipartFile.fromFileSync(originalDocPath),
        compareDoc: MultipartFile.fromFileSync(compareDocPath));
    // 2. 网络请求
    try {
      Response? res = await httpInstance?.post("/dupcheck/file",
          data: FormData.fromMap(req.toJson()));

      // 3. 解析请求
      Map<String, dynamic> result = jsonDecode(res.toString());
      BaseResponse baseResponse = BaseResponse.fromJson(result);
      DupCheckResponse dupCheckResponse =
          DupCheckResponse.fromJson(baseResponse.serializeData);

      // 返回结果
      return dupCheckResponse;
    } on DioException catch (e) {
      showshowSnackbar(context, "Network error: ${e.message}");
    }
    return DupCheckResponse();
  }

  // 查重文本执行
  Future<DupCheckResponse> startTextDupCheck(
      int langSelect, String originalDoc, String compareDoc) async {
    // 1. 构造请求
    DupCheckTxtRequest req = DupCheckTxtRequest(
        lang: langSelect == 0 ? "zh" : "en",
        originalTxt: originalDoc,
        compareTxt: compareDoc);

    // 2. 网络请求
    try {
      Response? res =
          await httpInstance?.post("/dupcheck/txt", data: FormData.fromMap(req.toJson()));

      // 3. 解析请求
      Map<String, dynamic> result = jsonDecode(res.toString());
      BaseResponse baseResponse = BaseResponse.fromJson(result);
      DupCheckResponse dupCheckResponse =
          DupCheckResponse.fromJson(baseResponse.serializeData);

      // 返回结果
      return dupCheckResponse;
    } on DioException catch (e) {
      showshowSnackbar(context, "Network error: ${e.message}");
    }
    return DupCheckResponse();
  }

  @override
  Widget build(BuildContext context) {
    final duplicateCheckModel = context.watch<DuplicateCheckModel>();

    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const PageHeader(
          title: Text("Duplicate check your paper"),
        ),
        Expanded(
            flex: 4,
            child: SizedBox(
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          height: double.infinity,
                          child: duplicateCheckModel.uploadMode &&
                                  !duplicateCheckModel.originalDocUploaded
                              ? FilledButton(
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FluentIcons.rocket,
                                        size: 20.0,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Upload",
                                        style: TextStyle(fontSize: 24.0),
                                      )
                                    ],
                                  ),
                                  onPressed: () async {
                                    // 选取文件
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles();
                                    if (result != null) {
                                      File file =
                                          File(result.files.single.path!);
                                      if (file.existsSync()) {
                                        setState(() {
                                          duplicateCheckModel.originalDocFile =
                                              file.path;
                                          //获取文件内容
                                          duplicateCheckModel
                                                  .originalDocContent =
                                              getFileContent(file);
                                          duplicateCheckModel
                                              .originalDocUploaded = true;
                                        });
                                      }
                                    }
                                  })
                              : TextBox(
                                  controller: TextEditingController(
                                      text: duplicateCheckModel
                                          .originalDocContent),
                                  maxLines: null,
                                  placeholder: "Your document is here....",
                                  textAlignVertical: TextAlignVertical.top,
                                  onSubmitted: (value) {
                                    setState(() {
                                      duplicateCheckModel.originalDocContent =
                                          value;
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      duplicateCheckModel.originalDocContent =
                                          value;
                                    });
                                  },
                                ),
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FluentIcons.inbox_check,
                            size: 34.0,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              RadioButton(
                                checked: duplicateCheckModel.langSelect == 0,
                                onChanged: (v) {
                                  setState(() {
                                    duplicateCheckModel.langSelect = 0;
                                  });
                                },
                                content: const Text("中文"),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              RadioButton(
                                checked: duplicateCheckModel.langSelect == 1,
                                onChanged: (v) {
                                  setState(() {
                                    duplicateCheckModel.langSelect = 1;
                                  });
                                },
                                content: const Text("英文"),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ToggleSwitch(
                              checked: duplicateCheckModel.uploadMode,
                              onChanged: (v) {
                                setState(() {
                                  duplicateCheckModel.uploadMode = v;
                                  duplicateCheckModel.originalDocUploaded =
                                      false;
                                  duplicateCheckModel.compareDocUploaded =
                                      false;
                                });
                              }),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(duplicateCheckModel.uploadMode ? "文件" : "文本")
                        ],
                      )),
                  Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          height: double.infinity,
                          child: duplicateCheckModel.uploadMode &&
                                  !duplicateCheckModel.compareDocUploaded
                              ? FilledButton(
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FluentIcons.rocket,
                                        size: 20.0,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Upload",
                                        style: TextStyle(fontSize: 24.0),
                                      )
                                    ],
                                  ),
                                  onPressed: () async {
                                    // 选取文件
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles();
                                    if (result != null) {
                                      File file =
                                          File(result.files.single.path!);
                                      if (file.existsSync()) {
                                        setState(() {
                                          duplicateCheckModel.compareDocFile =
                                              file.path;
                                          //获取文件内容
                                          duplicateCheckModel
                                                  .compareDocContent =
                                              getFileContent(file);
                                          duplicateCheckModel
                                              .compareDocUploaded = true;
                                        });
                                      }
                                    }
                                  })
                              : TextBox(
                                  controller: TextEditingController(
                                      text: duplicateCheckModel
                                          .compareDocContent),
                                  maxLines: null,
                                  placeholder: "Your document is here....",
                                  textAlignVertical: TextAlignVertical.top,
                                  onSubmitted: (value) {
                                    setState(() {
                                      duplicateCheckModel.compareDocContent =
                                          value;
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      duplicateCheckModel.compareDocContent =
                                          value;
                                    });
                                  },
                                ),
                        ),
                      ))
                ],
              ),
            )),
        Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FilledButton(
                  onPressed: (duplicateCheckModel.originalDocUploaded &&
                              duplicateCheckModel.compareDocUploaded) ||
                          !duplicateCheckModel.uploadMode
                      ? () {
                          setState(() {
                            duplicateCheckModel.isCompleted = false;
                          });
                          if (duplicateCheckModel.uploadMode) {
                            print("file check");
                            startFileDupCheck(
                                    duplicateCheckModel.langSelect,
                                    duplicateCheckModel.originalDocFile,
                                    duplicateCheckModel.compareDocFile)
                                .then((value) {
                              setState(() {
                                duplicateCheckModel.docSimilarity =
                                    value.similarity ?? "";
                                duplicateCheckModel.conclusion =
                                    value.conclusion ?? "";
                                duplicateCheckModel.isCompleted = true;
                              });
                              // 展示对话框显示结果
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ContentDialog(
                                      title: const Text('提示'),
                                      content: Text(
                                          "比对完成, 文档相似度: ${duplicateCheckModel.docSimilarity}\n结论如下:\n${duplicateCheckModel.conclusion}"),
                                      actions: [
                                        FilledButton(
                                            child: const Text("Got it"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            })
                                      ],
                                    );
                                  });
                            });
                          } else {
                            print("text check");
                            startTextDupCheck(
                                    duplicateCheckModel.langSelect,
                                    duplicateCheckModel.originalDocContent,
                                    duplicateCheckModel.compareDocContent)
                                .then((value) {
                              setState(() {
                                duplicateCheckModel.docSimilarity =
                                    value.similarity ?? "";
                                duplicateCheckModel.conclusion =
                                    value.conclusion ?? "";
                                duplicateCheckModel.isCompleted = true;
                              });
                              // 展示对话框显示结果
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ContentDialog(
                                      title: const Text('提示'),
                                      content: Text(
                                          "比对完成, 文档相似度: ${duplicateCheckModel.docSimilarity}\n结论如下:\n${duplicateCheckModel.conclusion}"),
                                      actions: [
                                        FilledButton(
                                            child: const Text("Got it"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            })
                                      ],
                                    );
                                  });
                            });
                          }
                        }
                      : null,
                  child: duplicateCheckModel.isCompleted
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FluentIcons.double_chevron_down,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Start Compare!"),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              FluentIcons.double_chevron_down,
                              size: 20,
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ProgressRing(),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text("正在比对中...")
                          ],
                        )),
            )),
      ],
    );
  }
}

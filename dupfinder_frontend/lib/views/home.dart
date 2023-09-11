import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dupfinder/http/request.dart';
import 'package:dupfinder/model/home_data.dart';
import 'package:dupfinder/model/request/search_request.dart';
import 'package:dupfinder/model/response/base_response.dart';
import 'package:dupfinder/model/response/search_response.dart';
import 'package:dupfinder/widgets/search_item.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

/// 主页

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  Future<List<SearchResultModel>> goSearch(
      String keyword, String lang, String type, int from) async {
    // 1. 构造请求
    SearchRequest req =
        SearchRequest(keyword: keyword, lang: lang, type: type, from: from);

    // 2. 发送请求
    try {
      Response? res =
          await httpInstance?.get("/search", queryParameters: req.toJson());

      // 3. 解析请求
      Map<String, dynamic> result = jsonDecode(res.toString());
      BaseResponse baseResponse = BaseResponse.fromJson(result);
      SearchResponse searchResponse =
          SearchResponse.fromJson(baseResponse.serializeData);

      // 4. 返回搜索记录
      return searchResponse.records;
    } on DioException catch (e) {
      // 5. 错误捕获
      showshowSnackbar(context, "Network Error: ${e.message}");
    }
    return List.empty();
  }

  @override
  Widget build(BuildContext context) {
    final homeModel = context.watch<HomeModel>();

    return Column(
      children: [
        Expanded(
            flex: 1,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              SizedBox(
                height: homeModel.isTop ? 0.0 : 100.0,
              ),
              const Text(
                "DupFinder",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50.0),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(homeModel.lang ? 'en_docs' : 'zh_docs'),
                  const SizedBox(
                    width: 10.0,
                  ),
                  ToggleSwitch(
                      checked: homeModel.lang,
                      onChanged: (v) {
                        setState(() {
                          homeModel.lang = v;
                        });
                      }),
                  const SizedBox(
                    width: 20.0,
                  ),
                  ToggleSwitch(
                      checked: homeModel.sType,
                      onChanged: (v) {
                        setState(() {
                          homeModel.sType = v;
                        });
                      }),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(homeModel.sType ? 'fullsearch' : 'keysearch'),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 118.0),
                child: TextBox(
                    controller: TextEditingController(text: homeModel.keyword),
                    onSubmitted: (v) {
                      setState(() {
                        homeModel.isTop = true;
                      });
                      homeModel.keyword = v;
                      goSearch(
                              v,
                              homeModel.lang ? 'en_docs' : 'zh_docs',
                              homeModel.sType ? 'full' : 'key',
                              homeModel.current)
                          .then((value) {
                        if (value.isNotEmpty) {
                          // 重建页面
                          setState(() {
                            homeModel.searchList = value;
                          });
                        }
                      });
                    },
                    // onChanged: (v) {
                    //   setState(() {
                    //     homeModel.keyword = v;
                    //   });
                    // },
                    autocorrect: true,
                    placeholder: 'You know, for search',
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Icon(FluentIcons.search),
                    )),
              ),
              const SizedBox(
                height: 30.0,
              ),
            ])),
        Expanded(
            flex: homeModel.isTop ? 2 : 1,
            child: !homeModel.isTop
                ? const SizedBox(
                    height: double.infinity,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemCount: homeModel.searchList.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        height: 90,
                        child: SearchItem(
                            title: homeModel.searchList[index].title,
                            content: homeModel.searchList[index].content),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 20.0,
                      );
                    },
                  )),
        !homeModel.isTop
            ? const SizedBox()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Prev"),
                  IconButton(
                      icon:
                          const Icon(FluentIcons.chevron_left_med, size: 15.0),
                      onPressed: () {
                        setState(() {
                          homeModel.current--;
                          if (homeModel.current < 0) {
                            homeModel.current = 0;
                            showshowSnackbar(context, "Cannot forward anymore");
                          }
                        });
                        goSearch(
                                homeModel.keyword,
                                homeModel.lang ? 'en_docs' : 'zh_docs',
                                homeModel.sType ? 'full' : 'key',
                                homeModel.current)
                            .then((value) {
                          if (value.isNotEmpty) {
                            // 重建页面
                            setState(() {
                              homeModel.searchList = value;
                            });
                          }
                        });
                      }),
                  const Icon(
                    FluentIcons.emoji,
                    size: 15.0,
                  ),
                  IconButton(
                      icon:
                          const Icon(FluentIcons.chevron_right_med, size: 15.0),
                      onPressed: () {
                        setState(() {
                          homeModel.current++;
                        });
                        goSearch(
                                homeModel.keyword,
                                homeModel.lang ? 'en_docs' : 'zh_docs',
                                homeModel.sType ? 'full' : 'key',
                                homeModel.current)
                            .then((value) {
                          if (value.isNotEmpty) {
                            // 重建页面
                            setState(() {
                              homeModel.searchList = value;
                            });
                          }
                        });
                      }),
                  const Text("Next"),
                ],
              )
      ],
    );
  }
}

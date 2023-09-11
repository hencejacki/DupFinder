import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dupfinder/http/request.dart';
import 'package:dupfinder/model/cluster_result_data.dart';
import 'package:dupfinder/model/request/cluster_request.dart';
import 'package:dupfinder/model/response/base_response.dart';
import 'package:dupfinder/model/response/cluster_response.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

/// 聚类结果分析界面

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

class ClusterResult extends StatefulWidget {
  const ClusterResult({super.key});

  @override
  State<StatefulWidget> createState() => _ClusterResultState();
}

class _ClusterResultState extends State<ClusterResult> {
  final List<String> entries = <String>[
    'A',
    'B',
    'C',
    'A',
    'B',
    'C',
    'A',
    'B',
    'C',
    'A',
    'B',
    'C',
    'A',
    'B',
    'C',
    'A',
  ];

  // 聚类类数
  final List<String> clusterType = <String>['5', '10', '20', '25', '50'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // 查询聚类结果
  Future<ClusterResponse> queryClusterResult(
      String lang, int clusterType) async {
    // 1. 构造请求
    ClusterRequest req =
        ClusterRequest(langSelect: lang, clusterSelect: clusterType);

    // 2. 网络请求
    try {
      Response? res =
          await httpInstance?.get("/cluster", queryParameters: req.toJson());
      Map<String, dynamic> result = jsonDecode(res.toString());
      BaseResponse baseResponse = BaseResponse.fromJson(result);
      ClusterResponse clusterResponse =
          ClusterResponse.fromJson(baseResponse.serializeData);
      return clusterResponse;
    } on DioException catch (e) {
      showshowSnackbar(context, "Network Error: ${e.message}");
    }
    return ClusterResponse();
  }

  @override
  Widget build(BuildContext context) {
    final clusterModel = context.watch<ClusterModel>();

    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const PageHeader(
          title: Text("Cluster Result for about your document"),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Text("语言选择: "),
                  const SizedBox(
                    width: 20.0,
                  ),
                  DropDownButton(
                    title: clusterModel.langSelect == "zh"
                        ? const Text("中文")
                        : const Text("英文"),
                    items: [
                      MenuFlyoutItem(
                          text: const Text("中文"),
                          onPressed: () {
                            setState(() {
                              clusterModel.langSelect = "zh";
                            });
                            // 查询聚类结果
                            queryClusterResult(
                                    clusterModel.langSelect,
                                    jsonDecode(clusterType[
                                        clusterModel.clusterSelect]))
                                .then((value) {
                              setState(() {
                                clusterModel.clusters = value.clusters!;
                              });
                              // print(clusterModel.clusters[0].docCount);
                            });
                          }),
                      MenuFlyoutItem(
                          text: const Text("英文"),
                          onPressed: () {
                            setState(() {
                              clusterModel.langSelect = "en";
                              // 查询聚类结果
                              queryClusterResult(
                                      clusterModel.langSelect,
                                      jsonDecode(clusterType[
                                          clusterModel.clusterSelect]))
                                  .then((value) {
                                setState(() {
                                  clusterModel.clusters = value.clusters!;
                                });
                                // print(clusterModel.clusters[0].docCount);
                              });
                            });
                          })
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  const Text("聚类类数选择: "),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: List.generate(clusterType.length, (index) {
                        return Row(
                          children: [
                            RadioButton(
                                checked: clusterModel.clusterSelect == index,
                                content: Text(clusterType[index]),
                                onChanged: (v) {
                                  setState(() {
                                    clusterModel.clusterSelect = index;
                                  });
                                  // 查询聚类结果
                                  queryClusterResult(
                                          clusterModel.langSelect,
                                          jsonDecode(clusterType[
                                              clusterModel.clusterSelect]))
                                      .then((value) {
                                    setState(() {
                                      clusterModel.clusters = value.clusters!;
                                    });
                                    // print(clusterModel.clusters[0].docCount);
                                  });
                                }),
                            const SizedBox(
                              width: 10.0,
                            )
                          ],
                        );
                      }),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        Expanded(
          flex: 12,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: clusterModel.clusters.length,
            itemBuilder: (BuildContext context, int index) {
              int docCount = clusterModel.clusters[index].docCount;
              List<String> clusters = clusterModel.clusters[index].nearestDocs;
              return Expander(
                header: Text('第 ${index + 1} 类  文档数: $docCount  文档语言: ${clusterModel.langSelect == 'zh' ? '中文' : '英文'}'),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Nearest document: ",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Row(
                        children: List.generate(
                      clusters.length,
                      (index) {
                        return Row(
                          children: [
                            Text(clusters[index]),
                            const SizedBox(
                              width: 20.0,
                            )
                          ],
                        );
                      },
                    ))
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

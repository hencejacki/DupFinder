import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_html/flutter_html.dart';

/// 搜索Item

class SearchItem extends StatefulWidget {
  const SearchItem({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  State<StatefulWidget> createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(FluentIcons.cat),
            const SizedBox(
              width: 5,
            ),
            HyperlinkButton(
                onPressed: () {},
                child: Text(
                  widget.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Color.fromARGB(255, 0, 162, 255)),
                ))
          ],
        ),
        Expanded(child: Html(
          data: widget.content,
          style: {
            "b": Style(
              color: Colors.red
            )
          },
          ))
      ],
    );
  }
}

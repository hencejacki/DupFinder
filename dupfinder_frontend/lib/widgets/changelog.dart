
// 更新日志

import 'package:fluent_ui/fluent_ui.dart';

class ChangeLog extends StatefulWidget {
  const ChangeLog({super.key});

  @override
  State<StatefulWidget> createState() => _ChangeLogState();
}

class _ChangeLogState extends State<ChangeLog> {

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('What \'s new'),
      content: const Text('Nothing Here!'),
      actions: [
        FilledButton(child: const Text("Got it"), onPressed: (){
          Navigator.pop(context);
        })
      ],
    );
  }
}
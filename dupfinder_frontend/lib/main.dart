import 'package:dupfinder/model/cluster_result_data.dart';
import 'package:dupfinder/model/duplicate_check_data.dart';
import 'package:dupfinder/model/gpt_model.dart';
import 'package:dupfinder/model/home_data.dart';
import 'package:dupfinder/views/cluster_result.dart';
import 'package:dupfinder/views/duplicate_check.dart';
import 'package:dupfinder/views/question_answer.dart';
import 'package:dupfinder/widgets/changelog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/link.dart';
import 'package:dupfinder/theme.dart';
import 'package:dupfinder/views/home.dart';
import 'package:dupfinder/views/settings.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const String appTitle = 'DupFinder';
late SharedPreferences pref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemTheme.accentColor.load();
  await flutter_acrylic.Window.initialize();
  await flutter_acrylic.Window.hideWindowControls();

  await windowManager.ensureInitialized();

  pref = await SharedPreferences.getInstance();

  WindowOptions windowOptions = const WindowOptions(
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMinimumSize(const Size(835, 600));
    await windowManager.show();
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
    await windowManager.focus();
  });
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key,});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      builder: (context, child) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp.router(
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: FluentThemeData(
              brightness: Brightness.dark,
              accentColor: appTheme.color,
              visualDensity: VisualDensity.standard,
              focusTheme: FocusThemeData(
                glowFactor: is10footScreen(context) ? 2.0 : 0.0,
              )),
          theme: FluentThemeData(
              accentColor: appTheme.color,
              visualDensity: VisualDensity.standard,
              focusTheme: FocusThemeData(
                glowFactor: is10footScreen(context) ? 2.0 : 0.0,
              )),
          locale: appTheme.locale,
          builder: (context, child) {
            return NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!);
          },
          routerDelegate: router.routerDelegate,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => DuplicateCheckModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClusterModel(),
        ),
        ChangeNotifierProvider(
          create: (_)  => GPTModel(),
        )
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.child,
    required this.shellContext,
    required this.state,
  });

  final Widget child;
  final BuildContext? shellContext;
  final GoRouterState state;

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');

  // 计算当前选中路由索引
  int _calculateSelectedIndex(BuildContext context) {
    final location = router.location;
    int indexOriginal = originalItems
        .where((element) => element.key != null)
        .toList()
        .indexWhere((element) => element.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = footerItems
          .where((element) => element.key != null)
          .toList()
          .indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
      }
      return originalItems
              .where((element) => element.key != null)
              .toList()
              .length +
          indexFooter;
    } else {
      return indexOriginal;
    }
  }

  final List<NavigationPaneItem> originalItems = [
    PaneItem(
      key: const Key('/'),
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (router.location != '/') router.pushNamed('home');
      },
    ),
    PaneItem(
      key: const Key('/dupcheck'),
      icon: const Icon(FluentIcons.graph_symbol),
      title: const Text('Duplicate Check'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (router.location != '/dupcheck') router.pushNamed('dupcheck');
      },
    ),
    PaneItem(
      key: const Key('/clusteres'),
      icon: const Icon(FluentIcons.diagnostic),
      title: const Text('Cluster Result'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (router.location != '/clusteres') router.pushNamed('clusteres');
      },
    ),
    PaneItem(
      key: const Key('/qagpt'),
      icon: const Icon(FluentIcons.robot),
      title: const Text('GPT-3.5'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (router.location != '/qagpt') router.pushNamed('qagpt');
      },
    ),
  ];

  final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const Key('/settings'),
      title: const Text("Settings"),
      icon: const Icon(FluentIcons.settings),
      body: const SizedBox.shrink(),
      onTap: () {
        if (router.location != '/settings') router.pushNamed('settings');
      },
    ),
    _LinkPaneItemAction(
      icon: const Icon(FluentIcons.open_source),
      title: const Text('Source code'),
      link: 'https://github.com/Mr-Jacks520',
      body: const SizedBox.shrink(),
    ),
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 全局主题
    final appTheme = context.watch<AppTheme>();

    // 国际化?
    // final localizations = FluentLocalizations.of(context);

    // 当前主题
    final theme = FluentTheme.of(context);

    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          title: const DragToMoveArea(
              child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(appTitle),
          )),
          actions: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8.0),
                child: ToggleSwitch(
                  content: const Text('Dark Mode'),
                  checked: FluentTheme.of(context).brightness.isDark,
                  onChanged: (v) {
                    if (v) {
                      appTheme.mode = ThemeMode.dark;
                    } else {
                      appTheme.mode = ThemeMode.light;
                    }
                  },
                ),
              ),
              const WindowButtons(),
            ],
          )),
      paneBodyBuilder: (item, body) {
        final name =
            item?.key is ValueKey ? (item!.key as ValueKey).value : null;

        return FocusTraversalGroup(
            key: ValueKey('body$name'), child: widget.child);
      },
      pane: NavigationPane(
          selected: _calculateSelectedIndex(context),
          header: SizedBox(
              height: kOneLineTileHeight,
              child: ShaderMask(
                // Unkown
                shaderCallback: (rect) {
                  final color =
                      appTheme.color.defaultBrushFor(theme.brightness);
                  return LinearGradient(colors: [color, color])
                      .createShader(rect);
                },
                child: IconButton(
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'What\'s new on 0.0.1',
                        style: theme.typography.body
                            ?.copyWith(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => const ChangeLog());
                  },
                ),
              )),
          displayMode: appTheme.displayMode,
          indicator: () {
            switch (appTheme.indicator) {
              case NavigationIndicators.end:
                return const EndNavigationIndicator();
              case NavigationIndicators.sticky:
              default:
                return const StickyNavigationIndicator();
            }
          }(),
          items: originalItems,
          footerItems: footerItems),
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      // Prevent below errors...
      // Don't use 'BuildContext's across async gaps.
      // Try rewriting the code to not reference the 'BuildContext'.
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (_) {
            return ContentDialog(
              title: const Text('Confirm close?'),
              content:
                  const Text('Are you sure you want to quit this application'),
              actions: [
                FilledButton(
                    child: const Text("Yes"),
                    onPressed: () {
                      Navigator.pop(context);
                      windowManager.destroy();
                    }),
                Button(
                    child: const Text("No"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            );
          });
    }
    super.onWindowClose();
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _LinkPaneItemAction extends PaneItem {
  _LinkPaneItemAction({
    required super.icon,
    required this.link,
    required super.body,
    super.title,
  });

  final String link;

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
    int? itemIndex,
  }) {
    return Link(
      uri: Uri.parse(link),
      builder: (context, followLink) => super.build(
        context,
        selected,
        followLink,
        displayMode: displayMode,
        showTextOnTop: showTextOnTop,
        itemIndex: itemIndex,
        autofocus: autofocus,
      ),
    );
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
  ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MyHomePage(
          state: state,
          shellContext: context,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const Settings(),
        ),
        GoRoute(
          path: '/dupcheck',
          name: 'dupcheck',
          builder: (context, state) => const DuplicateCheck(),
        ),
        GoRoute(
          path: '/clusteres',
          name: 'clusteres',
          builder: (context, state) => const ClusterResult(),
        ),
        GoRoute(
          path: '/qagpt',
          name: 'qagpt',
          builder: (context, state) => QAGptPage(preferences: pref,),
        )
      ])
]);

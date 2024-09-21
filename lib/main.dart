import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getx_scaffold/getx_scaffold.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:work_helper/home/index.dart';
import 'package:work_helper/theme.dart';

const String APP_NAME = 'WorkHelper';
const double WINDOW_WIDTH = 1600;
const double WINDOW_HEIGHT = 1050;

void main() async {
  //框架初始化
  await init(
    isDebug: kDebugMode,
    logTag: APP_NAME,
  );
  await windowManager.ensureInitialized();
  await Hive.initFlutter();
  Size size = const Size(WINDOW_WIDTH, WINDOW_HEIGHT);
  WindowOptions windowOptions = WindowOptions(
    size: size,
    minimumSize: size,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: APP_NAME,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(
    GetxApp(
      // 设计尺寸
      designSize: const Size(WINDOW_WIDTH, WINDOW_HEIGHT),
      // Debug Banner
      debugShowCheckedModeBanner: false,
      // Getx Log
      enableLog: kDebugMode,
      // 默认的跳转动画
      defaultTransition: Transition.fadeIn,
      // 主题模式
      themeMode: GlobalService.to.themeMode,
      // 主题
      theme: AppTheme.light,
      // AppTitle
      title: APP_NAME,
      // 首页
      home: const HomePage(),
      // Builder
      builder: (context, widget) {
        return widget!;
      },
    ),
  );
}

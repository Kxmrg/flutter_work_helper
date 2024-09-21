import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:getx_scaffold/getx_scaffold.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeController extends GetxController with BaseControllerMixin {
  HomeController();

  @override
  String get builderId => 'home';

  static const String NOON_BREAK_START = 'NOON_BREAK_START';
  static const String NOON_BREAK_END = 'NOON_BREAK_END';

  final EventController eventController = EventController();

  late Box hiveBox;

  Timer? _clockTimer;
  //当前时间
  RxString currentTime = ''.obs;
  //今日上班时间
  RxString todayStartTime = ''.obs;
  //今日下班时间
  RxString todayEndTime = ''.obs;

  //午休开始时间
  Rx<DateTime> noonBreakStart = Rx<DateTime>(DateTime.now());
  //午休结束时间
  Rx<DateTime> noonBreakEnd = Rx<DateTime>(DateTime.now());
  //午休时长
  RxString noonBreakDuration = ''.obs;

  @override
  void onInit() {
    super.onInit();
    var start = getStringAsync(NOON_BREAK_START, defaultValue: '2000-10-10 11:30');
    var end = getStringAsync(NOON_BREAK_END, defaultValue: '2000-10-10 13:30');
    noonBreakStart.value = DateTime.parse(start);
    noonBreakEnd.value = DateTime.parse(end);
    updateNoonBreakDuration();
  }

  @override
  void onReady() async {
    super.onReady();
    hiveBox = await Hive.openBox('events');
    _saveTime();
    _runClockTimer();
    setEvent(DateTime.now());
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    _clockTimer = null;
    super.onClose();
  }

  void _runClockTimer() {
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        currentTime.value = getNowDateTimeString();
      },
    );
  }

  void _saveTime() {
    String nowDate = DateTime.now().toDateString();
    String nowTime = DateTime.now().toTimeString();
    var data = hiveBox.get(nowDate, defaultValue: null);
    if (data == null) {
      todayStartTime.value = nowTime;
      hiveBox.put(
        nowDate,
        {
          'start': nowTime,
          'end': null,
        },
      );
    } else {
      todayStartTime.value = data['start'];
      todayEndTime.value = nowTime;
      data['end'] = nowTime;
      hiveBox.put(
        nowDate,
        data,
      );
    }
  }

  void updateEndTime() {
    _saveTime();
    setEvent(DateTime.now());
  }

  void setEvent(DateTime dateTime) async {
    // 获取当前月份的第一天
    DateTime firstDayOfMonth = DateTime(dateTime.year, dateTime.month, 1);
    // 获取下个月的第一天
    DateTime firstDayOfNextMonth = DateTime(dateTime.year, dateTime.month + 1, 1);
    // 计算当前月份的天数
    int daysInMonth = firstDayOfNextMonth.difference(firstDayOfMonth).inDays;
    // 创建一个列表，遍历每一天
    List<String> days = [];
    for (int i = 0; i < daysInMonth; i++) {
      days.add(firstDayOfMonth.add(Duration(days: i)).toDateString());
    }
    // 从缓存中拿出全部数据
    for (String day in days) {
      Map? data = hiveBox.get(day, defaultValue: null);
      if (data != null) {
        final calendarEventData = CalendarEventData<Map>(
          title: day,
          date: DateTime.parse(day),
          event: data,
        );
        eventController.add(calendarEventData);
      }
    }
  }

  int getNoonBreakDuration() {
    Duration difference = noonBreakEnd.value.difference(noonBreakStart.value);
    return difference.inMinutes;
  }

  void updateNoonBreakDuration() {
    Duration difference = noonBreakEnd.value.difference(noonBreakStart.value);
    String hours = difference.inHours.toString().padLeft(2, '0');
    String minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    noonBreakDuration.value = '$hours:$minutes:$seconds';
  }
}

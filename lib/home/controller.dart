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

  //日历上显示的月份
  late DateTime showDate;

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
    onPageChange(DateTime.now());
  }

  void onPageChange(DateTime dateTime) {
    showDate = dateTime;
    updateEvent();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    _clockTimer = null;
    eventController.dispose();
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

  Map? getEvent(DateTime date) {
    return hiveBox.get(date.toDateString(), defaultValue: null);
  }

  //更新当日上班时间
  void updateStartTime(DateTime time) {
    String nowDate = DateTime.now().toDateString();
    todayStartTime.value = time.toTimeString();
    var data = hiveBox.get(nowDate, defaultValue: null);
    data['start'] = time.toTimeString();
    hiveBox.put(
      nowDate,
      data,
    );
    updateEvent();
  }

  void updateEndTime() {
    _saveTime();
    updateEvent();
  }

  //设置Event
  void updateEvent() async {
    // 获取当前月份的第一天
    DateTime firstDayOfMonth = DateTime(showDate.year, showDate.month, 1);
    // 获取下个月的第一天
    DateTime firstDayOfNextMonth = DateTime(showDate.year, showDate.month + 1, 1);
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

  //获取午休时长
  Duration _getNoonBreakDuration() {
    return noonBreakEnd.value.difference(noonBreakStart.value);
  }

  //更新午休时长
  void updateNoonBreakDuration() {
    Duration difference = noonBreakEnd.value.difference(noonBreakStart.value);
    String hours = difference.inHours.toString().padLeft(2, '0');
    String minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    noonBreakDuration.value = '$hours:$minutes:$seconds';
    //同时刷新event
    updateEvent();
  }

  //计算工时
  Duration getWorkDuration(String startTime, String endTime) {
    //午休开始时间
    DateTime noonStart = timeToDateTime(noonBreakStart.value.toTimeString());
    //午休结束时间
    DateTime noonEnd = timeToDateTime(noonBreakEnd.value.toTimeString());
    //将传入的Datetime调整为同一天
    DateTime start = timeToDateTime(startTime);
    DateTime end = timeToDateTime(endTime);
    //最终的计算时间
    DateTime computeStart;
    DateTime computeEnd;
    bool isNoonBreak = false;
    if ((start.isBefore(noonStart) && end.isBefore(noonStart)) ||
        (start.isAfter(noonEnd) && end.isAfter(noonEnd))) {
      //开始结束时间都在午休之前 或者 开始结束时间都在午休之后 最终的计算时间就是传入的时间
      computeStart = start;
      computeEnd = end;
    } else if (start.isBefore(noonStart) && end.isBefore(noonEnd)) {
      //开始时间在午休之前 结束时间在午休结束之前 结束时间将改为 午休开始时间
      computeStart = start;
      computeEnd = noonStart;
    } else if (start.isAfter(noonStart) && start.isBefore(noonEnd) && end.isAfter(noonEnd)) {
      //开始时间在午休之后 午休结束之前 结束时间在午休结束之后 开始时间将改为 午休结束时间
      computeStart = noonEnd;
      computeEnd = end;
    } else if (start.isBefore(noonStart) && end.isAfter(noonEnd)) {
      //开始时间在午休之前 结束时间在午休之后 正常情况 减去2小时午休
      computeStart = start;
      computeEnd = end;
      isNoonBreak = true;
    } else {
      //开始时间在午休开始之后 结束时间在午休结束之前 没有工时
      return const Duration(seconds: 0);
    }
    Duration difference = computeEnd.difference(computeStart);
    if (isNoonBreak) {
      difference = difference - _getNoonBreakDuration();
    }
    return difference;
  }

  //返回工时分钟数
  int getWorkDurationMinutes(String start, String end) {
    Duration duration = getWorkDuration(start, end);
    return duration.inMinutes;
  }

  //返回工时字符串
  String getWorkDurationString(String start, String end) {
    Duration duration = getWorkDuration(start, end);
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  //时间字符串转DateTime
  DateTime timeToDateTime(String? time) {
    time ??= '00:00:00';
    return DateTime.parse('2000-10-10 $time');
  }

  //补卡上班时间
  void startTimeRemedy(DateTime date, DateTime time) {
    String dateStr = date.toDateString();
    var data = hiveBox.get(dateStr, defaultValue: null);
    if (data == null) {
      hiveBox.put(
        dateStr,
        {
          'start': time.toTimeString(),
          'end': null,
        },
      );
    } else {
      data['start'] = time.toTimeString();
      hiveBox.put(
        dateStr,
        data,
      );
    }
    //更新日历
    updateEvent();
  }

  //补卡下班时间
  void endTimeRemedy(DateTime date, DateTime time) {
    String dateStr = date.toDateString();
    var data = hiveBox.get(dateStr, defaultValue: null);
    if (data == null) {
      showError('请先补卡上班时间');
    } else {
      data['end'] = time.toTimeString();
      hiveBox.put(
        dateStr,
        data,
      );
    }
    //更新日历
    updateEvent();
  }

  void cleanData(DateTime date) async {
    await hiveBox.delete(date.toDateString());
    final calendarEventData = eventController.getEventsOnDay(DateTime.parse(date.toDateString()));
    eventController.removeAll(calendarEventData);
    updateEvent();
  }
}

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:getx_scaffold/getx_scaffold.dart';
import 'package:time_pickerr/time_pickerr.dart';
import 'package:work_helper/theme.dart';

import 'index.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  // 主视图
  Widget _buildView() {
    return <Widget>[
      MonthView(
        controller: controller.eventController,
        minMonth: DateTime(2024),
        maxMonth: DateTime(2050),
        cellAspectRatio: 1,
        startDay: WeekDays.monday,
        initialMonth: DateTime.now(),
        showWeekTileBorder: false,
        hideDaysNotInMonth: true,
        showBorder: false,
        headerStyle: HeaderStyle(
            headerTextStyle: TextStyle(
              fontSize: 20.sp,
              fontFamily: AppTheme.Font_Montserrat,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
            )),
        onHeaderTitleTap: (date) async {
          return;
        },
        cellBuilder: _buildCell,
        weekDayStringBuilder: (week) {
          switch (week) {
            case 0:
              return '星期一';
            case 1:
              return '星期二';
            case 2:
              return '星期三';
            case 3:
              return '星期四';
            case 4:
              return '星期五';
            case 5:
              return '星期六';
            case 6:
              return '星期天';
            default:
              return '';
          }
        },
        onPageChange: (date, pageIndex) {
          controller.updateEvent(date);
        },
        onCellTap: (events, date) {},
      ).tight(
        width: 0.67.sw,
        height: 1.sh,
      ),
      Container(
        color: Colors.grey[300],
        width: 1.w,
        height: 1.sh,
      ),
      _buildRightViews().expand(),
    ].toRow();
  }

  Widget _buildCell(
    DateTime date,
    List<CalendarEventData<Object?>> events,
    bool isToday,
    bool isInMonth,
    bool hideDaysNotInMonth,
  ) {
    if (!isInMonth) {
      return Container();
    }
    DateTime cellTime = DateTime.parse('${date.toDateString()} 00:00:00');
    DateTime nowTime = DateTime.parse('${getNowDateString()} 00:00:00');
    int tag;
    if (isToday) {
      tag = 0;
    } else if (cellTime.isBefore(nowTime)) {
      tag = -1;
    } else {
      tag = 1;
    }
    String? start;
    String? end;
    if (events.isNotEmpty) {
      var event = events[0];
      Map map = event.event as Map;
      start = map['start'] as String?;
      end = map['end'] as String?;
    }
    return <Widget>[
      _buildCellTitle(
        date.dateFormat('d'),
        tag,
        start,
        end,
      ),
      8.verticalSpace,
      if (start != null)
        TextX.labelMedium(
          '上班：$start',
          color: Colors.green,
          weight: FontWeight.bold,
        ),
      2.verticalSpace,
      if (end != null)
        TextX.labelMedium(
          '下班：$end',
          color: Colors.green,
          weight: FontWeight.bold,
        ),
      2.verticalSpace,
      if (start != null && end != null)
        TextX.labelMedium(
          '工时：${controller.getWorkDurationString(start, end)}',
          color: Colors.orange,
          weight: FontWeight.bold,
        ),
      2.verticalSpace,
      if (start != null && end != null)
        TextX.labelMedium(
          '分钟：${controller.getWorkDurationMinutes(start, end)}',
          color: Colors.orange,
          weight: FontWeight.bold,
        ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).padding(all: 10.w).card();
  }

  Widget _buildCellTitle(
    String text,
    int tag,
    String? start,
    String? end,
  ) {
    switch (tag) {
      case -1:
        Widget widget;
        if (start == null || end == null) {
          widget = <Widget>[
            TextX.titleMedium(
              text,
              color: Colors.red,
              weight: FontWeight.bold,
            ),
            TextX.labelMedium(
              '缺卡',
              color: Colors.red,
              weight: FontWeight.bold,
            ),
          ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween);
        } else {
          widget = TextX.titleMedium(
            text,
            color: Colors.green,
            weight: FontWeight.bold,
          );
        }
        return widget;
      case 0:
        return TextX.titleMedium(
          text,
          color: AppTheme.themeColor,
          weight: FontWeight.bold,
        );
      case 1:
        return TextX.titleMedium(
          text,
          weight: FontWeight.w300,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildRightViews() {
    return Obx(
      () => <Widget>[
        <Widget>[
          TextX.headlineSmall('当前时间：${controller.currentTime.value}'),
          15.verticalSpace,
          <Widget>[
            TextX.titleLarge('今日上班时间：${controller.todayStartTime.value}'),
            ButtonX.secondary(
              '修改',
              onPressed: () {
                Get.dialog(
                  CustomHourPicker(
                    title: '请选择今日上班时间',
                    initDate: controller.timeToDateTime(controller.todayStartTime.value),
                    date: controller.timeToDateTime(controller.todayStartTime.value),
                    elevation: 2,
                    positiveButtonText: '确认修改',
                    negativeButtonText: '取消',
                    onPositivePressed: (context, time) {
                      controller.updateStartTime(time);
                      Get.back();
                    },
                    onNegativePressed: (context) {
                      Get.back();
                    },
                  ).padding(horizontal: 600.w),
                );
              },
            ).padding(left: 20.w),
          ].toRow(),
          5.verticalSpace,
          TextX.titleLarge('今日下班时间：${controller.todayEndTime.value}'),
          20.verticalSpace,
          ButtonX.primary(
            '更新下班时间',
            textSize: 22.sp,
            onPressed: () => controller.updateEndTime(),
          ),
        ]
            .toColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
            )
            .paddingAll(20.w)
            .card()
            .width(double.infinity),
        3.verticalSpace,
        <Widget>[
          <Widget>[
            TextX.titleLarge('午休开始时间：'),
            TextX.titleLarge(controller.noonBreakStart.value.toTimeString()),
            ButtonX.secondary(
              '修改',
              onPressed: () {
                Get.dialog(
                  CustomHourPicker(
                    title: '请选择午休开始时间',
                    initDate: controller.noonBreakStart.value,
                    date: controller.noonBreakStart.value,
                    elevation: 2,
                    positiveButtonText: '确认修改',
                    negativeButtonText: '取消',
                    onPositivePressed: (context, time) {
                      DateTime start = controller.timeToDateTime(time.toTimeString());
                      DateTime end =
                          controller.timeToDateTime(controller.noonBreakEnd.value.toTimeString());

                      if (start.isBefore(end)) {
                        controller.noonBreakStart.value = time;
                        controller.updateNoonBreakDuration();
                        setValue(HomeController.NOON_BREAK_START, time.toDateTimeString());
                        Get.back();
                      } else {
                        showError('午休开始时间要在结束时间之前');
                      }
                    },
                    onNegativePressed: (context) {
                      Get.back();
                    },
                  ).padding(horizontal: 600.w),
                );
              },
            ).padding(left: 20.w),
          ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
          5.verticalSpace,
          <Widget>[
            TextX.titleLarge('午休结束时间：'),
            TextX.titleLarge(controller.noonBreakEnd.value.toTimeString()),
            ButtonX.secondary(
              '修改',
              onPressed: () {
                Get.dialog(
                  CustomHourPicker(
                    title: '请选择午休结束时间',
                    initDate: controller.noonBreakEnd.value,
                    date: controller.noonBreakEnd.value,
                    elevation: 2,
                    positiveButtonText: '确认修改',
                    negativeButtonText: '取消',
                    onPositivePressed: (context, time) {
                      DateTime start =
                          controller.timeToDateTime(controller.noonBreakStart.value.toTimeString());
                      DateTime end = controller.timeToDateTime(time.toTimeString());
                      if (end.isAfter(start)) {
                        controller.noonBreakEnd.value = time;
                        controller.updateNoonBreakDuration();
                        setValue(HomeController.NOON_BREAK_END, time.toDateTimeString());
                        Get.back();
                      } else {
                        showError('午休结束时间要在开始时间之后');
                      }
                    },
                    onNegativePressed: (context) {
                      Get.back();
                    },
                  ).padding(horizontal: 600.w),
                );
              },
            ).padding(left: 20.w),
          ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
          5.verticalSpace,
          TextX.titleLarge('午休时长：${controller.noonBreakDuration.value}'),
        ]
            .toColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
            )
            .paddingAll(20.w)
            .card()
            .width(double.infinity),
      ]
          .toColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
          )
          .padding(all: 5.w),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      id: "home",
      builder: (_) {
        return Scaffold(
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:getx_scaffold/getx_scaffold.dart';
import 'package:time_pickerr/time_pickerr.dart';
import 'package:work_helper/theme.dart';

import 'index.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  // 主视图
  Widget _buildView(BuildContext context) {
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
        cellBuilder: (date, events, isToday, isInMonth, hideDaysNotInMonth) {
          if (!isInMonth) {
            return Container();
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
            TextX.titleMedium(
              date.dateFormat('d'),
              color: isToday ? AppTheme.themeColor : null,
              weight: isToday ? FontWeight.bold : FontWeight.w300,
            ),
            10.verticalSpace,
            if (start != null)
              TextX.labelMedium(
                '上班：$start',
                color: Colors.green,
                weight: FontWeight.bold,
              ),
            5.verticalSpace,
            if (end != null)
              TextX.labelMedium(
                '下班：$end',
                color: Colors.red,
                weight: FontWeight.bold,
              ),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).padding(all: 10.w).card();
        },
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
          log(date.toDateTimeString());
        },
        onCellTap: (events, date) {},
        onEventTap: (event, date) => print(event),
        onEventDoubleTap: (events, date) => print(events),
        onEventLongTap: (event, date) => print(event),
        onDateLongPress: (date) => print(date),
      ).tight(
        width: 0.67.sw,
        height: 1.sh,
      ),
      Container(
        color: Colors.grey[300],
        width: 1.w,
        height: 1.sh,
      ),
      _buildRightViews(context).expand(),
    ].toRow();
  }

  Widget _buildRightViews(BuildContext context) {
    return Obx(
      () => <Widget>[
        <Widget>[
          TextX.titleLarge('当前时间：${controller.currentTime.value}'),
          5.verticalSpace,
          TextX.titleLarge('今日上班时间：${controller.todayStartTime.value}'),
          5.verticalSpace,
          TextX.titleLarge('今日下班时间：${controller.todayEndTime.value}'),
          20.verticalSpace,
          ButtonX.primary(
            '更新上下班时间',
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomHourPicker(
                      title: '请选择午休开始时间',
                      initDate: controller.noonBreakStart.value,
                      date: controller.noonBreakStart.value,
                      elevation: 2,
                      positiveButtonText: '确认修改',
                      negativeButtonText: '取消',
                      onPositivePressed: (context, time) {
                        DateTime start = DateTime.parse('2000-10-10 ${time.toTimeString()}');
                        DateTime end = DateTime.parse(
                            '2000-10-10 ${controller.noonBreakEnd.value.toTimeString()}');

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
                    ).padding(horizontal: 500.w);
                  },
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomHourPicker(
                      title: '请选择午休结束时间',
                      initDate: controller.noonBreakEnd.value,
                      date: controller.noonBreakEnd.value,
                      elevation: 2,
                      positiveButtonText: '确认修改',
                      negativeButtonText: '取消',
                      onPositivePressed: (context, time) {
                        DateTime start = DateTime.parse(
                            '2000-10-10 ${controller.noonBreakStart.value.toTimeString()}');
                        DateTime end = DateTime.parse('2000-10-10 ${time.toTimeString()}');
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
                    ).padding(horizontal: 500.w);
                  },
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
            child: _buildView(context),
          ),
        );
      },
    );
  }
}

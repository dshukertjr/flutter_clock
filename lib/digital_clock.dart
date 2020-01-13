// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final hourFontSize = MediaQuery.of(context).size.width / 5;
    final hourStyle = TextStyle(
      color: Colors.white,
      fontSize: hourFontSize,
      fontWeight: FontWeight.w900,
      height: 1,
    );

    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          // color: Colors.red,
          height: hourFontSize,
          child: ClipRect(
            child: OverflowBox(
              maxHeight: double.infinity,
              child: DefaultTextStyle(
                style: hourStyle,
                child: _ClockNumbers(
                    hour: hour,
                    hourFontSize: hourFontSize,
                    dateTime: _dateTime,
                    minute: minute),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClockNumbers extends StatelessWidget {
  const _ClockNumbers({
    Key key,
    @required this.hour,
    @required this.hourFontSize,
    @required DateTime dateTime,
    @required this.minute,
  })  : _dateTime = dateTime,
        super(key: key);

  final String hour;
  final double hourFontSize;
  final DateTime _dateTime;
  final String minute;

  @override
  Widget build(BuildContext context) {
    final hourTenthDigitOffsetFactor = int.parse(hour[1]) / 10;
    final hourFirstDigitOffsetFactor = _dateTime.minute / 60;
    final minuteTenthDigitOffsetFactor = int.parse(minute[1]) / 10;
    final minuteFirstDigitOffsetFactor = _dateTime.second / 60;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _IntColumn(
          numberString: hour[0],
          fontHeight: hourFontSize,
          offset: hourTenthDigitOffsetFactor,
        ),
        _IntColumn(
          numberString: hour[1],
          fontHeight: hourFontSize,
          offset: hourFirstDigitOffsetFactor,
        ),
        Text(':'),
        _IntColumn(
          numberString: minute[0],
          fontHeight: hourFontSize,
          offset: minuteTenthDigitOffsetFactor,
        ),
        _IntColumn(
          numberString: minute[1],
          fontHeight: hourFontSize,
          offset: minuteFirstDigitOffsetFactor,
        ),
      ],
    );
  }
}

class _IntColumn extends StatelessWidget {
  const _IntColumn({
    Key key,
    @required this.numberString,
    @required this.fontHeight,
    @required this.offset,
  }) : super(key: key);

  final String numberString;
  final double fontHeight;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final number = int.parse(numberString);
    final nextNumber = (number + 1) % 10;
    final double offsetY = -fontHeight / 2 + fontHeight * offset;
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Container(
        // color: Colors.blue,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(nextNumber.toString()),
            Text(numberString),
          ],
        ),
      ),
    );
  }
}

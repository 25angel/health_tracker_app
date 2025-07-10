import 'package:flutter/material.dart';

class ActivityRow extends StatelessWidget {
  final String activity;
  final String distance;
  final String time;

  const ActivityRow({
    required this.activity,
    required this.distance,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(activity), Text(distance), Text(time)],
    );
  }
}

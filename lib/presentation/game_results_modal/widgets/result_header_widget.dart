import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ResultHeaderWidget extends StatelessWidget {
  final String result;
  final String emoji;
  final Color resultColor;

  const ResultHeaderWidget({
    Key? key,
    required this.result,
    required this.emoji,
    required this.resultColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 48.sp),
          ),
          SizedBox(height: 2.h),
          Text(
            result,
            style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
              color: resultColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

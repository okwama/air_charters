import 'package:flutter/material.dart';
import 'skeleton_loading.dart';

class SkeletonFormField extends StatelessWidget {
  final double? height;

  const SkeletonFormField({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      width: double.infinity,
      height: height ?? 56,
      borderRadius: BorderRadius.circular(14),
    );
  }
}

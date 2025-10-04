import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';
import 'skeleton_loading.dart';

class SkeletonListTile extends StatelessWidget {
  final EdgeInsets? margin;

  const SkeletonListTile({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          SkeletonLoading(
            width: double.infinity,
            height: 150,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          // Content skeleton
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoading(
                            width: double.infinity,
                            height: 18,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 4),
                          SkeletonLoading(
                            width: 120,
                            height: 14,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    SkeletonLoading(
                      width: 60,
                      height: 24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonLoading(
                      width: 80,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(width: 16),
                    SkeletonLoading(
                      width: 60,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(width: 16),
                    SkeletonLoading(
                      width: 70,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoading(
                            width: 100,
                            height: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 4),
                          SkeletonLoading(
                            width: 80,
                            height: 12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    SkeletonLoading(
                      width: 80,
                      height: 36,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 5, this.height = 90});

  final int itemCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => SkeletonBox(height: height),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: itemCount,
    );
  }
}

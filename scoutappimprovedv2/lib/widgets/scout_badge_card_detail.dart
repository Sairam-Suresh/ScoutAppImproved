import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';

import '../logic/scout_badge.dart';

class ScoutBadgeCardDetail extends HookWidget {
  const ScoutBadgeCardDetail({super.key, required this.badge});

  final ScoutBadge badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Image.network(
                  badge.imageURL!,
                  width: 40,
                  height: 40,
                ),
                const SizedBox(
                  width: 10,
                ),
                AutoSizeText(badge.name!),
              ],
            ),
            Html(
              data: badge.description,
            )
          ],
        ),
      ),
    );
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../logic/scout_badge/scout_badge.dart';

class ScoutBadgeCard extends HookWidget {
  const ScoutBadgeCard({super.key, required this.badge});
  final ScoutBadge badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go("/badge/${badge.name!.replaceAll(" ", "_")}");
      },
      child: SizedBox(
          width: 250,
          height: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Container()),
                      if (badge.completed != null)
                        const Icon(Icons.check_circle),
                    ],
                  ),
                  Image.network(
                    badge.imageURL!,
                    width: 120,
                    height: 120,
                  ),
                  Expanded(
                    child: AutoSizeText(
                      badge.name!,
                      minFontSize: 10,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 30),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

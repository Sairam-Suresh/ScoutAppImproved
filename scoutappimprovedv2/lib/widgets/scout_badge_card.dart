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
          // width: 250,
          // height: double.infinity,
          child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Center(
                child: Image.network(
                  badge.imageURL!,
                  width: 100,
                  height: 100,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Container()),
                  if (badge.completed != null)
                    const CircleAvatar(
                        radius: 12, child: Icon(Icons.check_circle)),
                ],
              ),
              // Expanded(
              //   child: AutoSizeText(
              //     badge.name!,
              //     minFontSize: 10,
              //     textAlign: TextAlign.center,
              //     style: const TextStyle(fontSize: 30),
              //   ),
              // )
            ],
          ),
        ),
      )),
    );
  }
}

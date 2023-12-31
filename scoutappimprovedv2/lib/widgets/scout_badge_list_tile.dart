import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/scout_badge/scout_badge.dart';

class ScoutBadgeListTile extends StatelessWidget {
  const ScoutBadgeListTile({super.key, required this.badge});
  final ScoutBadge badge;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (context.canPop()) {
          Navigator.of(context).pop();
        }
        context.go("/badge/${badge.name!.replaceAll(" ", "_")}");
      },
      leading: SizedBox(
        height: 50,
        width: 50,
        child: CachedNetworkImageBuilder(
          url: badge.imageURL!,
          builder: (image) {
            return Center(child: Image.file(image));
          },
          // Optional Placeholder widget until image loaded from url
          placeHolder: const Center(
            child: SizedBox(
                width: 10, height: 10, child: CircularProgressIndicator()),
          ),
          // Optional error widget
          errorWidget: const Icon(Icons.error_outline),
          // Optional describe your image extensions default values are; jpg, jpeg, gif and png
        ),
      ),
      title: Text(badge.name!),
      trailing: (badge.completed != null) ? const Icon(Icons.check) : null,
    );
  }
}

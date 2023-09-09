import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:isar/isar.dart';
import 'package:scoutappimprovedv2/widgets/scout_badge_card_detail.dart';

import '../logic/scout_badge/scout_badge.dart';

class ViewAllBadgesView extends StatefulHookWidget {
  const ViewAllBadgesView({super.key});

  @override
  State<ViewAllBadgesView> createState() => _ViewAllBadgesViewState();
}

class _ViewAllBadgesViewState extends State<ViewAllBadgesView> {
  var futureDB;

  @override
  void initState() {
    // TODO: implement initState
    futureDB = getDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var badges = useState<List<ScoutBadge>>([]);
    AsyncSnapshot<Isar> db = useFuture(futureDB);

    useEffect(() {
      StreamSubscription? listenerInstance;
      if (db.hasData) {
        listenerInstance = db.data!.scoutBadges
            .watchLazy(fireImmediately: true)
            .listen((event) async {
          badges.value = await db.data!.scoutBadges.where().findAll();
        });
      }
      return () {
        listenerInstance?.cancel();
      };
    }, [db.hasData]);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView(
            children: badges.value
                .map((e) => ScoutBadgeCardDetail(badge: e))
                .toList(),
          ),
        ),
      ),
    );
  }
}

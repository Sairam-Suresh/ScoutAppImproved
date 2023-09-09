import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:isar/isar.dart';
import 'package:scoutappimprovedv2/logic/scout_badge/scout_badge.dart';

class Settings extends StatefulHookWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var futureDB = getDB();

  @override
  Widget build(BuildContext context) {
    var account = useState<GoogleSignInAccount?>(null);
    AsyncSnapshot<Isar> db = useFuture(futureDB);

    useEffect(() {
      GoogleSignIn().signInSilently(reAuthenticate: true).then((value) {
        account.value = value;
      }).onError((error, stackTrace) {
        GoogleSignIn().signIn().then((value) {
          account.value = value;
        });
      });

      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: [
            const Text("Your Google Account"),
            ListTile(
              onTap: account.value == null
                  ? () {
                      GoogleSignIn().signIn().then((value) {
                        account.value = value;
                      }).onError((error, stackTrace) {
                        account.value = null;
                      });
                    }
                  : null,
              leading: SizedBox(
                width: 50,
                height: 50,
                child: CircleAvatar(
                  child: ClipOval(
                    child: (account.value?.photoUrl != null)
                        ? Image.network(account.value!.photoUrl!)
                        : const Icon(Icons.login),
                  ),
                ),
              ),
              title: Text(
                (account.value?.displayName != null)
                    ? account.value!.displayName!
                    : "Sign In Now",
                style: const TextStyle(fontSize: 18),
              ),
              contentPadding: EdgeInsets.zero,
              trailing: (account.value != null)
                  ? IconButton(
                      onPressed: () {
                        GoogleSignIn().signOut();
                        GoogleSignIn().disconnect();
                        account.value = null;
                      },
                      icon: const Icon(Icons.logout),
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                    )
                  : null,
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              "Danger Zone",
            ),
            ListTile(
              onTap: () {
                var allData = db.data!.scoutBadges
                    .where()
                    .findAllSync()
                    .map((e) => e.id)
                    .toList();
                if (db.hasData) {
                  db.data!.writeTxn(() {
                    return db.data!.scoutBadges.deleteAll(allData);
                  });
                }

                context.pop();

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Deleted ${allData.length} badges")));
              },
              title: Text(
                "Clear Caches",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              leading: Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

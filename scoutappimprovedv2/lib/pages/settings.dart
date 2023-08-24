import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Settings extends HookWidget {
  const Settings(this.finishedDownloadingFromOnline, {Key? key})
      : super(key: key);

  final String finishedDownloadingFromOnline;

  @override
  Widget build(BuildContext context) {
    var doneDownloadingScoutBadges =
        useState(finishedDownloadingFromOnline == "false" ? false : true);

    var account = useState<GoogleSignInAccount?>(null);

    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'https://www.googleapis.com/auth/spreadsheets'],
    );

    useEffect(() {
      googleSignIn.signInSilently(reAuthenticate: true).then((value) {
        account.value = value;
      }).onError((error, stackTrace) {
        googleSignIn.signIn().then((value) {
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
                      googleSignIn.signIn().then((value) {
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
                    : "Unknown User",
                style: const TextStyle(fontSize: 18),
              ),
              contentPadding: EdgeInsets.zero,
              trailing: (account.value != null)
                  ? IconButton(
                      onPressed: () {
                        googleSignIn.signOut();
                        account.value = null;
                      },
                      icon: const Icon(Icons.logout),
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                    )
                  : null,
            ),
            if (!doneDownloadingScoutBadges.value)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Badges are still loading"),
                trailing: SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

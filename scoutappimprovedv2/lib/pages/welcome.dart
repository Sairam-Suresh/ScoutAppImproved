import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends HookWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var index = useState(0);
    var account = useState<GoogleSignInAccount?>(null);

    return IntroductionScreen(
      onChange: (indexPage) {
        index.value = indexPage;
      },
      canProgress: (indexPage) {
        if (indexPage != 2) {
          return true;
        } else {
          return account.value == null ? false : true;
        }
      },
      showBackButton: index.value != 2,
      showDoneButton: account.value != null,
      back: const Text("Go back"),
      pages: [
        PageViewModel(
          title: "Welcome to the Revamped Scouts App!",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "This App has more interactivity than the main Scouts app, and has more features!",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          image: SafeArea(
            child: Center(
                child: Image.network(
                    "https://app.scout.sg/img/main_view/adult.png")),
          ),
        ),
        PageViewModel(
          title: "Some Features Include:",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Locally downloaded Scout Badges"),
              Text("Something else here")
            ],
          ),
          image: const Center(
              child: Icon(
            Icons.dataset_outlined,
            size: 100,
          )),
        ),
        PageViewModel(
          title: "Before we begin...",
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Please log in with your Google Account, so that we can obtain your badges!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(
                height: 50,
              ),
              FilledButton(
                  onPressed: () {
                    GoogleSignIn().signIn().then((value) {
                      account.value = value;
                    }).onError((error, stackTrace) {});
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Sign in with Google"),
                      if (account.value != null) const Icon(Icons.check)
                    ],
                  )),
              const SizedBox(
                height: 10,
              ),
              if (account.value != null)
                Text("Signed in as ${account.value!.displayName}"),
            ],
          ),
          image: const Center(
              child: Icon(
            Icons.dataset_outlined,
            size: 100,
          )),
        )
      ],
      showNextButton: false,
      done: const Text("Done"),
      onDone: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool("already_processing_badges", false);
          context.go("/");
        });
      },
    );
  }
}

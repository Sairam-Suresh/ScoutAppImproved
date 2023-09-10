import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatefulHookWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _InterMediaryState();
}

class _InterMediaryState extends State<Welcome> {
  var prefFuture = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    var sharedPref = useFuture(prefFuture);
    var index = useState(0);
    var account = useState<GoogleSignInAccount?>(null);
    var showIntro = useState<bool?>(null);

    useEffect(() {
      Future.delayed(const Duration(seconds: 1)).then((_) {
        if (sharedPref.hasData) {
          if (!(sharedPref.data!.getBool("shown_welcome") ?? false)) {
            showIntro.value = true;
          } else {
            context.go("/");
          }
        }
      });

      return null;
    }, [sharedPref.hasData]);

    return showIntro.value == null
        ? const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : (showIntro.value ?? true)
            ? IntroductionScreen(
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Swipe to continue",
                              textAlign: TextAlign.center,
                            ),
                            Icon(Icons.arrow_forward)
                          ],
                        ),
                      ],
                    ),
                    image: SafeArea(
                      child: Center(
                          child: Image.network(
                        "https://app.scout.sg/img/main_view/adult.png",
                        height: 250,
                        width: 250,
                      )),
                    ),
                  ),
                  PageViewModel(
                    title: "Some Features Include:",
                    bodyWidget: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "1. Locally downloaded Scout Badges",
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "2. Scout badges are synced with your achievements!",
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "3. More to come!",
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Swipe to continue",
                              textAlign: TextAlign.center,
                            ),
                            Icon(Icons.arrow_forward)
                          ],
                        ),
                      ],
                    ),
                    image: const Center(
                        child: Icon(
                      Icons.dataset_outlined,
                      size: 250,
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
                                if (account.value != null)
                                  const Icon(Icons.check)
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
                      Icons.pause,
                      size: 250,
                    )),
                  )
                ],
                showNextButton: false,
                done: const Text("Done"),
                onDone: () {
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool("shown_welcome", true);
                    context.go("/");
                  });
                },
              )
            : Container();
  }
}

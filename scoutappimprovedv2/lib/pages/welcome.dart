import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Welcome extends HookWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
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
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("This App will prompt you to login with google"),
              Text("Please login with your google account when prompted")
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
        context.go("/");
      },
    );
  }
}

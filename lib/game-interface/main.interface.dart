import 'package:flutter/material.dart';
import '../main.dart';

class MainInterface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [SignOutButton()],
          ),
        ),
      ],
    );
  }
}

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Icon(Icons.logout),
      onPressed: () {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text("Sign out ?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text("Cancel"),
                  ),
                  TextButton(
                      onPressed: () {
                        meteor.logout();
                        Navigator.of(ctx).pop();
                      },
                      child: Text("Sign out"),
                  ),
                ],
              );
            }
          );
      },
    );
  }
}
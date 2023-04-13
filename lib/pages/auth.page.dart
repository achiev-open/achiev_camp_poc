import 'package:achiev_camp_poc/services/auth.service.dart';
import 'package:dart_meteor/dart_meteor.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class AuthFormData {
  String name = "";
  String email = "";
  String password = "";
  String confirmPassword = "";

  toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
    };
  }
}

enum AuthNavigationState {
  signIn,
  signUp,
}

class AuthPage extends StatefulWidget {
  const AuthPage({ super.key });

  @override
  State<AuthPage> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  List<dynamic> navigationStates = [
    { "state": AuthNavigationState.signIn, "label": "Sign in" },
    { "state": AuthNavigationState.signUp, "label": "Sign up" },
  ];
  AuthNavigationState selectedState = AuthNavigationState.signIn;
  AuthFormData form = AuthFormData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              buildNavigationToggle(),
              SizedBox(height: 20),
              selectedState == AuthNavigationState.signIn
                  ? buildSignInForm()
                  : buildSignUpForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavigationToggle() {
    return Center(
      child: ToggleButtons(
        onPressed: (int index) {
          setState(() {
            selectedState = navigationStates[index]["state"];
          });
        },
        constraints: const BoxConstraints(
          minHeight: 40.0,
          minWidth: 80.0,
        ),
        isSelected: navigationStates.map((e) => e["state"] == selectedState).toList(),
        children: navigationStates.map((e) => Text(e["label"])).toList(),
      ),
    );
  }

  Widget buildSignUpForm() {
    return Expanded(
        child: ListView(
          children: [
            TextField(
              decoration: InputDecoration(label: Text("Name")),
              onChanged: (value) {
                setState(() { form.name = value; });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(label: Text("Email")),
              onChanged: (value) {
                setState(() { form.email = value; });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(label: Text("Password")),
              obscureText: true,
              onChanged: (value) {
                setState(() { form.password = value; });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(label: Text("Confirm password")),
              obscureText: true,
              onChanged: (value) {
                setState(() { form.confirmPassword = value; });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (form.name.isEmpty || form.email.isEmpty || form.password.isEmpty) {
                  showError("Name, Email and password are required");
                  return;
                }
                if (form.password != form.confirmPassword) {
                  showError("Password doesn't match");
                  return;
                }
                try {
                  await meteor.call("signup", args: [form.toJson()]);
                  await AuthService.loginWithPassword(form.email, form.password);
                } catch (err) {
                  if (err is MeteorError) {
                    showError(err.reason ?? "Error with no details");
                  } else {
                    showError("An error occured");
                  }
                }
              },
              child: Text("Sign in"),
            ),
          ],
        )
    );
  }

  Widget buildSignInForm() {
    return Expanded(
      child: ListView(
        children: [
          TextField(
            decoration: InputDecoration(label: Text("Email")),
            onChanged: (value) {
              setState(() { form.email = value; });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(label: Text("Password")),
            obscureText: true,
            onChanged: (value) {
              setState(() { form.password = value; });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () async {
                try {
                  if (form.email.isEmpty || form.password.isEmpty) {
                    showError("Email and password are required");
                    return;
                  }
                  await AuthService.loginWithPassword(form.email, form.password);
                } catch (err) {
                  if (err is MeteorError) {
                    showError(err.reason ?? "Error with no details");
                  } else {
                    showError("An error occured");
                  }
                }
              },
              child: Text("Sign in"),
          ),
        ],
      )
    );
  }

  void showError(reason) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
            title: Text("Error"),
            content: Text(reason),
            actions: [
              TextButton(
                child: Text('Dismiss'),
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
            ]
        );
      },
    );
  }
}
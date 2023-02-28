import 'package:achiev_camp_poc/main.dart';
import 'package:dart_meteor/dart_meteor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage(
  mOptions: MacOsOptions(
    synchronizable: true
  )
);

class AuthService {
  static _saveMeteorLoginResult(MeteorClientLoginResult result) async {
    await storage.write(key: 'loginToken', value: result.token);
    await storage.write(
      key: 'loginTokenExpires',
      value: result.tokenExpires.millisecondsSinceEpoch.toString(),
    );
  }

  static loginWithToken() async {
    String? tokenExpiresStr = await storage.read(key: 'loginTokenExpires');
    if (tokenExpiresStr == null) { return; }

    int millisecond = int.parse(tokenExpiresStr);
    DateTime expires = DateTime.fromMillisecondsSinceEpoch(millisecond);

    String? token = await storage.read(key: 'loginToken');
    if (token == null) { return; }

    try {
      MeteorClientLoginResult? result = await meteor.loginWithToken(
          token: token,
          tokenExpires: expires,
      );
      if (result == null) { return; }
      _saveMeteorLoginResult(result);
    } catch (e) {}
  }

  static loginWithPassword(String email, String password) async {
    MeteorClientLoginResult result = await meteor.loginWithPassword(email, password);
    _saveMeteorLoginResult(result);
  }
}
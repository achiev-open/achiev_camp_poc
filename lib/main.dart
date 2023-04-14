import 'dart:io';
import 'package:achiev_camp_poc/decorations/house.dart';
import 'package:achiev_camp_poc/entities/guide.dart';
import 'package:achiev_camp_poc/entities/other-player.dart';
import 'package:achiev_camp_poc/entities/visitor.dart';
import 'package:achiev_camp_poc/game-interface/main.interface.dart';
import 'package:achiev_camp_poc/pages/auth.page.dart';
import 'package:achiev_camp_poc/pages/connecting.page.dart';
import 'package:achiev_camp_poc/services/auth.service.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:dart_meteor/dart_meteor.dart';

var meteor = MeteorClient.connect(url: 'http://localhost:3000');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bonfire+Meteor POC',
      // home: SimpleLevel(),
      home: StreamBuilder<DdpConnectionStatus>(
        stream: meteor.status(),
        builder: (context, snapshot) {
          // No information yet
          if (!snapshot.hasData) {
            return Container();
          }

          // No connexion
          if (snapshot.data == null || !snapshot.data!.connected) {
            return ConnectingPage();
          }

          // Try to auto-connect here
          AuthService.loginWithToken();

          // Check authentication status
          return StreamBuilder<String?>(
              stream: meteor.userId(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return AuthPage();
                }
                return SimpleLevel();
              }
          );
        }
      )
    );
  }
}

class SimpleLevel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SimpleLevelState();
}

class SimpleLevelState extends State<SimpleLevel> {
  bool subscriptionReady = false;
  late GameController controller;
  Map<String, OtherPlayer> players = {};

  Map<String, Direction> directions = {
    "right": Direction.right,
    "left": Direction.left,
    "up": Direction.up,
    "down": Direction.down,
  };

  @override
  initState() {
    controller = GameController();
    meteor.subscribe("onlinePlayers", onReady: () {
      setState(() {
        subscriptionReady = true;
      });
    });
    super.initState();
  }

  _simulateOtherPlayers() {
    if (!controller.isMounted) {
      Future.delayed(Duration(milliseconds: 100), _simulateOtherPlayers);
      return;
    }

    meteor.collection("users").listen((users) {
      // Remove disconnected players - Using tmp userIds list to not update players while iterating on its keys
      List<String> userIds = players.keys.toList();
      for (var id in userIds) {
        if (!users.keys.contains(id) && players[id] != null) {
          players[id]!.removeFromParent();
          players.remove(id);
        }
      }

      users.values.forEach((user) {
        if (user["_id"] == meteor.userIdCurrentValue()) {
          return;
        }
        if (user["status"]["online"] != true || user["location"] == null) {
          return;
        }

        String id = user["_id"];
        Vector2 position = Vector2(user["location"]["x"], user["location"]["y"]);
        Direction direction = directions[user["location"]["direction"]] ?? Direction.up;

        if (players[id] == null) { // New connexion, add to game
          players[id] = OtherPlayer(position, direction);
          controller.gameRef.add(players[id]!);
        } else {
          players[id]!.moveToPosition(position);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double TILE_SIZE = 32.0;
    int mapHeight = 50;
    int mapWidth = 30;

    if (!subscriptionReady) {
      return const CircularProgressIndicator();
    }

    _simulateOtherPlayers();

    dynamic location = meteor.userCurrentValue()!["location"] ?? {};

    return BonfireWidget(
        gameController: controller,
      // showCollisionArea: true,
        cameraConfig: CameraConfig(
          moveOnlyMapArea: true,
          sizeMovementWindow: Vector2(50,50),
          zoom: 2,
          angle: 45 * pi / 180, // 45 deg
        ),
        map: WorldMapByTiled(
          "tiles/small-map.json",
          forceTileSize: Vector2(32, 32),
          objectsBuilder: {
            'house': (TiledObjectProperties properties) => House(properties.position),
            'npc': (TiledObjectProperties properties) {
              if (properties.type == "Guide") {
                return Guide(properties.position);
              }
              throw UnimplementedError();
            }
          }
        ),
        player: Visitor(
          Vector2(location["x"] ?? mapWidth / 2 * TILE_SIZE, location["y"] ?? (mapHeight - 12) * TILE_SIZE),
          directions[location["direction"]] ?? Direction.up,
        ),
        joystick: getJoystickForPlatform(),
        overlayBuilderMap: {
            'main': (BuildContext context, BonfireGame game) {
              return MainInterface();
            },
        },
        initialActiveOverlays: const ['main'],
    );
  }

  Joystick getJoystickForPlatform() {
    bool isMobile = false;

    if (kIsWeb) { // Web cannot access platform
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
        isMobile = true;
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      isMobile = true;
    }

    if (isMobile) {
      return Joystick(
          directional: JoystickDirectional(),
          // actions: [
          //   JoystickAction(actionId: LogicalKeyboardKey.shiftLeft.keyId)
          // ], // Uncomment to activate run on mobile, need to be styled
      );
    }
    // Web or desktop
    return KeyboardJoystick(
      keyboardConfig: KeyboardConfig(
        enable: true,
        acceptedKeys: [LogicalKeyboardKey.shiftLeft],
      )
    );
  }
}

/** Fix Joystick behaviour which doesn't trigger keyup action.
 * Issue opened to fix it in bonfire
 * https://github.com/RafaelBarbosatec/bonfire/issues/379
 * **/
class KeyboardJoystick extends Joystick {
  KeyboardJoystick({
    List<JoystickAction> actions = const [],
    JoystickDirectional? directional,
    KeyboardConfig? keyboardConfig,
  }) : super(actions: actions, directional: directional, keyboardConfig: keyboardConfig);

  @override
  bool onKeyboard(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    /// If the keyboard is disabled, we do not process the event
    if (!keyboardConfig.enable) return false;

    /// If the key is not accepted, we do not process the event
    if (keyboardConfig.acceptedKeys != null) {
      final acceptedKeys = keyboardConfig.acceptedKeys!;
      if (!acceptedKeys.contains(event.logicalKey)) {
        return false;
      }
    }

    if (_isDirectional(event.logicalKey)) {
      return super.onKeyboard(event, keysPressed);
    }

    if (event is RawKeyUpEvent) {
      joystickAction(JoystickActionEvent(
        id: event.logicalKey.keyId,
        event: ActionEvent.UP,
      ));
    } else {
      return super.onKeyboard(event, keysPressed);
    }
    return true;
  }

  bool _isDirectional(LogicalKeyboardKey key) {
    if (keyboardConfig.keyboardDirectionalType ==
        KeyboardDirectionalType.arrows) {
      return key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowDown;
    } else if (keyboardConfig.keyboardDirectionalType ==
        KeyboardDirectionalType.wasd) {
      return key == LogicalKeyboardKey.keyA ||
          key == LogicalKeyboardKey.keyW ||
          key == LogicalKeyboardKey.keyD ||
          key == LogicalKeyboardKey.keyS;
    } else {
      return key == LogicalKeyboardKey.keyA ||
          key == LogicalKeyboardKey.keyW ||
          key == LogicalKeyboardKey.keyD ||
          key == LogicalKeyboardKey.keyS ||
          key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowDown;
    }
  }
}
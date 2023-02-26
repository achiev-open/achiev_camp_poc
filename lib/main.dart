import 'dart:io';
import 'package:achiev_camp_poc/decorations/house.dart';
import 'package:achiev_camp_poc/entities/guide.dart';
import 'package:achiev_camp_poc/entities/visitor.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bonfire+Meteor POC',
      home: SimpleLevel(),
    );
  }
}

class SimpleLevel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double TILE_SIZE = 32.0;
    int mapHeight = 50;
    int mapWidth = 30;

    return BonfireWidget(
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
        player: Visitor(Vector2(mapWidth / 2 * TILE_SIZE, (mapHeight - 12) * TILE_SIZE)),
        joystick: getJoystickForPlatform()
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
import 'package:achiev_camp_poc/main.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

class VisitorSpriteSheet {
  static double speed = 0.2;

  static Future<SpriteAnimation> get idleRight => SpriteAnimation.load(
      "players/Alex_idle_anim_16x16.png",
      SpriteAnimationData.range(
        start: 0,
        end: 5,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get idleUp => SpriteAnimation.load(
      "players/Alex_idle_anim_16x16.png",
      SpriteAnimationData.range(
        start: 6,
        end: 11,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get idleDown => SpriteAnimation.load(
      "players/Alex_idle_anim_16x16.png",
      SpriteAnimationData.range(
        start: 18,
        end: 23,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get runRight => SpriteAnimation.load(
      "players/Alex_run_16x16.png",
      SpriteAnimationData.range(
        start: 0,
        end: 5,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get runUp => SpriteAnimation.load(
      "players/Alex_run_16x16.png",
      SpriteAnimationData.range(
        start: 6,
        end: 11,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get runDown => SpriteAnimation.load(
      "players/Alex_run_16x16.png",
      SpriteAnimationData.range(
        start: 18,
        end: 23,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static SimpleDirectionAnimation get simpleDirectionAnimation =>
      SimpleDirectionAnimation(
        idleRight: idleRight,
        idleUp: idleUp,
        idleDown: idleDown,
        runRight: runRight,
        runUp: runUp,
        runDown: runDown,
      );
}

class Visitor extends SimplePlayer with ObjectCollision {
  Visitor(Vector2 position, Direction initDirection): super(
    position: position,
    size: Vector2(16, 32),
    animation: VisitorSpriteSheet.simpleDirectionAnimation,
    speed: 75,
    initDirection: initDirection,
  ) {
    setupCollision(
      CollisionConfig(
          collisions: [
            CollisionArea.rectangle(size: Vector2(16, 8), align: Vector2(0, 24))
          ]
      ),
    );
  }

  void toggleRun(bool isRunning) {
    if (isRunning) {
      speed = 150;
    } else {
      speed = 75;
    }
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    int key = event.id;

    if (key == LogicalKeyboardKey.shiftLeft.keyId) {
      toggleRun(event.event.name == "DOWN");
    }

    super.joystickAction(event);
  }

  DateTime lastPositionUpdate = DateTime.now();
  @override
  void onMove(double speed, Direction direction, double angle) {
    DateTime now = DateTime.now();
    if (now.difference(lastPositionUpdate).inMilliseconds < 40) {
      return;
    }
    meteor.call("updateLocation", args: [position.x, position.y, direction.name]);
    lastPositionUpdate = now;
    super.onMove(speed, direction, angle);
  }
}
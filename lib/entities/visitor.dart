import 'package:bonfire/bonfire.dart';

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

class Visitor extends SimplePlayer {
  Visitor(Vector2 position): super(
    position: position,
    size: Vector2(16, 32),
    animation: VisitorSpriteSheet.simpleDirectionAnimation,
    speed: 75
  );
}
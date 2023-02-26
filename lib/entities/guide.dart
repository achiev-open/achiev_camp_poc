import 'package:bonfire/bonfire.dart';
import 'package:flutter/cupertino.dart';

class GuideSpriteSheet {
  static double speed = 0.2;

  static Future<SpriteAnimation> get idleRight => SpriteAnimation.load(
      "players/Amelia_idle_anim_16x16.png",
      SpriteAnimationData.range(
        start: 0,
        end: 5,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get idleUp => SpriteAnimation.load(
      "players/Amelia_idle_anim_16x16.png",
      SpriteAnimationData.range(
        start: 6,
        end: 11,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get idleDown => SpriteAnimation.load(
      "players/Amelia_idle_anim_16x16.png",
      SpriteAnimationData.range(
        start: 18,
        end: 23,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get runRight => SpriteAnimation.load(
      "players/Amelia_run_16x16.png",
      SpriteAnimationData.range(
        start: 0,
        end: 5,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get runUp => SpriteAnimation.load(
      "players/Amelia_run_16x16.png",
      SpriteAnimationData.range(
        start: 6,
        end: 11,
        amount: 24,
        stepTimes: List.filled(6, speed),
        textureSize: Vector2(16, 32),
      )
  );

  static Future<SpriteAnimation> get runDown => SpriteAnimation.load(
      "players/Amelia_run_16x16.png",
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

class Guide extends SimpleNpc with ObjectCollision, AutomaticRandomMovement {
  bool hasGreetedPlayer = false;
  bool isTalking = false;

  Guide(Vector2 position): super(
    position: position,
    size: Vector2(16, 32),
    animation: GuideSpriteSheet.simpleDirectionAnimation,
    speed: 75,
    initDirection: Direction.left
  ) {
    setupCollision(
      CollisionConfig(
          collisions: [
            CollisionArea.rectangle(size: Vector2(16, 8), align: Vector2(0, 24))
          ]
      ),
    );
  }

  @override
  void update(double dt) {
    if (isTalking) { return; }
    if (!hasGreetedPlayer) {
      seeAndMoveToPlayer(
          radiusVision: 32 * 4,
          closePlayer: (player) {
            isTalking = true;
            TalkDialog.show(
              context,
              [
                Say(
                  text: [TextSpan(text: "Hello !\nWelcome to the island")],
                  person: GuideSpriteSheet.idleDown.asWidget(),
                ),
                Say(
                  text: [TextSpan(text: "My name is Amelia.\nI am here to help you.\nCome see me if you have any question")],
                  person: GuideSpriteSheet.idleDown.asWidget(),
                )
              ],
              onClose: () {
                isTalking = false;
                hasGreetedPlayer = true;
              }
            );
          },
          notObserved: () {
            runRandomMovement(dt);
          }
      );
    } else {
      runRandomMovement(dt);
    }
    super.update(dt);
  }
}
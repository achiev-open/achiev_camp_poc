import 'package:achiev_camp_poc/entities/visitor.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class Guide extends SimpleNpc with ObjectCollision, AutomaticRandomMovement, TapGesture {
  bool hasGreetedPlayer = false;
  bool isTalking = false;
  bool isCloseToPlayer = false;

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
      if (!isCloseToPlayer) { // Stop moving when we're close to the player
        runRandomMovement(dt);
      }

      seePlayer(
        observed: (player) {
          isCloseToPlayer = true;
          _toggleEmote();
        },
        notObserved: () {
          isCloseToPlayer = false;
          _toggleEmote();
        }
      );
    }
    super.update(dt);
  }

  AnimatedFollowerObject? emote;
  void _toggleEmote() {
    if (isCloseToPlayer) {
      if (emote != null) return; // Already displayed
      emote = AnimatedFollowerObject(
          animation: SpriteAnimation.load(
            "ui/talk_16x16.png",
            SpriteAnimationData.sequenced(amount: 8, stepTime: 0.1, textureSize: Vector2(16, 16)),
          ),
          target: this,
          size: Vector2(16, 16),
          positionFromTarget: Vector2(0, 0),
          loopAnimation: true
      );

      gameRef.add(emote!);
    } else {
      if (emote == null) return; // No emote to remove
      emote!.removeFromParent();
      emote = null;
    }
  }

  @override
  void onTap() {
    if (!isCloseToPlayer) return;
    _showChoicesDialog();
  }

  void _showChoicesDialog() {
    Map<String, String> possibleQuestions = {
      "What's your name ?": "My name is Amelia, I'm here to help you",
      "Where are we ?": "We're on The Island, it's pretty empty yet but it will become an amazing place one day",
    };

    showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext dialogContext) {
          List<Widget> questionsWidgets = [];
          possibleQuestions.forEach((key, value) {
            questionsWidgets.add(const SizedBox(height: 10));
            questionsWidgets.add(ElevatedButton(
              child: Text(key),
              onPressed: () {
                _answerQuestion(dialogContext, value);
              },
            ));
          });

          return TalkDialog(
              says: [
                Say(
                    text: [TextSpan(text: "How can I help you ?")],
                    person: Container(
                      padding: EdgeInsets.only(bottom: 110 + ((possibleQuestions.length - 1) * 38)), // textBoxMinHeight = 100. button = 28. Spacing = 10
                      child: GuideSpriteSheet.idleDown.asWidget(),
                    ),
                    bottom: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: questionsWidgets,
                        ),
                        SizedBox(width: 10),
                        VisitorSpriteSheet.idleDown.asWidget(),
                      ],
                    )
                ),
              ]
          );
        }
    );
  }

  void _answerQuestion(BuildContext dialogContext, String answer) {
    Navigator.of(dialogContext).pop();
    TalkDialog.show(
        context,
        [
          Say(
            text: [TextSpan(text: answer)],
            person: GuideSpriteSheet.idleDown.asWidget(),
          ),
        ],
        onClose: () {
          Future.delayed(Duration.zero, _showChoicesDialog); // Delayed to avoid calling setState when widget tree is locked
        }
    );
  }
}
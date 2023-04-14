import 'package:achiev_camp_poc/entities/visitor.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'dart:async' as async;

class OtherPlayer extends SimpleNpc with ObjectCollision {
  final _debouncer = Debouncer(milliseconds: 200);

  OtherPlayer(Vector2 position, Direction initDirection): super(
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

  moveToPosition(Vector2 newPosition) {
    double diffX = newPosition.x - position.x;
    double diffY = newPosition.y - position.y;

    if (diffX > 0) {
      moveRight(0);
    } else if (diffX < 0) {
      moveLeft(0);
    } else if (diffY > 0) {
      moveDown(0);
    } else if (diffY < 0) {
      moveUp(0);
    }
    position = newPosition;
    _debouncer.run(() { idle(); });
  }
}

class Debouncer {
  final int milliseconds;
  async.Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = async.Timer(Duration(milliseconds: milliseconds), action);
  }
}

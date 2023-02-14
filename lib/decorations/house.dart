import 'package:bonfire/bonfire.dart';

class House extends GameDecoration with ObjectCollision {
  House(Vector2 position) : super.withSprite(
      sprite: Sprite.load("decorations/house.png"),
      position: position,
      size: Vector2(128, 128),
  ) {
    setupCollision(
        CollisionConfig(
            collisions: [
              CollisionArea.rectangle(
                size: Vector2(110, 36),
                align: Vector2(12, 60),
              ),
          ],
        ),
    );
  }
}
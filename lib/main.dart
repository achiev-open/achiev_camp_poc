import 'package:achiev_camp_poc/entities/visitor.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
    TileModelSprite waterSprite = TileModelSprite(path: "tiles/water.png");
    TileModelSprite grassSprite = TileModelSprite(path: "tiles/grass.png");
    double TILE_SIZE = 32.0;

    List<List<double>> map = [
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ];
    int mapHeight = map.length;
    int mapWidth = map[0].length;

    return BonfireWidget(
      // showCollisionArea: true,
        cameraConfig: CameraConfig(
          moveOnlyMapArea: true,
          sizeMovementWindow: Vector2(50,50),
          zoom: 2,
          angle: 45 * pi / 180, // 45 deg
        ),
        map: MatrixMapGenerator.generate(
            axisInverted: true,
            matrix: map,
            builder: (ItemMatrixProperties prop) {
              TileModelSprite? sprite;
              List<CollisionArea> collisions = [];

              if (prop.value == 0) {
                sprite = waterSprite;
                collisions.add(CollisionArea.rectangle(
                  size: Vector2(TILE_SIZE, TILE_SIZE),
                  align: Vector2(0, 0),
                ));
              }
              else if (prop.value == 1) { sprite = grassSprite; }
              else { throw new Exception("Value ${prop.value} doesn't match any sprite"); }

              return TileModel(
                  x: prop.position.x,
                  y: prop.position.y,
                  sprite: sprite,
                  width: TILE_SIZE,
                  height: TILE_SIZE,
                  collisions: collisions,
              );
            },
        ),
        player: Visitor(Vector2(mapWidth / 2 * TILE_SIZE, (mapHeight - 10.5) * TILE_SIZE)),
        joystick: Joystick(directional: JoystickDirectional())
    );
  }
}
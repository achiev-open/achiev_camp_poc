import 'package:achiev_camp_poc/decorations/house.dart';
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
        map: WorldMapByTiled("tiles/small-map.json", forceTileSize: Vector2(32, 32)),
        player: Visitor(Vector2(mapWidth / 2 * TILE_SIZE, (mapHeight - 12) * TILE_SIZE)),
        joystick: Joystick(directional: JoystickDirectional()),
        decorations: [House(Vector2(mapWidth / 2 * TILE_SIZE, 20 * TILE_SIZE))],
    );
  }
}
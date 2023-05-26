import 'package:flutter/material.dart';

class BatteryBars extends StatelessWidget {
  final double currentCapacity;
  final double parentContainerHeight;

  const BatteryBars({
    Key? key,
    required this.currentCapacity,
    required this.parentContainerHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(
          left: 0.4 * screenWidth, top: 0.3725 * parentContainerHeight),
      child: Row(
        children: buildBarsList(numberOfBars(currentCapacity), screenWidth),
      ),
    );
  }

  List<Widget> buildBarsList(int numberOfBars, double screenWidth) {
    List<Widget> bars = [];
    for (int i = 0; i < numberOfBars; i++) {
      bars.add(
        Row(
          children: [
            Container(
              color: Colors.green,
              width: 0.051 * screenWidth,
              height: 0.2195 * parentContainerHeight,
            ),
            Container(
              color: Colors.black,
              width: 0.0127 * screenWidth,
              height: 0.2195 * parentContainerHeight,
            )
          ],
        ),
      );
    }
    return bars;
  }

  int numberOfBars(double currentCapacity) {
    if (currentCapacity <= 0) return 0;
    if (currentCapacity > 0 && currentCapacity <= 33) return 1;
    if (currentCapacity > 33 && currentCapacity <= 66) return 2;
    if (currentCapacity > 66 && currentCapacity <= 99) return 3;
    if (currentCapacity > 99) return 4;
    throw Exception();
  }
}

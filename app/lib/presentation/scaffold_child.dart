import 'package:app/presentation/battery.dart';
import 'package:flutter/material.dart';

class ScaffoldChild extends StatelessWidget {
  const ScaffoldChild({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Icon(
              Icons.wb_sunny,
              color: Colors.yellow,
              size: 0.33 * screenWidth,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 3.0),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: Colors.green,
              size: 0.254 * screenWidth,
            ),
          ),
          Battery(),
          Container(
            padding: const EdgeInsets.only(top: 3.0),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: Colors.red,
              size: 0.254 * screenWidth,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 3.0),
            child: Icon(
              Icons.devices,
              color: Colors.white,
              size: 0.254 * screenWidth,
            ),
          ),
        ],
      ),
    );
  }
}

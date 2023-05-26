import 'dart:async';

import 'package:app/data/datasources/awsiot_remote_datasource.dart';
import 'package:app/data/models/measurement_model.dart';
import 'package:app/presentation/battery_bars.dart';
import 'package:flutter/material.dart';

class Battery extends StatefulWidget {
  final AwsIotRemoteDataSourceImpl remoteDataSource =
      AwsIotRemoteDataSourceImpl();

  Battery({
    Key? key,
  }) : super(key: key);

  @override
  State<Battery> createState() => _BatteryState();
}

class _BatteryState extends State<Battery> {
  MeasurementModel? measurementModel;

  @override
  void initState() {
    super.initState();
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(
        oneSecond,
        (Timer t) => setState(() {
              updateMeasurement();
            }));
  }

  Future<void> updateMeasurement() async {
    final MeasurementModel measurement =
        await widget.remoteDataSource.getShadow();
    measurementModel = measurement;
    setState(() {
      measurementModel = measurement;
    });
  }

  Widget buildPowerInText() {
    if (measurementModel != null) {
      return Text(
        "${measurementModel!.powerIn.toStringAsFixed(3)} mW",
        style: const TextStyle(color: Colors.white, fontSize: 20.0),
      );
    } else {
      return Container();
    }
  }

  Widget buildPowerOutText() {
    if (measurementModel != null) {
      return Text(
        "${measurementModel!.powerOut.toStringAsFixed(3)} mW",
        style: const TextStyle(color: Colors.white, fontSize: 20.0),
      );
    } else {
      return Container();
    }
  }

  Widget buildBatteryText() {
    if (measurementModel != null) {
      return Text(
        "${measurementModel!.batterycapacity.toStringAsFixed(2)} %",
        style: const TextStyle(color: Colors.white, fontSize: 20.0),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double containerHeight = screenHeight * 0.27;
    return Container(
      height: containerHeight,
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Align(
                alignment: Alignment.topCenter, child: buildPowerInText()),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3.0),
            child: Align(
                alignment: Alignment.bottomCenter, child: buildPowerOutText()),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: buildBatteryText(),
            ),
          ),
          Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Icon(
                Icons.battery_0_bar,
                color: Colors.white,
                size: 0.5089 * screenWidth,
              ),
            ),
          ),
          BatteryBars(
            currentCapacity: measurementModel != null
                ? measurementModel!.batterycapacity
                : 0,
            parentContainerHeight: containerHeight,
          )
        ],
      ),
    );
  }
}

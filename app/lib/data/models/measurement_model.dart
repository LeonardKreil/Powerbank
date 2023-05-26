class MeasurementModel {
  final double powerIn;
  final double powerOut;
  final double batterycapacity;

  MeasurementModel({
    required this.powerIn,
    required this.powerOut,
    required this.batterycapacity,
  });

  MeasurementModel.fromJson(Map<String, dynamic> json)
      : powerIn = json['state']['reported']['generated']['powerIn'],
        powerOut = json['state']['reported']['generated']['powerOut'],
        batterycapacity = (json['state']['reported']['generated']
                ['batteryCapacity'])
            .toDouble();
}

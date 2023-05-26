import 'package:app/data/datasources/awsiot_remote_datasource.dart';
import 'package:app/data/models/measurement_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should return String when getShadow is called', () async {
    //arrange
    final remoteDataSource = AwsIotRemoteDataSourceImpl();
    //act
    final shadow = await remoteDataSource.getShadow();
    print(shadow.powerIn);
    //assert
    expect(shadow, isA<MeasurementModel>());
  });
}

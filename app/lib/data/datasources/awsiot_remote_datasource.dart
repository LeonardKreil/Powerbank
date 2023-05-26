import 'package:app/data/datasources/http_functions.dart';
import 'package:app/data/models/measurement_model.dart';

abstract class AwsIotRemoteDataSource {
  Future<MeasurementModel> getShadow();
}

class AwsIotRemoteDataSourceImpl implements AwsIotRemoteDataSource {
  @override
  Future<MeasurementModel> getShadow() async {
    final result = await sendGetRequest();
    return MeasurementModel.fromJson(result);
  }
}

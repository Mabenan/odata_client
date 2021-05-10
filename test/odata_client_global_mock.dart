
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:http/http.dart' as http;
import 'odata_client_global_mock.mocks.dart';
@GenerateMocks([http.Client])
MockClient GetClient(){
  return MockClient();
}
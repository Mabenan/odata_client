import 'package:test/test.dart';

import 'package:odata_client/odata_client.dart';
import 'package:odata_client/odata_connection.dart';

void main() {
  test('returns connection', () async{
    ODataConnection? connection = ODataClient().getConnection(Uri.http("services.odata.org", "TripPinRESTierService"));
    expect(connection, isNot(null));
  });
  test('returns same connection for baseURI', ()async {
    ODataConnection connection = ODataClient().getConnection(Uri.http("services.odata.org", "TripPinRESTierService"));
    ODataConnection connection2 = ODataClient().getConnection(Uri.http("services.odata.org", "TripPinRESTierService"));
    expect(connection, equals(connection2));
  });
  test('returns different connection for different baseURI', () async {
    ODataConnection connection = ODataClient().getConnection(Uri.http("services.odata.org", "TripPinRESTierService"));
    ODataConnection connection2 = ODataClient().getConnection(Uri.http("services2.odata.org", "TripPinRESTierService"));
    expect(connection, isNot(null));
    expect(connection2, isNot(null));
    expect(connection, isNot(connection2));
  });
}

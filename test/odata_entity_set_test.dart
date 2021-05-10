import 'dart:convert';

import 'package:odata_client/odata_entity.dart';
import 'package:odata_client/odata_entity_set.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:odata_client/odata_client.dart';
import 'package:odata_client/odata_connection.dart';
import 'package:mockito/mockito.dart';
import 'package:xml/xml.dart';
import 'odata_client_global_mock.dart';
import 'odata_client_global_mock.mocks.dart';


class People extends ODataEntity{
  People() : super("People");

}
class PeopleSet extends ODataEntitySet<People>{
  PeopleSet() : super("People");
}

void main() {
  MockClient client = GetClient();
  Uri serverUri = Uri.http("services.odata.org", "TripPinRESTierService/");

  ODataConnection getConnection() {
    ODataClient().registerEntitySet<PeopleSet>(() => PeopleSet());
    ODataClient().registerEntity<People>(() => People());
    ODataConnection connection =
    new ODataConnection(client,serverUri );
    when(
      client.get(serverUri.resolve("\$metadata"), headers: anyNamed("headers")),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("\$metadata")));
    return connection;
  }

  test("returns EntitySet Object on Get", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People")));
    ODataEntitySet entitySet = await connection.entitySet(entityName:"People");
    expect(entitySet, isNotNull);
    expect(entitySet.first.get<String>("FirstName"), equals("Russell"));
  });

  test("uses Custom Object", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People")));
    PeopleSet entitySet = await connection.entitySet<PeopleSet>();
    expect(entitySet, isNotNull);
    expect(entitySet, equals(TypeMatcher<PeopleSet>()));
    expect(entitySet.first, equals(TypeMatcher<People>()));
    expect(entitySet.first.get<String>("FirstName"), equals("Russell"));
  });
}
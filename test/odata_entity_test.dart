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
  People.clone(): this();
  @override clone() => People.clone()..fromJson(toJson());

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

  test("returns Entity Object on Get", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People('russellwhyte')"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People('russellwhyte')")));
    People entity = await connection.getEntity<People>({"UserName": "russellwhyte"});
    expect(entity, isNotNull);
    expect(entity.get<String>("FirstName"), equals("Russell"));
    verify(client.get(serverUri.resolve("People('russellwhyte')"), headers: null));
  });
  test("can clone", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People('russellwhyte')"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People('russellwhyte')")));
    ODataEntity entity = await connection.getEntity({"UserName": "russellwhyte"}, entityName: "People");
    ODataEntity clone = entity.clone();
    expect(clone, isNotNull);
    expect(clone.get<String>("FirstName"), equals("Russell"));
    verify(client.get(serverUri.resolve("People('russellwhyte')"), headers: null));
  });

  test("uses Custom Object", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People('russellwhyte')"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People('russellwhyte')")));
    People entity = await connection.getEntity<People>({"UserName": "russellwhyte"});
    expect(entity, isNotNull);
    expect(entity, equals(TypeMatcher<People>()));
    expect(entity.get<String>("FirstName"), equals("Russell"));
    verify(client.get(serverUri.resolve("People('russellwhyte')"), headers: null));
  });

  test("can clone Object", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People('russellwhyte')"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People('russellwhyte')")));
    People entity = await connection.getEntity<People>({"UserName": "russellwhyte"});
    People clone  = entity.clone();
    expect(clone, isNotNull);
    expect(clone, equals(TypeMatcher<People>()));
    expect(clone.get<String>("FirstName"), equals("Russell"));
    verify(client.get(serverUri.resolve("People('russellwhyte')"), headers: null));

  });

  test("handles multi key", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People(UserName='russellwhyte',AnyNumber=12)"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People('russellwhyte')")));
    People entity = await connection.getEntity<People>({"UserName": "russellwhyte", "AnyNumber": 12});
    expect(entity, isNotNull);
    expect(entity, equals(TypeMatcher<People>()));
    expect(entity.get<String>("FirstName"), equals("Russell"));
    verify(client.get(serverUri.resolve("People(UserName='russellwhyte',AnyNumber=12)"), headers: null));
  });
}
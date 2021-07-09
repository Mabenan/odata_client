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
  PeopleSet.clone(): this();
  @override clone() => PeopleSet.clone()..fromJson(toJson());
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
    ODataEntitySet entitySet = await connection.getEntitySet(entityName:"People");
    expect(entitySet, isNotNull);
    expect(entitySet.first.get<String>("FirstName"), equals("Russell"));
  });
  test("can clone", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People")));
    ODataEntitySet entitySet = await connection.getEntitySet(entityName:"People");
    ODataEntitySet clone = entitySet.clone();
    expect(clone, isNotNull);
    expect(clone.first.get<String>("FirstName"), equals("Russell"));
  });

  test("can iterate over collection", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People")));
    PeopleSet entitySet = await connection.getEntitySet<PeopleSet>();
    expect(entitySet, isNotNull);
    expect(entitySet, equals(TypeMatcher<PeopleSet>()));
    expect(entitySet.length, equals(20));
    for (var entity in entitySet) {
      expect(entity, equals(TypeMatcher<People>()));
    }

    var iter = entitySet.iterator;
    while(iter.moveNext()){
      expect(iter.current, equals(TypeMatcher<People>()));
    }
  });
  test("uses Custom Object", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People")));
    PeopleSet entitySet = await connection.getEntitySet<PeopleSet>();
    expect(entitySet, isNotNull);
    expect(entitySet, equals(TypeMatcher<PeopleSet>()));
    expect(entitySet.first, equals(TypeMatcher<People>()));
    expect(entitySet.first.get<String>("FirstName"), equals("Russell"));
  });
  test("can clone Custom Object", () async {
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People")));
    PeopleSet entitySet = await connection.getEntitySet<PeopleSet>();
    PeopleSet clone = entitySet.clone();
    expect(clone, isNotNull);
    expect(clone, equals(TypeMatcher<PeopleSet>()));
    expect(clone.first, equals(TypeMatcher<People>()));
    expect(clone.first.get<String>("FirstName"), equals("Russell"));
  });
}
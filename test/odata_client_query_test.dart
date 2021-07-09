import 'dart:convert';

import 'package:odata_client/odata_entity.dart';
import 'package:odata_client/odata_entity_set.dart';
import 'package:odata_client/odata_enum.dart';
import 'package:odata_client/odata_query.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:odata_client/odata_client.dart';
import 'package:odata_client/odata_connection.dart';
import 'package:mockito/mockito.dart';
import 'package:xml/xml.dart';
import 'odata_client_global_mock.dart';
import 'odata_client_global_mock.mocks.dart';

class People extends ODataEntity {
  People() : super("People");
}

class PeopleSet extends ODataEntitySet<People> {
  PeopleSet() : super("People");
}

void main() {
  MockClient client = GetClient();
  Uri serverUri = Uri.http("services.odata.org", "TripPinRESTierService/");

  ODataConnection getConnection() {
    ODataClient().registerEntitySet<PeopleSet>(() => PeopleSet());
    ODataClient().registerEntity<People>(() => People());
    ODataConnection connection = new ODataConnection(client, serverUri);
    when(
      client.get(serverUri.resolve("\$metadata"), headers: anyNamed("headers")),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("\$metadata")));
    return connection;
  }

  test("Connections adds query", () async {
    ODataQuery query = ODataQuery();
    query.filter();
    query.equalTo("FirstName", "Scott");
    var connection = getConnection();
    when(
      client.get(serverUri.resolve("People").replace(query: query.toString()),
          headers: null),
    ).thenAnswer((realInvocation) =>
        http.get(serverUri.resolve("People").replace(query: query.toString())));
    ODataEntitySet entitySet =
        await connection.getEntitySet(entityName: "People", query: query);
    expect(entitySet, isNotNull);
    expect(entitySet.length, equals(1));
    expect(entitySet.first.get<String>("FirstName"), equals("Scott"));
    verify(client.get(
        serverUri.resolve("People").replace(query: query.toString()),
        headers: null));
  });

  test("throwsEx on two values without connection", () async {
    ODataQuery query = ODataQuery();
    query.filter();
    query.equalTo("UserName", "russelwhite");
    try {
      query.equalTo("UserName", "russelwhite2");
    } catch (ex) {
      expect(ex, equals(TypeMatcher<ODataQueryException>()));
      expect(ex.toString(), equals("you must connect two operations"));
    }
    expect(query.toString(), equals("\$filter=UserName eq 'russelwhite'"));
  });

  test("build complex query", () async {
    ODataQuery query = ODataQuery();
    query
        .filter()
        .equalTo("UserName", "russelwhite")
        .and()
        .bracketOpen()
        .equalTo("Gender", ODataEnumValue("PersonGender", "Male"))
        .or()
        .gtTo("Age", 21)
        .bracketClose()
        .expand("BestFriend")
        .bracketOpen()
        .select(["UserName", "FirstName"])
        .bracketClose()
        .select(["UserName", "FirstName"]);
    expect(
        query.toString(),
        equals(
            "\$filter=UserName eq 'russelwhite' and (Gender eq PersonGender'Male' or Age gt 21)&\$expand=BestFriend(\$select=UserName, FirstName)&\$select=UserName, FirstName"));
  });

  test("throw ex on twice top select", () async {
    ODataQuery query = ODataQuery();
    query.select(["UserName", "FirstName"]);
    try {
      query.select(["Middelname"]);
    } catch (ex) {
      expect(ex, equals(TypeMatcher<ODataQueryException>()));
    }
    expect(query.toString(), equals("\$select=UserName, FirstName"));
  });
  test("throw ex on twice top expand", () async {
    ODataQuery query = ODataQuery();
    query.expand("BestFriend");
    try {
      query.expand("Trips");
    } catch (ex) {
      expect(ex, equals(TypeMatcher<ODataQueryException>()));
    }
    expect(query.toString(), equals("\$expand=BestFriend"));
  });

  test("position of operations can be switched", () async {
    ODataQuery query = ODataQuery();
    query
        .expand("BestFriend")
        .bracketOpen()
        .select(["UserName", "FirstName"])
        .bracketClose()
        .filter()
        .equalTo("UserName", "russelwhite")
        .and()
        .bracketOpen()
        .equalTo("Gender", ODataEnumValue("PersonGender", "Male"))
        .or()
        .gtTo("Age", 21)
        .bracketClose()
        .select(["UserName", "FirstName"]);
    expect(
        query.toString(),
        equals(
            "\$expand=BestFriend(\$select=UserName, FirstName)&\$filter=UserName eq 'russelwhite' and (Gender eq PersonGender'Male' or Age gt 21)&\$select=UserName, FirstName"));
  });

  test("throwsEx on two filters", () async {
    ODataQuery query = ODataQuery();
    query.filter();
    try {
      query.filter();
    } catch (ex) {
      expect(ex, equals(TypeMatcher<ODataQueryException>()));
    }
    query.equalTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName eq 'russelwhite'"));
  });

  test("writes filter eq", () async {
    ODataQuery query = ODataQuery();
    query.filter().equalTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName eq 'russelwhite'"));
  });

  test("writes filter ne", () async {
    ODataQuery query = ODataQuery();
    query.filter().notEqualTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName ne 'russelwhite'"));
  });

  test("writes filter gt", () async {
    ODataQuery query = ODataQuery();
    query.filter().gtTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName gt 'russelwhite'"));
  });
  test("writes filter ge", () async {
    ODataQuery query = ODataQuery();
    query.filter().geTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName ge 'russelwhite'"));
  });
  test("writes filter lt", () async {
    ODataQuery query = ODataQuery();
    query.filter().ltTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName lt 'russelwhite'"));
  });
  test("writes filter le", () async {
    ODataQuery query = ODataQuery();
    query.filter().leTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName le 'russelwhite'"));
  });

  test("writes filter has", () async {
    ODataQuery query = ODataQuery();
    query.filter().has("UserName", ODataEnumValue("Sales.Color", "Yellow"));
    expect(
        query.toString(), equals("\$filter=UserName has Sales.Color'Yellow'"));
  });
  test("writes filter in", () async {
    ODataQuery query = ODataQuery();
    query.filter().inList("UserName", ['Redmond', 'London']);
    expect(
        query.toString(), equals("\$filter=UserName in ('Redmond', 'London')"));
  });
}

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
    new ODataConnection(client, serverUri);
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
      client.get(serverUri.resolve("People").replace(query:query.toString()), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People").replace(query:query.toString())));
    ODataEntitySet entitySet = await connection.getEntitySet(entityName:"People", query: query);
    expect(entitySet, isNotNull);
    expect(entitySet.length, equals(1));
    expect(entitySet.first.get<String>("FirstName"), equals("Scott"));
    verify(client.get(serverUri.resolve("People").replace(query:query.toString()), headers: null));
  });

  test("throwsEx on two filters", () async{
    ODataQuery query = ODataQuery();
    query.filter();
    try{
      query.filter();
    }catch(ex) {
      expect(ex, equals(TypeMatcher<ODataQueryException>()));
    }
    query.equalTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName eq 'russelwhite'"));
  });

  test("writes filter eq", () async{
    ODataQuery query = ODataQuery();
    query.filter().equalTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName eq 'russelwhite'"));
  });

  test("writes filter ne", () async{
    ODataQuery query = ODataQuery();
    query.filter().notEqualTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName ne 'russelwhite'"));
  });

  test("writes filter gt", () async{
    ODataQuery query = ODataQuery();
    query.filter().gtTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName gt 'russelwhite'"));
  });
  test("writes filter ge", () async{
    ODataQuery query = ODataQuery();
    query.filter().geTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName ge 'russelwhite'"));
  });
  test("writes filter lt", () async{
    ODataQuery query = ODataQuery();
    query.filter().ltTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName lt 'russelwhite'"));
  });
  test("writes filter le", () async{
    ODataQuery query = ODataQuery();
    query.filter().leTo("UserName", "russelwhite");
    expect(query.toString(), equals("\$filter=UserName le 'russelwhite'"));
  });

  test("writes filter has", () async{
    ODataQuery query = ODataQuery();
    query.filter().has("UserName", ODataEnumValue("Sales.Color", "Yellow"));
    expect(query.toString(), equals("\$filter=UserName has Sales.Color'Yellow'"));
  });
  test("writes filter in", () async{
    ODataQuery query = ODataQuery();
    query.filter().inList("UserName", ['Redmond', 'London']);
    expect(query.toString(), equals("\$filter=UserName in ('Redmond', 'London')"));
  });
}
import 'dart:convert';

import 'package:odata_client/odata_entity_set.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:odata_client/odata_client.dart';
import 'package:odata_client/odata_connection.dart';
import 'package:mockito/mockito.dart';
import 'odata_client_global_mock.dart';
import 'odata_client_global_mock.mocks.dart';

void main() {
 MockClient client = GetClient();
  Uri serverUri = Uri.http("services.odata.org", "TripPinRESTierService/");

  ODataConnection getConnection() {
    ODataConnection connection =
       new ODataConnection(client,serverUri );
    return connection;
  }

  String getAuthString(String username, String password) {
    final token = base64.encode(latin1.encode('$username:$password'));

    final authstr = 'Basic ' + token.trim();

    return authstr;
  }

  test('is login', () async{
    ODataConnection connection = getConnection();
    when(
      client.get(serverUri.resolve("People"), headers: anyNamed("headers")),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People")));
    when(
      client.get(serverUri.resolve("\$metadata"), headers: anyNamed("headers")),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("\$metadata")));
    connection.login("test", "pass");
    expect(await connection.getEntitySet(entityName: "People"), equals(TypeMatcher<ODataEntitySet>()));
    verify(client.get(any,
        headers: {"Authorization": getAuthString("test", "pass")}));
  });

  test("handle refused login", () async  {
      ODataConnection connection = getConnection();
      when(
        client.get(serverUri.resolve("\$metadata"), headers: anyNamed("headers")),
      ).thenAnswer((realInvocation) async => http.Response("",401));
      connection.login("test", "pass");
      expect(connection.init(), throwsA(TypeMatcher<ODataLoginException>()));
  });

  test("don't continue after failed login", () async {
    ODataConnection connection = getConnection();
    when(
      client.get(serverUri.resolve("\$metadata"), headers: anyNamed("headers")),
    ).thenAnswer((realInvocation) async => http.Response("",401));
    connection.login("test", "pass");
    expect(connection.getEntitySet(entityName:"People"), throwsA(TypeMatcher<ODataLoginException>()));
    verify(client.get(serverUri.resolve("\$metadata"),
        headers: {"Authorization": getAuthString("test", "pass")}));

  });

  test("handles open service without login", () async {

    ODataConnection connection = getConnection();
    when(
      client.get(serverUri.resolve("People"), headers: null),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People")));
    when(
      client.get(serverUri.resolve("\$metadata"), headers: anyNamed("headers")),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("\$metadata")));
    expect(await connection.getEntitySet(entityName:"People"), equals(TypeMatcher<ODataEntitySet>()));
    verify(client.get(any,
        headers: {"Authorization": getAuthString("test", "pass")}));
  });
}

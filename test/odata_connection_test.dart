import 'dart:convert';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:odata_client/odata_client.dart';
import 'package:odata_client/odata_connection.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'odata_connection_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
 MockClient client = new MockClient();
  Uri serverUri = Uri.http("services.odata.org", "TripPinRESTierService/");

  ODataConnection getConnection() {
    ODataConnection connection =
        ODataClient().getConnection(serverUri, client: client);
    return connection;
  }

  String getAuthString(String username, String password) {
    final token = base64.encode(latin1.encode('$username:$password'));

    final authstr = 'Basic ' + token.trim();

    return authstr;
  }

  test('is login', () {
    ODataConnection connection = getConnection();
    when(
      client.get(serverUri.resolve("People"), headers: anyNamed("headers")),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("People")));
    when(
      client.get(serverUri.resolve("\$metadata"), headers: anyNamed("headers")),
    ).thenAnswer((realInvocation) => http.get(serverUri.resolve("\$metadata")));
    connection.login("test", "pass");
    connection.entitySet("People");
    verify(client.get(any,
        headers: {"Authorization": getAuthString("test", "pass")}));
  });

  test("handle refused login", () {
      ODataConnection connection = getConnection();
      when(
        client.get(serverUri.resolve("\$metadata"), headers: anyNamed("headers")),
      ).thenAnswer((realInvocation) async => http.Response("",401));
      connection.login("test", "pass");
      expect(connection.init(), throwsA(TypeMatcher<ODataLoginException>()));
  });

  test("don't continue after failed login", (){
    ODataConnection connection = getConnection();
    when(
      client.get(serverUri.resolve("\$metadata"), headers: anyNamed("headers")),
    ).thenAnswer((realInvocation) async => http.Response("",401));
    connection.login("test", "pass");
    expect(connection.entitySet("People"), throwsA(TypeMatcher<ODataLoginException>()));
    verify(client.get(serverUri.resolve("\$metadata"),
        headers: {"Authorization": getAuthString("test", "pass")}));

  });
}

library odata_client;

import 'package:odata_client/odata_connection.dart';
import 'package:http/http.dart' as http;

/// Organizes OData Connections
class ODataClient {

  static final ODataClient _instance = ODataClient._internal();

  ODataClient._internal();

  factory ODataClient(){
    return _instance;
  }

  Map<Uri, ODataConnection> _connections = {};

  /// Returns the Connection for the [baseUri]
  ///
  /// If you don't want to use the default [http.Client] of package:http/http.dart
  /// set [client]
  getConnection(Uri baseUri, {http.Client? client}){
     if(!_connections.containsKey(baseUri)){
       _connections[baseUri] = new ODataConnection(client != null ? client : http.Client(), baseUri);
     }
     return _connections[baseUri];
  }

}
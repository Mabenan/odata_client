library odata_client;

import 'package:odata_client/odata_connection.dart';
import 'package:http/http.dart' as http;
import 'package:odata_client/odata_entity.dart';

import 'odata_entity_set.dart';

/// Organizes OData Connections
class ODataClient {

  static final ODataClient _instance = ODataClient._internal();

  ODataClient._internal();

  factory ODataClient(){
    return _instance;
  }

  Map<Uri, ODataConnection> _connections = {};

  Map<Type, ODataEntitySetConstructor> _entitySetConstructor = {};
  Map<Type, ODataEntityConstructor> _entityConstructor = {};

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

  /// Registers a subclass of [ODataEntitySet]
  ///
  /// [T] must be provided
  registerEntitySet<T>(ODataEntitySetConstructor constructor){
    _entitySetConstructor[T] = constructor;
  }

  /// Registers a subclass of [ODataEntity]
  ///
  /// [T] must be provided
  registerEntity<T>(ODataEntityConstructor constructor){
    _entityConstructor[T] = constructor;
  }

  ODataEntitySetConstructor? getEntitySet<T>(){
    return _entitySetConstructor[T];
  }
  ODataEntityConstructor? getEntity<T>(){
    return _entityConstructor[T];
  }

}
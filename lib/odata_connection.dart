import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mutex/mutex.dart';
import 'package:odata_client/odata_client.dart';
import 'package:odata_client/odata_entity.dart';
import 'package:odata_client/odata_entity_set.dart';
import 'package:xml/xml.dart';

class ODataConnection{
  final http.Client client;

  final Uri baseURI;

  String _authString = "";

  bool _init = false;

  final Mutex _initLock = Mutex();

  XmlDocument? _metadata;


  ODataConnection(this.client,this.baseURI);

  /// Sets Credentials for all Requests
  void login(String username, String password){
    final token = base64.encode(latin1.encode('$username:$password'));

    _authString = 'Basic ' + token.trim();
  }

  /// Loads the metadata and checks Credentials
  ///
  /// Can be called directly but is latest called before first request
  Future<bool> init() async{
    if(!_init){
      await _initLock.acquire();
      try {
        if (!_init) {
          http.Response resp = await _get(baseURI.resolve("\$metadata"));
          if (resp.statusCode == 403
              || resp.statusCode == 401) {
            throw ODataLoginException();
          }
          _metadata = XmlDocument.parse(resp.body);
          _init = true;
        }
      }finally{
        _initLock.release();
      }
    }
    return _init;
  }

  /// Returns an EntitySet of type [T]
  ///
  /// If [T] is not provided or is not registered on the Client [entityName] needs to be provided
  Future<T> getEntitySet<T extends ODataEntitySet>({String? entityName}) async{
    if(await init()) {
      ODataEntitySet<ODataEntity> entitySet = _getEntitySetInstance<T>(entityName);
      http.Response resp = await _get(baseURI.resolve(entitySet.entityName));
      return (entitySet..fromJson(jsonDecode(resp.body)["value"] as List) ) as T;
    }else{
      throw Exception("cannot initialize");
    }
  }

  /// Returns an Entity of type [T] for the [key]
  ///
  /// If [T] is not provided or is not registered on the Client [entityName] needs to be provided
  Future<T> getEntity<T extends ODataEntity>(Map<String, dynamic> key, {String? entityName}) async{
    if(await init()) {
      ODataEntity entity = _getEntityInstance<T>(entityName);
      var keyString = "";
      if(key.length == 1){
        var keyPair = key.entries.first;
        keyString = formatKeyValue(keyPair);
      }else {
        for (var keyPair in key.entries) {
          if (keyString != "") {
            keyString += ",";
          }
          keyString += keyPair.key + "="+formatKeyValue(keyPair);
        }
      }
      http.Response resp = await _get(baseURI.resolve(entity.entityName+"("+ keyString + ")"));
      return (entity..fromJson(jsonDecode(resp.body))) as T;
    }else{
      throw Exception("cannot initialize");
    }

  }

  ODataEntitySet<ODataEntity> _getEntitySetInstance<T extends ODataEntitySet>(String? entityName) {
    ODataEntitySetConstructor? setConst = ODataClient().getEntitySet<T>();
    ODataEntitySet entitySet;
    if(setConst == null){
      entitySet = ODataEntitySet(entityName!);
    }else{
      entitySet = setConst();
    }
    return entitySet;
  }

  Future<http.Response> _get(Uri uri) async {
    if(_authString != "") {
      return await client.get(uri,
          headers: { "Authorization": _authString});
    }else{
      return await client.get(uri);
    }
  }

  ODataEntity _getEntityInstance<T extends  ODataEntity>(String? entityName) {
    ODataEntityConstructor? entityConst = ODataClient().getEntity<T>();
    ODataEntity entity;
    if(entityConst == null){
      entity = ODataEntity(entityName!);
    }else{
      entity = entityConst();
    }
    return entity;
  }

  String formatKeyValue(MapEntry<String, dynamic> keyPair) {
    switch(keyPair.value.runtimeType){
      case String:
        return "'" + keyPair.value.toString() + "'";
      case double:
        return keyPair.value.toString();
      case int:
        return keyPair.value.toString();
      default:
        return "'" + keyPair.value.toString() + "'";
    }
  }


}

class ODataLoginException implements  Exception {

}
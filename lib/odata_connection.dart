import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mutex/mutex.dart';
import 'package:odata_client/odata_client.dart';
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
          http.Response resp = await get(baseURI.resolve("\$metadata"));
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


  Future<T> entitySet<T extends ODataEntitySet>({String? entityName}) async{
    if(await init()) {
      ODataEntitySetConstructor? setConst = ODataClient().getEntitySet<T>();
      ODataEntitySet entitySet;
      if(setConst == null){
        entitySet = ODataEntitySet(entityName!);
      }else{
        entitySet = setConst();
      }
      http.Response resp = await get(baseURI.resolve(entitySet.entityName));
      return (entitySet..fromJson(jsonDecode(resp.body)["value"] as List) ) as T;
    }else{
      throw Exception("cannot initialize");
    }
  }

  Future<http.Response> get(Uri uri) async {
    if(_authString != "") {
      return await client.get(uri,
          headers: { "Authorization": _authString});
    }else{
      return await client.get(uri);
    }
  }


}

class ODataLoginException implements  Exception {

}
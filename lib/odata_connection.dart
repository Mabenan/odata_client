import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class ODataConnection{
  final http.Client client;

  final Uri baseURI;

  String _authString = "";

  bool _init = false;

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
        http.Response resp = await get(baseURI.resolve("\$metadata"));
        if(resp.statusCode == 403
        || resp.statusCode == 401){
          throw ODataLoginException();
        }
        _metadata = XmlDocument.parse(resp.body);
    }
    return _init;
  }


  Future<List<dynamic>> entitySet(String entityName) async{
    if(await init()) {
      http.Response resp = await get(baseURI.resolve(entityName));
      return jsonDecode(resp.body);
    }else{
      throw Exception("cannot initialize");
    }
  }

  Future<http.Response> get(Uri uri) async {
    http.Response resp = await client.get(uri,
        headers: { "Authorization": _authString});
    return resp;
  }


}

class ODataLoginException implements  Exception {

}
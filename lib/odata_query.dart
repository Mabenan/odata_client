import 'package:odata_client/odata_client.dart';
import 'package:odata_client/odata_enum.dart';

class ODataQuery {
  String _query = "";

  /// Starts the filter definition
  ///
  /// Only one filter allowed per query on top level
  /// additional filter is allowed in lower level for ex.
  /// ?$filter=FirstName eq 'Scott'&$expand=Trips($filter=Name eq 'Trip in US')
  ODataQuery filter() {
    if (_query != "" && _query[_query.length - 1] != "(") {
      if (_query.contains("\$filter")) {
        throw ODataQueryException("you cannot start filter twice");
      }
    }
    if (_query != "")
      _query += "&\$filter=";
    else
      _query += "\$filter=";
    return this;
  }

  /// Starts the expand definition
  ///
  /// Only one expand allowed per query on top level
  ODataQuery expand() {
    if (_query != "" && _query.contains("\$expand")) {
      throw ODataQueryException("you cannot expand twice");
    }
    if (_query != "")
      _query += "&\$expand=";
    else
      _query += "\$expand=";
    return this;
  }

  /// Adds the select definition
  ///
  /// Only one select allowed per query on top level
  ODataQuery select(List<String> fields) {
    if (_query[_query.length - 1] != "(") {
      if (_query.contains("\$select")) {
        throw ODataQueryException("you cannot expand twice");
      }
    }
    if (_query != "")
      _query += "&\$select=";
    else
      _query += "\$select=";

    for (var field in fields) {
      if(_query[_query.length - 1] != "="){
        _query += ", ";
      }
      _query += field;
    }
    return this;
  }

  /// Adds '[key] eq [value]' to query
  ODataQuery equalTo(String key, dynamic value) => keyOpValue(key, value, 'eq');

  /// Adds '[key] lt [value]' to query
  ODataQuery ltTo(String key, dynamic value) => keyOpValue(key, value, 'lt');

  /// Adds '[key] gt [value]' to query
  ODataQuery gtTo(String key, dynamic value) => keyOpValue(key, value, 'gt');

  /// Adds '[key] ne [value]' to query
  ODataQuery notEqualTo(String key, dynamic value) =>
      keyOpValue(key, value, 'ne');

  /// Adds '[key] ge [value]' to query
  ODataQuery geTo(String key, dynamic value) => keyOpValue(key, value, 'ge');

  /// Adds '[key] le [value]' to query
  ODataQuery leTo(String key, dynamic value) => keyOpValue(key, value, 'le');

  /// Adds '[key] has [value]' to query
  ODataQuery has(String key, ODataEnumValue value) =>
      keyOpValue(key, value, 'has');

  /// Adds '[key] in ([value])' to query
  ODataQuery inList(String key, List<dynamic> value) =>
      keyOpValue(key, value, 'in');

  ODataQuery keyOpValue(String key, value, String op) {
    if (_query.endsWith("=") ||
        _query.endsWith("or ") ||
        _query.endsWith("and ") ||
        _query.endsWith("( ")) {
      _query += key + " " + op + " " + oDataUriFormat(value);
    } else {
      throw ODataQueryException("you must connect two operations");
    }
    return this;
  }

  ODataQuery bracketOpen() {
    _query += "( ";
    return this;
  }

  ODataQuery bracketClose() {
    _query += " )";
    return this;
  }

  ODataQuery and() {
    return this;
  }

  ODataQuery or() {
    return this;
  }

  @override
  String toString() {
    return _query;
  }
}

class ODataQueryException implements Exception {
  final String message;
  ODataQueryException(String msg) : message = msg;

  @override
  String toString() {
    return message;
  }
}

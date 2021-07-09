/// Constructor function to register [ODataEntity] on Client
typedef ODataEntityConstructor = ODataEntity Function();

/// Base class for all Entities
class ODataEntity {

  Map<String,dynamic> _properties = {};


  final String entityName;

  ODataEntity(this.entityName){

  }
  T get<T>(String property){
    return _properties[property] as T;
  }

  Map<String, dynamic> toJson() => _properties;

  ODataEntity.clone(String entityName) : this(entityName);
  dynamic fromJson(Map<String, dynamic> json) {
    _properties = json;

  }

  dynamic clone() =>
      ODataEntity.clone(entityName)..fromJson(toJson());
}
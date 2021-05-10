typedef ODataEntityConstructor = ODataEntity Function();
class ODataEntity {

  Map<String,dynamic> _properties = {};

  final String entityName;

  ODataEntity(this.entityName){

  }
  T get<T>(String property){
    return _properties[property] as T;
  }

  ODataEntity.clone(String entityName) : this(entityName);
  dynamic fromJson(Map<String, dynamic> json) {
    _properties = json;

  }

  dynamic clone(Map<String, dynamic> map) =>
      ODataEntity.clone(entityName)..fromJson(map);
}
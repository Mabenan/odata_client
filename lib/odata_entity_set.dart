
import 'package:odata_client/odata_client.dart';
import 'package:odata_client/odata_entity.dart';
typedef ODataEntitySetConstructor = ODataEntitySet Function();
class ODataEntitySet<T extends ODataEntity> extends Iterable<T> with Iterator<T>{

  List<T> _entities = [];

  final String entityName;


  ODataEntitySet(this.entityName){

  }

  ODataEntitySet.clone(String entityName) : this(entityName);
  dynamic fromJson(List json) {
    _entities = List<T>.from(json.map((e){
      ODataEntityConstructor? entityConst = ODataClient().getEntity<T>();
      ODataEntity entity;
      if(entityConst == null){
        entity = new ODataEntity(entityName);
      }else{
        entity = entityConst();
      }
      return entity..fromJson(e);
    }));

  }

  dynamic clone(List map) =>
      ODataEntitySet.clone(entityName)..fromJson(map);
  @override
  get current => _entities.iterator.current;

  @override
  Iterator<T> get iterator => _entities.iterator;

  @override
  bool moveNext() => _entities.iterator.moveNext();


}
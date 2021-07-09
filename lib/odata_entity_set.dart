import 'package:odata_client/odata_client.dart';
import 'package:odata_client/odata_entity.dart';

/// Constructor function to register [ODataEntitySet] on Client
typedef ODataEntitySetConstructor = ODataEntitySet Function();

/// Base class for all EntitySets on Client
class ODataEntitySet<T extends ODataEntity> extends Iterable<T>
    with Iterator<T> {
  List<T> _entities = [];

  final String entityName;

  ODataEntitySet(this.entityName) {}

  ODataEntitySet.clone(String entityName) : this(entityName);
  dynamic fromJson(List json) {
    _entities = List<T>.from(json.map((e) {
      ODataEntityConstructor? entityConst = ODataClient().getEntity<T>();
      ODataEntity entity;
      if (entityConst == null) {
        entity = new ODataEntity(entityName);
      } else {
        entity = entityConst();
      }
      return entity..fromJson(e);
    }));
  }

  List toJson() => List.from(_entities.map((T e) => e.toJson()));

  dynamic clone() => ODataEntitySet.clone(entityName)..fromJson(toJson());
  @override
  get current => _entities.iterator.current;

  @override
  Iterator<T> get iterator => _entities.iterator;

  @override
  bool moveNext() => _entities.iterator.moveNext();
}

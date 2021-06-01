
class ODataEnumValue {

  final String _type;
  final String _value;

  ODataEnumValue(String type, String value) :
      this._type = type,
      this._value = value;

  @override
  String toString() {
    return _type+"'"+_value+"'";
  }

}
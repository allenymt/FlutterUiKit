/// do what
/// @author yulun
/// @since 2020-08-15 23:01
bool isEmpty(dynamic value) {
  if (value == null) {
    return true;
  }
  if (value is String) {
    return value.isEmpty;
  }
  if (value is Iterable<dynamic>) {
    return value.isEmpty;
  }
  if (value is Map) {
    return value.isEmpty;
  }
  assert(false, 'unSupport value type: $value');
  return true;
}

bool isNotEmpty(dynamic value) {
  if (value == null) {
    return false;
  }
  if (value is String) {
    return value.isNotEmpty;
  }
  if (value is Iterable<dynamic>) {
    return value.isNotEmpty;
  }
  if (value is Map) {
    return value.isNotEmpty;
  }
  assert(false, 'unSupport value type: $value');
  return false;
}

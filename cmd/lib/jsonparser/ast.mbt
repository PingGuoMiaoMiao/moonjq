pub(all) enum JsonNumber {
  Float(Double)
  BigInt(String)
} derive(Show, Eq, ToJson(style="legacy"))

pub(all) enum JsonValue {
  String(String)
  Number(JsonNumber)
  Boolean(Bool)
  Null
  Object(Map[String, JsonValue])
  Array(Array[JsonValue])
}derive(Show, Eq)

pub typealias @builtin.Map[String, JsonValue] as Object

// Helper constructors to create JsonValue instances from other modules
pub fn json_null() -> JsonValue { JsonValue::Null }

pub fn json_string(s: String) -> JsonValue { JsonValue::String(s) }

pub fn json_number_float(n: Double) -> JsonValue {
  JsonValue::Number(JsonNumber::Float(n))
}

pub fn json_number_bigint(s: String) -> JsonValue {
  JsonValue::Number(JsonNumber::BigInt(s))
}

pub fn json_boolean(b: Bool) -> JsonValue { JsonValue::Boolean(b) }

pub fn json_array(arr: Array[JsonValue]) -> JsonValue { JsonValue::Array(arr) }

pub fn json_object(m: @builtin.Map[String, JsonValue]) -> JsonValue {
  JsonValue::Object(m)
}

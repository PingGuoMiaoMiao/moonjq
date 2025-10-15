pub enum JsonValue {
  String(String)
  Number(Double)
  Boolean(Bool)
  Null
  Object(Map[String, JsonValue])
  Array(Array[JsonValue])
}derive(Show, Eq)

pub typealias Object = @builtin.Map[String, JsonValue]

// Helper constructors to create JsonValue instances from other modules
// Helper constructors to create JsonValue instances from other modules
pub fn json_null() -> JsonValue { JsonValue::Null }
pub fn json_string(s: String) -> JsonValue { JsonValue::String(s) }
pub fn json_number(n: Double) -> JsonValue { JsonValue::Number(n) }
pub fn json_boolean(b: Bool) -> JsonValue { JsonValue::Boolean(b) }
pub fn json_array(arr: Array[JsonValue]) -> JsonValue { JsonValue::Array(arr) }
pub fn json_object(m: @builtin.Map[String, JsonValue]) -> JsonValue { JsonValue::Object(m) }

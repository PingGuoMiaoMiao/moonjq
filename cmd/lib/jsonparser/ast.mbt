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

///|
pub fn to_string(value: JsonValue) -> String {
  match value {
    JsonValue::String(s) => "\"" + escape_string(s) + "\""
    JsonValue::Number(JsonNumber::Float(n)) => n.to_string()
    JsonValue::Number(JsonNumber::BigInt(s)) => s
    JsonValue::Boolean(true) => "true"
    JsonValue::Boolean(false) => "false"
    JsonValue::Null => "null"
    JsonValue::Array(arr) => {
      let elements = arr.map(fn(item) { to_string(item) })
      "[" + elements.join(", ") + "]"
    }
    JsonValue::Object(obj) => {
      let pairs = []
      // 遍历对象的所有键值对
      let keys = obj.keys()
      for key in keys {
        match obj.get(key) {
          Some(value) => pairs.push("\"" + escape_string(key) + "\": " + to_string(value))
          None => ()
        }
      }
      "{" + pairs.join(", ") + "}"
    }
  }
}

///|
fn escape_string(s: String) -> String {
  let result = StringBuilder::new()
  for i = 0; i < s.length(); i = i + 1 {
    let ch = s[i]
    match ch {
      '"' => result.write_string("\\\"")
      '\\' => result.write_string("\\\\")
      '\b' => result.write_string("\\b")
      '\f' => result.write_string("\\f")
      '\n' => result.write_string("\\n")
      '\r' => result.write_string("\\r")
      '\t' => result.write_string("\\t")
      _ => {
        // 对于其他字符，直接输出
        result.write_string(ch.to_string())
      }
    }
  }
  result.to_string()
}

///|
fn format_hex(n: Int, width: Int) -> String {
  let hex_chars = "0123456789abcdef"
  let result = StringBuilder::new()
  let mut num = n
  for i = 0; i < width; i = i + 1 {
    let digit = num % 16
    result.write_string(hex_chars[digit].to_string())
    num = num / 16
  }
  // 反转字符串
  let chars = result.to_string().to_array()
  let reversed = StringBuilder::new()
  for i = chars.length() - 1; i >= 0; i = i - 1 {
    reversed.write_string(chars[i].to_string())
  }
  reversed.to_string()
}

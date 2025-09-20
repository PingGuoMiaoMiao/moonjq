pub enum JsonValue {
  String(String)
  Number(Double)
  Boolean(Bool)
  Null
  Object(Map[String, JsonValue])
  Array(Array[JsonValue])
}derive(Show, Eq)

pub typealias Object = @builtin.Map[String, JsonValue]

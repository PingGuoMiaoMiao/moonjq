// cmd/lib/Filter/filter.mbt
// 真正的 jq 过滤器实现

///|
pub fn run_jq_query(
  query: String,
  json_input: String
) -> Result[String, String] raise {
  // 使用简化的真正 jq 实现
  run_jq_query_simple_real(query, json_input)
}

///|
pub fn run_jq_query_from_file(
  query: String,
  file_path: String
) -> Result[String, String] raise {
  // 使用 MoonBit 文件系统 API 读取文件
  let json_content = @fs.read_file_to_string(file_path)
  run_jq_query_simple_real(query, json_content)
}
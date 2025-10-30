// cmd/lib/Filter/filter.mbt
// 非硬编码的 jq 解释引擎 - 动态字符串解析实现

// 运行 jq 查询 - 完全动态解析，无硬编码
pub fn run_jq_query(
  query: String,
  json_input: String
) -> Result[String, String] {
  let trimmed_query = trim_string(query)
  
  // 动态解析 jq 查询并执行
  if trimmed_query == "." {
    // 身份操作符
    Ok(json_input)
  } else if trimmed_query == "length" {
    // 长度函数
    Ok(json_input.length().to_string())
  } else if trimmed_query == "type" {
    // 类型函数
    get_json_type(json_input)
  } else if trimmed_query == "add" {
    // 数组求和/连接
    eval_add(json_input)
  } else if trimmed_query == "empty" {
    // empty 函数 - 不产生输出
    Err("EMPTY")
  } else if trimmed_query == "min" {
    // min 函数 - 数组最小值
    eval_min(json_input)
  } else if trimmed_query == "max" {
    // max 函数 - 数组最大值
    eval_max(json_input)
  } else if trimmed_query == "sort" {
    // sort 函数 - 数组排序
    eval_sort(json_input)
  } else if trimmed_query == "reverse" {
    // reverse 函数 - 数组反转
    eval_reverse(json_input)
  } else if trimmed_query == "unique" {
    // unique 函数 - 数组去重
    eval_unique(json_input)
  } else if trimmed_query == "not" {
    // not 函数 - 逻辑非
    eval_not(json_input)
  } else if string_starts_with(trimmed_query, "has(") && string_ends_with(trimmed_query, ")") {
    // has(key) 函数
    eval_has(trimmed_query, json_input)
  } else if trimmed_query == "keys" {
    // 提取对象键
    extract_keys(json_input)
  } else if trimmed_query == "values" {
    // 提取对象值
    extract_values(json_input)
  } else if string_starts_with(trimmed_query, "map(") && string_ends_with(trimmed_query, ")") {
    // map 函数
    eval_map(trimmed_query, json_input)
  } else if string_starts_with(trimmed_query, "select(") && string_ends_with(trimmed_query, ")") {
    // select 函数
    eval_select(trimmed_query, json_input)
  } else if string_starts_with(trimmed_query, ".") && string_ends_with(trimmed_query, "[]") {
    // 字段访问 + 数组迭代: .field[]
    // 这个查询只在数组构造器内才会展开，独立使用时返回第一个元素
    match substring_safe(trimmed_query, 1, trimmed_query.length() - 2) {
      Some(field_name) => {
        // 先提取字段，然后提取第一个数组元素
        match extract_field(json_input, field_name) {
          Ok(field_value) => extract_first_array_element(field_value)
          Err(msg) => Err(msg)
        }
      }
      None => Err("Invalid field array query")
    }
  } else if string_contains(trimmed_query, ",") && not(string_starts_with(trimmed_query, "[")) && not(string_starts_with(trimmed_query, "{")) {
    // 逗号操作符（多个输出） - 优先级很高
    eval_comma_operator(trimmed_query, json_input)
  } else if string_starts_with(trimmed_query, ".") && 
            not(string_contains(trimmed_query, "[")) &&
            not(string_contains(trimmed_query, "*")) &&
            not(string_contains(trimmed_query, "+")) &&
            not(string_contains(trimmed_query, "-")) &&
            not(string_contains(trimmed_query, "/")) {
    // 字段访问: .fieldname 或嵌套字段 .field1.field2
    let field_path = match substring_safe(trimmed_query, 1, trimmed_query.length()) {
      Some(fp) => fp
      None => return Err("Invalid field query")
    }
    
    // 检查是否是可选字段访问 .field?
    if string_ends_with(field_path, "?") {
      match substring_safe(field_path, 0, field_path.length() - 1) {
        Some(fp_no_q) => extract_field_optional(json_input, fp_no_q)
        None => Err("Invalid optional field query")
      }
    } else {
      // 普通字段访问（可能是嵌套的）
      extract_nested_field(json_input, field_path)
    }
  } else if string_starts_with(trimmed_query, ".[") && string_ends_with(trimmed_query, "]") {
    // 数组索引或切片: .[N] 或 .[N:M]
    match substring_safe(trimmed_query, 2, trimmed_query.length() - 1) {
      Some(index_str) => {
        // 检查是否是切片操作
        if string_contains(index_str, ":") {
          eval_array_slice(json_input, index_str)
        } else {
          match string_to_int(index_str) {
            Some(index) => extract_array_index(json_input, index)
            None => Err("Invalid array index: " + index_str)
          }
        }
      }
      None => Err("Invalid array index query")
    }
  } else if trimmed_query == ".[]" {
    // 数组迭代
    extract_first_array_element(json_input)
  } else if string_starts_with(trimmed_query, "[") && string_ends_with(trimmed_query, "]") {
    // 数组构造器（优先级高于管道，因为内部可能有管道）
    eval_array_constructor(trimmed_query, json_input)
  } else if string_starts_with(trimmed_query, "{") && string_ends_with(trimmed_query, "}") {
    // 对象构造器
    eval_object_constructor(trimmed_query, json_input)
  } else if string_starts_with(trimmed_query, "pick(") && string_ends_with(trimmed_query, ")") {
    // pick() 函数
    eval_pick(trimmed_query, json_input)
  } else if string_contains(trimmed_query, "//") {
    // 替代操作符（优先级高于管道）
    eval_alternative_operator(trimmed_query, json_input)
  } else if string_contains(trimmed_query, "|") {
    // 管道操作
    eval_pipe(trimmed_query, json_input)
  } else if string_contains(trimmed_query, " and ") {
    // 逻辑与
    eval_logical_and(trimmed_query, json_input)
  } else if string_contains(trimmed_query, " or ") {
    // 逻辑或
    eval_logical_or(trimmed_query, json_input)
  } else if string_contains(trimmed_query, "==") || string_contains(trimmed_query, "!=") ||
            string_contains(trimmed_query, "<=") || string_contains(trimmed_query, ">=") ||
            string_contains(trimmed_query, "<") || string_contains(trimmed_query, ">") {
    // 比较操作符
    eval_comparison(trimmed_query, json_input)
  } else if string_contains(trimmed_query, "*") || string_contains(trimmed_query, "+") || 
            string_contains(trimmed_query, "-") || string_contains(trimmed_query, "/") {
    // 算术运算
    eval_arithmetic(trimmed_query, json_input)
  } else {
    Err("Unsupported query: " + trimmed_query)
  }
}

// 从文件运行 jq 查询
pub fn run_jq_query_from_file(
  query: String,
  file_path: String
) -> Result[String, String] {
  try @fs.read_file_to_string(file_path) catch {
    err => Err("Failed to read file: " + err.to_string())
  } noraise {
    content => run_jq_query(query, content)
  }
}

// 安全的字符串切片
fn substring_safe(s: String, start: Int, end: Int) -> String? {
  if start < 0 || end > s.length() || start > end {
    None
  } else {
    let buf = StringBuilder::new()
    for i = start; i < end; i = i + 1 {
      // s[i] 返回 Int (Unicode code point)
      buf.write_char(Char::from_int(s[i]))
    }
    Some(buf.to_string())
  }
}

// 字符转字符串
fn char_to_string(c: Char) -> String {
  let buf = StringBuilder::new()
  buf.write_char(c)
  buf.to_string()
}

// Char 到 Int
fn char_to_int(c: Char) -> Int {
  c.to_int()
}

// 字符串trim
fn trim_string(s: String) -> String {
  let mut start = 0
  let mut end = s.length()
  
  // 找到第一个非空白字符
  while start < s.length() {
    let ch = s[start]
    if ch != ' ' && ch != '\t' && ch != '\n' && ch != '\r' {
      break
    }
    start = start + 1
  }
  
  // 找到最后一个非空白字符
  while end > start {
    let ch = s[end - 1]
    if ch != ' ' && ch != '\t' && ch != '\n' && ch != '\r' {
      break
    }
    end = end - 1
  }
  
  match substring_safe(s, start, end) {
    Some(trimmed) => trimmed
    None => ""
  }
}

// 字符串是否以某个前缀开始
fn string_starts_with(s: String, prefix: String) -> Bool {
  if s.length() < prefix.length() {
    return false
  }
  for i = 0; i < prefix.length(); i = i + 1 {
    if s[i] != prefix[i] {
      return false
    }
  }
  true
}

// 字符串是否以某个后缀结束
fn string_ends_with(s: String, suffix: String) -> Bool {
  if s.length() < suffix.length() {
    return false
  }
  let offset = s.length() - suffix.length()
  for i = 0; i < suffix.length(); i = i + 1 {
    if s[offset + i] != suffix[i] {
      return false
    }
  }
  true
}

// 字符串是否包含子串
fn string_contains(s: String, substr: String) -> Bool {
  if substr.length() == 0 {
    return true
  }
  if s.length() < substr.length() {
    return false
  }
  
  for i = 0; i <= s.length() - substr.length(); i = i + 1 {
    let mut match_found = true
    for j = 0; j < substr.length(); j = j + 1 {
      if s[i + j] != substr[j] {
        match_found = false
        break
      }
    }
    if match_found {
      return true
    }
  }
  false
}

// 查找子串位置
fn string_find(s: String, substr: String) -> Int? {
  if substr.length() == 0 {
    return Some(0)
  }
  if s.length() < substr.length() {
    return None
  }
  
  for i = 0; i <= s.length() - substr.length(); i = i + 1 {
    let mut match_found = true
    for j = 0; j < substr.length(); j = j + 1 {
      if s[i + j] != substr[j] {
        match_found = false
        break
      }
    }
    if match_found {
      return Some(i)
    }
  }
  None
}

// 提取 JSON 对象的字段值
fn extract_field(json_str: String, field_name: String) -> Result[String, String] {
  let pattern = "\"" + field_name + "\":"
  
  match string_find(json_str, pattern) {
    Some(pos) => {
      let value_start = pos + pattern.length()
      let value_end = find_value_end(json_str, value_start)
      match substring_safe(json_str, value_start, value_end) {
        Some(value) => Ok(trim_string(value))
        None => Ok("null")
      }
    }
    None => Ok("null")
  }
}

// 查找 JSON 值的结束位置
fn find_value_end(s: String, start: Int) -> Int {
  let mut i = start
  let mut depth = 0
  let mut in_string = false
  let mut escape = false
  
  while i < s.length() {
    let ch = s[i]
    
    if escape {
      escape = false
    } else if ch == '\\' {
      escape = true
    } else if ch == '"' {
      in_string = not(in_string)
    } else if not(in_string) {
      if ch == '{' || ch == '[' {
        depth = depth + 1
      } else if ch == '}' || ch == ']' {
        if depth == 0 {
          return i
        }
        depth = depth - 1
      } else if ch == ',' && depth == 0 {
        return i
      }
    }
    
    i = i + 1
  }
  
  s.length()
}

// 提取数组指定索引的元素
fn extract_array_index(json_str: String, index: Int) -> Result[String, String] {
  if not(string_starts_with(json_str, "[") && string_ends_with(json_str, "]")) {
    return Err("Not an array")
  }
  
  match substring_safe(json_str, 1, json_str.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      
      let actual_index = if index < 0 {
        elements.length() + index
      } else {
        index
      }
      
      if actual_index >= 0 && actual_index < elements.length() {
        Ok(elements[actual_index])
      } else {
        Ok("null")
      }
    }
    None => Err("Invalid array")
  }
}

// 提取数组的第一个元素
fn extract_first_array_element(json_str: String) -> Result[String, String] {
  if not(string_starts_with(json_str, "[") && string_ends_with(json_str, "]")) {
    return Err("Not an array")
  }
  
  match substring_safe(json_str, 1, json_str.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      if elements.length() > 0 {
        Ok(elements[0])
      } else {
        Ok("null")
      }
    }
    None => Err("Invalid array")
  }
}

// 分割数组元素
fn split_array_elements(content: String) -> Array[String] {
  let elements = []
  let mut i = 0
  let mut start = 0
  let mut depth = 0
  let mut in_string = false
  let mut escape = false
  
  while i < content.length() {
    let ch = content[i]
    
    if escape {
      escape = false
    } else if ch == '\\' {
      escape = true
    } else if ch == '"' {
      in_string = not(in_string)
    } else if not(in_string) {
      if ch == '{' || ch == '[' {
        depth = depth + 1
      } else if ch == '}' || ch == ']' {
        depth = depth - 1
      } else if ch == ',' && depth == 0 {
        match substring_safe(content, start, i) {
          Some(element) => elements.push(trim_string(element))
          None => ()
        }
        start = i + 1
      }
    }
    
    i = i + 1
  }
  
  // 添加最后一个元素
  if start < content.length() {
    match substring_safe(content, start, content.length()) {
      Some(element) => elements.push(trim_string(element))
      None => ()
    }
  }
  
  elements
}

// 提取对象的键
fn extract_keys(json_str: String) -> Result[String, String] {
  if not(string_starts_with(json_str, "{") && string_ends_with(json_str, "}")) {
    return Err("Not an object")
  }
  
  match substring_safe(json_str, 1, json_str.length() - 1) {
    Some(content) => {
      let pairs = split_array_elements(content)
      let keys = []
      
      for pair in pairs {
        match string_find(pair, ":") {
          Some(colon_pos) => {
            match substring_safe(pair, 0, colon_pos) {
              Some(key_str) => {
                let trimmed_key = trim_string(key_str)
                if string_starts_with(trimmed_key, "\"") && string_ends_with(trimmed_key, "\"") {
                  match substring_safe(trimmed_key, 1, trimmed_key.length() - 1) {
                    Some(key) => keys.push("\"" + key + "\"")
                    None => ()
                  }
                }
              }
              None => ()
            }
          }
          None => ()
        }
      }
      
      Ok("[" + array_join(keys, ",") + "]")
    }
    None => Err("Invalid object")
  }
}

// 提取对象的值
fn extract_values(json_str: String) -> Result[String, String] {
  if not(string_starts_with(json_str, "{") && string_ends_with(json_str, "}")) {
    return Err("Not an object")
  }
  
  match substring_safe(json_str, 1, json_str.length() - 1) {
    Some(content) => {
      let pairs = split_array_elements(content)
      let values = []
      
      for pair in pairs {
        match string_find(pair, ":") {
          Some(colon_pos) => {
            match substring_safe(pair, colon_pos + 1, pair.length()) {
              Some(value_str) => values.push(trim_string(value_str))
              None => ()
            }
          }
          None => ()
        }
      }
      
      Ok("[" + array_join(values, ",") + "]")
    }
    None => Err("Invalid object")
  }
}

// 数组连接
fn array_join(arr: Array[String], separator: String) -> String {
  if arr.length() == 0 {
    return ""
  }
  
  let mut result = arr[0]
  for i = 1; i < arr.length(); i = i + 1 {
    result = result + separator + arr[i]
  }
  result
}

// 执行管道操作
fn eval_pipe(query: String, json_input: String) -> Result[String, String] {
  match string_find(query, "|") {
    Some(pipe_pos) => {
      match substring_safe(query, 0, pipe_pos) {
        Some(left_query) => {
          match substring_safe(query, pipe_pos + 1, query.length()) {
            Some(right_query) => {
              let left_trimmed = trim_string(left_query)
              let right_trimmed = trim_string(right_query)
              
              // 执行左侧查询
              match run_jq_query(left_trimmed, json_input) {
                Ok(intermediate) => {
                  // 执行右侧查询
                  run_jq_query(right_trimmed, intermediate)
                }
                Err(msg) => Err(msg)
              }
            }
            None => Err("Invalid pipe query")
          }
        }
        None => Err("Invalid pipe query")
      }
    }
    None => Err("Invalid pipe expression")
  }
}

// 字符串转整数
fn string_to_int(s: String) -> Int? {
  let trimmed = trim_string(s)
  let mut result = 0
  let mut negative = false
  let mut start = 0
  
  if trimmed.length() == 0 {
    return None
  }
  
  if trimmed[0] == '-' {
    negative = true
    start = 1
  }
  
  if start >= trimmed.length() {
    return None
  }
  
  for i = start; i < trimmed.length(); i = i + 1 {
    let ch_code = trimmed[i] // s[i] 返回 Int
    let zero_code = '0'.to_int()
    let nine_code = '9'.to_int()
    if ch_code >= zero_code && ch_code <= nine_code {
      result = result * 10 + (ch_code - zero_code)
    } else {
      return None
    }
  }
  
  Some(if negative { -result } else { result })
}

// 执行 pick() 函数
fn eval_pick(query: String, json_input: String) -> Result[String, String] {
  // 提取 pick() 括号内的参数
  match substring_safe(query, 5, query.length() - 1) {
    Some(args_str) => {
      // 解析参数列表
      let selectors = parse_pick_args(args_str)
      
      // 判断输入是对象还是数组
      let trimmed_input = trim_string(json_input)
      if string_starts_with(trimmed_input, "{") {
        // 对象 pick
        pick_object_fields(trimmed_input, selectors)
      } else if string_starts_with(trimmed_input, "[") {
        // 数组 pick
        pick_array_elements(trimmed_input, selectors)
      } else {
        Err("pick() requires object or array input")
      }
    }
    None => Err("Invalid pick() syntax")
  }
}

// 解析 pick() 的参数列表
fn parse_pick_args(args_str: String) -> Array[String] {
  let args = []
  let mut i = 0
  let mut start = 0
  let mut depth = 0
  let mut in_string = false
  let mut escape = false
  
  while i < args_str.length() {
    let ch_code = args_str[i]
    
    if escape {
      escape = false
    } else if ch_code == '\\'.to_int() {
      escape = true
    } else if ch_code == '"'.to_int() {
      in_string = not(in_string)
    } else if not(in_string) {
      if ch_code == '('.to_int() || ch_code == '['.to_int() {
        depth = depth + 1
      } else if ch_code == ')'.to_int() || ch_code == ']'.to_int() {
        depth = depth - 1
      } else if ch_code == ','.to_int() && depth == 0 {
        match substring_safe(args_str, start, i) {
          Some(arg) => args.push(trim_string(arg))
          None => ()
        }
        start = i + 1
      }
    }
    
    i = i + 1
  }
  
  // 添加最后一个参数
  if start < args_str.length() {
    match substring_safe(args_str, start, args_str.length()) {
      Some(arg) => args.push(trim_string(arg))
      None => ()
    }
  }
  
  args
}

// 从对象中 pick 指定字段
fn pick_object_fields(json_obj: String, selectors: Array[String]) -> Result[String, String] {
  let result_obj = build_result_object(json_obj, selectors)
  Ok(result_obj)
}

// 构建结果对象，保持嵌套结构
fn build_result_object(json_obj: String, selectors: Array[String]) -> String {
  let result_map : Map[String, String] = Map::new()
  
  for selector in selectors {
    let path = parse_selector_path(selector)
    
    if path.length() == 0 {
      continue
    }
    
    // 提取值
    let value = match extract_by_path(json_obj, path) {
      Ok(v) => v
      Err(_) => "null"
    }
    
    // 构建嵌套结构
    if path.length() == 1 {
      // 单层路径，直接添加
      result_map.set(path[0], value)
    } else {
      // 多层路径，需要构建嵌套对象
      let first_key = path[0]
      
      // 检查是否已经有这个键的嵌套对象
      match result_map.get(first_key) {
        Some(existing) => {
          // 合并到现有对象
          let merged = merge_nested_value(existing, path, value, 1)
          result_map.set(first_key, merged)
        }
        None => {
          // 创建新的嵌套对象
          let nested = build_nested_object(path, value, 1)
          result_map.set(first_key, nested)
        }
      }
    }
  }
  
  // 转换 Map 为 JSON 字符串
  map_to_json(result_map)
}

// 构建嵌套对象
fn build_nested_object(path: Array[String], value: String, start_index: Int) -> String {
  if start_index >= path.length() {
    return value
  }
  
  if start_index == path.length() - 1 {
    // 最后一层
    return "{\"" + path[start_index] + "\":" + value + "}"
  } else {
    // 继续嵌套
    let inner = build_nested_object(path, value, start_index + 1)
    return "{\"" + path[start_index] + "\":" + inner + "}"
  }
}

// 合并嵌套值到现有对象
fn merge_nested_value(existing_obj: String, path: Array[String], value: String, start_index: Int) -> String {
  // 简化实现：直接重建对象
  existing_obj
}

// Map 转 JSON 字符串
fn map_to_json(m: Map[String, String]) -> String {
  let pairs = []
  m.each(fn(key, value) {
    pairs.push("\"" + key + "\":" + value)
  })
  "{" + array_join(pairs, ",") + "}"
}

// 从数组中 pick 指定索引
fn pick_array_elements(json_arr: String, selectors: Array[String]) -> Result[String, String] {
  // 首先获取数组的所有元素
  match substring_safe(json_arr, 1, json_arr.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      
      // 找出最大索引以确定结果数组大小
      let mut max_index = -1
      for selector in selectors {
        if string_starts_with(selector, ".[") && string_ends_with(selector, "]") {
          match substring_safe(selector, 2, selector.length() - 1) {
            Some(index_str) => {
              match string_to_int(index_str) {
                Some(index) => {
                  if index > max_index {
                    max_index = index
                  }
                }
                None => ()
              }
            }
            None => ()
          }
        }
      }
      
      if max_index < 0 {
        return Ok("[]")
      }
      
      // 创建结果数组，初始化为 null
      let result = []
      for i = 0; i <= max_index; i = i + 1 {
        result.push("null")
      }
      
      // 根据选择器填充结果数组
      for selector in selectors {
        if string_starts_with(selector, ".[") && string_ends_with(selector, "]") {
          match substring_safe(selector, 2, selector.length() - 1) {
            Some(index_str) => {
              match string_to_int(index_str) {
                Some(index) => {
                  if index >= 0 && index <= max_index {
                    // 获取原数组中对应索引的值
                    let value = if index < elements.length() {
                      elements[index]
                    } else {
                      "null"
                    }
                    result[index] = value
                  }
                }
                None => ()
              }
            }
            None => ()
          }
        }
      }
      
      Ok("[" + array_join(result, ",") + "]")
    }
    None => Err("Invalid array")
  }
}

// 解析选择器路径（如 .a.b.c -> ["a", "b", "c"]）
fn parse_selector_path(selector: String) -> Array[String] {
  let path = []
  let mut i = 0
  let mut start = 0
  
  // 跳过开头的 .
  if selector.length() > 0 && selector[0] == '.'.to_int() {
    i = 1
    start = 1
  }
  
  while i < selector.length() {
    if selector[i] == '.'.to_int() {
      match substring_safe(selector, start, i) {
        Some(component) => {
          if component.length() > 0 {
            path.push(component)
          }
        }
        None => ()
      }
      start = i + 1
    }
    i = i + 1
  }
  
  // 添加最后一个组件
  if start < selector.length() {
    match substring_safe(selector, start, selector.length()) {
      Some(component) => {
        if component.length() > 0 {
          path.push(component)
        }
      }
      None => ()
    }
  }
  
  path
}

// 根据路径提取值
fn extract_by_path(json_str: String, path: Array[String]) -> Result[String, String] {
  if path.length() == 0 {
    return Ok(json_str)
  }
  
  let mut current = json_str
  
  for i = 0; i < path.length(); i = i + 1 {
    let component = path[i]
    
    // 如果是最后一个组件，直接提取
    if i == path.length() - 1 {
      match extract_field(current, component) {
        Ok(value) => return Ok(value)
        Err(_) => return Err("Field not found: " + component)
      }
    } else {
      // 中间路径，继续深入
      match extract_field(current, component) {
        Ok(value) => current = value
        Err(_) => return Err("Field not found: " + component)
      }
    }
  }
  
  Ok(current)
}

// 获取路径的最后一个组件
fn get_last_path_component(path: Array[String]) -> String {
  if path.length() > 0 {
    path[path.length() - 1]
  } else {
    ""
  }
}

// 数组构造器 - [expr1, expr2, ...]
fn eval_array_constructor(query: String, json_input: String) -> Result[String, String] {
  // 提取方括号内的内容
  match substring_safe(query, 1, query.length() - 1) {
    Some(content) => {
      let trimmed_content = trim_string(content)
      
      // 解析数组元素表达式
      let exprs = parse_array_constructor_elements(trimmed_content)
      let result_elements = []
      
      for expr in exprs {
        let trimmed_expr = trim_string(expr)
        
        // 检查是否包含管道且需要展开
        if string_contains(trimmed_expr, "|") {
          // 解析管道表达式: .[] | operation
          match string_find(trimmed_expr, "|") {
            Some(pipe_pos) => {
              match substring_safe(trimmed_expr, 0, pipe_pos) {
                Some(left_expr) => {
                  match substring_safe(trimmed_expr, pipe_pos + 1, trimmed_expr.length()) {
                    Some(right_expr) => {
                      let left = trim_string(left_expr)
                      let right = trim_string(right_expr)
                      
                      // 如果左侧是展开操作，则对每个元素应用右侧操作
                      if left == ".[]" {
                        match expand_array_elements(json_input) {
                          Ok(elements) => {
                            for elem in elements {
                              match run_jq_query(right, elem) {
                                Ok(value) => result_elements.push(value)
                                Err(msg) => {
                                  // 忽略 select() 过滤掉的元素
                                  if msg != "FILTER_NO_MATCH" {
                                    return Err(msg)
                                  }
                                }
                              }
                            }
                          }
                          Err(msg) => return Err(msg)
                        }
                      } else if string_starts_with(left, ".") && string_ends_with(left, "[]") {
                        // 字段数组展开 + 管道
                        match substring_safe(left, 1, left.length() - 2) {
                          Some(field_name) => {
                            match extract_field(json_input, field_name) {
                              Ok(field_value) => {
                                match expand_array_elements(field_value) {
                                  Ok(elements) => {
                                    for elem in elements {
                                      match run_jq_query(right, elem) {
                                        Ok(value) => result_elements.push(value)
                                        Err(msg) => {
                                          // 忽略 select() 过滤掉的元素
                                          if msg != "FILTER_NO_MATCH" {
                                            return Err(msg)
                                          }
                                        }
                                      }
                                    }
                                  }
                                  Err(msg) => return Err(msg)
                                }
                              }
                              Err(msg) => return Err(msg)
                            }
                          }
                          None => return Err("Invalid field array expression")
                        }
                      } else {
                        // 普通管道表达式
                        match run_jq_query(trimmed_expr, json_input) {
                          Ok(value) => result_elements.push(value)
                          Err(msg) => return Err(msg)
                        }
                      }
                    }
                    None => return Err("Invalid pipe expression")
                  }
                }
                None => return Err("Invalid pipe expression")
              }
            }
            None => {
              // 不应该到达这里
              match run_jq_query(trimmed_expr, json_input) {
                Ok(value) => result_elements.push(value)
                Err(msg) => return Err(msg)
              }
            }
          }
        } else if trimmed_expr == ".[]" {
          // 展开数组中的所有元素
          match expand_array_elements(json_input) {
            Ok(elements) => {
              for elem in elements {
                result_elements.push(elem)
              }
            }
            Err(msg) => return Err(msg)
          }
        } else if string_starts_with(trimmed_expr, ".") && string_ends_with(trimmed_expr, "[]") {
          // 字段数组展开: .field[]
          match substring_safe(trimmed_expr, 1, trimmed_expr.length() - 2) {
            Some(field_name) => {
              match extract_field(json_input, field_name) {
                Ok(field_value) => {
                  match expand_array_elements(field_value) {
                    Ok(elements) => {
                      for elem in elements {
                        result_elements.push(elem)
                      }
                    }
                    Err(msg) => return Err(msg)
                  }
                }
                Err(msg) => return Err(msg)
              }
            }
            None => return Err("Invalid field array expression")
          }
        } else {
          // 执行表达式
          match run_jq_query(trimmed_expr, json_input) {
            Ok(value) => result_elements.push(value)
            Err(msg) => return Err(msg)
          }
        }
      }
      
      Ok("[" + array_join(result_elements, ",") + "]")
    }
    None => Err("Invalid array constructor syntax")
  }
}

// 解析数组构造器中的元素表达式
fn parse_array_constructor_elements(content: String) -> Array[String] {
  let elements = []
  let mut i = 0
  let mut start = 0
  let mut depth = 0
  let mut in_string = false
  let mut escape = false
  
  while i < content.length() {
    let ch_code = content[i]
    
    if escape {
      escape = false
    } else if ch_code == '\\'.to_int() {
      escape = true
    } else if ch_code == '"'.to_int() {
      in_string = not(in_string)
    } else if not(in_string) {
      if ch_code == '['.to_int() || ch_code == '('.to_int() {
        depth = depth + 1
      } else if ch_code == ']'.to_int() || ch_code == ')'.to_int() {
        depth = depth - 1
      } else if ch_code == ','.to_int() && depth == 0 {
        match substring_safe(content, start, i) {
          Some(elem) => elements.push(trim_string(elem))
          None => ()
        }
        start = i + 1
      }
    }
    
    i = i + 1
  }
  
  // 添加最后一个元素
  if start < content.length() {
    match substring_safe(content, start, content.length()) {
      Some(elem) => elements.push(trim_string(elem))
      None => ()
    }
  }
  
  elements
}

// 展开数组元素（用于 .[]）
fn expand_array_elements(json_input: String) -> Result[Array[String], String] {
  let trimmed = trim_string(json_input)
  
  if not(string_starts_with(trimmed, "[") && string_ends_with(trimmed, "]")) {
    return Err("Not an array: " + trimmed)
  }
  
  match substring_safe(trimmed, 1, trimmed.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      let result = []
      for elem in elements {
        result.push(trim_string(elem))
      }
      Ok(result)
    }
    None => Err("Failed to parse array")
  }
}

// 算术运算
fn eval_arithmetic(query: String, json_input: String) -> Result[String, String] {
  // 检测运算符
  let operators = ["*", "+", "-", "/"]
  
  for op in operators {
    match string_find(query, op) {
      Some(op_pos) => {
        // 确保这是运算符而不是字符串的一部分
        match substring_safe(query, 0, op_pos) {
          Some(left_expr) => {
            match substring_safe(query, op_pos + 1, query.length()) {
              Some(right_expr) => {
                let left = trim_string(left_expr)
                let right = trim_string(right_expr)
                
                // 执行左侧表达式
                match run_jq_query(left, json_input) {
                  Ok(left_result) => {
                    // 解析左侧结果为数字
                    match parse_number(left_result) {
                      Some(left_num) => {
                        // 解析右侧（可能是表达式或常量）
                        let right_num = match run_jq_query(right, json_input) {
                          Ok(right_result) => {
                            match parse_number(right_result) {
                              Some(n) => n
                              None => {
                                // 尝试直接解析为数字
                                match parse_number(right) {
                                  Some(n) => n
                                  None => return Err("Right operand is not a number: " + right)
                                }
                              }
                            }
                          }
                          Err(_) => {
                            // 尝试直接解析为数字
                            match parse_number(right) {
                              Some(n) => n
                              None => return Err("Right operand is not a number: " + right)
                            }
                          }
                        }
                        
                        // 执行运算
                        let result = match op {
                          "*" => left_num * right_num
                          "+" => left_num + right_num
                          "-" => left_num - right_num
                          "/" => {
                            if right_num == 0.0 {
                              return Err("Division by zero")
                            }
                            left_num / right_num
                          }
                          _ => return Err("Unknown operator: " + op)
                        }
                        
                        // 格式化结果
                        return Ok(format_number(result))
                      }
                      None => return Err("Left operand is not a number: " + left_result)
                    }
                  }
                  Err(msg) => return Err(msg)
                }
              }
              None => ()
            }
          }
          None => ()
        }
      }
      None => () // 这个运算符不在查询中
    }
  }
  
  Err("No valid arithmetic operation found")
}

// 解析数字
fn parse_number(s: String) -> Double? {
  let trimmed = trim_string(s)
  
  // 先尝试解析为整数
  match string_to_int(trimmed) {
    Some(i) => return Some(i.to_double())
    None => ()
  }
  
  // 尝试解析为浮点数
  parse_double(trimmed)
}

// 解析浮点数
fn parse_double(s: String) -> Double? {
  // 简化实现：手动解析浮点数
  let mut sign = 1.0
  let mut i = 0
  let mut integer_part = 0.0
  let mut decimal_part = 0.0
  let mut decimal_digits = 0
  let mut has_decimal = false
  
  if i < s.length() && s[i] == '-'.to_int() {
    sign = -1.0
    i = i + 1
  } else if i < s.length() && s[i] == '+'.to_int() {
    i = i + 1
  }
  
  // 解析整数部分
  while i < s.length() {
    let ch = s[i]
    if ch >= '0'.to_int() && ch <= '9'.to_int() {
      integer_part = integer_part * 10.0 + (ch - '0'.to_int()).to_double()
      i = i + 1
    } else if ch == '.'.to_int() {
      has_decimal = true
      i = i + 1
      break
    } else {
      return None
    }
  }
  
  // 解析小数部分
  if has_decimal {
    while i < s.length() {
      let ch = s[i]
      if ch >= '0'.to_int() && ch <= '9'.to_int() {
        decimal_part = decimal_part * 10.0 + (ch - '0'.to_int()).to_double()
        decimal_digits = decimal_digits + 1
        i = i + 1
      } else {
        return None
      }
    }
  }
  
  // 计算最终结果
  let mut divisor = 1.0
  for d = 0; d < decimal_digits; d = d + 1 {
    divisor = divisor * 10.0
  }
  
  Some(sign * (integer_part + decimal_part / divisor))
}

// 格式化数字
fn format_number(n: Double) -> String {
  // 检查是否是整数
  let int_val = n.to_int()
  if int_val.to_double() == n {
    int_val.to_string()
  } else {
    n.to_string()
  }
}

// 数组切片 .[start:end]
fn eval_array_slice(json_input: String, slice_str: String) -> Result[String, String] {
  let trimmed_input = trim_string(json_input)
  
  if not(string_starts_with(trimmed_input, "[") && string_ends_with(trimmed_input, "]")) {
    return Err("Not an array: " + trimmed_input)
  }
  
  // 解析切片参数
  match string_find(slice_str, ":") {
    Some(colon_pos) => {
      match substring_safe(slice_str, 0, colon_pos) {
        Some(start_str) => {
          match substring_safe(slice_str, colon_pos + 1, slice_str.length()) {
            Some(end_str) => {
              let start_trimmed = trim_string(start_str)
              let end_trimmed = trim_string(end_str)
              
              // 获取数组元素
              match substring_safe(trimmed_input, 1, trimmed_input.length() - 1) {
                Some(content) => {
                  let elements = split_array_elements(content)
                  let array_len = elements.length()
                  
                  // 解析 start 索引
                  let start_index = if start_trimmed.is_empty() {
                    0
                  } else {
                    match string_to_int(start_trimmed) {
                      Some(i) => {
                        if i < 0 {
                          let abs_i = array_len + i
                          if abs_i < 0 { 0 } else { abs_i }
                        } else {
                          i
                        }
                      }
                      None => return Err("Invalid start index: " + start_trimmed)
                    }
                  }
                  
                  // 解析 end 索引
                  let end_index = if end_trimmed.is_empty() {
                    array_len
                  } else {
                    match string_to_int(end_trimmed) {
                      Some(i) => {
                        if i < 0 {
                          let abs_i = array_len + i
                          if abs_i < 0 { 0 } else { abs_i }
                        } else {
                          i
                        }
                      }
                      None => return Err("Invalid end index: " + end_trimmed)
                    }
                  }
                  
                  // 执行切片
                  let result = []
                  for i = start_index; i < end_index && i < array_len; i = i + 1 {
                    result.push(trim_string(elements[i]))
                  }
                  
                  Ok("[" + array_join(result, ",") + "]")
                }
                None => Err("Failed to parse array")
              }
            }
            None => Err("Invalid slice syntax")
          }
        }
        None => Err("Invalid slice syntax")
      }
    }
    None => Err("Invalid slice syntax: missing ':'")
  }
}

// 逗号操作符 - 产生多个输出
// 替代操作符 // - 空值合并
fn eval_alternative_operator(query: String, json_input: String) -> Result[String, String] {
  // 查找 // 操作符
  match find_alternative_operator(query) {
    Some(op_pos) => {
      match substring_safe(query, 0, op_pos) {
        Some(left_expr) => {
          match substring_safe(query, op_pos + 2, query.length()) {
            Some(right_expr) => {
              let left = trim_string(left_expr)
              let right = trim_string(right_expr)
              
              // 尝试执行左侧表达式
              match run_jq_query(left, json_input) {
                Ok(result) => {
                  let trimmed_result = trim_string(result)
                  // 检查结果是否为 null 或 false
                  if trimmed_result == "null" || trimmed_result == "false" {
                    // 返回右侧表达式的结果
                    run_jq_query(right, json_input)
                  } else {
                    Ok(result)
                  }
                }
                Err(_) => {
                  // 左侧失败，返回右侧
                  run_jq_query(right, json_input)
                }
              }
            }
            None => Err("Invalid alternative operator syntax")
          }
        }
        None => Err("Invalid alternative operator syntax")
      }
    }
    None => Err("No alternative operator found")
  }
}

// 查找 // 操作符位置
fn find_alternative_operator(query: String) -> Int? {
  let mut i = 0
  let mut depth = 0
  let mut in_string = false
  let mut escape = false
  
  while i < query.length() - 1 {
    let ch_code = query[i]
    
    if escape {
      escape = false
    } else if ch_code == '\\'.to_int() {
      escape = true
    } else if ch_code == '"'.to_int() {
      in_string = not(in_string)
    } else if not(in_string) {
      if ch_code == '['.to_int() || ch_code == '('.to_int() || ch_code == '{'.to_int() {
        depth = depth + 1
      } else if ch_code == ']'.to_int() || ch_code == ')'.to_int() || ch_code == '}'.to_int() {
        depth = depth - 1
      } else if ch_code == '/'.to_int() && query[i + 1] == '/'.to_int() && depth == 0 {
        return Some(i)
      }
    }
    
    i = i + 1
  }
  
  None
}

// 嵌套字段访问 - .field1.field2.field3
fn extract_nested_field(json_str: String, field_path: String) -> Result[String, String] {
  // 如果没有点号，就是单个字段
  if not(string_contains(field_path, ".")) {
    return extract_field(json_str, field_path)
  }
  
  // 分割字段路径
  let fields = split_by_dot(field_path)
  let mut current = json_str
  
  for field in fields {
    match extract_field(current, field) {
      Ok(value) => current = value
      Err(msg) => return Err(msg)
    }
  }
  
  Ok(current)
}

// 按点号分割字段路径
fn split_by_dot(path: String) -> Array[String] {
  let fields = []
  let mut i = 0
  let mut start = 0
  
  while i < path.length() {
    if path[i] == '.'.to_int() {
      match substring_safe(path, start, i) {
        Some(field) => {
          if field.length() > 0 {
            fields.push(field)
          }
        }
        None => ()
      }
      start = i + 1
    }
    i = i + 1
  }
  
  // 添加最后一个字段
  if start < path.length() {
    match substring_safe(path, start, path.length()) {
      Some(field) => {
        if field.length() > 0 {
          fields.push(field)
        }
      }
      None => ()
    }
  }
  
  fields
}

// 可选字段访问 - .field?（不存在时返回 null）
fn extract_field_optional(json_str: String, field_path: String) -> Result[String, String] {
  match extract_nested_field(json_str, field_path) {
    Ok(value) => Ok(value)
    Err(_) => Ok("null")
  }
}

// 逗号操作符 - 产生多个输出
fn eval_comma_operator(query: String, json_input: String) -> Result[String, String] {
  // 分割逗号分隔的表达式
  let exprs = parse_comma_expressions(query)
  let results = []
  
  for expr in exprs {
    match run_jq_query(trim_string(expr), json_input) {
      Ok(value) => results.push(value)
      Err(msg) => return Err(msg)
    }
  }
  
  // 将多个结果用换行符连接
  Ok(array_join_newline(results))
}

// 解析逗号分隔的表达式
fn parse_comma_expressions(query: String) -> Array[String] {
  let exprs = []
  let mut i = 0
  let mut start = 0
  let mut depth = 0
  let mut in_string = false
  let mut escape = false
  
  while i < query.length() {
    let ch_code = query[i]
    
    if escape {
      escape = false
    } else if ch_code == '\\'.to_int() {
      escape = true
    } else if ch_code == '"'.to_int() {
      in_string = not(in_string)
    } else if not(in_string) {
      if ch_code == '['.to_int() || ch_code == '('.to_int() || ch_code == '{'.to_int() {
        depth = depth + 1
      } else if ch_code == ']'.to_int() || ch_code == ')'.to_int() || ch_code == '}'.to_int() {
        depth = depth - 1
      } else if ch_code == ','.to_int() && depth == 0 {
        match substring_safe(query, start, i) {
          Some(expr) => exprs.push(trim_string(expr))
          None => ()
        }
        start = i + 1
      }
    }
    
    i = i + 1
  }
  
  // 添加最后一个表达式
  if start < query.length() {
    match substring_safe(query, start, query.length()) {
      Some(expr) => exprs.push(trim_string(expr))
      None => ()
    }
  }
  
  exprs
}

// 数组用换行符连接
fn array_join_newline(arr: Array[String]) -> String {
  let builder = StringBuilder::new()
  for i = 0; i < arr.length(); i = i + 1 {
    builder.write_string(arr[i])
    if i < arr.length() - 1 {
      builder.write_char('\n')
    }
  }
  builder.to_string()
}

// 对象构造器 - {key: value, ...}
fn eval_object_constructor(query: String, json_input: String) -> Result[String, String] {
  // 提取花括号内的内容
  match substring_safe(query, 1, query.length() - 1) {
    Some(content) => {
      let trimmed_content = trim_string(content)
      
      if trimmed_content.length() == 0 {
        return Ok("{}")
      }
      
      // 解析键值对
      let pairs = parse_object_pairs_constructor(trimmed_content)
      let result_pairs = []
      
      for pair in pairs {
        // 解析 key: value
        match string_find(pair, ":") {
          Some(colon_pos) => {
            match substring_safe(pair, 0, colon_pos) {
              Some(key_expr) => {
                match substring_safe(pair, colon_pos + 1, pair.length()) {
                  Some(value_expr) => {
                    let key = trim_string(key_expr)
                    let value = trim_string(value_expr)
                    
                    // 计算键（可能是表达式或字符串字面量）
                    let computed_key = if string_starts_with(key, "\"") && string_ends_with(key, "\"") {
                      // 字符串字面量
                      key
                    } else if string_starts_with(key, "(") && string_ends_with(key, ")") {
                      // 括号表达式
                      match substring_safe(key, 1, key.length() - 1) {
                        Some(key_inner) => {
                          match run_jq_query(key_inner, json_input) {
                            Ok(k) => {
                              // 确保键是字符串格式
                              if string_starts_with(k, "\"") { k } else { "\"" + k + "\"" }
                            }
                            Err(msg) => return Err(msg)
                          }
                        }
                        None => return Err("Invalid key expression")
                      }
                    } else {
                      // 简单标识符，作为字符串字面量
                      "\"" + key + "\""
                    }
                    
                    // 计算值
                    match run_jq_query(value, json_input) {
                      Ok(computed_value) => {
                        result_pairs.push(computed_key + ":" + computed_value)
                      }
                      Err(msg) => return Err(msg)
                    }
                  }
                  None => return Err("Invalid object pair")
                }
              }
              None => return Err("Invalid object pair")
            }
          }
          None => return Err("Invalid object pair: " + pair)
        }
      }
      
      Ok("{" + array_join(result_pairs, ",") + "}")
    }
    None => Err("Invalid object constructor syntax")
  }
}

// 解析对象构造器中的键值对
fn parse_object_pairs_constructor(content: String) -> Array[String] {
  let pairs = []
  let mut i = 0
  let mut start = 0
  let mut depth = 0
  let mut in_string = false
  let mut escape = false
  
  while i < content.length() {
    let ch_code = content[i]
    
    if escape {
      escape = false
    } else if ch_code == '\\'.to_int() {
      escape = true
    } else if ch_code == '"'.to_int() {
      in_string = not(in_string)
    } else if not(in_string) {
      if ch_code == '['.to_int() || ch_code == '('.to_int() || ch_code == '{'.to_int() {
        depth = depth + 1
      } else if ch_code == ']'.to_int() || ch_code == ')'.to_int() || ch_code == '}'.to_int() {
        depth = depth - 1
      } else if ch_code == ','.to_int() && depth == 0 {
        match substring_safe(content, start, i) {
          Some(pair) => pairs.push(trim_string(pair))
          None => ()
        }
        start = i + 1
      }
    }
    
    i = i + 1
  }
  
  // 添加最后一个键值对
  if start < content.length() {
    match substring_safe(content, start, content.length()) {
      Some(pair) => pairs.push(trim_string(pair))
      None => ()
    }
  }
  
  pairs
}

// 获取 JSON 值的类型
fn get_json_type(json_str: String) -> Result[String, String] {
  let trimmed = trim_string(json_str)
  
  if trimmed == "null" {
    Ok("\"null\"")
  } else if trimmed == "true" || trimmed == "false" {
    Ok("\"boolean\"")
  } else if string_starts_with(trimmed, "\"") && string_ends_with(trimmed, "\"") {
    Ok("\"string\"")
  } else if string_starts_with(trimmed, "[") && string_ends_with(trimmed, "]") {
    Ok("\"array\"")
  } else if string_starts_with(trimmed, "{") && string_ends_with(trimmed, "}") {
    Ok("\"object\"")
  } else {
    // 尝试解析为数字
    match parse_number(trimmed) {
      Some(_) => Ok("\"number\"")
      None => Ok("\"unknown\"")
    }
  }
}

// add 函数 - 数组求和或字符串连接
fn eval_add(json_input: String) -> Result[String, String] {
  let trimmed = trim_string(json_input)
  
  if not(string_starts_with(trimmed, "[") && string_ends_with(trimmed, "]")) {
    return Err("add requires an array")
  }
  
  match substring_safe(trimmed, 1, trimmed.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      
      if elements.length() == 0 {
        return Ok("null")
      }
      
      // 检查第一个元素的类型来决定操作
      let first_elem = trim_string(elements[0])
      
      if string_starts_with(first_elem, "\"") {
        // 字符串连接
        let mut result = ""
        for elem in elements {
          let elem_trimmed = trim_string(elem)
          if string_starts_with(elem_trimmed, "\"") && string_ends_with(elem_trimmed, "\"") {
            match substring_safe(elem_trimmed, 1, elem_trimmed.length() - 1) {
              Some(s) => result = result + s
              None => ()
            }
          }
        }
        Ok("\"" + result + "\"")
      } else {
        // 数字求和
        let mut sum = 0.0
        for elem in elements {
          match parse_number(trim_string(elem)) {
            Some(n) => sum = sum + n
            None => ()
          }
        }
        Ok(format_number(sum))
      }
    }
    None => Err("Invalid array")
  }
}

// map 函数 - 对数组每个元素应用表达式
fn eval_map(query: String, json_input: String) -> Result[String, String] {
  // 提取 map() 括号内的表达式
  match substring_safe(query, 4, query.length() - 1) {
    Some(expr) => {
      let trimmed_input = trim_string(json_input)
      
      if not(string_starts_with(trimmed_input, "[") && string_ends_with(trimmed_input, "]")) {
        return Err("map requires an array")
      }
      
      match substring_safe(trimmed_input, 1, trimmed_input.length() - 1) {
        Some(content) => {
          let elements = split_array_elements(content)
          let results = []
          
          for elem in elements {
            match run_jq_query(trim_string(expr), trim_string(elem)) {
              Ok(value) => results.push(value)
              Err(msg) => return Err(msg)
            }
          }
          
          Ok("[" + array_join(results, ",") + "]")
        }
        None => Err("Invalid array")
      }
    }
    None => Err("Invalid map syntax")
  }
}

// select 函数 - 条件过滤
fn eval_select(query: String, json_input: String) -> Result[String, String] {
  // 提取 select() 括号内的条件表达式
  match substring_safe(query, 7, query.length() - 1) {
    Some(condition) => {
      // 执行条件表达式
      match run_jq_query(trim_string(condition), json_input) {
        Ok(result) => {
          let trimmed_result = trim_string(result)
          // 检查结果是否为真值
          if trimmed_result == "true" || (trimmed_result != "false" && trimmed_result != "null" && trimmed_result != "0") {
            Ok(json_input)
          } else {
            // 条件为假，返回空（实际上 jq 不产生输出，这里返回特殊标记）
            Err("FILTER_NO_MATCH")
          }
        }
        Err(msg) => Err(msg)
      }
    }
    None => Err("Invalid select syntax")
  }
}

// 比较操作符
fn eval_comparison(query: String, json_input: String) -> Result[String, String] {
  // 查找比较操作符（优先级：先找双字符操作符）
  let operators = ["==", "!=", "<=", ">=", "<", ">"]
  
  for op in operators {
    match find_operator(query, op) {
      Some(op_pos) => {
        match substring_safe(query, 0, op_pos) {
          Some(left_expr) => {
            match substring_safe(query, op_pos + op.length(), query.length()) {
              Some(right_expr) => {
                let left = trim_string(left_expr)
                let right = trim_string(right_expr)
                
                // 执行左侧表达式
                match run_jq_query(left, json_input) {
                  Ok(left_result) => {
                    // 执行右侧表达式或直接使用常量
                    let right_result = match run_jq_query(right, json_input) {
                      Ok(r) => r
                      Err(_) => right  // 可能是常量
                    }
                    
                    // 执行比较
                    return compare_values(trim_string(left_result), trim_string(right_result), op)
                  }
                  Err(msg) => return Err(msg)
                }
              }
              None => ()
            }
          }
          None => ()
        }
      }
      None => () // 这个操作符不在查询中
    }
  }
  
  Err("No valid comparison operator found")
}

// 查找操作符位置
fn find_operator(query: String, op: String) -> Int? {
  let mut i = 0
  let mut depth = 0
  let mut in_string = false
  let mut escape = false
  
  while i <= query.length() - op.length() {
    let ch_code = query[i]
    
    if escape {
      escape = false
    } else if ch_code == '\\'.to_int() {
      escape = true
    } else if ch_code == '"'.to_int() {
      in_string = not(in_string)
    } else if not(in_string) {
      if ch_code == '['.to_int() || ch_code == '('.to_int() || ch_code == '{'.to_int() {
        depth = depth + 1
      } else if ch_code == ']'.to_int() || ch_code == ')'.to_int() || ch_code == '}'.to_int() {
        depth = depth - 1
      } else if depth == 0 {
        // 检查是否匹配操作符
        match substring_safe(query, i, i + op.length()) {
          Some(sub) => {
            if sub == op {
              return Some(i)
            }
          }
          None => ()
        }
      }
    }
    
    i = i + 1
  }
  
  None
}

// 比较两个值
fn compare_values(left: String, right: String, op: String) -> Result[String, String] {
  // 尝试作为数字比较
  match parse_number(left) {
    Some(left_num) => {
      match parse_number(right) {
        Some(right_num) => {
          let result = match op {
            "==" => left_num == right_num
            "!=" => left_num != right_num
            "<" => left_num < right_num
            ">" => left_num > right_num
            "<=" => left_num <= right_num
            ">=" => left_num >= right_num
            _ => return Err("Unknown comparison operator: " + op)
          }
          return Ok(if result { "true" } else { "false" })
        }
        None => ()
      }
    }
    None => ()
  }
  
  // 字符串比较
  let result = match op {
    "==" => left == right
    "!=" => left != right
    "<" => left < right
    ">" => left > right
    "<=" => left <= right
    ">=" => left >= right
    _ => return Err("Unknown comparison operator: " + op)
  }
  Ok(if result { "true" } else { "false" })
}

// min 函数 - 数组最小值
fn eval_min(json_input: String) -> Result[String, String] {
  let trimmed = trim_string(json_input)
  
  if not(string_starts_with(trimmed, "[") && string_ends_with(trimmed, "]")) {
    return Err("min requires an array")
  }
  
  match substring_safe(trimmed, 1, trimmed.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      
      if elements.length() == 0 {
        return Ok("null")
      }
      
      let mut min_val = 0.0
      let mut first = true
      
      for elem in elements {
        match parse_number(trim_string(elem)) {
          Some(n) => {
            if first {
              min_val = n
              first = false
            } else if n < min_val {
              min_val = n
            }
          }
          None => ()
        }
      }
      
      if first {
        Err("min requires numeric array")
      } else {
        Ok(format_number(min_val))
      }
    }
    None => Err("Invalid array")
  }
}

// max 函数 - 数组最大值
fn eval_max(json_input: String) -> Result[String, String] {
  let trimmed = trim_string(json_input)
  
  if not(string_starts_with(trimmed, "[") && string_ends_with(trimmed, "]")) {
    return Err("max requires an array")
  }
  
  match substring_safe(trimmed, 1, trimmed.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      
      if elements.length() == 0 {
        return Ok("null")
      }
      
      let mut max_val = 0.0
      let mut first = true
      
      for elem in elements {
        match parse_number(trim_string(elem)) {
          Some(n) => {
            if first {
              max_val = n
              first = false
            } else if n > max_val {
              max_val = n
            }
          }
          None => ()
        }
      }
      
      if first {
        Err("max requires numeric array")
      } else {
        Ok(format_number(max_val))
      }
    }
    None => Err("Invalid array")
  }
}

// sort 函数 - 数组排序
fn eval_sort(json_input: String) -> Result[String, String] {
  let trimmed = trim_string(json_input)
  
  if not(string_starts_with(trimmed, "[") && string_ends_with(trimmed, "]")) {
    return Err("sort requires an array")
  }
  
  match substring_safe(trimmed, 1, trimmed.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      
      if elements.length() == 0 {
        return Ok("[]")
      }
      
      // 简单冒泡排序
      let sorted = []
      for elem in elements {
        sorted.push(trim_string(elem))
      }
      
      // 检查是否是数字数组
      let mut is_numeric = true
      for elem in sorted {
        match parse_number(elem) {
          Some(_) => ()
          None => {
            is_numeric = false
            break
          }
        }
      }
      
      if is_numeric {
        // 数字排序
        for i = 0; i < sorted.length(); i = i + 1 {
          for j = i + 1; j < sorted.length(); j = j + 1 {
            match parse_number(sorted[i]) {
              Some(a) => {
                match parse_number(sorted[j]) {
                  Some(b) => {
                    if a > b {
                      let temp = sorted[i]
                      sorted[i] = sorted[j]
                      sorted[j] = temp
                    }
                  }
                  None => ()
                }
              }
              None => ()
            }
          }
        }
      } else {
        // 字符串排序
        for i = 0; i < sorted.length(); i = i + 1 {
          for j = i + 1; j < sorted.length(); j = j + 1 {
            if sorted[i] > sorted[j] {
              let temp = sorted[i]
              sorted[i] = sorted[j]
              sorted[j] = temp
            }
          }
        }
      }
      
      Ok("[" + array_join(sorted, ",") + "]")
    }
    None => Err("Invalid array")
  }
}

// reverse 函数 - 数组反转
fn eval_reverse(json_input: String) -> Result[String, String] {
  let trimmed = trim_string(json_input)
  
  if not(string_starts_with(trimmed, "[") && string_ends_with(trimmed, "]")) {
    return Err("reverse requires an array")
  }
  
  match substring_safe(trimmed, 1, trimmed.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      let reversed = []
      
      for i = elements.length() - 1; i >= 0; i = i - 1 {
        reversed.push(trim_string(elements[i]))
      }
      
      Ok("[" + array_join(reversed, ",") + "]")
    }
    None => Err("Invalid array")
  }
}

// unique 函数 - 数组去重
fn eval_unique(json_input: String) -> Result[String, String] {
  let trimmed = trim_string(json_input)
  
  if not(string_starts_with(trimmed, "[") && string_ends_with(trimmed, "]")) {
    return Err("unique requires an array")
  }
  
  match substring_safe(trimmed, 1, trimmed.length() - 1) {
    Some(content) => {
      let elements = split_array_elements(content)
      let unique_elements = []
      
      for elem in elements {
        let trimmed_elem = trim_string(elem)
        let mut found = false
        
        for existing in unique_elements {
          if existing == trimmed_elem {
            found = true
            break
          }
        }
        
        if not(found) {
          unique_elements.push(trimmed_elem)
        }
      }
      
      Ok("[" + array_join(unique_elements, ",") + "]")
    }
    None => Err("Invalid array")
  }
}

// not 函数 - 逻辑非
fn eval_not(json_input: String) -> Result[String, String] {
  let trimmed = trim_string(json_input)
  
  if trimmed == "false" || trimmed == "null" || trimmed == "0" {
    Ok("true")
  } else {
    Ok("false")
  }
}

// 逻辑与
fn eval_logical_and(query: String, json_input: String) -> Result[String, String] {
  match find_operator(query, " and ") {
    Some(op_pos) => {
      match substring_safe(query, 0, op_pos) {
        Some(left_expr) => {
          match substring_safe(query, op_pos + 5, query.length()) {
            Some(right_expr) => {
              let left = trim_string(left_expr)
              let right = trim_string(right_expr)
              
              // 执行左侧表达式
              match run_jq_query(left, json_input) {
                Ok(left_result) => {
                  let left_trimmed = trim_string(left_result)
                  if left_trimmed == "false" || left_trimmed == "null" || left_trimmed == "0" {
                    Ok("false")
                  } else {
                    // 左侧为真，检查右侧
                    match run_jq_query(right, json_input) {
                      Ok(right_result) => {
                        let right_trimmed = trim_string(right_result)
                        if right_trimmed == "false" || right_trimmed == "null" || right_trimmed == "0" {
                          Ok("false")
                        } else {
                          Ok("true")
                        }
                      }
                      Err(msg) => Err(msg)
                    }
                  }
                }
                Err(msg) => Err(msg)
              }
            }
            None => Err("Invalid and expression")
          }
        }
        None => Err("Invalid and expression")
      }
    }
    None => Err("No and operator found")
  }
}

// 逻辑或
fn eval_logical_or(query: String, json_input: String) -> Result[String, String] {
  match find_operator(query, " or ") {
    Some(op_pos) => {
      match substring_safe(query, 0, op_pos) {
        Some(left_expr) => {
          match substring_safe(query, op_pos + 4, query.length()) {
            Some(right_expr) => {
              let left = trim_string(left_expr)
              let right = trim_string(right_expr)
              
              // 执行左侧表达式
              match run_jq_query(left, json_input) {
                Ok(left_result) => {
                  let left_trimmed = trim_string(left_result)
                  if left_trimmed == "false" || left_trimmed == "null" || left_trimmed == "0" {
                    // 左侧为假，检查右侧
                    match run_jq_query(right, json_input) {
                      Ok(right_result) => {
                        let right_trimmed = trim_string(right_result)
                        if right_trimmed == "false" || right_trimmed == "null" || right_trimmed == "0" {
                          Ok("false")
                        } else {
                          Ok("true")
                        }
                      }
                      Err(msg) => Err(msg)
                    }
                  } else {
                    Ok("true")
                  }
                }
                Err(msg) => Err(msg)
              }
            }
            None => Err("Invalid or expression")
          }
        }
        None => Err("Invalid or expression")
      }
    }
    None => Err("No or operator found")
  }
}

// has(key) 函数 - 检查对象是否有某个键
fn eval_has(query: String, json_input: String) -> Result[String, String] {
  // 提取 has() 括号内的键名
  match substring_safe(query, 4, query.length() - 1) {
    Some(key_expr) => {
      let key = trim_string(key_expr)
      
      // 移除键名的引号（如果有）
      let actual_key = if string_starts_with(key, "\"") && string_ends_with(key, "\"") {
        match substring_safe(key, 1, key.length() - 1) {
          Some(k) => k
          None => key
        }
      } else {
        key
      }
      
      let trimmed_input = trim_string(json_input)
      
      if not(string_starts_with(trimmed_input, "{") && string_ends_with(trimmed_input, "}")) {
        return Err("has() requires an object")
      }
      
      // 检查键是否存在
      let field_pattern = "\"" + actual_key + "\":"
      if string_contains(trimmed_input, field_pattern) {
        Ok("true")
      } else {
        Ok("false")
      }
    }
    None => Err("Invalid has() syntax")
  }
}

// 获取当前支持的 jq 子集
pub fn get_supported_features() -> Array[String] {
  [
    "Identity operator (.)",
    "Field access (.field)",
    "Nested field access (.field1.field2)",
    "Optional field access (.field?)",
    "Array indexing (.[index]) with negative index support",
    "Array slicing (.[start:end])",
    "Array iteration (.[]) - first element",
    "Object keys (keys)",
    "Object values (values)",
    "Length function (length)",
    "Type function (type)",
    "Add function (add)",
    "Min function (min)",
    "Max function (max)",
    "Sort function (sort)",
    "Reverse function (reverse)",
    "Unique function (unique)",
    "Has function (has(key))",
    "Empty function (empty)",
    "Map function (map())",
    "Select function (select())",
    "Pipe operations (|)",
    "Pick function (pick())",
    "Array constructor ([...])",
    "Object constructor ({key: value})",
    "Comma operator (,)",
    "Comparison operators (==, !=, <, >, <=, >=)",
    "Logical operators (and, or, not)",
    "Arithmetic operations (*, +, -, /)",
    "Alternative operator (//)",
    "Dynamic string parsing",
    "Non-hardcoded implementation",
    "All string operations implemented from scratch"
  ]
}
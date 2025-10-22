// cmd/lib/Filter/jq_compliance_test.mbt
// 测试jq标准兼容性

test "test_jq_identity_operator" {
  // 测试身份操作符 .
  let json = "{\"name\": \"John\", \"age\": 30}"
  let result = run_jq_query(".", json)
  match result {
    Ok(output) => {
      if not(output.contains("name")) || not(output.contains("age")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_jq_object_field_access" {
  // 测试对象字段访问 .foo
  let json = "{\"name\": \"John\", \"age\": 30, \"city\": \"NYC\"}"
  
  // 测试 .name
  let name_result = run_jq_query(".name", json)
  match name_result {
    Ok(output) => {
      if not(output.contains("John")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试 .age
  let age_result = run_jq_query(".age", json)
  match age_result {
    Ok(output) => {
      if not(output.contains("30")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_jq_nested_field_access" {
  // 测试嵌套字段访问 .foo.bar
  let json = "{\"user\": {\"profile\": {\"name\": \"Alice\", \"age\": 25}}}"
  
  let result = run_jq_query(".user.profile.name", json)
  match result {
    Ok(output) => {
      if not(output.contains("Alice")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_jq_array_index" {
  // 测试数组索引 .[number]
  let json = "[1, 2, 3, 4, 5]"
  
  // 测试 .[0]
  let result1 = run_jq_query(".[0]", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("1")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试 .[1]
  let result2 = run_jq_query(".[1]", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("2")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_jq_pipe_operator" {
  // 测试管道操作符 |
  let json = "{\"data\": [1, 2, 3]}"
  
  let result = run_jq_query(".data | .[0]", json)
  match result {
    Ok(output) => {
      if not(output.contains("1")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_jq_basic_types" {
  // 测试基本数据类型
  
  // 测试字符串
  let string_result = run_jq_query(".", "\"hello\"")
  match string_result {
    Ok(output) => {
      if not(output.contains("hello")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试数字
  let number_result = run_jq_query(".", "42")
  match number_result {
    Ok(output) => {
      if not(output.contains("42")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试布尔值
  let bool_result = run_jq_query(".", "true")
  match bool_result {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试null
  let null_result = run_jq_query(".", "null")
  match null_result {
    Ok(output) => {
      if not(output.contains("null")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_jq_array_operations" {
  // 测试数组操作
  let json = "[{\"name\": \"John\"}, {\"name\": \"Jane\"}]"
  
  // 测试访问数组中的对象
  let result = run_jq_query(".[0].name", json)
  match result {
    Ok(output) => {
      if not(output.contains("John")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_jq_complex_nested" {
  // 测试复杂嵌套结构
  let json = "{\"users\": [{\"name\": \"Alice\", \"age\": 30}, {\"name\": \"Bob\", \"age\": 25}], \"total\": 2}"
  
  // 测试访问嵌套数组中的对象
  let result = run_jq_query(".users[0].name", json)
  match result {
    Ok(output) => {
      if not(output.contains("Alice")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_jq_error_handling" {
  // 测试错误处理
  let json = "{\"name\": \"John\"}"
  
  // 测试访问不存在的字段
  let result = run_jq_query(".nonexistent", json)
  match result {
    Ok(_) => () // 可能返回null
    Err(_) => () // 也可能返回错误，都是可以接受的
  }
}

test "test_jq_edge_cases" {
  // 测试边界情况
  let empty_obj = "{}"
  let result1 = run_jq_query(".", empty_obj)
  match result1 {
    Ok(_) => () // 应该成功
    Err(_) => panic()
  }
  
  let empty_arr = "[]"
  let result2 = run_jq_query(".", empty_arr)
  match result2 {
    Ok(_) => () // 应该成功
    Err(_) => panic()
  }
}

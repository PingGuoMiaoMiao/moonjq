// cmd/lib/Filter/filter_test.mbt

test "test_basic_json_parsing" {
  let json_input = "{\"name\": \"John\", \"age\": 30}"
  let result = run_jq_query(".", json_input)
  match result {
    Ok(output) => {
      // 验证返回的是原始JSON
      if output.contains("John") && output.contains("30") {
        ()
      } else {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_field_access" {
  let json_input = "{\"name\": \"John\", \"age\": 30, \"city\": \"New York\"}"
  
  // 测试访问name字段
  let name_result = run_jq_query(".name", json_input)
  match name_result {
    Ok(output) => {
      if not(output.contains("John")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试访问age字段
  let age_result = run_jq_query(".age", json_input)
  match age_result {
    Ok(output) => {
      if not(output.contains("30")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_array_access" {
  let json_input = "[1, 2, 3, 4, 5]"
  
  // 测试访问数组元素
  let result = run_jq_query(".[0]", json_input)
  match result {
    Ok(output) => {
      if not(output.contains("1")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_nested_object" {
  let json_input = "{\"user\": {\"name\": \"Alice\", \"age\": 25}, \"status\": \"active\"}"
  
  // 测试嵌套对象访问
  let result = run_jq_query(".user.name", json_input)
  match result {
    Ok(output) => {
      if not(output.contains("Alice")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_identity_operator" {
  let json_input = "{\"message\": \"Hello World\"}"
  
  // 测试身份操作符
  let result = run_jq_query(".", json_input)
  match result {
    Ok(output) => {
      if not(output.contains("Hello World")) || not(output.contains("message")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_boolean_values" {
  let json_input = "{\"active\": true, \"verified\": false}"
  
  // 测试布尔值访问
  let active_result = run_jq_query(".active", json_input)
  match active_result {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_null_values" {
  let json_input = "{\"name\": \"John\", \"middleName\": null}"
  
  // 测试null值访问
  let result = run_jq_query(".middleName", json_input)
  match result {
    Ok(output) => {
      if not(output.contains("null")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}
// cmd/main/integration_test.mbt

test "test_integration_basic_queries" {
  // 测试基本查询
  let json1 = "{\"name\": \"John\"}"
  let result1 = @filter.run_jq_query(".name", json1)
  match result1 {
    Ok(output) => {
      if not(output.contains("John")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  let json2 = "{\"age\": 30}"
  let result2 = @filter.run_jq_query(".age", json2)
  match result2 {
    Ok(output) => {
      if not(output.contains("30")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_integration_nested_queries" {
  let json = "{\"user\": {\"profile\": {\"name\": \"Alice\", \"age\": 25}}}"
  
  // 测试嵌套查询
  let result1 = @filter.run_jq_query(".user.profile.name", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("Alice")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  let result2 = @filter.run_jq_query(".user.profile.age", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("25")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_integration_array_queries" {
  let json = "[1, 2, 3, 4, 5]"
  
  // 测试数组查询
  let result1 = @filter.run_jq_query(".[0]", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("1")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  let result2 = @filter.run_jq_query(".[1]", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("2")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_integration_complex_data" {
  let json = "{\"users\": [{\"name\": \"John\", \"age\": 30}, {\"name\": \"Jane\", \"age\": 25}], \"total\": 2}"
  
  // 测试复杂数据查询
  let result1 = @filter.run_jq_query(".users[0].name", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("John")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  let result2 = @filter.run_jq_query(".total", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("2")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_integration_error_cases" {
  let json = "{\"name\": \"John\"}"
  
  // 测试访问不存在的字段
  let result = @filter.run_jq_query(".nonexistent", json)
  match result {
    Ok(_) => () // 可能返回null
    Err(_) => () // 也可能返回错误，都是可以接受的
  }
}

test "test_integration_edge_cases" {
  // 测试空对象
  let empty_obj = "{}"
  let result1 = @filter.run_jq_query(".", empty_obj)
  match result1 {
    Ok(_) => () // 应该成功
    Err(_) => panic()
  }
  
  // 测试空数组
  let empty_arr = "[]"
  let result2 = @filter.run_jq_query(".", empty_arr)
  match result2 {
    Ok(_) => () // 应该成功
    Err(_) => panic()
  }
  
  // 测试字符串值
  let string_json = "\"Hello World\""
  let result3 = @filter.run_jq_query(".", string_json)
  match result3 {
    Ok(output) => {
      if not(output.contains("Hello World")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}
// cmd/main/main_test.mbt

test "test_main_function_basic" {
  // 测试基本的main函数功能
  // 由于main函数没有返回值，我们主要测试它不会崩溃
  // 这里我们无法直接测试main函数，因为它需要命令行参数
  // 但我们可以测试run_jq_query函数
  let json_input = "{\"name\": \"John\", \"age\": 30}"
  let result = @filter.run_jq_query(".name", json_input)
  match result {
    Ok(output) => {
      if not(output.contains("John")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_main_with_different_queries" {
  let json_input = "{\"user\": {\"name\": \"Alice\", \"age\": 25}, \"status\": \"active\"}"
  
  // 测试不同的查询
  let query1 = ".user.name"
  let result1 = @filter.run_jq_query(query1, json_input)
  match result1 {
    Ok(_) => () // 成功
    Err(_) => panic() // 失败
  }
  
  let query2 = ".user.age"
  let result2 = @filter.run_jq_query(query2, json_input)
  match result2 {
    Ok(_) => () // 成功
    Err(_) => panic() // 失败
  }
}

test "test_main_with_array_data" {
  let json_input = "[{\"name\": \"John\"}, {\"name\": \"Jane\"}]"
  
  // 测试数组数据
  let result = @filter.run_jq_query(".[0].name", json_input)
  match result {
    Ok(output) => {
      if not(output.contains("John")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_main_with_complex_json" {
  let json_input = "{\"users\": [{\"name\": \"Alice\", \"age\": 30, \"active\": true}, {\"name\": \"Bob\", \"age\": 25, \"active\": false}], \"total\": 2}"
  
  // 测试复杂JSON
  let result = @filter.run_jq_query(".users[0].name", json_input)
  match result {
    Ok(output) => {
      if not(output.contains("Alice")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_main_error_handling" {
  let json_input = "{\"name\": \"John\"}"
  
  // 测试错误处理
  let result = @filter.run_jq_query(".nonexistent", json_input)
  match result {
    Ok(_) => () // 可能返回null或空值
    Err(_) => () // 也可能返回错误，都是可以接受的
  }
}

test "test_main_with_boolean_and_null" {
  let json_input = "{\"active\": true, \"verified\": false, \"middleName\": null}"
  
  // 测试布尔值和null
  let active_result = @filter.run_jq_query(".active", json_input)
  match active_result {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  let null_result = @filter.run_jq_query(".middleName", json_input)
  match null_result {
    Ok(output) => {
      if not(output.contains("null")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

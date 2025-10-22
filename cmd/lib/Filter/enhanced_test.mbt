// cmd/lib/Filter/enhanced_test.mbt
// 测试增强功能

test "test_binary_operators" {
  let json = "{\"a\": 5, \"b\": 3}"
  
  // 测试加法
  let result1 = run_jq_query(".a + .b", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("8")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试减法
  let result2 = run_jq_query(".a - .b", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("2")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试乘法
  let result3 = run_jq_query(".a * .b", json)
  match result3 {
    Ok(output) => {
      if not(output.contains("15")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试除法
  let result4 = run_jq_query(".a / .b", json)
  match result4 {
    Ok(output) => {
      if not(output.contains("1.666")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_comparison_operators" {
  let json = "{\"a\": 5, \"b\": 3, \"c\": 5}"
  
  // 测试等于
  let result1 = run_jq_query(".a == .c", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试不等于
  let result2 = run_jq_query(".a != .b", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试大于
  let result3 = run_jq_query(".a > .b", json)
  match result3 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试小于
  let result4 = run_jq_query(".b < .a", json)
  match result4 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_string_operations" {
  let json = "{\"first\": \"Hello\", \"last\": \"World\"}"
  
  // 测试字符串连接
  let result1 = run_jq_query(".first + .last", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("HelloWorld")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试字符串比较
  let result2 = run_jq_query(".first == \"Hello\"", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_logical_operators" {
  let json = "{\"a\": true, \"b\": false, \"c\": true}"
  
  // 测试逻辑与
  let result1 = run_jq_query(".a and .c", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试逻辑或
  let result2 = run_jq_query(".a or .b", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_array_operations" {
  let json = "{\"arr1\": [1, 2, 3], \"arr2\": [4, 5, 6]}"
  
  // 测试数组连接
  let result1 = run_jq_query(".arr1 + .arr2", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("1")) || not(output.contains("4")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_stream_iteration" {
  let json = "[1, 2, 3, 4, 5]"
  
  // 测试数组流式迭代
  let result = run_jq_query(".[]", json)
  match result {
    Ok(output) => {
      // 应该返回数组中的元素
      if not(output.contains("1")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_object_stream_iteration" {
  let json = "{\"a\": 1, \"b\": 2, \"c\": 3}"
  
  // 测试对象流式迭代
  let result = run_jq_query(".[]", json)
  match result {
    Ok(output) => {
      // 应该返回对象中的值
      if not(output.contains("1")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_complex_expressions" {
  let json = "{\"users\": [{\"name\": \"Alice\", \"age\": 25}, {\"name\": \"Bob\", \"age\": 30}], \"min_age\": 20}"
  
  // 测试复杂表达式
  let result = run_jq_query(".users[0].age > .min_age", json)
  match result {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_boolean_literals" {
  let json = "{\"flag\": true}"
  
  // 测试布尔字面量
  let result1 = run_jq_query(".flag", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试布尔比较
  let result2 = run_jq_query(".flag == true", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_null_handling" {
  let json = "{\"value\": null, \"other\": \"test\"}"
  
  // 测试null值
  let result1 = run_jq_query(".value", json)
  match result1 {
    Ok(output) => {
      if not(output.contains("null")) {
        panic()
      }
    }
    Err(_) => panic()
  }
  
  // 测试null比较
  let result2 = run_jq_query(".value == null", json)
  match result2 {
    Ok(output) => {
      if not(output.contains("true")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

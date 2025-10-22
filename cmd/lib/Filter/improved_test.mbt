// cmd/lib/Filter/improved_test.mbt
// 测试改进后的功能

test "test_improved_array_iteration" {
  let json = "[1, 2, 3, 4, 5]"
  
  // 测试数组迭代 - 应该返回第一个元素
  let result = run_jq_query(".[]", json)
  match result {
    Ok(output) => {
      if not(output.contains("1")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_improved_object_iteration" {
  let json = "{\"a\": 1, \"b\": 2, \"c\": 3}"
  
  // 测试对象迭代 - 应该返回第一个值
  let result = run_jq_query(".[]", json)
  match result {
    Ok(output) => {
      // 应该返回某个值
      if output == "null" {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_improved_comma_operator" {
  let json = "{\"name\": \"John\", \"age\": 30}"
  
  // 测试逗号操作符 - 应该返回右侧结果
  let result = run_jq_query(".name, .age", json)
  match result {
    Ok(output) => {
      if not(output.contains("30")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_negative_index" {
  let json = "[1, 2, 3, 4, 5]"
  
  // 测试负数索引 - 应该返回最后一个元素
  let result = run_jq_query(".[-1]", json)
  match result {
    Ok(output) => {
      if not(output.contains("5")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_improved_array_constructor" {
  let json = "{\"name\": \"John\", \"age\": 30}"
  
  // 测试数组构造
  let result = run_jq_query("[.name, .age]", json)
  match result {
    Ok(output) => {
      if not(output.contains("John")) || not(output.contains("30")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_improved_object_constructor" {
  let json = "{\"name\": \"John\", \"age\": 30}"
  
  // 测试对象构造
  let result = run_jq_query("{name: .name, age: .age}", json)
  match result {
    Ok(output) => {
      if not(output.contains("name")) || not(output.contains("age")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_complex_pipeline" {
  let json = "{\"users\": [{\"name\": \"Alice\", \"age\": 25}, {\"name\": \"Bob\", \"age\": 30}]}"
  
  // 测试复杂管道操作
  let result = run_jq_query(".users | .[0] | .name", json)
  match result {
    Ok(output) => {
      if not(output.contains("Alice")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

test "test_nested_operations" {
  let json = "{\"data\": {\"items\": [1, 2, 3]}}"
  
  // 测试嵌套操作
  let result = run_jq_query(".data.items[0]", json)
  match result {
    Ok(output) => {
      if not(output.contains("1")) {
        panic()
      }
    }
    Err(_) => panic()
  }
}

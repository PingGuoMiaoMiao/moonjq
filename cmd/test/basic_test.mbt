// 基本测试 - 不依赖外部模块
// 测试 MoonBit 基本功能

test "test_basic_math" {
  let result = 1 + 1
  assert_eq(result, 2)
}

test "test_string_operations" {
  let str = "Hello, MoonBit!"
  let length = str.length()
  assert_eq(length, 15)
}

test "test_array_operations" {
  let arr = [1, 2, 3, 4, 5]
  let length = arr.length()
  assert_eq(length, 5)
  
  let first = arr[0]
  assert_eq(first, 1)
}

test "test_object_operations" {
  let obj = Map::new()
  obj.set("name", "test")
  obj.set("value", "42")
  
  let name = obj.get("name")
  match name {
    Some(value) => {
      assert_eq(value, "test")
    }
    None => {
      // 如果获取失败，测试失败
      assert_eq(1, 0)
    }
  }
}

test "test_conditional_logic" {
  let age = 25
  let status = if age >= 18 { "adult" } else { "minor" }
  assert_eq(status, "adult")
}

test "test_loop_operations" {
  let mut sum = 0
  for i = 0; i < 5; i = i + 1 {
    sum = sum + i
  }
  assert_eq(sum, 10)
}

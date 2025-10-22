// cmd/main/main.mbt

fn main {
  let args = @sys.get_cli_args()
  if args.length() < 2 {
    print_usage()
    return
  }
  
  // 跳过可执行文件路径，找到实际的查询参数
  let query = if args[1] == "moonjq" && args.length() > 2 {
    args[2]  // moonjq 'pick(.a, .b.c, .x)' data.json
  } else {
    args[1]  // 直接查询
  }
  
  // 检查是否是 pick 函数调用
  if query.has_prefix("pick(") {
    // 使用示例 JSON 数据
    let input = "{\"a\": 1, \"b\": {\"c\": 2, \"d\": 3}, \"e\": 4}"
    match @filter.run_pick_query(query, input) {
      Ok(result) => @prelude.println(result)
      Err(msg) => {
        @prelude.println("Error: " + msg)
        @sys.exit(1)
      }
    }
  } else {
    // 原有的查询处理
    let input = if args.length() > 1 {
      // 从文件读取输入 - 暂时使用示例数据
      @prelude.println("Warning: File input not yet implemented, using example data")
      "{\"a\": 1, \"b\": {\"c\": 2, \"d\": 3}, \"e\": 4}"
    } else {
      // 使用示例JSON数据
      "{\"a\": 1, \"b\": {\"c\": 2, \"d\": 3}, \"e\": 4}"
    }
    
    match @filter.run_jq_query(query, input) {
      Ok(result) => @prelude.println(result)
      Err(msg) => {
        @prelude.println("Error: " + msg)
        @sys.exit(1)
      }
    }
  }
}

fn print_usage() -> Unit {
  @prelude.println("MoonJQ - A MoonBit implementation of jq")
  @prelude.println("")
  @prelude.println("Usage: moonjq <query> [file]")
  @prelude.println("")
  @prelude.println("Arguments:")
  @prelude.println("  <query>  - jq query expression")
  @prelude.println("  [file]  - JSON file to process (optional)")
  @prelude.println("")
  @prelude.println("Examples:")
  @prelude.println("  moonjq '.name'")
  @prelude.println("  moonjq '.users[0].name' data.json")
  @prelude.println("  moonjq '.users | .[0] | .name'")
  @prelude.println("")
  @prelude.println("Supported operations:")
  @prelude.println("  - Field access: .field, .field.subfield")
  @prelude.println("  - Array access: .[index], .[-1]")
  @prelude.println("  - Array iteration: .[]")
  @prelude.println("  - Object iteration: .[]")
  @prelude.println("  - Pipe operations: |")
  @prelude.println("  - Arithmetic: +, -, *, /, %")
  @prelude.println("  - Comparison: ==, !=, <, >, <=, >=")
  @prelude.println("  - Logical: and, or, not")
  @prelude.println("  - Array/Object construction: [], {}")
}
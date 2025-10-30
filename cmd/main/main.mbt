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
  
  // 使用真正的 jq 实现
  if args.length() > 2 {
    // 从文件读取输入
    let filename = args[2]
    let result = safe_run_jq_query_from_file(query, filename)
    @prelude.println(result)
  } else {
    // 从 stdin 读取输入（这里使用示例数据模拟）
    let input = "{\"users\": [{\"name\": \"Alice\", \"age\": 30}, {\"name\": \"Bob\", \"age\": 25}]}"
    let result = safe_run_jq_query(query, input)
    @prelude.println(result)
  }
}

// 安全的 jq 查询函数
fn safe_run_jq_query(query: String, input: String) -> String {
  match @filter.run_jq_query(query, input) {
    Ok(result) => result
    Err(msg) => "Error: " + msg
  }
}

// 安全的文件 jq 查询函数
fn safe_run_jq_query_from_file(query: String, filename: String) -> String {
  match @filter.run_jq_query_from_file(query, filename) {
    Ok(result) => result
    Err(msg) => "Error: " + msg
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

test "lexing a single dot with debugging" {
  @builtin.println("--- Lexer Test Start: lexing a single dot ---")
  let jq_str = "."
  @builtin.println("Input string: \"\{jq_str}\"")

  let lexbuf = Lexbuf::from_string(jq_str)
  let tokens = []
  let mut i = 0

  @builtin.println("Starting tokenization loop...")
  while true {
    @builtin.println("\n[Iteration \{i}]")
    i = i + 1
    let tok = token(lexbuf)
    
    match tok {
      DOT => @builtin.println("  - Success! Got token: DOT")
      WHITESPACE => @builtin.println("  - Success! Got token: WHITESPACE")
      EOF => @builtin.println("  - Success! Got token: EOF")
      IDENT(s) => @builtin.println("  - Success! Got token: IDENT(\"\{s}\")")
      STRING(s) => @builtin.println("  - Success! Got token: STRING(\"\{s}\")")
      NUMBER(n) => @builtin.println("  - Success! Got token: NUMBER(\"\{n}\")")
      _ => @builtin.println("  - Success! Got an unhandled token.")
    }

    if tok == EOF {
      @builtin.println("  - Condition: tok == EOF is true. Breaking loop.")
      break
    }

    if tok != WHITESPACE {
      @builtin.println("  - Condition: tok != WHITESPACE is true. Pushing token to list.")
      tokens.push(tok)
    } else {
      @builtin.println("  - Condition: Token is WHITESPACE. Skipping.")
    }
  }

  @builtin.println("\n--- Loop Finished ---")
  // 【核心修改】 删掉下面这行导致崩溃的调试代码
  // @json.inspect(tokens) 

  @builtin.println("Proceeding to final assertion...")
  // 只保留这一行真正的测试断言
  @json.inspect(tokens, content=[
    { "$tag": "DOT" },
  ])
  @builtin.println("--- Test Passed ---")
}


// 下面是第二个测试，保持原样，不带调试信息，作为对比
test "lexing multiple tokens" {
    let jq_str = ". | select(.name == \"moon\")"
    let lexbuf = Lexbuf::from_string(jq_str)
    let tokens = []

    while true {
        let tok = token(lexbuf)
        if tok == EOF {
            break
        }
        if tok != WHITESPACE {
            tokens.push(tok)
        }
    }

    @json.inspect(tokens, content=[
        { "$tag": "DOT" },
        { "$tag": "PIPE" },
        { "$tag": "SELECT" },
        { "$tag": "LPAREN" },
        { "$tag": "DOT" },
        { "$tag": "IDENT", "0": "name" },
        { "$tag": "EQ" },
        { "$tag": "STRING", "0": "\"moon\"" },
        { "$tag": "RPAREN" },
    ])
}
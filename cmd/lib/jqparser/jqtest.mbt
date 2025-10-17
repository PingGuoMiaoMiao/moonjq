test "jq parser basic" {
  let tokens : Array[(Token, Int, Int)] = [
    (DOT, 0, 1),
    (IDENT("foo"), 1, 4),
    (LBRACKET, 4, 5),
    (NUMBER(0), 5, 6),
    (RBRACKET, 6, 7),
    (PIPE, 8, 9),
    (DOT, 10, 11),
    (IDENT("bar"), 11, 14),
    (EOF, 14, 15),
  ]

  // 假设 start(tokens) 返回一个 Expr
  let expr = start(tokens)

  let s = expr.to_string()
  @builtin.println(s)

  // 检查输出字符串是否匹配实际内容
  inspect(s, content="Pipe(Index(FieldAccess(Single(\"foo\")), 0), FieldAccess(Single(\"bar\")))")
}


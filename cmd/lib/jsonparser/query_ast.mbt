// query_ast.mbt

pub enum Expr {
  // --- 基础过滤器 ---
  Ident // 身份过滤器 '.' 
  FieldAccess(Expr, String) // 字段访问 '.field'
  ArrayIndex(Expr, Int) // 数组索引 '.[0]'
  ArrayIter(Expr) // 数组迭代 '.[]'
  ObjectIter(Expr) // 对象迭代（可选） '.{}' 或 'keys/values'
  Pipe(Expr, Expr) // 管道操作 'expr1 | expr2'
  Literal(JsonValue) // 字面量，如数字、字符串常量

  // --- 复合表达式与运算符 ---
  BinaryOp(Expr, BinOp, Expr) // 二元运算，如 '.a + .b', '.count > 10'
  UnaryOp(UnOp, Expr) // 一元运算，如 '- .value', '! .is_valid'
  Conditional(Expr, Expr, Expr) // 条件表达式，if-then-else

  // --- 函数调用 ---
  Call(String, @list.List[Expr]) // 函数调用，如 'length(.array)', 'map(.+1)'

  // --- 变量绑定与引用 ---
  AsBinding(Expr, String) // 变量绑定，如 '.user as $u'
  VarRef(String) // 变量引用，如 '$u.name'
  Comma(Expr, Expr)         // filter1, filter2 (逗号操作符)
  Select(Expr, Expr)        // select(condition) (条件选择)
  // --- 构造器（高级）---
  ArrayConstructor(@list.List[Expr]) // 数组构造，如 '[.a, .b, 1]'
  ObjectConstructor(@list.List[(String, Expr)]) // 对象构造，如 '{name: .user, age: .age}'
}

// 二元操作符枚举
pub enum BinOp {
  Add // +
  Sub // -
  Mul // *
  Div // /
  Mod // %
  Eq // ==
  Neq // !=
  Lt // <
  Gt // >
  Lte // <=
  Gte // >=
  And // &&
  Or // ||
}

// 一元操作符枚举
pub enum UnOp {
  Neg // - (取负)
  Not // ! (取反)
}
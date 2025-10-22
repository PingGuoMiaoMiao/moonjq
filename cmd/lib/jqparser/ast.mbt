pub enum Expr {
  Identity
  FieldAccess(Field)
  Index(Expr, Int)
  ArrayIter(Expr)  // .[]
  ObjectIter(Expr) // .{}
  Number(Int)
  String(String)
  Boolean(Bool)
  Null
  Pipe(Expr, Expr)
  BinaryOp(Expr, BinOp, Expr)
  UnaryOp(UnOp, Expr)
  Conditional(Expr, Expr, Expr)
  Call(String, Array[Expr])
  AsBinding(Expr, String)  // .user as $u
  VarRef(String)          // $u
  Comma(Expr, Expr)       // filter1, filter2
  Select(Expr)            // select(condition)
  ArrayConstructor(Array[Expr])
  ObjectConstructor(Array[(String, Expr)])
}

pub enum Field {
  Single(String)
  Chain(Field, String)
}

pub enum BinOp {
  Add    // +
  Sub    // -
  Mul    // *
  Div    // /
  Mod    // %
  Eq     // ==
  Neq    // !=
  Lt     // <
  Gt     // >
  Lte    // <=
  Gte    // >=
  And    // &&
  Or     // ||
}

pub enum UnOp {
  Neg    // - (取负)
  Not    // ! (取反)
}


fn Expr::to_string(self:Expr) -> String {
  match self {
    Identity => "Identity"
    FieldAccess(f) => "FieldAccess(" + f.to_string() + ")"
    Index(e, idx) => "Index(" + e.to_string() + ", " + idx.to_string() + ")"
    ArrayIter(e) => "ArrayIter(" + e.to_string() + ")"
    ObjectIter(e) => "ObjectIter(" + e.to_string() + ")"
    Number(n) => "Number(" + n.to_string() + ")"
    String(s) => "String(\"" + s + "\")"
    Boolean(b) => "Boolean(" + b.to_string() + ")"
    Null => "Null"
    Pipe(lhs, rhs) => "Pipe(" + lhs.to_string() + ", " + rhs.to_string() + ")"
    BinaryOp(lhs, op, rhs) => "BinaryOp(" + lhs.to_string() + ", " + op.to_string() + ", " + rhs.to_string() + ")"
    UnaryOp(op, expr) => "UnaryOp(" + op.to_string() + ", " + expr.to_string() + ")"
    Conditional(cond, then_expr, else_expr) => "Conditional(" + cond.to_string() + ", " + then_expr.to_string() + ", " + else_expr.to_string() + ")"
    Call(name, args) => "Call(" + name + ", [" + args.map(fn(arg) { arg.to_string() }).join(", ") + "])"
    AsBinding(expr, var_name) => "AsBinding(" + expr.to_string() + ", " + var_name + ")"
    VarRef(var_name) => "VarRef(" + var_name + ")"
    Comma(lhs, rhs) => "Comma(" + lhs.to_string() + ", " + rhs.to_string() + ")"
    Select(expr) => "Select(" + expr.to_string() + ")"
    ArrayConstructor(items) => "ArrayConstructor([" + items.map(fn(item) { item.to_string() }).join(", ") + "])"
    ObjectConstructor(pairs) => "ObjectConstructor([" + pairs.map(fn(pair) { pair.0 + ": " + pair.1.to_string() }).join(", ") + "])"
  }
}

fn Field::to_string(self:Field) -> String {
  match self {
    Single(name) => "Single(\"" + name + "\")"
    Chain(f, name) => "Chain(" + f.to_string() + ", \"" + name + "\")"
  }
}

fn BinOp::to_string(self:BinOp) -> String {
  match self {
    Add => "+"
    Sub => "-"
    Mul => "*"
    Div => "/"
    Mod => "%"
    Eq => "=="
    Neq => "!="
    Lt => "<"
    Gt => ">"
    Lte => "<="
    Gte => ">="
    And => "&&"
    Or => "||"
  }
}

fn UnOp::to_string(self:UnOp) -> String {
  match self {
    Neg => "-"
    Not => "!"
  }
}

pub impl Show for Expr with output(self, logger) {
  match self {
    Identity => logger.write_string("Identity")
    FieldAccess(f) => {
      logger.write_string("FieldAccess(")
      f.output(logger)
      logger.write_string(")")
    }
    Index(e, idx) => {
      logger.write_string("Index(")
      e.output(logger)
      logger.write_string(", " + idx.to_string() + ")")
    }
    ArrayIter(e) => {
      logger.write_string("ArrayIter(")
      e.output(logger)
      logger.write_string(")")
    }
    ObjectIter(e) => {
      logger.write_string("ObjectIter(")
      e.output(logger)
      logger.write_string(")")
    }
    Number(n) => logger.write_string("Number(" + n.to_string() + ")")
    String(s) => logger.write_string("String(\"" + s + "\")")
    Boolean(b) => logger.write_string("Boolean(" + b.to_string() + ")")
    Null => logger.write_string("Null")
    Pipe(lhs, rhs) => {
      logger.write_string("Pipe(")
      lhs.output(logger)
      logger.write_string(", ")
      rhs.output(logger)
      logger.write_string(")")
    }
    BinaryOp(lhs, op, rhs) => {
      logger.write_string("BinaryOp(")
      lhs.output(logger)
      logger.write_string(", ")
      op.output(logger)
      logger.write_string(", ")
      rhs.output(logger)
      logger.write_string(")")
    }
    UnaryOp(op, expr) => {
      logger.write_string("UnaryOp(")
      op.output(logger)
      logger.write_string(", ")
      expr.output(logger)
      logger.write_string(")")
    }
    Conditional(cond, then_expr, else_expr) => {
      logger.write_string("Conditional(")
      cond.output(logger)
      logger.write_string(", ")
      then_expr.output(logger)
      logger.write_string(", ")
      else_expr.output(logger)
      logger.write_string(")")
    }
    Call(name, args) => {
      logger.write_string("Call(" + name + ", [")
      for i = 0; i < args.length(); i = i + 1 {
        if i > 0 {
          logger.write_string(", ")
        }
        args[i].output(logger)
      }
      logger.write_string("])")
    }
    AsBinding(expr, var_name) => {
      logger.write_string("AsBinding(")
      expr.output(logger)
      logger.write_string(", " + var_name + ")")
    }
    VarRef(var_name) => logger.write_string("VarRef(" + var_name + ")")
    Comma(lhs, rhs) => {
      logger.write_string("Comma(")
      lhs.output(logger)
      logger.write_string(", ")
      rhs.output(logger)
      logger.write_string(")")
    }
    Select(expr) => {
      logger.write_string("Select(")
      expr.output(logger)
      logger.write_string(")")
    }
    ArrayConstructor(items) => {
      logger.write_string("ArrayConstructor([")
      for i = 0; i < items.length(); i = i + 1 {
        if i > 0 {
          logger.write_string(", ")
        }
        items[i].output(logger)
      }
      logger.write_string("])")
    }
    ObjectConstructor(pairs) => {
      logger.write_string("ObjectConstructor([")
      for i = 0; i < pairs.length(); i = i + 1 {
        if i > 0 {
          logger.write_string(", ")
        }
        logger.write_string(pairs[i].0 + ": ")
        pairs[i].1.output(logger)
      }
      logger.write_string("])")
    }
  }
}
pub impl Show for Field with output(self, logger) {
  match self {
    Single(name) => logger.write_string("Single(\"" + name + "\")")
    Chain(f, name) => {
      logger.write_string("Chain(")
      f.output(logger)
      logger.write_string(", \"" + name + "\")")
    }
  }
}

pub impl Show for BinOp with output(self, logger) {
  match self {
    Add => logger.write_string("+")
    Sub => logger.write_string("-")
    Mul => logger.write_string("*")
    Div => logger.write_string("/")
    Mod => logger.write_string("%")
    Eq => logger.write_string("==")
    Neq => logger.write_string("!=")
    Lt => logger.write_string("<")
    Gt => logger.write_string(">")
    Lte => logger.write_string("<=")
    Gte => logger.write_string(">=")
    And => logger.write_string("&&")
    Or => logger.write_string("||")
  }
}

pub impl Show for UnOp with output(self, logger) {
  match self {
    Neg => logger.write_string("-")
    Not => logger.write_string("!")
  }
}

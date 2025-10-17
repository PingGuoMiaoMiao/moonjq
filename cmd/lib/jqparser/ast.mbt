pub enum Expr {
  Identity
  FieldAccess(Field)
  Index(Expr, Int)
  Number(Int)
  String(String)
  Pipe(Expr, Expr)
}

pub enum Field {
  Single(String)
  Chain(Field, String)
}


fn Expr::to_string(self:Expr) -> String {
  match self {
    Identity => "Identity"
    Pipe(lhs, rhs) => "Pipe(" + lhs.to_string() + ", " + rhs.to_string() + ")"
    FieldAccess(f) => "FieldAccess(" + f.to_string() + ")"
    Index(e, idx) => "Index(" + e.to_string() + ", " + idx.to_string() + ")"
    Number(n) => "Number(" + n.to_string() + ")"
    String(s) => "String(\"" + s + "\")"
  }
}

fn Field::to_string(self:Field) -> String {
  match self {
    Single(name) => "Single(\"" + name + "\")"
    Chain(f, name) => "Chain(" + f.to_string() + ", \"" + name + "\")"
  }
}

pub impl Show for Expr with output(self, logger) {
  match self {
    Identity => logger.write_string("Identity")
    Pipe(lhs, rhs) => {
      logger.write_string("Pipe(")
      lhs.output(logger)
      logger.write_string(", ")
      rhs.output(logger)
      logger.write_string(")")
    }
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
    Number(n) => logger.write_string("Number(" + n.to_string() + ")")
    String(s) => logger.write_string("String(\"" + s + "\")")
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

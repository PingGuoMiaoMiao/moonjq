///|
pub(all) enum Token {
  STRING(String)
  NUMBER(Double)
  TRUE
  FALSE
  NULL
  LBRACE
  RBRACE
  LBRACKET
  RBRACKET
  COLON
  COMMA
} derive(ToJson(style="legacy"))

pub impl Show for Token with output(self, logger) {
  match self {
    STRING(s) => logger.write_string("STRING(\"" + s + "\")")
    NUMBER(n) => logger.write_string("NUMBER(" + n.to_string() + ")")
    TRUE => logger.write_string("TRUE")
    FALSE => logger.write_string("FALSE")
    NULL => logger.write_string("NULL")
    LBRACE => logger.write_string("LBRACE")
    RBRACE => logger.write_string("RBRACE")
    LBRACKET => logger.write_string("LBRACKET")
    RBRACKET => logger.write_string("RBRACKET")
    COLON => logger.write_string("COLON")
    COMMA => logger.write_string("COMMA")
  }
}

///|
pub fn Token::kind(self : Token) -> TokenKind {
  match self {
    STRING(_) => TK_STRING
    NUMBER(_) => TK_NUMBER
    TRUE => TK_TRUE
    FALSE => TK_FALSE
    NULL => TK_NULL
    LBRACE => TK_LBRACE
    RBRACE => TK_RBRACE
    LBRACKET => TK_LBRACKET
    RBRACKET => TK_RBRACKET
    COLON => TK_COLON
    COMMA => TK_COMMA
  }
}

///|
pub(all) enum TokenKind {
  TK_STRING
  TK_NUMBER
  TK_TRUE
  TK_FALSE
  TK_NULL
  TK_LBRACE
  TK_RBRACE
  TK_LBRACKET
  TK_RBRACKET
  TK_COLON
  TK_COMMA
}

///|
pub impl Show for TokenKind with output(self, logger) {
  logger.write_string(
    match self {
      TK_STRING => "STRING"
      TK_NUMBER => "NUMBER"
      TK_TRUE => "\"true\""
      TK_FALSE => "\"false\""
      TK_NULL => "\"null\""
      TK_LBRACE => "\"{\""
      TK_RBRACE => "\"}\""
      TK_LBRACKET => "\"[\""
      TK_RBRACKET => "\"]\""
      TK_COLON => "\":\""
      TK_COMMA => "\",\""
    },
  )
}

///|
pub suberror ParseError {
  UnexpectedToken(Token, (Int, Int), Array[TokenKind])
  UnexpectedEndOfInput(Int, Array[TokenKind])
} derive(Show)

///|
typealias Error as YYObj

///|
priv suberror YYObj_Void

///|
priv suberror YYObj_Array Array[Array[JsonValue]]

///|
priv suberror YYObj_Double Double

///|
priv suberror YYObj_Object Object

///|
priv suberror YYObj_String String

///|
priv suberror YYObj_JsonValue JsonValue

///|
priv suberror YYObj__list_List_JsonValue_ @list.List[JsonValue]

///|
priv suberror YYObj__list_List__String__JsonValue__ @list.List[
  (String, JsonValue),
]

///|
priv suberror YYObj__String__JsonValue_ (String, JsonValue)

///|
typealias (YYSymbol) -> YYDecision as YYState

///|
typealias (Int, ArrayView[(YYObj, Int, Int)]) -> YYObj as YYAction

///|
priv enum YYDecision {
  Accept
  Shift(YYState)
  Reduce(Int, YYSymbol, YYAction)
  ReduceNoLookahead(Int, YYSymbol, YYAction)
  Error
}

///|
priv enum YYSymbol {
  T_STRING
  T_NUMBER
  T_TRUE
  T_FALSE
  T_NULL
  T_LBRACE
  T_RBRACE
  T_LBRACKET
  T_RBRACKET
  T_COLON
  T_COMMA
  NT_json_value
  NT_object
  NT_members
  NT_member
  NT_array
  NT_elements
  EOI
}

// Workaround for EOI unused warning

///|
fn init {
  match (EOI : YYSymbol) {
    EOI => ()
    _ => ()
  }
}

// file:///./parser.mbty
// 66|    LBRACKET RBRACKET     { Array::new() }

///|
fn yy_action_0(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Array(
    {
      ()
      Array::new()
    },
  )
}

// file:///./parser.mbty
// 67|    LBRACKET elements RBRACKET { 
// 68|      // 将 List[JsonValue] 转换为 Array[JsonValue]
// 69|      list_to_array($2)
// 70|    }

///|
fn yy_action_1(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj__list_List_JsonValue_(_dollar2)
  YYObj_Array(
    {
      ()
      // 将 List[JsonValue] 转换为 Array[JsonValue]
      [list_to_array(_dollar2)]
    },
  )
}

// file:///./parser.mbty
// 49|    LBRACE RBRACE         { @map.Map::new() }

///|
fn yy_action_2(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Object(
    {
      ()
      @builtin.Map::new()
    },
  )
}

// file:///./parser.mbty
// 50|    LBRACE members RBRACE { 
// 51|      // 使用辅助函数 list_to_map 从成员列表构建 Map
// 52|      list_to_map($2)
// 53|    }

///|
fn yy_action_3(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj__list_List__String__JsonValue__(_dollar2)
  YYObj_Object(
    {
      ()
      // 使用辅助函数 list_to_map 从成员列表构建 Map
      list_to_map(_dollar2)
    },
  )
}

// file:///./parser.mbty
// 58|    member COMMA members  { @list.More($1, $3) }

///|
fn yy_action_4(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj__String__JsonValue_(_dollar1)
  guard _args[2].0 is YYObj__list_List__String__JsonValue__(_dollar3)
  YYObj__list_List__String__JsonValue__(
    {
      ()
      @list.cons(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 57|    member                { @list.More($1, @list.Empty) }

///|
fn yy_action_5(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj__String__JsonValue_(_dollar1)
  YYObj__list_List__String__JsonValue__(
    {
      ()
  @list.new().prepend(_dollar1) // 创建空列表后 prepend 元素
    },
  )
}

// file:///./parser.mbty
// 39|    STRING                { JsonValue::String($1) }

///|
fn yy_action_6(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_JsonValue(
    {
      ()
      JsonValue::String(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 40|    NUMBER                { JsonValue::Number($1) }

///|
fn yy_action_7(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Double(_dollar1)
  YYObj_JsonValue(
    {
      ()
      JsonValue::Number(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 41|    TRUE                  { JsonValue::Boolean(true) }

///|
fn yy_action_8(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_JsonValue(
    {
      ()
      JsonValue::Boolean(true)
    },
  )
}

// file:///./parser.mbty
// 42|    FALSE                 { JsonValue::Boolean(false) }

///|
fn yy_action_9(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_JsonValue(
    {
      ()
      JsonValue::Boolean(false)
    },
  )
}

// file:///./parser.mbty
// 43|    NULL                  { JsonValue::Null }

///|
fn yy_action_10(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_JsonValue(
    {
      ()
      JsonValue::Null
    },
  )
}

// file:///./parser.mbty
// 44|    object                { JsonValue::Object($1) }

///|
fn yy_action_11(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Object(_dollar1)
  YYObj_JsonValue(
    {
      ()
      JsonValue::Object(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 45|    array                 { JsonValue::Array($1) }



///|
pub fn yy_action_12(_last_pos: Int, _args: ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array(arrs)
    let arr: Array[JsonValue] = if arrs.length() == 1 {
      arrs[0]
    } else {
      let flat: Array[JsonValue] = Array::new()
      for sub in arrs {
        for v in sub {
          flat.push(v)
        }
      }
      flat
    }
    YYObj_JsonValue(
      {
        ()
        JsonValue::Array(arr)
      },
    )
}

// file:///./parser.mbty
// 62|    STRING COLON json_value { ($1, $3) }

///|
fn yy_action_13(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_JsonValue(_dollar3)
  YYObj__String__JsonValue_(
    {
      ()
      (_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 75|    json_value COMMA elements { @list.More($1, $3) }

///|
fn yy_action_14(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_JsonValue(_dollar1)
  guard _args[2].0 is YYObj__list_List_JsonValue_(_dollar3)
  YYObj__list_List_JsonValue_(
    {
      ()
      @list.cons(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 74|    json_value           { @list.More($1, @list.Empty) }

///|
fn yy_action_15(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_JsonValue(_dollar1)
  YYObj__list_List_JsonValue_(
    {
      ()
       @list.new().prepend(_dollar1) // 创建空列表后 prepend 元素s
    },
  )
}

///|
fn yy_input(
  token : Token,
  _start_pos : Int,
  _end_pos : Int,
) -> (YYSymbol, YYObj) {
  match token {
    STRING(data) => (T_STRING, YYObj_String(data))
    NUMBER(data) => (T_NUMBER, YYObj_Double(data))
    TRUE => (T_TRUE, YYObj_Void)
    FALSE => (T_FALSE, YYObj_Void)
    NULL => (T_NULL, YYObj_Void)
    LBRACE => (T_LBRACE, YYObj_Void)
    RBRACE => (T_RBRACE, YYObj_Void)
    LBRACKET => (T_LBRACKET, YYObj_Void)
    RBRACKET => (T_RBRACKET, YYObj_Void)
    COLON => (T_COLON, YYObj_Void)
    COMMA => (T_COMMA, YYObj_Void)
  }
}

// [0, json_value → • STRING, $]
// [1, json_value → • NUMBER, $]
// [2, json_value → • TRUE, $]
// [3, json_value → • FALSE, $]
// [4, json_value → • NULL, $]
// [5, json_value → • object, $]
// [6, json_value → • array, $]
// [7, object → • LBRACE RBRACE, $]
// [8, object → • LBRACE members RBRACE, $]
// [12, array → • LBRACKET RBRACKET, $]
// [13, array → • LBRACKET elements RBRACKET, $]
// [16, json_value_prime → • json_value, $]

///|
fn yy_state_0(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_json_value => Shift(yy_state_1)
    T_LBRACKET => Shift(yy_state_2)
    T_LBRACE => Shift(yy_state_6)
    NT_array => Shift(yy_state_10)
    NT_object => Shift(yy_state_11)
    T_NULL => Shift(yy_state_12)
    T_FALSE => Shift(yy_state_13)
    T_TRUE => Shift(yy_state_14)
    T_NUMBER => Shift(yy_state_15)
    T_STRING => Shift(yy_state_16)
    _ => Error
  }
}

// [16, json_value_prime → json_value •, $]

///|
fn yy_state_1(_lookahead : YYSymbol) -> YYDecision {
  Accept
}

// [0, json_value → • STRING, RBRACKET / COMMA]
// [1, json_value → • NUMBER, RBRACKET / COMMA]
// [2, json_value → • TRUE, RBRACKET / COMMA]
// [3, json_value → • FALSE, RBRACKET / COMMA]
// [4, json_value → • NULL, RBRACKET / COMMA]
// [5, json_value → • object, RBRACKET / COMMA]
// [6, json_value → • array, RBRACKET / COMMA]
// [7, object → • LBRACE RBRACE, RBRACKET / COMMA]
// [8, object → • LBRACE members RBRACE, RBRACKET / COMMA]
// [12, array → • LBRACKET RBRACKET, RBRACKET / COMMA]
// [12, array → LBRACKET • RBRACKET, $ / RBRACE / RBRACKET / COMMA]
// [13, array → • LBRACKET elements RBRACKET, RBRACKET / COMMA]
// [13, array → LBRACKET • elements RBRACKET, $ / RBRACE / RBRACKET / COMMA]
// [14, elements → • json_value, RBRACKET]
// [15, elements → • json_value COMMA elements, RBRACKET]

///|
fn yy_state_2(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACKET => Shift(yy_state_2)
    NT_json_value => Shift(yy_state_3)
    T_LBRACE => Shift(yy_state_6)
    NT_array => Shift(yy_state_10)
    NT_object => Shift(yy_state_11)
    T_NULL => Shift(yy_state_12)
    T_FALSE => Shift(yy_state_13)
    T_TRUE => Shift(yy_state_14)
    T_NUMBER => Shift(yy_state_15)
    T_STRING => Shift(yy_state_16)
    NT_elements => Shift(yy_state_23)
    T_RBRACKET => Shift(yy_state_25)
    _ => Error
  }
}

// [14, elements → json_value •, RBRACKET]
// [15, elements → json_value • COMMA elements, RBRACKET]

///|
fn yy_state_3(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_4)
    T_RBRACKET => Reduce(1, NT_elements, yy_action_15)
    _ => Error
  }
}

// [0, json_value → • STRING, RBRACKET / COMMA]
// [1, json_value → • NUMBER, RBRACKET / COMMA]
// [2, json_value → • TRUE, RBRACKET / COMMA]
// [3, json_value → • FALSE, RBRACKET / COMMA]
// [4, json_value → • NULL, RBRACKET / COMMA]
// [5, json_value → • object, RBRACKET / COMMA]
// [6, json_value → • array, RBRACKET / COMMA]
// [7, object → • LBRACE RBRACE, RBRACKET / COMMA]
// [8, object → • LBRACE members RBRACE, RBRACKET / COMMA]
// [12, array → • LBRACKET RBRACKET, RBRACKET / COMMA]
// [13, array → • LBRACKET elements RBRACKET, RBRACKET / COMMA]
// [14, elements → • json_value, RBRACKET]
// [15, elements → • json_value COMMA elements, RBRACKET]
// [15, elements → json_value COMMA • elements, RBRACKET]

///|
fn yy_state_4(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACKET => Shift(yy_state_2)
    NT_json_value => Shift(yy_state_3)
    NT_elements => Shift(yy_state_5)
    T_LBRACE => Shift(yy_state_6)
    NT_array => Shift(yy_state_10)
    NT_object => Shift(yy_state_11)
    T_NULL => Shift(yy_state_12)
    T_FALSE => Shift(yy_state_13)
    T_TRUE => Shift(yy_state_14)
    T_NUMBER => Shift(yy_state_15)
    T_STRING => Shift(yy_state_16)
    _ => Error
  }
}

// [15, elements → json_value COMMA elements •, RBRACKET]

///|
fn yy_state_5(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_elements, yy_action_14)
}

// [7, object → LBRACE • RBRACE, $ / RBRACE / RBRACKET / COMMA]
// [8, object → LBRACE • members RBRACE, $ / RBRACE / RBRACKET / COMMA]
// [9, members → • member, RBRACE]
// [10, members → • member COMMA members, RBRACE]
// [11, member → • STRING COLON json_value, RBRACE / COMMA]

///|
fn yy_state_6(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_STRING => Shift(yy_state_7)
    NT_member => Shift(yy_state_17)
    NT_members => Shift(yy_state_20)
    T_RBRACE => Shift(yy_state_22)
    _ => Error
  }
}

// [11, member → STRING • COLON json_value, RBRACE / COMMA]

///|
fn yy_state_7(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLON => Shift(yy_state_8)
    _ => Error
  }
}

// [0, json_value → • STRING, RBRACE / COMMA]
// [1, json_value → • NUMBER, RBRACE / COMMA]
// [2, json_value → • TRUE, RBRACE / COMMA]
// [3, json_value → • FALSE, RBRACE / COMMA]
// [4, json_value → • NULL, RBRACE / COMMA]
// [5, json_value → • object, RBRACE / COMMA]
// [6, json_value → • array, RBRACE / COMMA]
// [7, object → • LBRACE RBRACE, RBRACE / COMMA]
// [8, object → • LBRACE members RBRACE, RBRACE / COMMA]
// [11, member → STRING COLON • json_value, RBRACE / COMMA]
// [12, array → • LBRACKET RBRACKET, RBRACE / COMMA]
// [13, array → • LBRACKET elements RBRACKET, RBRACE / COMMA]

///|
fn yy_state_8(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACKET => Shift(yy_state_2)
    T_LBRACE => Shift(yy_state_6)
    NT_json_value => Shift(yy_state_9)
    NT_array => Shift(yy_state_10)
    NT_object => Shift(yy_state_11)
    T_NULL => Shift(yy_state_12)
    T_FALSE => Shift(yy_state_13)
    T_TRUE => Shift(yy_state_14)
    T_NUMBER => Shift(yy_state_15)
    T_STRING => Shift(yy_state_16)
    _ => Error
  }
}

// [11, member → STRING COLON json_value •, RBRACE / COMMA]

///|
fn yy_state_9(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_member, yy_action_13)
}

// [6, json_value → array •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_10(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_json_value, yy_action_12)
}

// [5, json_value → object •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_11(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_json_value, yy_action_11)
}

// [4, json_value → NULL •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_12(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_json_value, yy_action_10)
}

// [3, json_value → FALSE •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_13(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_json_value, yy_action_9)
}

// [2, json_value → TRUE •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_14(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_json_value, yy_action_8)
}

// [1, json_value → NUMBER •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_15(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_json_value, yy_action_7)
}

// [0, json_value → STRING •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_16(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_json_value, yy_action_6)
}

// [9, members → member •, RBRACE]
// [10, members → member • COMMA members, RBRACE]

///|
fn yy_state_17(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_18)
    T_RBRACE => Reduce(1, NT_members, yy_action_5)
    _ => Error
  }
}

// [9, members → • member, RBRACE]
// [10, members → • member COMMA members, RBRACE]
// [10, members → member COMMA • members, RBRACE]
// [11, member → • STRING COLON json_value, RBRACE / COMMA]

///|
fn yy_state_18(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_STRING => Shift(yy_state_7)
    NT_member => Shift(yy_state_17)
    NT_members => Shift(yy_state_19)
    _ => Error
  }
}

// [10, members → member COMMA members •, RBRACE]

///|
fn yy_state_19(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_members, yy_action_4)
}

// [8, object → LBRACE members • RBRACE, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_20(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RBRACE => Shift(yy_state_21)
    _ => Error
  }
}

// [8, object → LBRACE members RBRACE •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_21(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_object, yy_action_3)
}

// [7, object → LBRACE RBRACE •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_22(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_object, yy_action_2)
}

// [13, array → LBRACKET elements • RBRACKET, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_23(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RBRACKET => Shift(yy_state_24)
    _ => Error
  }
}

// [13, array → LBRACKET elements RBRACKET •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_24(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_array, yy_action_1)
}

// [12, array → LBRACKET RBRACKET •, $ / RBRACE / RBRACKET / COMMA]

///|
fn yy_state_25(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_array, yy_action_0)
}

///|
fn[T] yy_parse(
  tokens : Array[(Token, Int, Int)],
  start : YYState,
  return_ : (YYObj) -> T,
  initial_pos? : Int,
) -> T raise ParseError {
  let mut cursor = 0
  let mut state_stack : @list.List[YYState] = @list.cons(start, @list.empty())
  let data_stack : Array[(YYObj, Int, Int)] = []
  let mut last_pos = initial_pos.unwrap_or(tokens[0].1)
  let mut state = start
  let mut lookahead : (YYSymbol, (YYObj, Int, Int), Token?)? = None
  let mut last_shifted_state_stack = state_stack
  while true {
    let decision = match state(EOI) {
      ReduceNoLookahead(_) | Accept as t => t
      _ =>
        match lookahead {
          Some(la) => state(la.0)
          None =>
            if cursor < tokens.length() {
              let (token, start_pos, end_pos) = tokens[cursor]
              cursor += 1
              let (symbol, data) = yy_input(token, start_pos, end_pos)
              lookahead = Some(
                (symbol, (data, start_pos, end_pos), Some(token)),
              )
              state(symbol)
            } else {
              lookahead = Some((EOI, (YYObj_Void, last_pos, last_pos), None))
              state(EOI)
            }
        }
    }
    match decision {
      Accept => return return_(data_stack.unsafe_pop().0)
      Shift(next_state) => {
        guard lookahead is Some(la)
        data_stack.push(la.1)
        state_stack = @list.cons(next_state, state_stack)
        last_shifted_state_stack = state_stack
        state = next_state
        last_pos = la.1.2
        lookahead = None
      }
      Reduce(count, symbol, action)
      | ReduceNoLookahead(count, symbol, action) =>
        loop (count, symbol, action) {
          _ => {
            let args = data_stack[data_stack.length() - count:]
            let data = action(last_pos, args)
            let (start_pos, end_pos) = if args.length() == 0 {
              (last_pos, last_pos)
            } else {
              (args[0].1, args[args.length() - 1].2)
            }
            for i in 0..<count {
              ignore(data_stack.unsafe_pop())
              state_stack = state_stack.unsafe_tail()
            }
            state = state_stack.unsafe_head()
            data_stack.push((data, start_pos, end_pos))
            match state(symbol) {
              Accept => return return_(data_stack.unsafe_pop().0)
              Shift(next_state) => {
                state_stack = @list.cons(next_state, state_stack)
                state = next_state
              }
              Reduce(count, symbol, action)
              | ReduceNoLookahead(count, symbol, action) =>
                continue (count, symbol, action)
              _ => panic()
            }
          }
        }
      Error => {
        let (_, (_, start_pos, end_pos), token) = lookahead.unwrap()
        error(last_shifted_state_stack, token, (start_pos, end_pos))
      }
    }
  }
  panic()
}

///|
fn error(
  stack : @list.List[YYState],
  token : Token?,
  loc : (Int, Int),
) -> Unit raise ParseError {
  let expected = []
  fn try_add(symbol : YYSymbol, kind : TokenKind) {
    fn go(stack : @list.List[YYState]) {
      match stack {
        Empty => ()
        More(state, ..) =>
          match state(symbol) {
            Accept | Shift(_) => expected.push(kind)
            Reduce(count, symbol, _) | ReduceNoLookahead(count, symbol, _) => {
              fn inner_go(stack : @list.List[YYState], count, symbol) {
                let stack = stack.drop(count)
                guard stack is More(state, ..)
                match state(symbol) {
                  Shift(state) => go(@list.cons(state, stack))
                  Reduce(count, symbol, _)
                  | ReduceNoLookahead(count, symbol, _) =>
                    inner_go(stack, count, symbol)
                  _ => panic()
                }
              }

              inner_go(stack, count, symbol)
            }
            Error => ()
          }
      }
    }

    go(stack)
  }

  for
    term in (
      [
        (T_STRING, TK_STRING),
        (T_NUMBER, TK_NUMBER),
        (T_TRUE, TK_TRUE),
        (T_FALSE, TK_FALSE),
        (T_NULL, TK_NULL),
        (T_LBRACE, TK_LBRACE),
        (T_RBRACE, TK_RBRACE),
        (T_LBRACKET, TK_LBRACKET),
        (T_RBRACKET, TK_RBRACKET),
        (T_COLON, TK_COLON),
        (T_COMMA, TK_COMMA),
      ] : Array[(YYSymbol, TokenKind)]) {
    try_add(term.0, term.1)
  }
  match token {
    None => raise UnexpectedEndOfInput(loc.1, expected)
    Some(token) => raise UnexpectedToken(token, loc, expected)
  }
}

///|
pub fn json_value(
  tokens : Array[(Token, Int, Int)],
  initial_pos? : Int,
) -> JsonValue raise ParseError {
  yy_parse(
    tokens,
    yy_state_0,
    it => {
      guard it is YYObj_JsonValue(result)
      result
    },
    initial_pos?,
  )
}

// 辅助函数：将 List[(String, JsonValue)] 转换为 Map[String, JsonValue]

///|
fn list_to_map(lst: @list.List[(String, JsonValue)]) -> @builtin.Map[String, JsonValue] {
  let map = @builtin.Map::new()
  let mut cur = lst
  while not(cur.is_empty()) {
    match cur.head() {
      Some((key, value)) => map.set(key, value)
      None => ()
    }
    cur = cur.unsafe_tail()
  }
  map
}

// 辅助函数：将 List[JsonValue] 转换为 Array[JsonValue]

///|
fn list_to_array(lst: @list.List[JsonValue]) -> Array[JsonValue] {
  let arr = Array::new()
  let mut cur = lst
  while not(cur.is_empty()) {
    match cur.head() {
      Some(val) => arr.push(val)
      None => ()
    }
    cur = cur.unsafe_tail()
  }
  arr
}

// 可选的初始化代码

///|
fn init {
  // 例如，初始化词法分析器或注册解析器
}

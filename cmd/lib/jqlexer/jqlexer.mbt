///|
struct Lexbuf {
  content : String
  mut pos : Int
}


///|
fn next(self : Lexbuf) -> Char? {
  if self.pos < self.content.length() {
    let ch = self.content[self.pos]
    self.pos += 1
    Some(ch.unsafe_to_char())
  } else {
    None
  }
}

pub fn Lexbuf::get_string(self: Lexbuf, start: Int, end: Int) -> String {
  self.content.substring(start~, end~)
}

pub fn Lexbuf::get_char(self: Lexbuf, start: Int, end: Int) -> String {
  self.content.substring(start~, end~)
}

pub fn Lexbuf::reset(self: Lexbuf, pos: Int) -> Unit {
  self.pos = pos
}

pub fn Lexbuf::next_as_int(self: Lexbuf) -> Int {
  match self.next() {
    Some(c) => c.to_int()
    None => 0 // Using 0 to represent EOF
  }
}

pub fn Lexbuf::from_string(s: String) -> Lexbuf {
  { content: s, pos: 0 }
}

pub fn Lexbuf::curr_pos(self: Lexbuf) -> Int {
  self.pos
}

pub enum Token {
  WHITESPACE // Explicitly include WHITESPACE as a token
  DOT        // .
  PIPE       // |
  IDENT(String) // fieldName (e.g., name, age)
  NUMBER(String) // 123, 1.23
  STRING(String) // "hello" - will include quotes
  TRUE       // true
  FALSE      // false
  NULL       // null
  LBRACKET   // [
  RBRACKET   // ]
  LBRACE     // {
  RBRACE     // }
  LPAREN     // (
  RPAREN     // )
  COMMA      // ,
  COLON      // :
  EQ         // ==
  GT         // >
  LT         // <
  GTE        // >=
  LTE        // <=
  PLUS       // +
  MINUS      // -
  STAR       // *
  SLASH      // /
  AND        // and
  OR         // or
  NOT        // not
  SELECT     // select keyword
  EOF        // End of File
  ILLEGAL    // Unrecognized token (explicitly included)
} derive(ToJson(style = "legacy"), Eq)

pub suberror LexError {
  EndOfFile
  UnexpectedEndOfFile
  Unrecognized(String)
}


pub fn token(lexbuf: Lexbuf) -> Token raise LexError  {
  // The matched pattern id
  let mut _match_pattern = @int.max_value
  let mut _match_start = lexbuf.curr_pos()
  let mut _match_end = -1
  let mut _capture_0_start = -1
  let mut _capture_0_end = -1
  let mut _capture_1_start = -1
  let mut _capture_1_end = -1

  // Handle EOF explicitly at the beginning
  if lexbuf.curr_pos() == lexbuf.content.length() {
    return EOF
  }

  loop 0 {
    0 => {
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        0..=8 => 1
        9..=10 => 2
        11..=12 => 1
        13 => 2
        14..=31 => 1
        32 => 2
        33 => 1
        34 => 3
        35..=39 => 1
        40 => 4
        41 => 5
        42 => 6
        43 => 7
        44 => 8
        45 => 9
        46 => 10
        47 => 11
        48 => 12
        49..=57 => 13
        58 => 14
        59 => 1
        60 => 15
        61 => 16
        62 => 17
        63..=64 => 1
        65..=90 => 18
        91 => 19
        92 => 1
        93 => 20
        94 => 1
        95 => 18
        96 => 1
        97 => 21
        98..=101 => 18
        102 => 22
        103..=109 => 18
        110 => 23
        111 => 24
        112..=114 => 18
        115 => 25
        116 => 26
        117..=122 => 18
        123 => 27
        124 => 28
        125 => 29
        126..=1114111 => 1
        _ => break
      }
    }
    1 => {
      _match_pattern = 31
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      break
    }
    2 => {
      _match_pattern = 0
      _match_end = lexbuf.curr_pos()
      break
    }
    3 => {
      _match_pattern = 28
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      break
    }
    4 => {
      _match_pattern = 10
      _match_end = lexbuf.curr_pos()
      break
    }
    5 => {
      _match_pattern = 11
      _match_end = lexbuf.curr_pos()
      break
    }
    6 => {
      _match_pattern = 18
      _match_end = lexbuf.curr_pos()
      break
    }
    7 => {
      _match_pattern = 16
      _match_end = lexbuf.curr_pos()
      break
    }
    8 => {
      _match_pattern = 12
      _match_end = lexbuf.curr_pos()
      break
    }
    9 => {
      _match_pattern = 17
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        48 => 12
        49..=57 => 13
        _ => break
      }
    }
    10 => {
      _match_pattern = 4
      _match_end = lexbuf.curr_pos()
      break
    }
    11 => {
      _match_pattern = 19
      _match_end = lexbuf.curr_pos()
      break
    }
    12 => {
      _match_pattern = 27
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        69 => 31
        101 => 31
        _ => break
      }
    }
    13 => {
      _match_pattern = 27
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        46 => 30
        48..=57 => 13
        69 => 31
        101 => 31
        _ => break
      }
    }
    14 => {
      _match_pattern = 13
      _match_end = lexbuf.curr_pos()
      break
    }
    15 => {
      _match_pattern = 15
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        61 => 39
        _ => break
      }
    }
    16 => {
      _match_pattern = 31
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      continue match lexbuf.next_as_int() {
        61 => 41
        _ => break
      }
    }
    17 => {
      _match_pattern = 14
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        61 => 40
        _ => break
      }
    }
    18 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=122 => 18
        _ => break
      }
    }
    19 => {
      _match_pattern = 6
      _match_end = lexbuf.curr_pos()
      break
    }
    20 => {
      _match_pattern = 7
      _match_end = lexbuf.curr_pos()
      break
    }
    21 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=109 => 18
        110 => 37
        111..=122 => 18
        _ => break
      }
    }
    22 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97 => 32
        98..=122 => 18
        _ => break
      }
    }
    23 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=110 => 18
        111 => 34
        112..=116 => 18
        117 => 35
        118..=122 => 18
        _ => break
      }
    }
    24 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=113 => 18
        114 => 36
        115..=122 => 18
        _ => break
      }
    }
    25 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=100 => 18
        101 => 38
        102..=122 => 18
        _ => break
      }
    }
    26 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=113 => 18
        114 => 33
        115..=122 => 18
        _ => break
      }
    }
    27 => {
      _match_pattern = 8
      _match_end = lexbuf.curr_pos()
      break
    }
    28 => {
      _match_pattern = 5
      _match_end = lexbuf.curr_pos()
      break
    }
    29 => {
      _match_pattern = 9
      _match_end = lexbuf.curr_pos()
      break
    }
    30 => {
      continue match lexbuf.next_as_int() {
        48..=57 => 44
        _ => break
      }
    }
    31 => {
      continue match lexbuf.next_as_int() {
        43 => 42
        45 => 42
        48..=57 => 43
        _ => break
      }
    }
    32 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=107 => 18
        108 => 45
        109..=122 => 18
        _ => break
      }
    }
    33 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=116 => 18
        117 => 46
        118..=122 => 18
        _ => break
      }
    }
    34 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=115 => 18
        116 => 48
        117..=122 => 18
        _ => break
      }
    }
    35 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=107 => 18
        108 => 47
        109..=122 => 18
        _ => break
      }
    }
    36 => {
      _match_pattern = 22
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=122 => 18
        _ => break
      }
    }
    37 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=99 => 18
        100 => 49
        101..=122 => 18
        _ => break
      }
    }
    38 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=107 => 18
        108 => 50
        109..=122 => 18
        _ => break
      }
    }
    39 => {
      _match_pattern = 3
      _match_end = lexbuf.curr_pos()
      break
    }
    40 => {
      _match_pattern = 2
      _match_end = lexbuf.curr_pos()
      break
    }
    41 => {
      _match_pattern = 1
      _match_end = lexbuf.curr_pos()
      break
    }
    42 => {
      continue match lexbuf.next_as_int() {
        48..=57 => 43
        _ => break
      }
    }
    43 => {
      _match_pattern = 27
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 43
        _ => break
      }
    }
    44 => {
      _match_pattern = 27
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 44
        69 => 31
        101 => 31
        _ => break
      }
    }
    45 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=114 => 18
        115 => 51
        116..=122 => 18
        _ => break
      }
    }
    46 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=100 => 18
        101 => 52
        102..=122 => 18
        _ => break
      }
    }
    47 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=107 => 18
        108 => 53
        109..=122 => 18
        _ => break
      }
    }
    48 => {
      _match_pattern = 23
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=122 => 18
        _ => break
      }
    }
    49 => {
      _match_pattern = 21
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=122 => 18
        _ => break
      }
    }
    50 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=100 => 18
        101 => 54
        102..=122 => 18
        _ => break
      }
    }
    51 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=100 => 18
        101 => 55
        102..=122 => 18
        _ => break
      }
    }
    52 => {
      _match_pattern = 24
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=122 => 18
        _ => break
      }
    }
    53 => {
      _match_pattern = 26
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=122 => 18
        _ => break
      }
    }
    54 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=98 => 18
        99 => 56
        100..=122 => 18
        _ => break
      }
    }
    55 => {
      _match_pattern = 25
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=122 => 18
        _ => break
      }
    }
    56 => {
      _match_pattern = 29
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=115 => 18
        116 => 57
        117..=122 => 18
        _ => break
      }
    }
    57 => {
      _match_pattern = 20
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        48..=57 => 18
        65..=90 => 18
        95 => 18
        97..=122 => 18
        _ => break
      }
    }
    _ => panic()
  }

  guard _match_pattern <= 31 else {
    // No pattern matched
    panic()
  }

  lexbuf.reset(_match_end)
  match _match_pattern {
    0 => { return WHITESPACE }
    1 => { return EQ }
    2 => { return GTE }
    3 => { return LTE }
    4 => { return DOT }
    5 => { return PIPE }
    6 => { return LBRACKET }
    7 => { return RBRACKET }
    8 => { return LBRACE }
    9 => { return RBRACE }
    10 => { return LPAREN }
    11 => { return RPAREN }
    12 => { return COMMA }
    13 => { return COLON }
    14 => { return GT }
    15 => { return LT }
    16 => { return PLUS }
    17 => { return MINUS }
    18 => { return STAR }
    19 => { return SLASH }
    20 => { return SELECT }
    21 => { return AND }
    22 => { return OR }
    23 => { return NOT }
    24 => { return TRUE }
    25 => { return FALSE }
    26 => { return NULL }
    27 => {
      let t = lexbuf.get_string(_capture_0_start, _capture_0_end)
      return NUMBER(t)
    }
    28 => {
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)

      let buf = StringBuilder::new()
      buf.write_string(t) // Write the opening quote
      lex_string(buf, lexbuf) // lex_string will write content and closing quote
      return STRING(buf.to_string())
    }
    29 => {
      let t = lexbuf.get_string(_capture_0_start, _capture_0_end)
      return IDENT(t)
    }
    30 => { return EOF }
    31 => {
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)
      raise(Unrecognized(t))
    }
    _ => panic()
  }
}


pub fn lex_string(buf : StringBuilder, lexbuf: Lexbuf) -> Unit raise LexError  {
  // The matched pattern id
  let mut _match_pattern = @int.max_value
  let mut _match_start = lexbuf.curr_pos()
  let mut _match_end = -1
  let mut _capture_0_start = -1
  let mut _capture_0_end = -1
  let mut _capture_1_start = -1
  let mut _capture_1_end = -1
  loop 0 {
    0 => {
      _match_pattern = 4
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
        0..=31 => 1
        32..=33 => 2
        34 => 3
        35..=91 => 2
        92 => 4
        93..=126 => 2
        127 => 1
        128..=1114111 => 2
        _ => break
      }
    }
    1 => {
      _match_pattern = 3
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      break
    }
    2 => {
      _match_pattern = 2
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      break
    }
    3 => {
      _match_pattern = 0
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      break
    }
    4 => {
      _match_pattern = 3
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      continue match lexbuf.next_as_int() {
        34 => 5
        47 => 5
        92 => 5
        98 => 5
        102 => 5
        110 => 5
        114 => 5
        116 => 5
        117 => 6
        _ => break
      }
    }
    5 => {
      _match_pattern = 1
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      break
    }
    6 => {
      continue match lexbuf.next_as_int() {
        48..=57 => 7
        65..=70 => 7
        97..=102 => 7
        _ => break
      }
    }
    7 => {
      continue match lexbuf.next_as_int() {
        48..=57 => 8
        65..=70 => 8
        97..=102 => 8
        _ => break
      }
    }
    8 => {
      continue match lexbuf.next_as_int() {
        48..=57 => 9
        65..=70 => 9
        97..=102 => 9
        _ => break
      }
    }
    9 => {
      continue match lexbuf.next_as_int() {
        48..=57 => 5
        65..=70 => 5
        97..=102 => 5
        _ => break
      }
    }
    _ => panic()
  }

  guard _match_pattern <= 4 else {
    // No pattern matched
    panic()
  }

  lexbuf.reset(_match_end)
  match _match_pattern {
    0 => {
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)
      buf.write_string(t)
      return ()
    }
    1 => {
      let t = lexbuf.get_string(_capture_0_start, _capture_0_end)

      buf.write_string(t)
      lex_string(buf, lexbuf)
      return ()
    }
    2 => {
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)

      buf.write_string(t)
      lex_string(buf, lexbuf)
      return ()
    }
    3 => {
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)
      raise(Unrecognized(t))
    }
    4 => {
      raise(UnexpectedEndOfFile)
    }
    _ => panic()
  }
}

///|





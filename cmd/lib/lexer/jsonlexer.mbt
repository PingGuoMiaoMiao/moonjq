pub suberror LexError {
  EndOfFile
  UnexpectedEndOfFile
  Unrecognized(String)
}

// 简单的字符串到 Double 解析器，支持可选符号、小数部分和指数部分。
fn str_to_double(s: String) -> Double {
  // We iterate by codepoint index using safe get_char().unwrap().
  let len = s.length()
  let mut i = 0
  let mut sign = 1.0
  if i < len {
    let c = s.get_char(i).unwrap()
    if c == '-' { sign = -1.0; i = i + 1 }
    else if c == '+' { i = i + 1 }
  }

  let mut int_part: Double = 0.0
  while i < len {
    let c = s.get_char(i).unwrap()
    if c >= '0' && c <= '9' {
      int_part = int_part * 10.0 + Double::from_int(char_digit(c))
      i = i + 1
    } else {
      break
    }
  }

  let mut frac_part: Double = 0.0
  let mut frac_div: Double = 1.0
  if i < len && s.get_char(i).unwrap() == '.' {
    i = i + 1
    while i < len {
      let c = s.get_char(i).unwrap()
      if c >= '0' && c <= '9' {
        frac_part = frac_part * 10.0 + Double::from_int(char_digit(c))
        frac_div = frac_div * 10.0
        i = i + 1
      } else { break }
    }
  }

  let mut exp_sign = 1
  let mut exp_val = 0
  if i < len {
    let c = s.get_char(i).unwrap()
    if c == 'e' || c == 'E' {
      i = i + 1
      if i < len {
        let c2 = s.get_char(i).unwrap()
        if c2 == '-' { exp_sign = -1; i = i + 1 }
        else if c2 == '+' { i = i + 1 }
      }
      while i < len {
        let c3 = s.get_char(i).unwrap()
        if c3 >= '0' && c3 <= '9' {
          exp_val = exp_val * 10 + char_digit(c3)
          i = i + 1
        } else { break }
      }
    }
  }

  let mut value = int_part + (if frac_div == 1.0 { 0.0 } else { frac_part / frac_div })
  if exp_val != 0 {
    let mut p = 1.0
    let mut k = 0
    while k < exp_val {
      p = p * 10.0
      k = k + 1
    }
    if exp_sign < 0 { value = value / p } else { value = value * p }
  }
  sign * value
}


// helper: convert a Char representing '0'..'9' to its Int digit value
fn char_digit(c: Char) -> Int {
  match c {
    '0' => 0
    '1' => 1
    '2' => 2
    '3' => 3
    '4' => 4
    '5' => 5
    '6' => 6
    '7' => 7
    '8' => 8
    '9' => 9
    _ => 0
  }
}


pub fn token(lexbuf : @lexbuf.StringLexbuf) -> @parser.Token raise LexError  {
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
      _match_pattern = 13
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
        35..=43 => 1
        44 => 4
        45 => 5
        46..=47 => 1
        48 => 6
        49..=57 => 7
        58 => 8
        59..=90 => 1
        91 => 9
        92 => 1
        93 => 10
        94..=101 => 1
        102 => 11
        103..=109 => 1
        110 => 12
        111..=115 => 1
        116 => 13
        117..=122 => 1
        123 => 14
        124 => 1
        125 => 15
        126..=1114111 => 1
        _ => break
      }
    }
    1 => {
      _match_pattern = 12
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
      _match_pattern = 2
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      break
    }
    4 => {
      _match_pattern = 7
      _match_end = lexbuf.curr_pos()
      break
    }
    5 => {
      _match_pattern = 12
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      continue match lexbuf.next_as_int() {
        48 => 6
        49..=57 => 7
        _ => break
      }
    }
    6 => {
      _match_pattern = 1
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        69 => 20
        101 => 20
        _ => break
      }
    }
    7 => {
      _match_pattern = 1
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        46 => 19
        48..=57 => 7
        69 => 20
        101 => 20
        _ => break
      }
    }
    8 => {
      _match_pattern = 8
      _match_end = lexbuf.curr_pos()
      break
    }
    9 => {
      _match_pattern = 5
      _match_end = lexbuf.curr_pos()
      break
    }
    10 => {
      _match_pattern = 6
      _match_end = lexbuf.curr_pos()
      break
    }
    11 => {
      _match_pattern = 12
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      continue match lexbuf.next_as_int() {
        97 => 17
        _ => break
      }
    }
    12 => {
      _match_pattern = 12
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      continue match lexbuf.next_as_int() {
        117 => 16
        _ => break
      }
    }
    13 => {
      _match_pattern = 12
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      continue match lexbuf.next_as_int() {
        114 => 18
        _ => break
      }
    }
    14 => {
      _match_pattern = 3
      _match_end = lexbuf.curr_pos()
      break
    }
    15 => {
      _match_pattern = 4
      _match_end = lexbuf.curr_pos()
      break
    }
    16 => {
      continue match lexbuf.next_as_int() {
        108 => 21
        _ => break
      }
    }
    17 => {
      continue match lexbuf.next_as_int() {
        108 => 22
        _ => break
      }
    }
    18 => {
      continue match lexbuf.next_as_int() {
        117 => 23
        _ => break
      }
    }
    19 => {
      continue match lexbuf.next_as_int() {
        48..=57 => 26
        _ => break
      }
    }
    20 => {
      continue match lexbuf.next_as_int() {
        43 => 24
        45 => 24
        48..=57 => 25
        _ => break
      }
    }
    21 => {
      continue match lexbuf.next_as_int() {
        108 => 27
        _ => break
      }
    }
    22 => {
      continue match lexbuf.next_as_int() {
        115 => 28
        _ => break
      }
    }
    23 => {
      continue match lexbuf.next_as_int() {
        101 => 29
        _ => break
      }
    }
    24 => {
      continue match lexbuf.next_as_int() {
        48..=57 => 25
        _ => break
      }
    }
    25 => {
      _match_pattern = 1
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 25
        _ => break
      }
    }
    26 => {
      _match_pattern = 1
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
        48..=57 => 26
        69 => 20
        101 => 20
        _ => break
      }
    }
    27 => {
      _match_pattern = 11
      _match_end = lexbuf.curr_pos()
      break
    }
    28 => {
      continue match lexbuf.next_as_int() {
        101 => 30
        _ => break
      }
    }
    29 => {
      _match_pattern = 9
      _match_end = lexbuf.curr_pos()
      break
    }
    30 => {
      _match_pattern = 10
      _match_end = lexbuf.curr_pos()
      break
    }
    _ => panic()
  }

  guard _match_pattern <= 13 else {
    // No pattern matched
    panic()
  }

  lexbuf.reset(pos=_match_end)
  match _match_pattern {
0 => {
  ()
  // Skip whitespace and get the next token
  token(lexbuf)
}
    1 => {
      ()
      let t = lexbuf.get_string(_capture_0_start, _capture_0_end)
      let n = str_to_double(t)
      NUMBER(n)
    }
    2 => {
      ()
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)

      let buf = StringBuilder::new()
      buf.write_char(t)
      lex_string(buf, lexbuf)
      STRING(buf.to_string())
    
    }
    3 => {
      ()
 LBRACE 
    }
    4 => {
      ()
 RBRACE 
    }
    5 => {
      ()
 LBRACKET 
    }
    6 => {
      ()
 RBRACKET 
    }
    7 => {
      ()
 COMMA 
    }
    8 => {
      ()
 COLON 
    }
    9 => {
      ()
 TRUE 
    }
    10 => {
      ()
 FALSE 
    }
    11 => {
      ()
 NULL 
    }
    12 => {
      ()
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)
 raise(Unrecognized(String::make(1, t))) 
    }
    13 => {
      ()
 raise(EndOfFile) 
    }
    _ => panic()
  }
}


pub fn lex_string(buf : StringBuilder, lexbuf : @lexbuf.StringLexbuf) -> Unit raise LexError  {
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

  lexbuf.reset(pos=_match_end)
  match _match_pattern {
    0 => {
      ()
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)
 buf.write_char(t) 
    }
    1 => {
      ()
      let t = lexbuf.get_string(_capture_0_start, _capture_0_end)
 
      buf.write_string(t)
      lex_string(buf, lexbuf)
    
    }
    2 => {
      ()
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)
 
      buf.write_char(t)
      lex_string(buf, lexbuf)
    
    }
    3 => {
      ()
      let t = lexbuf.get_char(_capture_0_start, _capture_0_end)
 raise(Unrecognized(String::make(1, t))) 
    }
    4 => {
      ()
 raise(UnexpectedEndOfFile) 
    }
    _ => panic()
  }
}




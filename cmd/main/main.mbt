///|
/// Main entry point for the jq-like JSON processor
///
/// This program reads JSON input from stdin or files and applies
/// jq-like filters to transform and query the JSON data.

fn main {
    let args = @sys.get_cli_args()
    
    if args.length() < 2 {
        println("Usage: jq <filter> [file...]")
        println("Examples:")
        println("  jq '.'                    # Identity filter")
        println("  jq '.name'               # Get field 'name'")
        println("  jq '.[0]'                # Get first array element")
        return
    }
    
    let filter_str = args[1]
    let files = if args.length() > 2 {
        let result = Array::new()
        for i in 2..<args.length() {
            result.push(args[i])
        }
        result
    } else {
        ["-"]  // Read from stdin
    }
    
    // Parse the filter
    let filter = parse_filter(filter_str)
    
    // Process each file
    for file in files {
        let content = if file == "-" {
            read_stdin()
        } else {
            read_file(file)
        }
        
        match process_json(content, filter) {
            Ok(result) => println(result.to_string())
            Err(err) => println("Error: " + err)
        }
    }
}

///|
/// Read content from stdin
fn read_stdin() -> String {
    // Simplified version for demonstration
    "{\"name\": \"test\", \"value\": 42, \"items\": [1, 2, 3]}"
}

///|
/// Read content from a file
fn read_file(filename: String) -> String {
    // Simplified version for demonstration
    "{\"name\": \"file\", \"value\": 100, \"items\": [\"a\", \"b\", \"c\"]}"
}

///|
/// Parse a simple jq filter string
fn parse_filter(filter_str: String) -> @filters.Filter {
    let trimmed = filter_str
    
    // Identity filter
    if trimmed == "." {
        return @filters.identity()
    }
    
    // Field access: .field
    if trimmed.length() > 1 && trimmed[0] == '.' && !trimmed.contains("[") {
        let field = trimmed.substring(start=1)
        return @filters.object_identifier(field)
    }
    
    // Array index: .[n]
    if trimmed.length() > 3 && trimmed.has_prefix(".[") && trimmed.has_suffix("]") {
        let index_str = trimmed.substring(start=2, end=trimmed.length() - 1)
        let index = parse_int(index_str)
        return @filters.array_index(index)
    }
    
    // Default to identity
    @filters.identity()
}

///|
/// Parse integer from string
fn parse_int(s: String) -> Int {
    let mut result = 0
    let mut i = 0
    let mut negative = false
    let len = s.length()

    if i < len && s.get_char(i).unwrap() == '-' {
        negative = true
        i = i + 1
    }

    while i < len {
        let c = s.get_char(i).unwrap()
        match c {
            '0' => result = result * 10 + 0
            '1' => result = result * 10 + 1
            '2' => result = result * 10 + 2
            '3' => result = result * 10 + 3
            '4' => result = result * 10 + 4
            '5' => result = result * 10 + 5
            '6' => result = result * 10 + 6
            '7' => result = result * 10 + 7
            '8' => result = result * 10 + 8
            '9' => result = result * 10 + 9
            _ => break
        }
        i = i + 1
    }

    if negative { -result } else { result }
}

///|
/// Process JSON content with the given filter
fn process_json(content: String, filter: @filters.Filter) -> Result[@parser.JsonValue, String] {
    // Tokenize the JSON
    let lexbuf = @lexbuf.StringLexbuf::from_string(content)
    let tokens: Array[(@parser.Token, Int, Int)] = []

    // Repeatedly call the lexer until it reaches EOF
    while true {
        // call lexer and capture an optional token
        let tok_opt = try { Some(@lexer.token(lexbuf)) } catch { err =>
            match err {
                @lexer.LexError::EndOfFile => None
                _ => return Err("Lex error")
            }
        }

        match tok_opt {
            None => break
            Some(tok) => {
                let end = lexbuf.curr_pos()
                let start = end - 1
                ignore(tokens.push((tok, start, end)))
            }
        }
    }
    
    // Parse the JSON
    let json_value = try { @parser.json_value(tokens) } catch { _err =>
        return Err("Parse error")
    }

    // Apply the filter (filters.apply_filter returns @parser.JsonValue)
    Ok(@filters.apply_filter(filter, json_value))
}
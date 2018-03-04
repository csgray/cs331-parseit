-- parseit.lua
-- Corey Gray
-- 25 February 2018
-- Source for parseit module for CS 331: Assignment 4 which is a recursive-descent parser
-- Heavily based on "rdparser4.lua" by Glenn G. Chappell
-- Requires lexit.lua

-- Grammar (with line numbers)
-- (01) program     →  	stmt_list
-- (02) stmt_list   →  	{ statement }
-- (03) statement   →  	‘input’ lvalue
-- (04)             |  	‘print’ print_arg { ‘;’ print_arg }
-- (05)             |  	‘func’ ID stmt_list ‘end’
-- (06)             |  	‘call’ ID
-- (07)             |  	‘if’ expr stmt_list { ‘elseif’ expr stmt_list } [ ‘else’ stmt_list ] ‘end’
-- (08)             |  	‘while’ expr stmt_list ‘end’
-- (09)             |  	lvalue ‘=’ expr
-- (10) print_arg   →  	‘cr’
-- (11)             |  	STRLIT
-- (12)             |  	expr
-- (13) expr        →  	comp_expr { ( ‘&&’ | ‘||’ ) comp_expr }
-- (14) comp_expr   →  	‘!’ comp_expr
-- (15)             |  	arith_expr { ( ‘==’ | ‘!=’ | ‘<’ | ‘<=’ | ‘>’ | ‘>=’ ) arith_expr }
-- (16) arith_expr  →  	term { ( ‘+’ | ‘-’ ) term }
-- (17) term        →  	factor { ( ‘*’ | ‘/’ | ‘%’ ) factor }
-- (18) factor      →  	‘(’ expr ‘)’
-- (19)             |  	( ‘+’ | ‘-’ ) factor
-- (20)             |  	‘call’ ID
-- (21)             |  	NUMLIT
-- (22)             |  	( ‘true’ | ‘false’ )
-- (23)             |  	lvalue
-- (24) lvalue      →  	ID [ ‘[’ expr ‘]’ ]
--
-- The following binary operators are left-associative:
-- &&, ||, ==, !=, <, <=, >, >=, binary +, binary -, *, /, %

local parseit = {}
lexit = require "lexit"

-- Symbolic Constants for AST
local STMT_LIST   = 1
local INPUT_STMT  = 2
local PRINT_STMT  = 3
local FUNC_STMT   = 4
local CALL_FUNC   = 5
local IF_STMT     = 6
local WHILE_STMT  = 7
local ASSN_STMT   = 8
local CR_OUT      = 9
local STRLIT_OUT  = 10
local BIN_OP      = 11
local UN_OP       = 12
local NUMLIT_VAL  = 13
local BOOLLIT_VAL = 14
local SIMPLE_VAR  = 15
local ARRAY_VAR   = 16

-- Variables
-- For lexer iteration
local iterator          -- Iterator returned by lexit.lex
local state             -- State for above iterator
local lexerOutString    -- First value returned from iterator
local lexerOutCategory  -- Second value returned from iterator
-- For current lexeme
local lexemeString = ""
local lexemeCategory = 0

-- Utility Functions
-- advance
-- Go to the next lexeme and load it into lexemeString, lexemeCategory.
-- Should be called once before any parsing is done.
-- Function initialize must be called before this function is called.
local function advance()
  lexerOutString, lexerOutCategory = iterator(state, lexerOutString)
  -- If we're not past the end, copy current lexeme into variables
  if lexerOutString ~= nil then
    lexemeString, lexemeCategory = lexerOutString, lexerOutCategory
  else
    lexemeString, lexemeCategory = "", 0
  end
end

-- initialize
-- Initial call. Sets the input for parsing functions.
local function initialize(program)
  iterator, state, lexerOutString = lexit.lex(program)
  advance()
end

-- atEnd
-- Return true if position has reached end of input.
-- Function init must be called before this function is called.
local function atEnd()
  return lexemeCategory == 0
end

-- matchString
-- Sees if current lexemeString is equal to given string.
-- If it is, advances to the next lexeme and returns true.
-- If it is not, then does not advance and returns false.
-- Function initialize must be called before this function is called.
local function matchString(string)
  if lexemeString == string then
    advance()
    return true
  else
    return false
  end
end

-- matchCategory
-- Sees if current lexemeCategory is qual to given lexeme category (integer).
-- If it is, advances to the next lexeme and returns true.
-- If it is not, does not advance and returns false.
-- Function initialize must be called before this function is called.
local function matchCategory(category)
  if lexemeCategory == category then
    advance()
    return true
  else
    return false
  end
end

-- Primary Function for Client Code

-- parse
-- Takes a program and returns two booleans and the AST.
-- Boolean 'good' indicates whether the parsing was succesful.
-- Boolean 'done' indicates whether the parser reached the end of the input.
-- The AST is only valid if both booleans are true.
function parseit.parse(program)
  initialize(program)
  local good, ast = parse_program()
  local done = atEnd()
  return good, done, ast
end

-- Parsing Functions
-- Each of the following is a parsing function for a nonterminal in the grammar.
-- Each function parses the nonterminal in its name and returns a pair: boolean, AST.
-- On a successful parse, the boolean is true, the AST is valid,
-- and the current lexeme is just past the end of the string the nonterminal expanded into.
-- Otherwise, the boolean is false, the AST is not valid, and no guarantees are made about the current lexeme.

-- parse_program
-- Parsing function for nonterminal "program"
-- Function initialize must be called before this function is called.
function parse_program()
  -- (01) Program
  local good, ast = parse_stmt_list()
  return good, ast
end

-- parse_stmt_list
-- Parsing function for nonterminal "stmt_list"
-- Function initialize must be called before this function is called.
function parse_stmt_list()
  local ast = { STMT_LIST }
  
  --io.write("Lexeme String: " .. lexemeString)
  --io.write("Lexeme Category: " .. lexemeCategory)
  if lexemeString ~= "input"
    and lexemeString ~= "print"
    and lexemeString ~= "func"
    and lexemeString ~= "call"
    and lexemeString ~= "if"
    and lexemeString ~= "while"
    and lexemeCategory ~= lexit.ID then
      return true, ast
  end
  return false, nil
end

-- parse_statement
-- Parsing function for nonterminal "statement"
function parse_statement()
  return true
end

-- parse_print_arg()
-- Parsing function for nonterminal "print_arg"
function parse_print_arg()
  return true
end

-- parse_expr
-- Parsing function for nonterminal "expr"
function parse_expr()
  return true
end

-- parse_comp_expr
-- Parsing function for nonterminal "comp_expr"
function parse_comp_expr()
  return true
end

-- parse_arith_expr
-- Parsing function for nonterminal "arith_expr"
function parse_arith_expr()
  return true
end

-- parse_term
-- Parsing function for nonterminal "term"
function parse_term()
  return true
end

-- parse_factor
-- Parsing function for nonterminal "factor"
function parse_factor()
  return true
end

-- parse_lvalue
-- Parsing function for nonterminal "lvalue"
function parse_lvalue()
  return true
end

return parseit
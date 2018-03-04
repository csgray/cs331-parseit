#!/usr/bin/env lua
-- parseit_test.lua
-- VERSION 2
-- Glenn G. Chappell
-- 23 Feb 2018
-- Updated 28 Feb 2018
--
-- For CS F331 / CSCE A331 Spring 2018
-- Test Program for Module parseit
-- Used in Assignment 4, Exercise A

parseit = require "parseit"  -- Import parseit module


-- *********************************************
-- * YOU MAY WISH TO CHANGE THE FOLLOWING LINE *
-- *********************************************

EXIT_ON_FIRST_FAILURE = true
-- If EXIT_ON_FIRST_FAILURE is true, then this program exits after the
-- first failing test. If it is false, then this program executes all
-- tests, reporting success/failure for each.


-- *********************************************************************
-- Testing Package
-- *********************************************************************


tester = {}
tester.countTests = 0
tester.countPasses = 0

function tester.test(self, success, testName)
    self.countTests = self.countTests+1
    io.write("    Test: " .. testName .. " - ")
    if success then
        self.countPasses = self.countPasses+1
        io.write("passed")
    else
        io.write("********** FAILED **********")
    end
    io.write("\n")
end

function tester.allPassed(self)
    return self.countPasses == self.countTests
end


-- *********************************************************************
-- Utility Functions
-- *********************************************************************


function fail_exit()
    if EXIT_ON_FIRST_FAILURE then
        io.write("**************************************************\n")
        io.write("* This test program is configured to exit after  *\n")
        io.write("* the first failing test. To make it execute all *\n")
        io.write("* tests, reporting success/failure for each, set *\n")
        io.write("* variable                                       *\n")
        io.write("*                                                *\n")
        io.write("*   EXIT_ON_FIRST_FAILURE                        *\n")
        io.write("*                                                *\n")
        io.write("* to false, near the start of the test program.  *\n")
        io.write("**************************************************\n")

        -- Wait for user
        io.write("\nPress ENTER to quit ")
        io.read("*l")

        -- Terminate program
        os.exit(1)
    end
end


-- printTable
-- Given a table, prints it in (roughly) Lua literal notation. If
-- parameter is not a table, prints <not a table>.
function printTable(t)
    -- out
    -- Print parameter, surrounded by double quotes if it is a string,
    -- or simply an indication of its type, if it is not number, string,
    -- or boolean.
    local function out(p)
        if type(p) == "number" then
            io.write(p)
        elseif type(p) == "string" then
            io.write('"'..p..'"')
        elseif type(p) == "boolean" then
            if p then
                io.write("true")
            else
                io.write("false")
            end
        else
            io.write('<'..type(p)..'>')
        end
    end

    if type(t) ~= "table" then
        io.write("<not a table>")
    end

    io.write("{ ")
    local first = true  -- First iteration of loop?
    for k, v in pairs(t) do
        if first then
            first = false
        else
            io.write(", ")
        end
        io.write("[")
        out(k)
        io.write("]=")
        out(v)
    end
    io.write(" }")
end


-- printArray
-- Given a table, prints it in (roughly) Lua literal notation for an
-- array. If parameter is not a table, prints <not a table>.
function printArray(t)
    -- out
    -- Print parameter, surrounded by double quotes if it is a string.
    local function out(p)
        if type(p) == "string" then io.write('"') end
        io.write(p)
        if type(p) == "string" then io.write('"') end
    end

    if type(t) ~= "table" then
        io.write("<not a table>")
    end

    io.write("{ ")
    local first = true  -- First iteration of loop?
    for k, v in ipairs(t) do
        if first then
            first = false
        else
            io.write(", ")
        end
        out(v)
    end
    io.write(" }")
end


-- tableEq
-- Compare equality of two tables.
-- Uses "==" on table values. Returns false if either of t1 or t2 is not
-- a table.
function tableEq(t1, t2)
    -- Both params are tables?
    local type1, type2 = type(t1), type(t2)
    if type1 ~= "table" or type2 ~= "table" then
        return false
    end

    -- Get number of keys in t1 & check values in t1, t2 are equal
    local t1numkeys = 0
    for k, v in pairs(t1) do
        t1numkeys = t1numkeys + 1
        if t2[k] ~= v then
            return false
        end
    end

    -- Check number of keys in t1, t2 same
    local t2numkeys = 0
    for k, v in pairs(t2) do
        t2numkeys = t2numkeys + 1
    end
    return t1numkeys == t2numkeys
end


-- *********************************************************************
-- Definitions for This Test Program
-- *********************************************************************


-- Symbolic Constants for AST
-- Names differ from those in assignment, to avoid interference.
local STMTxLIST   = 1
local INPUTxSTMT  = 2
local PRINTxSTMT  = 3
local FUNCxSTMT   = 4
local CALLxFUNC   = 5
local IFxSTMT     = 6
local WHILExSTMT  = 7
local ASSNxSTMT   = 8
local CRxOUT      = 9
local STRLITxOUT  = 10
local BINxOP      = 11
local UNxOP       = 12
local NUMLITxVAL  = 13
local BOOLLITxVAL = 14
local SIMPLExVAR  = 15
local ARRAYxVAR   = 16


-- String forms of symbolic constants

symbolNames = {
  [1]="STMT_LIST",
  [2]="INPUT_STMT",
  [3]="PRINT_STMT",
  [4]="FUNC_STMT",
  [5]="CALL_FUNC",
  [6]="IF_STMT",
  [7]="WHILE_STMT",
  [8]="ASSN_STMT",
  [9]="CR_OUT",
  [10]="STRLIT_OUT",
  [11]="BIN_OP",
  [12]="UN_OP",
  [13]="NUMLIT_VAL",
  [14]="BOOLLIT_VAL",
  [15]="SIMPLE_VAR",
  [16]="ARRAY_VAR",
}


-- writeAST_parseit
-- Write an AST, in (roughly) Lua form, with numbers replaced by the
-- symbolic constants used in parseit.
-- A table is assumed to represent an array.
-- See the Assignment 4 description for the AST Specification.
function writeAST_parseit(x)
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            io.write("<ERROR: Unknown constant: "..x..">")
        else
            io.write(name)
        end
    elseif type(x) == "string" then
        io.write('"'..x..'"')
    elseif type(x) == "boolean" then
        if x then
            io.write("true")
        else
            io.write("false")
        end
    elseif type(x) == "table" then
        local first = true
        io.write("{")
        for k = 1, #x do  -- ipairs is problematic
            if not first then
                io.write(", ")
            end
            writeAST_parseit(x[k])
            first = false
        end
        io.write("}")
    elseif type(x) == "nil" then
        io.write("nil")
    else
        io.write("<ERROR: "..type(x)..">")
    end
end


-- astEq
-- Checks equality of two ASTs, represented as in the Assignment 4
-- description. Returns true if equal, false otherwise.
function astEq(ast1, ast2)
    if type(ast1) ~= type(ast2) then
        return false
    end

    if type(ast1) ~= "table" then
        return ast1 == ast2
    end

    if #ast1 ~= #ast2 then
        return false
    end

    for k = 1, #ast1 do  -- ipairs is problematic
        if not astEq(ast1[k], ast2[k]) then
            return false
        end
    end
    return true
end


-- bool2Str
-- Given boolean, return string representing it: "true" or "false".
function bool2Str(b)
    if b then
        return "true"
    else
        return "false"
    end
end


-- checkParse
-- Given tester object, input string ("program"), expected output values
-- from parser (good, AST), and string giving the name of the test. Do
-- test & print result. If test fails and EXIT_ON_FIRST_FAILURE is true,
-- then print detailed results and exit program.
function checkParse(t, prog,
                    expectedGood, expectedDone, expectedAST,
                    testName)
    local actualGood, actualDone, actualAST = parseit.parse(prog)
    local sameGood = (expectedGood == actualGood)
    local sameDone = (expectedDone == actualDone)
    local sameAST = true
    if sameGood and expectedGood and sameDone and expectedDone then
        sameAST = astEq(expectedAST, actualAST)
    end
    local success = sameGood and sameDone and sameAST
    t:test(success, testName)

    if success or not EXIT_ON_FIRST_FAILURE then
        return
    end

    io.write("\n")
    io.write("Input for the last test above:\n")
    io.write('"'..prog..'"\n')
    io.write("\n")
    io.write("Expected parser 'good' return value: ")
    io.write(bool2Str(expectedGood).."\n")
    io.write("Actual parser 'good' return value: ")
    io.write(bool2Str(actualGood).."\n")
    io.write("Expected parser 'done' return value: ")
    io.write(bool2Str(expectedDone).."\n")
    io.write("Actual parser 'done' return value: ")
    io.write(bool2Str(actualDone).."\n")
    if not sameAST then
        io.write("\n")
        io.write("Expected AST:\n")
        writeAST_parseit(expectedAST)
        io.write("\n")
        io.write("\n")
        io.write("Returned AST:\n")
        writeAST_parseit(actualAST)
        io.write("\n")
    end
    io.write("\n")
    fail_exit()
end


-- *********************************************************************
-- Test Suite Functions
-- *********************************************************************


function test_simple(t)
    io.write("Test Suite: simple cases\n")

    checkParse(t, "", true, true, {STMTxLIST},
      "Empty program")
    checkParse(t, "end", true, false, nil,
      "Bad program: Keyword only #1")
    checkParse(t, "elseif", true, false, nil,
      "Bad program: Keyword only #2")
    checkParse(t, "else", true, false, nil,
      "Bad program: Keyword only #3")
    checkParse(t, "bc", false, true, nil,
      "Bad program: Identifier only")
    checkParse(t, "123", true, false, nil,
      "Bad program: NumericLiteral only")
    checkParse(t, "'xyz'", true, false, nil,
      "Bad program: StringLiteral only #1")
    checkParse(t, '"xyz"', true, false, nil,
      "Bad program: StringLiteral only #2")
    checkParse(t, "<=", true, false, nil,
      "Bad program: Operator only")
    checkParse(t, "{", true, false, nil,
      "Bad program: Punctuation only")
    checkParse(t, "\a", true, false, nil,
      "Bad program: Malformed only #1")
    checkParse(t, "'", true, false, nil,
      "bad program: malformed only #2")
end


function test_call_stmt(t)
    io.write("Test Suite: call statements\n")

    checkParse(t, "call s", true, true,
      {STMTxLIST,{CALLxFUNC,"s"}},
      "Call statement #1")
    checkParse(t, "call sssssssssssssssssssssssssssssssss", true, true,
      {STMTxLIST,{CALLxFUNC,"sssssssssssssssssssssssssssssssss"}},
      "Call statement #2")
    checkParse(t, "call sss call ttt", true, true,
      {STMTxLIST,{CALLxFUNC,"sss"},{CALLxFUNC,"ttt"}},
      "Two call statements")
    checkParse(t, "call call sss", false, false, nil,
      "Bad call statement: extra call")
    checkParse(t, "call sss sss", false, true, nil,
      "Bad call statement: extra name")
    checkParse(t, "call (sss)", false, false, nil,
      "Bad call statement: parentheses around name")
end


function test_input_stmt(t)
    io.write("Test Suite: input statements\n")

    checkParse(t, "input x", true, true,
      {STMTxLIST,{INPUTxSTMT,{SIMPLExVAR,"x"}}},
      "Input statement: simple")
    checkParse(t, "input x[1]", true, true,
      {STMTxLIST,{INPUTxSTMT,{ARRAYxVAR,"x",
        {NUMLITxVAL,"1"}}}},
      "Input statement: array ref")
    checkParse(t, "input x[(a==b[c[d]])+e[3e7%5]]", true, true,
      {STMTxLIST,{INPUTxSTMT,{ARRAYxVAR,"x",{{BINxOP,"+"},
        {{BINxOP,"=="},{SIMPLExVAR,"a"},{ARRAYxVAR,"b",{ARRAYxVAR,
        "c",{SIMPLExVAR,"d"}}}},{ARRAYxVAR,"e",
        {{BINxOP,"%"},{NUMLITxVAL,"3e7"},{NUMLITxVAL,"5"}}}}}}},
      "Input statement, complex array ref")
    checkParse(t, "input", false, true, nil,
      "Bad input statement: no lvalue")
    checkParse(t, "input a b", false, true, nil,
      "Bad input statement: two lvalues")
    checkParse(t, "input end", false, false, nil,
      "Bad input statement: keyword")
    checkParse(t, "input (x)", false, false, nil,
      "Bad input statement: var in parens")
    checkParse(t, "input (x[1])", false, false, nil,
      "Bad input statement: array ref in parens")
end


function test_print_stmt_no_expr(t)
    io.write("Test Suite: print statements - no expressions\n")

    checkParse(t, "print 'abc'", true, true,
      {STMTxLIST,{PRINTxSTMT,{STRLITxOUT,"'abc'"}}},
      "Print statement: StringLiteral")
    checkParse(t, "print cr", true, true,
      {STMTxLIST,{PRINTxSTMT,{CRxOUT}}},
      "Print statement: cr")
    checkParse(t, "print cr; cr", true, true,
      {STMTxLIST,{PRINTxSTMT,{CRxOUT},{CRxOUT}}},
      "Print statement: 2 cr")
    checkParse(t, "print cr; cr; cr; cr; cr", true, true,
      {STMTxLIST,{PRINTxSTMT,{CRxOUT},{CRxOUT},{CRxOUT},{CRxOUT},
        {CRxOUT}}},
      "Print statement: many cr")
    checkParse(t, "print 'a'; cr; 'b'; cr", true, true,
      {STMTxLIST,{PRINTxSTMT,{STRLITxOUT,"'a'"},{CRxOUT},{STRLITxOUT,
        "'b'"},{CRxOUT}}},
      "Print statement: StringLiterals & CRs")

    checkParse(t, "print", false, true, nil,
      "Bad print statement: empty")
    checkParse(t, "print end", false, false, nil,
      "Bad print statement: keyword #1")
    checkParse(t, "print print", false, false, nil,
      "Bad print statement: keyword #2")
    checkParse(t, "print ;", false, false, nil,
      "Bad print statement: print semicolon")
    checkParse(t, "; cr", true, false, nil,
      "Bad print statement: (no print) semicolon cr")
    checkParse(t, "print cr end", true, false, nil,
      "Bad print statement: print cr followed by end")
    checkParse(t, "cr", true, false, nil,
      "Bad program: (no print) cr only")
    checkParse(t, "print cr; cr; cr; cr;", false, true, nil,
      "Bad print statement: end with semicolon")
    checkParse(t, "print cr;; cr", false, false, nil,
      "Bad print statement: 2 semicolon")
end


function test_func_stmt_no_expr(t)
    io.write("Test Suite: function definitions - no expressions\n")

    checkParse(t, "func s end", true, true,
      {STMTxLIST,{FUNCxSTMT,"s",{STMTxLIST}}},
      "Function definition: empty body")
    checkParse(t, "func end", false, false, nil,
      "Bad function definition: missing name")
    checkParse(t, "func &s end", false, false, nil,
      "Bad function definition: ampersand before name")
    checkParse(t, "func s() end", false, false, nil,
      "Bad function definition: C-style parameter list")
    checkParse(t, "func s end end", true, false, nil,
      "Bad function definition: extra end")
    checkParse(t, "func s s end", false, false, nil,
      "Bad function definition: extra name")
    checkParse(t, "func (s) end", false, false, nil,
      "Bad function definition: name in parentheses")
    checkParse(t, "func s print cr end", true, true,
      {STMTxLIST,{FUNCxSTMT,"s",{STMTxLIST,{PRINTxSTMT,{CRxOUT}}}}},
      "Function definition: 1-statement body #1")
    checkParse(t, "func s print 'x' end", true, true,
      {STMTxLIST,{FUNCxSTMT,"s",{STMTxLIST,{PRINTxSTMT,
        {STRLITxOUT,"'x'"}}}}},
      "Function definition: 1-statment body #2")
    checkParse(t, "func s input x call y end", true, true,
      {STMTxLIST,{FUNCxSTMT,"s",{STMTxLIST,{INPUTxSTMT,
        {SIMPLExVAR,"x"}},{CALLxFUNC,"y"}}}},
      "Function definition: 2-statment body")
    checkParse(t, "func sss print cr print cr print cr end", true, true,
      {STMTxLIST,{FUNCxSTMT,"sss",{STMTxLIST,{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}}}}},
      "Function definition: longer body")
    checkParse(t, "func s func t func u print cr end end func v print "
      .."cr end end", true, true,
      {STMTxLIST,{FUNCxSTMT,"s",{STMTxLIST,{FUNCxSTMT,"t",{STMTxLIST,
        {FUNCxSTMT,"u",{STMTxLIST,{PRINTxSTMT,{CRxOUT}}}}}},{FUNCxSTMT,
        "v",{STMTxLIST,{PRINTxSTMT,{CRxOUT}}}}}}},
      "Function definition: nested function definitions")
end


function test_while_stmt_simple_expr(t)
    io.write("Test Suite: while statements - simple expressions only\n")

    checkParse(t, "while 1 print cr end", true, true,
      {STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"1"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}}}}},
      "While statement: simple")
    checkParse(t, "while 2 print cr print cr print cr print cr print "
     .."cr print cr print cr print cr print cr print cr end", true,
     true,
      {STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"2"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,
        {CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}}}}},
      "While statement: longer statement list")
    checkParse(t, "while 3 end", true, true,
      {STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"3"},{STMTxLIST}}},
      "While statement: empty statement list")
    checkParse(t, "while 1 while 2 while 3 while 4 while 5 while 6 "
      .."while 7 print cr end end end end end end end", true, true,
      {STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"1"},{STMTxLIST,{WHILExSTMT,
        {NUMLITxVAL,"2"},{STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"3"},
        {STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"4"},{STMTxLIST,{WHILExSTMT,
        {NUMLITxVAL,"5"},{STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"6"},
        {STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"7"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}}}}}}}}}}}}}}}}},
      "While statement: nested")

    checkParse(t, "while print cr end", false, false, nil,
      "Bad while statement: no expr")
    checkParse(t, "while 1 print cr", false, true, nil,
      "Bad while statement: no end")
    checkParse(t, "while 1 print cr else print cr end ",
      false, false, nil,
      "Bad while statement: has else")
    checkParse(t, "while 1 print cr end end", true, false, nil,
      "Bad while statement: followed by end")
end


function test_if_stmt_simple_expr(t)
    io.write("Test Suite: if statements - simple expressions only\n")

    checkParse(t, "if 1 print cr end", true, true,
      {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"1"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}}}}},
      "If statement: simple")
    checkParse(t, "if 2 end", true, true,
      {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"2"},{STMTxLIST}}},
      "If statement: empty statement list")
    checkParse(t, "if 3 print cr else print cr print cr end", true,
      true,
      {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"3"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}}},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,
        {CRxOUT}}}}},
      "If statement: else")
    checkParse(t, "if 4 print cr elseif 5 print cr print cr else print "
      .."cr print cr print cr end", true, true,
      {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"4"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}}},{NUMLITxVAL,"5"},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}}},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}}}}},
      "If statement: elseif, else")
    checkParse(t, "if a print cr elseif b print cr print cr elseif c "
      .."print cr print cr print cr elseif d print cr print cr print "
      .."cr print cr elseif e print cr print cr print cr print cr "
      .."print cr else print cr print cr print cr print cr print cr "
      .."print cr end", true, true,
      {STMTxLIST,{IFxSTMT,{SIMPLExVAR,"a"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}}},{SIMPLExVAR,"b"},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}}},{SIMPLExVAR,"c"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}}},
        {SIMPLExVAR,"d"},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,
        {CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}}},
        {SIMPLExVAR,"e"},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,
        {CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}}},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,
        {CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}}}}},
      "If statement: multiple elseif, else")
    checkParse(t, "if 1 print cr elseif 2 print cr print cr elseif 3 "
      .."print cr print cr print cr elseif 4 print cr print cr print "
      .."cr print cr elseif 5 print cr print cr print cr print cr "
      .."print cr end", true, true,
      {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"1"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}}},{NUMLITxVAL,"2"},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}}},{NUMLITxVAL,"3"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}}},
        {NUMLITxVAL,"4"},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,
        {CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}}},
        {NUMLITxVAL,"5"},{STMTxLIST,{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,
        {CRxOUT}},{PRINTxSTMT,{CRxOUT}},{PRINTxSTMT,{CRxOUT}},
        {PRINTxSTMT,{CRxOUT}}}}},
      "If statement: multiple elseif, no else")
    checkParse(t, "if 1 elseif 2 elseif 3 elseif 4 elseif 5 else end",
      true, true,
      {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"1"},{STMTxLIST},{NUMLITxVAL,"2"},
        {STMTxLIST},{NUMLITxVAL,"3"},{STMTxLIST},{NUMLITxVAL,"4"},
        {STMTxLIST},{NUMLITxVAL,"5"},{STMTxLIST},{STMTxLIST}}},
      "If statement: multiple elseif, else, empty statement lists")
    checkParse(t, "if 1 if 2 print cr else print cr end elseif 3 if 4 "
      .."print cr else print cr end else if 5 print cr else print cr "
      .."end end", true, true,
      {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"1"},{STMTxLIST,{IFxSTMT,
        {NUMLITxVAL,"2"},{STMTxLIST,{PRINTxSTMT,{CRxOUT}}},{STMTxLIST,
        {PRINTxSTMT,{CRxOUT}}}}},{NUMLITxVAL,"3"},{STMTxLIST,{IFxSTMT,
        {NUMLITxVAL,"4"},{STMTxLIST,{PRINTxSTMT,{CRxOUT}}},{STMTxLIST,
        {PRINTxSTMT,{CRxOUT}}}}},{STMTxLIST,{IFxSTMT,{NUMLITxVAL,"5"},
        {STMTxLIST,{PRINTxSTMT,{CRxOUT}}},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}}}}}}},
      "If statement: nested #1")
    checkParse(t, "if 1 if 2 if 3 if 4 if 5 if 6 if 7 print cr end end "
      .."end end end end end", true, true,
      {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"1"},{STMTxLIST,{IFxSTMT,
        {NUMLITxVAL,"2"},{STMTxLIST,{IFxSTMT,{NUMLITxVAL,"3"},
        {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"4"},{STMTxLIST,{IFxSTMT,
        {NUMLITxVAL,"5"},{STMTxLIST,{IFxSTMT,{NUMLITxVAL,"6"},
        {STMTxLIST,{IFxSTMT,{NUMLITxVAL,"7"},{STMTxLIST,{PRINTxSTMT,
        {CRxOUT}}}}}}}}}}}}}}}}},
      "If statement: nested #2")
    checkParse(t, "while 1 if 2 while 3 end elseif 4 while 5 if 6 end "
      .."end elseif 7 while 8 end else while 9 end end end", true, true,
      {STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"1"},{STMTxLIST,{IFxSTMT,
        {NUMLITxVAL,"2"},{STMTxLIST,{WHILExSTMT,{NUMLITxVAL,"3"},
        {STMTxLIST}}},{NUMLITxVAL,"4"},{STMTxLIST,{WHILExSTMT,
        {NUMLITxVAL,"5"},{STMTxLIST,{IFxSTMT,{NUMLITxVAL,"6"},
        {STMTxLIST}}}}},{NUMLITxVAL,"7"},{STMTxLIST,{WHILExSTMT,
        {NUMLITxVAL,"8"},{STMTxLIST}}},{STMTxLIST,{WHILExSTMT,
        {NUMLITxVAL,"9"},{STMTxLIST}}}}}}},
      "While statement: nested while & if")

    checkParse(t, "if cr end", false, false, nil,
      "Bad if statement: no expr")
    checkParse(t, "if a print cr", false, true, nil,
      "Bad if statement: no end")
    checkParse(t, "if a b cr end", false, false, nil,
      "Bad if statement: 2 expressions")
    checkParse(t, "if a cr else cr elseif b cr", false, false, nil,
      "Bad if statement: else before elseif")
    checkParse(t, "if a print cr end end", true, false, nil,
      "Bad if statement: followed by end")
end


function test_assn_stmt_simple_expr(t)
    io.write("Test Suite: assignment statements - simple expressions\n")

    checkParse(t, "abc=123", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"abc"},{NUMLITxVAL,"123"}}},
      "Assignment statement: NumericLiteral")
    checkParse(t, "abc=xyz", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR, "abc"},{SIMPLExVAR,"xyz"}}},
      "Assignment statement: identifier")
    checkParse(t, "abc[1]=xyz", true, true,
      {STMTxLIST,{ASSNxSTMT,{ARRAYxVAR,"abc",{NUMLITxVAL,"1"}},
        {SIMPLExVAR,"xyz"}}},
      "Assignment statement: array ref = ...")
    checkParse(t, "abc=true", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR, "abc"},{BOOLLITxVAL,"true"}}},
      "Assignment statement: boolean literal Keyword: true")
    checkParse(t, "abc=false", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR, "abc"},{BOOLLITxVAL,"false"}}},
      "Assignment statement: boolean literal Keyword: false")
    checkParse(t, "=123", true, false, nil,
      "Bad assignment statement: missing LHS")
    checkParse(t, "123=123", true, false, nil,
      "Bad assignment statement: LHS is NumericLiteral")
    checkParse(t, "end=123", true, false, nil,
      "Bad assignment statement: LHS is Keyword")
    checkParse(t, "abc 123", false, false, nil,
      "Bad assignment statement: missing assignment op")
    checkParse(t, "abc == 123", false, false, nil,
      "Bad assignment statement: assignment op replaced by equality")
    checkParse(t, "abc =", false, true, nil,
      "Bad assignment statement: RHS is empty")
    checkParse(t, "abc=end", false, false, nil,
      "Bad assignment statement: RHS is Keyword")
    checkParse(t, "abc=1 2", true, false, nil,
      "Bad assignment statement: RHS is two NumericLiterals")
    checkParse(t, "abc=1 end", true, false, nil,
      "Bad assignment statement: followed by end")
end


function test_expr_simple(t)
    io.write("Test Suite: simple expressions\n")

    checkParse(t, "x=true", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{BOOLLITxVAL,"true"}}},
      "Simple expression: true")
    checkParse(t, "x=false", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{BOOLLITxVAL,"false"}}},
      "Simple expression: true")
    checkParse(t, "x=call foo", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{CALLxFUNC,"foo"}}},
      "Simple expression: call")
    checkParse(t, "x=call", false, true, nil,
      "Bad expression: call without name")
    checkParse(t, "x=1&&2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: &&")
    checkParse(t, "x=1||2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: ||")
    checkParse(t, "x=1 + 2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary + (numbers with space)")
    checkParse(t, "x=1+2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary + (numbers without space)")
    checkParse(t, "x=a+2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},
        {SIMPLExVAR,"a"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary + (var+number)")
    checkParse(t, "x=1+b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},
        {NUMLITxVAL,"1"},{SIMPLExVAR,"b"}}}},
      "Simple expression: binary + (number+var)")
    checkParse(t, "x=a+b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},
        {SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}},
      "Simple expression: binary + (vars)")
    checkParse(t, "x=1+", false, true, nil,
      "Bad expression: end with +")
    checkParse(t, "x=1 - 2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary - (numbers with space)")
    checkParse(t, "x=1-2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary - (numbers without space)")
    checkParse(t, "x=1-", false, true, nil,
      "Bad expression: end with -")
    checkParse(t, "x=1*2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: * (numbers)")
    checkParse(t, "x=a*2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},
        {SIMPLExVAR,"a"},{NUMLITxVAL,"2"}}}},
      "Simple expression: * (var*number)")
    checkParse(t, "x=1*b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},
        {NUMLITxVAL,"1"},{SIMPLExVAR,"b"}}}},
      "Simple expression: * (number*var)")
    checkParse(t, "x=a*b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},
        {SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}},
      "Simple expression: * (vars)")
    checkParse(t, "x=1*", false, true, nil,
      "Bad expression: end with *")
    checkParse(t, "x=1/2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"/"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: /")
    checkParse(t, "x=1/", false, true, nil,
      "Bad expression: end with /")
    checkParse(t, "x=1%2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: % #1")
    checkParse(t, "x=1%true", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},
        {NUMLITxVAL,"1"},{BOOLLITxVAL,"true"}}}},
      "Simple expression: % #2")
    checkParse(t, "x=1%false", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},
        {NUMLITxVAL,"1"},{BOOLLITxVAL,"false"}}}},
      "Simple expression: % #3")
    checkParse(t, "x=1%", false, true, nil,
      "Bad expression: end with %")
    checkParse(t, "x=1==2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: == (numbers)")
    checkParse(t, "x=a==2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},
        {SIMPLExVAR,"a"},{NUMLITxVAL,"2"}}}},
      "Simple expression: == (var==number)")
    checkParse(t, "x=1==b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},
        {NUMLITxVAL,"1"},{SIMPLExVAR,"b"}}}},
      "Simple expression: == (number==var)")
    checkParse(t, "x=a==b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},
        {SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}},
      "Simple expression: == (vars)")
    checkParse(t, "x=1==", false, true, nil,
      "Bad expression: end with ==")
    checkParse(t, "x=1!=2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"!="},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: !=")
    checkParse(t, "x=1!=", false, true, nil,
      "Bad expression: end with !=")
    checkParse(t, "x=1<2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"<"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: <")
    checkParse(t, "x=1<", false, true, nil,
      "Bad expression: end with <")
    checkParse(t, "x=1<=2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"<="},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: <=")
    checkParse(t, "x=1<=", false, true, nil,
      "Bad expression: end with <=")
    checkParse(t, "x=1>2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: >")
    checkParse(t, "x=1>", false, true, nil,
      "Bad expression: end with >")
    checkParse(t, "x=1>=2", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">="},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: >=")
    checkParse(t, "x=+a", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"+"},{SIMPLExVAR,
        "a"}}}},
      "Simple expression: unary +")
    checkParse(t, "x=-a", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"-"},{SIMPLExVAR,
        "a"}}}},
      "Simple expression: unary -")
    checkParse(t, "x=1>=", false, true, nil,
      "Bad expression: end with >=")
    checkParse(t, "x=(1)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{NUMLITxVAL,"1"}}},
      "Simple expression: parens (number)")
    checkParse(t, "x=(a)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{SIMPLExVAR,"a"}}},
      "Simple expression: parens (var)")
    checkParse(t, "x=a[1]", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{ARRAYxVAR,"a",
        {NUMLITxVAL,"1"}}}},
      "Simple expression: array ref")
    checkParse(t, "x=(1", false, true, nil,
      "Bad expression: no closing paren")
    checkParse(t, "x=()", false, false, nil,
      "Bad expression: empty parens")
    checkParse(t, "x=a[1", false, true, nil,
      "Bad expression: no closing bracket")
    checkParse(t, "x=a 1]", true, false, nil,
      "Bad expression: no opening bracket")
    checkParse(t, "x=a[]", false, false, nil,
      "Bad expression: empty brackets")
    checkParse(t, "x=(x)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{SIMPLExVAR,"x"}}},
      "Simple expression: var in parens on RHS")
    checkParse(t, "(x)=x", true, false, nil,
      "Bad expression: var in parens on LHS")
    checkParse(t, "x[1]=(x[1])", true, true,
      {STMTxLIST,{ASSNxSTMT,{ARRAYxVAR,"x",{NUMLITxVAL,"1"}},
        {ARRAYxVAR,"x",{NUMLITxVAL,"1"}}}},
      "Simple expression: array ref in parens on RHS")
    checkParse(t, "(x[1])=x[1]", true, false, nil,
      "Bad expression: array ref in parens on LHS")

    checkParse(t, "x=call call f", false, false, nil,
      "Bad expression: consecutive call keywords")
    checkParse(t, "x=call 3", false, false, nil,
      "Bad expression: call number")
    checkParse(t, "x=call true", false, false, nil,
      "Bad expression: call boolean")
    checkParse(t, "x=call (x)", false, false, nil,
      "Bad expression: call with parentheses")
end


function test_print_stmt_with_expr(t)
    io.write("Test Suite: print statements - with expressions\n")

    checkParse(t, "print x", true, true,
      {STMTxLIST,{PRINTxSTMT,{SIMPLExVAR,"x"}}},
      "print statement: variable")
    checkParse(t, "print a+x[b*(c==d-f)]%g<=h", true, true,
      {STMTxLIST,{PRINTxSTMT,{{BINxOP,"<="},{{BINxOP,"+"},{SIMPLExVAR,
        "a"},{{BINxOP,"%"},{ARRAYxVAR,"x",{{BINxOP,"*"},{SIMPLExVAR,
        "b"},{{BINxOP,"=="},{SIMPLExVAR,"c"},{{BINxOP,"-"},{SIMPLExVAR,
        "d"},{SIMPLExVAR,"f"}}}}},{SIMPLExVAR,"g"}}},{SIMPLExVAR,
        "h"}}}},
      "print statement: expression")
    checkParse(t, "print 1 end", true, false, nil,
      "bad print statement: print 1 followed by end")
end


function test_func_stmt_with_expr(t)
    io.write("Test Suite: function declarations - with expressions\n")

    checkParse(t, "func q print abc+3 end", true, true,
      {STMTxLIST,{FUNCxSTMT,"q",{STMTxLIST,{PRINTxSTMT,{{BINxOP,"+"},
        {SIMPLExVAR,"abc"},{NUMLITxVAL,"3"}}}}}},
      "func declaration: with print expr")
    checkParse(t, "func qq print a+x[b*(c==d-f)]%g<=h end", true, true,
      {STMTxLIST,{FUNCxSTMT,"qq",{STMTxLIST,{PRINTxSTMT,{{BINxOP,"<="},
        {{BINxOP,"+"},{SIMPLExVAR,"a"},{{BINxOP,"%"},{ARRAYxVAR,"x",
        {{BINxOP,"*"},{SIMPLExVAR,"b"},{{BINxOP,"=="},{SIMPLExVAR,"c"},
        {{BINxOP,"-"},{SIMPLExVAR,"d"},{SIMPLExVAR,"f"}}}}},{SIMPLExVAR,
        "g"}}},{SIMPLExVAR,"h"}}}}}},
      "function declaration: complex expression")
end


function test_expr_prec_assoc(t)
    io.write("Test Suite: expressions - precedence & associativity\n")

    checkParse(t, "x=1&&2&&3&&4&&5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{{BINxOP,
        "&&"},{{BINxOP, "&&"},{{BINxOP,"&&"},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator && is left-associative")
    checkParse(t, "x=1||2||3||4||5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{{BINxOP,
        "||"},{{BINxOP, "||"},{{BINxOP,"||"},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator || is left-associative")
    checkParse(t, "x=1+2+3+4+5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{{BINxOP,
        "+"},{{BINxOP, "+"},{{BINxOP,"+"},{NUMLITxVAL,"1"},{NUMLITxVAL,
        "2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Binary operator + is left-associative")
    checkParse(t, "x=1-2-3-4-5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{{BINxOP,
        "-"},{{BINxOP, "-"},{{BINxOP,"-"},{NUMLITxVAL,"1"},{NUMLITxVAL,
        "2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Binary operator - is left-associative")
    checkParse(t, "x=1*2*3*4*5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{{BINxOP,
        "*"},{{BINxOP, "*"},{{BINxOP,"*"},{NUMLITxVAL,"1"},{NUMLITxVAL,
        "2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator * is left-associative")
    checkParse(t, "x=1/2/3/4/5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"/"},{{BINxOP,
        "/"},{{BINxOP, "/"},{{BINxOP,"/"},{NUMLITxVAL,"1"},{NUMLITxVAL,
        "2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator / is left-associative")
    checkParse(t, "x=1%2%3%4%5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},{{BINxOP,
        "%"},{{BINxOP, "%"},{{BINxOP,"%"},{NUMLITxVAL,"1"},{NUMLITxVAL,
        "2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator % is left-associative")
    checkParse(t, "x=1==2==3==4==5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{{BINxOP,
        "=="},{{BINxOP, "=="},{{BINxOP,"=="},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator == is left-associative")
    checkParse(t, "x=1!=2!=3!=4!=5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"!="},{{BINxOP,
        "!="},{{BINxOP, "!="},{{BINxOP,"!="},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator != is left-associative")
    checkParse(t, "x=1<2<3<4<5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"<"},{{BINxOP,
        "<"},{{BINxOP, "<"},{{BINxOP,"<"},{NUMLITxVAL,"1"},{NUMLITxVAL,
        "2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator < is left-associative")
    checkParse(t, "x=1<=2<=3<=4<=5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"<="},{{BINxOP,
        "<="},{{BINxOP, "<="},{{BINxOP,"<="},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator <= is left-associative")
    checkParse(t, "x=1>2>3>4>5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{{BINxOP,
        ">"},{{BINxOP, ">"},{{BINxOP,">"},{NUMLITxVAL,"1"},{NUMLITxVAL,
        "2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator > is left-associative")
    checkParse(t, "x=1>=2>=3>=4>=5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">="},{{BINxOP,
        ">="},{{BINxOP, ">="},{{BINxOP,">="},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator >= is left-associative")

    checkParse(t, "x=!!!!a", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{UNxOP,"!"},
        {{UNxOP,"!"},{{UNxOP,"!"},{SIMPLExVAR,"a"}}}}}}},
      "Operator ! is right-associative")
    checkParse(t, "x=++++a", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"+"},{{UNxOP,"+"},
        {{UNxOP,"+"},{{UNxOP,"+"},{SIMPLExVAR,"a"}}}}}}},
      "Unary operator + is right-associative")
    checkParse(t, "x=----a", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"-"},{{UNxOP,"-"},
        {{UNxOP,"-"},{{UNxOP,"-"},{SIMPLExVAR,"a"}}}}}}},
      "Unary operator - is right-associative")

    checkParse(t, "x=a&&b||c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{{BINxOP,
        "&&"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: &&, ||")
    checkParse(t, "x=a&&b==c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,"=="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, ==")
    checkParse(t, "x=a&&b!=c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,"!="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, !=")
    checkParse(t, "x=a&&b<c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,"<"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, <")
    checkParse(t, "x=a&&b<=c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,"<="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, <=")
    checkParse(t, "x=a&&b>c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,">"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, >")
    checkParse(t, "x=a&&b>=c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,">="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, >=")
    checkParse(t, "x=a&&b+c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,"+"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, binary +")
    checkParse(t, "x=a&&b-c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,"-"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, binary -")
    checkParse(t, "x=a&&b*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,"*"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, *")
    checkParse(t, "x=a&&b/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,"/"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, /")
    checkParse(t, "x=a&&b%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{SIMPLExVAR,
        "a"},{{BINxOP,"%"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: &&, %")

    checkParse(t, "x=a||b&&c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{{BINxOP,
        "||"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: ||, &&")
    checkParse(t, "x=a||b==c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,"=="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, ==")
    checkParse(t, "x=a||b!=c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,"!="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, !=")
    checkParse(t, "x=a||b<c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,"<"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, <")
    checkParse(t, "x=a||b<=c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,"<="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, <=")
    checkParse(t, "x=a||b>c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,">"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, >")
    checkParse(t, "x=a||b>=c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,">="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, >=")
    checkParse(t, "x=a||b+c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,"+"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, binary +")
    checkParse(t, "x=a||b-c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,"-"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, binary -")
    checkParse(t, "x=a||b*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,"*"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, *")
    checkParse(t, "x=a||b/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,"/"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, /")
    checkParse(t, "x=a||b%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{SIMPLExVAR,
        "a"},{{BINxOP,"%"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ||, %")

    checkParse(t, "x=a==b>c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{{BINxOP,
        "=="},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: ==, >")
    checkParse(t, "x=a==b+c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{SIMPLExVAR,
        "a"},{{BINxOP,"+"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ==, binary +")
    checkParse(t, "x=a==b-c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{SIMPLExVAR,
        "a"},{{BINxOP,"-"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ==, binary -")
    checkParse(t, "x=a==b*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{SIMPLExVAR,
        "a"},{{BINxOP,"*"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ==, *")
    checkParse(t, "x=a==b/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{SIMPLExVAR,
        "a"},{{BINxOP,"/"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ==, /")
    checkParse(t, "x=a==b%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{SIMPLExVAR,
        "a"},{{BINxOP,"%"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: ==, %")

    checkParse(t, "x=a>b==c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{{BINxOP,
        ">"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: >, ==")
    checkParse(t, "x=a>b+c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{SIMPLExVAR,
        "a"},{{BINxOP,"+"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: >, binary +")
    checkParse(t, "x=a>b-c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{SIMPLExVAR,
        "a"},{{BINxOP,"-"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: >, binary -")
    checkParse(t, "x=a>b*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{SIMPLExVAR,
        "a"},{{BINxOP,"*"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: >, *")
    checkParse(t, "x=a>b/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{SIMPLExVAR,
        "a"},{{BINxOP,"/"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: >, /")
    checkParse(t, "x=a>b%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{SIMPLExVAR,
        "a"},{{BINxOP,"%"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: >, %")

    checkParse(t, "x=a+b==c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{{BINxOP,
        "+"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: binary +, ==")
    checkParse(t, "x=a+b>c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{{BINxOP,
        "+"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: binary +, >")
    checkParse(t, "x=a+b-c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{{BINxOP,
        "+"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: binary +, binary -")
    checkParse(t, "x=a+b*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{SIMPLExVAR,
        "a"},{{BINxOP,"*"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: binary +, *")
    checkParse(t, "x=a+b/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{SIMPLExVAR,
        "a"},{{BINxOP,"/"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: binary +, /")
    checkParse(t, "x=a+b%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{SIMPLExVAR,
        "a"},{{BINxOP,"%"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: binary +, %")

    checkParse(t, "x=a-b==c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{{BINxOP,
        "-"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: binary -, ==")
    checkParse(t, "x=a-b>c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{{BINxOP,
        "-"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: binary -, >")
    checkParse(t, "x=a-b+c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{{BINxOP,
        "-"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: binary -, binary +")
    checkParse(t, "x=a-b*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{SIMPLExVAR,
        "a"},{{BINxOP,"*"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: binary -, *")
    checkParse(t, "x=a-b/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{SIMPLExVAR,
        "a"},{{BINxOP,"/"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: binary -, /")
    checkParse(t, "x=a-b%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{SIMPLExVAR,
        "a"},{{BINxOP,"%"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence check: binary -, %")

    checkParse(t, "x=a*b==c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{{BINxOP,
        "*"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: *, ==")
    checkParse(t, "x=a*b>c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{{BINxOP,
        "*"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: *, >")
    checkParse(t, "x=a*b+c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{{BINxOP,
        "*"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: *, binary +")
    checkParse(t, "x=a*b-c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{{BINxOP,
        "*"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: *, binary -")
    checkParse(t, "x=a*b/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"/"},{{BINxOP,
        "*"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: *, /")
    checkParse(t, "x=a*b%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},{{BINxOP,
        "*"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: *, %")

    checkParse(t, "x=a/b==c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{{BINxOP,
        "/"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: /, ==")
    checkParse(t, "x=a/b>c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{{BINxOP,
        "/"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: /, >")
    checkParse(t, "x=a/b+c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{{BINxOP,
        "/"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: /, binary +")
    checkParse(t, "x=a/b-c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{{BINxOP,
        "/"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: /, binary -")
    checkParse(t, "x=a/b*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{{BINxOP,
        "/"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: /, *")
    checkParse(t, "x=a/b%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},{{BINxOP,
        "/"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: /, %")

    checkParse(t, "x=a%b==c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{{BINxOP,
        "%"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: %, ==")
    checkParse(t, "x=a%b>c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{{BINxOP,
        "%"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: %, >")
    checkParse(t, "x=a%b+c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{{BINxOP,
        "%"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: %, binary +")
    checkParse(t, "x=a%b-c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{{BINxOP,
        "%"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: %, binary -")
    checkParse(t, "x=a%b*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{{BINxOP,
        "%"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: %, *")
    checkParse(t, "x=a%b/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"/"},{{BINxOP,
        "%"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: %, /")

    checkParse(t, "x=!a&&b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{{UNxOP,
        "!"},{SIMPLExVAR,"a"}},{SIMPLExVAR,"b"}}}},
      "Precedence check: !, &&")
    checkParse(t, "x=!a||b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{{UNxOP,
        "!"},{SIMPLExVAR,"a"}},{SIMPLExVAR,"b"}}}},
      "Precedence check: !, ||")
    checkParse(t, "x=!a==b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        "=="},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, ==")
    checkParse(t, "x=!a!=b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        "!="},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, !=")
    checkParse(t, "x=!a<b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        "<"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, <")
    checkParse(t, "x=!a<=b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        "<="},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, <=")
    checkParse(t, "x=!a>b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        ">"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, >")
    checkParse(t, "x=!a>=b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        ">="},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, >=")
    checkParse(t, "x=!a+b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        "+"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, binary +")
    checkParse(t, "x=!a-b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        "-"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, binary -")
    checkParse(t, "x=!a*b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        "*"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, *")
    checkParse(t, "x=!a/b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        "/"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, /")
    checkParse(t, "x=!a%b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"!"},{{BINxOP,
        "%"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !, %")
    checkParse(t, "x=a!=+b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"!="},{SIMPLExVAR,
        "a"},{{UNxOP,"+"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: !=, unary +")
    checkParse(t, "x=-a<c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"<"},{{UNxOP,
        "-"},{SIMPLExVAR,"a"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: unary -, <")
    checkParse(t, "x=a++b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{SIMPLExVAR,
        "a"},{{UNxOP,"+"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: binary +, unary +")
    checkParse(t, "x=a+-b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{SIMPLExVAR,
        "a"},{{UNxOP,"-"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: binary +, unary -")
    checkParse(t, "x=+a+b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{{UNxOP,"+"},
        {SIMPLExVAR,"a"}},{SIMPLExVAR,"b"}}}},
      "Precedence check: unary +, binary +, *")
    checkParse(t, "x=-a+b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{{UNxOP,"-"},
        {SIMPLExVAR,"a"}},{SIMPLExVAR,"b"}}}},
      "Precedence check: unary -, binary +")
    checkParse(t, "x=a-+b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{SIMPLExVAR,
        "a"},{{UNxOP,"+"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: binary -, unary +")
    checkParse(t, "x=a--b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{SIMPLExVAR,
        "a"},{{UNxOP,"-"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: binary -, unary -")
    checkParse(t, "x=+a-b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{{UNxOP,"+"},
        {SIMPLExVAR,"a"}},{SIMPLExVAR,"b"}}}},
      "Precedence check: unary +, binary -, *")
    checkParse(t, "x=-a-b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{{UNxOP,"-"},
        {SIMPLExVAR,"a"}},{SIMPLExVAR,"b"}}}},
      "Precedence check: unary -, binary -")
    checkParse(t, "x=a*-b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{SIMPLExVAR,
        "a"},{{UNxOP,"-"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: *, unary -")
    checkParse(t, "x=+a*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{{UNxOP,"+"},
        {SIMPLExVAR,"a"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: unary +, *")
    checkParse(t, "x=a/+b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"/"},{SIMPLExVAR,
        "a"},{{UNxOP,"+"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: /, unary +")
    checkParse(t, "x=-a/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"/"},{{UNxOP,"-"},
        {SIMPLExVAR,"a"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: unary -, /")
    checkParse(t, "x=a%-b", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},{SIMPLExVAR,
        "a"},{{UNxOP,"-"},{SIMPLExVAR,"b"}}}}},
      "Precedence check: %, unary -")
    checkParse(t, "x=+a%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},{{UNxOP,"+"},
        {SIMPLExVAR,"a"}},{SIMPLExVAR,"c"}}}},
      "Precedence check: unary +, %")

    checkParse(t, "x=1&&(2&&3&&4)&&5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"&&"},{{BINxOP,
        "&&"},{NUMLITxVAL,"1"},{{BINxOP,"&&"},{{BINxOP,"&&"},
          {NUMLITxVAL,"2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},
          {NUMLITxVAL,"5"}}}},
      "Associativity override: &&")
    checkParse(t, "x=1||(2||3||4)||5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"||"},{{BINxOP,
        "||"},{NUMLITxVAL,"1"},{{BINxOP,"||"},{{BINxOP,"||"},
        {NUMLITxVAL,"2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},
        {NUMLITxVAL,"5"}}}},
      "Associativity override: ||")
    checkParse(t, "x=1==(2==3==4)==5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{{BINxOP,
        "=="},{NUMLITxVAL,"1"},{{BINxOP,"=="},{{BINxOP,"=="},
        {NUMLITxVAL,"2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},
        {NUMLITxVAL,"5"}}}},
      "Associativity override: ==")
    checkParse(t, "x=1!=(2!=3!=4)!=5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"!="},{{BINxOP,
        "!="},{NUMLITxVAL,"1"},{{BINxOP,"!="},{{BINxOP,"!="},
        {NUMLITxVAL,"2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},
        {NUMLITxVAL,"5"}}}},
      "Associativity override: !=")
    checkParse(t, "x=1<(2<3<4)<5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"<"},{{BINxOP,
        "<"},{NUMLITxVAL,"1"},{{BINxOP,"<"},{{BINxOP,"<"},{NUMLITxVAL,
        "2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: <")
    checkParse(t, "x=1<=(2<=3<=4)<=5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"<="},{{BINxOP,
        "<="},{NUMLITxVAL,"1"},{{BINxOP,"<="},{{BINxOP,"<="},
        {NUMLITxVAL,"2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},
        {NUMLITxVAL,"5"}}}},
      "Associativity override: <=")
    checkParse(t, "x=1>(2>3>4)>5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">"},{{BINxOP,
        ">"},{NUMLITxVAL,"1"},{{BINxOP,">"},{{BINxOP,">"},{NUMLITxVAL,
        "2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: >")
    checkParse(t, "x=1>=(2>=3>=4)>=5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">="},{{BINxOP,
        ">="},{NUMLITxVAL,"1"},{{BINxOP,">="},{{BINxOP,">="},
        {NUMLITxVAL,"2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},
        {NUMLITxVAL,"5"}}}},
      "Associativity override: >=")
    checkParse(t, "x=1+(2+3+4)+5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},
        {{BINxOP,"+"},{NUMLITxVAL,"1"},{{BINxOP,"+"},{{BINxOP,"+"},
        {NUMLITxVAL,"2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},
        {NUMLITxVAL,"5"}}}},
      "Associativity override: binary +")
    checkParse(t, "x=1-(2-3-4)-5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{{BINxOP,
        "-"},{NUMLITxVAL,"1"},{{BINxOP,"-"},{{BINxOP,"-"},{NUMLITxVAL,
        "2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: binary -")
    checkParse(t, "x=1*(2*3*4)*5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{{BINxOP,
        "*"},{NUMLITxVAL,"1"},{{BINxOP,"*"},{{BINxOP,"*"},{NUMLITxVAL,
        "2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: *")
    checkParse(t, "x=1/(2/3/4)/5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"/"},{{BINxOP,
        "/"},{NUMLITxVAL,"1"},{{BINxOP,"/"},{{BINxOP,"/"},{NUMLITxVAL,
        "2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: /")
    checkParse(t, "x=1%(2%3%4)%5", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},{{BINxOP,
        "%"},{NUMLITxVAL,"1"},{{BINxOP,"%"},{{BINxOP,"%"},{NUMLITxVAL,
        "2"},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: %")

    checkParse(t, "x=(a==b)+c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{{BINxOP,
        "=="},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence override: ==, binary +")
    checkParse(t, "x=(a!=b)-c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"-"},{{BINxOP,
        "!="},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence override: !=, binary -")
    checkParse(t, "x=(a<b)*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{{BINxOP,
        "<"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence override: <, *")
    checkParse(t, "x=(a<=b)/c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"/"},{{BINxOP,
        "<="},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence override: <=, /")
    checkParse(t, "x=(a>b)%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},{{BINxOP,
        ">"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence override: >, %")
    checkParse(t, "x=a+(b>=c)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"+"},{SIMPLExVAR,
       "a"},{{BINxOP,">="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence override: binary +, >=")
    checkParse(t, "x=(a-b)*c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{{BINxOP,
        "-"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence override: binary -, *")
    checkParse(t, "x=(a+b)%c", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},{{BINxOP,
        "+"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,"c"}}}},
      "Precedence override: binary +, %")
    checkParse(t, "x=a*(b==c)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{SIMPLExVAR,
        "a"},{{BINxOP,"=="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence override: *, ==")
    checkParse(t, "x=a/(b!=c)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"/"},{SIMPLExVAR,
        "a"},{{BINxOP,"!="},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence override: /, !=")
    checkParse(t, "x=a%(b<c)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"%"},{SIMPLExVAR,
        "a"},{{BINxOP,"<"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}}}}},
      "Precedence override: %, <")

    checkParse(t, "x=+(a<=b)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"+"},{{BINxOP,
        "<="},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence override: unary +, <=")
    checkParse(t, "x=-(a>b)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"-"},{{BINxOP,">"},
        {SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence override: unary -, >")
    checkParse(t, "x=+(a+b)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"+"},{{BINxOP,"+"},
        {SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence override: unary +, binary +")
    checkParse(t, "x=-(a-b)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"-"},{{BINxOP,"-"},
        {SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence override: unary -, binary -")
    checkParse(t, "x=+(a*b)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"+"},{{BINxOP,"*"},
        {SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence override: unary +, *")
    checkParse(t, "x=-(a/b)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"-"},{{BINxOP,"/"},
        {SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence override: unary -, /")
    checkParse(t, "x=+(a%b)", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{UNxOP,"+"},{{BINxOP,"%"},
        {SIMPLExVAR,"a"},{SIMPLExVAR,"b"}}}}},
      "Precedence override: unary +, %")

    checkParse(t, "x=call f * 3", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"*"},{CALLxFUNC,
        "f"},{NUMLITxVAL,"3"}}}},
      "Precedence check: call has high precedence")
end


function test_expr_complex(t)
    io.write("Test Suite: complex expressions\n")

    checkParse(t, "x=((((((((((((((((((((((((((((((((((((((((a)))"
      ..")))))))))))))))))))))))))))))))))))))", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{SIMPLExVAR,"a"}}},
      "Complex expression: many parens")
    checkParse(t, "x=(((((((((((((((((((((((((((((((((((((((a))))"
      .."))))))))))))))))))))))))))))))))))))", true, false, nil,
      "Bad complex expression: many parens, mismatch #1")
    checkParse(t, "x=((((((((((((((((((((((((((((((((((((((((a)))"
      .."))))))))))))))))))))))))))))))))))))", false, true, nil,
      "Bad complex expression: many parens, mismatch #2")
    checkParse(t, "x=a==b+c[x-y[2]]*+d!=e-f/-g<h+i%+j", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"<"},
        {{BINxOP,"!="},{{BINxOP,"=="},{SIMPLExVAR,"a"},{{BINxOP,"+"},
        {SIMPLExVAR,"b"},{{BINxOP,"*"},{ARRAYxVAR,"c",{{BINxOP,"-"},
        {SIMPLExVAR,"x"},{ARRAYxVAR,"y",{NUMLITxVAL,"2"}}}},{{UNxOP,
        "+"},{SIMPLExVAR,"d"}}}}},{{BINxOP,"-"},{SIMPLExVAR,"e"},
        {{BINxOP,"/"},{SIMPLExVAR,"f"},{{UNxOP,"-"},{SIMPLExVAR,
        "g"}}}}},{{BINxOP,"+"},{SIMPLExVAR,"h"},{{BINxOP,"%"},
        {SIMPLExVAR,"i"},{{UNxOP,"+"},{SIMPLExVAR,"j"}}}}}}},
      "Complex expression: misc #1")
    checkParse(t, "x=a==b+(c*+(d!=e[z]-f/-g)<h+i)%+j", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,"=="},{SIMPLExVAR,
        "a"},{{BINxOP,"+"},{SIMPLExVAR,"b"},{{BINxOP,"%"},{{BINxOP,"<"},
        {{BINxOP,"*"},{SIMPLExVAR,"c"},{{UNxOP,"+"},{{BINxOP,"!="},
        {SIMPLExVAR,"d"},{{BINxOP,"-"},{ARRAYxVAR,"e",{SIMPLExVAR,"z"}},
        {{BINxOP,"/"},{SIMPLExVAR,"f"},{{UNxOP,"-"},{SIMPLExVAR,
        "g"}}}}}}},{{BINxOP,"+"},{SIMPLExVAR,"h"},{SIMPLExVAR,"i"}}},
        {{UNxOP,"+"},{SIMPLExVAR,"j"}}}}}}},
      "Complex expression: misc #2")
    checkParse(t, "x=a[x[y[z]]%4]++b*c<=d--e/f>g+-h%i>=j", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">="},{{BINxOP,
        ">"},{{BINxOP,"<="},{{BINxOP,"+"},{ARRAYxVAR,"a",{{BINxOP,"%"},
        {ARRAYxVAR,"x",{ARRAYxVAR,"y",{SIMPLExVAR,"z"}}},{NUMLITxVAL,
        "4"}}},{{BINxOP,"*"},{{UNxOP,"+"},{SIMPLExVAR,"b"}},{SIMPLExVAR,
        "c"}}},{{BINxOP,"-"},{SIMPLExVAR,"d"},{{BINxOP,"/"},
        {{UNxOP,"-"},{SIMPLExVAR,"e"}},{SIMPLExVAR,"f"}}}},
        {{BINxOP,"+"},{SIMPLExVAR,"g"},{{BINxOP,"%"},{{UNxOP,"-"},
        {SIMPLExVAR,"h"}},{SIMPLExVAR,"i"}}}},{SIMPLExVAR,"j"}}}},
      "Complex expression: misc #3")
    checkParse(t, "x=a++(b*c<=d)--e/(f>g+-h%i)>=j[-z]", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{{BINxOP,">="},
        {{BINxOP,"-"},{{BINxOP,"+"},{SIMPLExVAR,"a"},{{UNxOP,"+"},
        {{BINxOP,"<="},{{BINxOP,"*"},{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}},
        {SIMPLExVAR,"d"}}}},{{BINxOP,"/"},{{UNxOP,"-"},
        {SIMPLExVAR,"e"}},{{BINxOP,">"},{SIMPLExVAR,"f"},{{BINxOP,"+"},
        {SIMPLExVAR,"g"},{{BINxOP,"%"},{{UNxOP,"-"},{SIMPLExVAR,"h"}},
        {SIMPLExVAR,"i"}}}}}},{ARRAYxVAR,"j",{{UNxOP,"-"},
        {SIMPLExVAR,"z"}}}}}},
      "Complex expression: misc #4")
    checkParse(t, "x=a==b+c*+d!=e-/-g<h+i%+j",
      false, false, nil,
      "Bad complex expression: misc #1")
    checkParse(t, "x=a==b+(c*+(d!=e-f/-g)<h+i)%+",
      false, true, nil,
      "Bad complex expression: misc #2")
    checkParse(t, "x=a++b*c<=d--e x/f>g+-h%i>=j",
      false, false, nil,
      "Bad complex expression: misc #3")
    checkParse(t, "x=a++b*c<=d)--e/(f>g+-h%i)>=j",
      true, false, nil,
      "Bad complex expression: misc #4")

    checkParse(t, "x=((a[(b[c[(d[((e[f]))])]])]))", true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"x"},{ARRAYxVAR,"a",
        {ARRAYxVAR,"b",{ARRAYxVAR,"c",{ARRAYxVAR,"d",{ARRAYxVAR,"e",
        {SIMPLExVAR,"f"}}}}}}}},
      "Complex expression: many parens/brackets")
    checkParse(t, "x=((a[(b[c[(d[((e[f]))]])])]))", false, false, nil,
      "Bad complex expression: mismatched parens/brackets")

    checkParse(t, "while (a+b)%d+call a!=true print cr end", true, true,
      {STMTxLIST,{WHILExSTMT,{{BINxOP,"!="},{{BINxOP,"+"},{{BINxOP,"%"},
        {{BINxOP,"+"},{SIMPLExVAR,"a"},{SIMPLExVAR,"b"}},{SIMPLExVAR,
        "d"}},{CALLxFUNC,"a"}},{BOOLLITxVAL,"true"}},{STMTxLIST,
        {PRINTxSTMT,{CRxOUT}}}}},
      "While statment with complex expression")
    checkParse(t, "if 6e+5==true/((call q))+-+-+-false a=3elseif 3+4+5 "
      .."x=5else r=7end", true, true,
      {STMTxLIST,{IFxSTMT,{{BINxOP,"=="},{NUMLITxVAL,"6e+5"},{{BINxOP,
        "+"},{{BINxOP,"/"},{BOOLLITxVAL,"true"},{CALLxFUNC,"q"}},
        {{UNxOP,"-"},{{UNxOP,"+"},{{UNxOP,"-"},{{UNxOP,"+"},{{UNxOP,
        "-"},{BOOLLITxVAL,"false"}}}}}}}},{STMTxLIST,{ASSNxSTMT,
        {SIMPLExVAR,"a"},{NUMLITxVAL,"3"}}},{{BINxOP,"+"},{{BINxOP,"+"},
        {NUMLITxVAL,"3"},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}},{STMTxLIST,
        {ASSNxSTMT,{SIMPLExVAR,"x"},{NUMLITxVAL,"5"}}},{STMTxLIST,
        {ASSNxSTMT,{SIMPLExVAR,"r"},{NUMLITxVAL,"7"}}}}},
      "If statement with complex expression")
end


function test_prog(t)
    io.write("Test Suite: complete programs\n")

    -- Example #1 from Assignment 4 description
    checkParse(t,
      [[#
        # Dugong Example #1
        # By GGC 2018-02-15
        nn = 3
        print nn; cr
      ]], true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"nn"},{NUMLITxVAL,"3"}},
        {PRINTxSTMT,{SIMPLExVAR,"nn"},{CRxOUT}}},
      "Program: Example #1 from Assignment 4 description")

    -- Example #2 from Assignment 4 description
    checkParse(t,
      [[#
        # fibo.du
        # Glenn G. Chappell
        # 12 Feb 2018
        #
        # For CS F331 / CSCE A331 Spring 2018
        # Dugong Example: Printing Fibonacci Numbers


        # Function fibo
        # Given k, return F(k),
        # where F(n) = nth Fibonacci no.
        func fibo
            a = 0  # Consecutive Fibos
            b = 1
            i = 0  # Loop counter
            while i < k
                c = a+b  # Advance
                a = b
                b = c
                i = i+1  # ++counter
            end
            return = a   # Result
        end


        # Main Program

        # Get number of Fibos to output
        print "How many Fibos to print: "
        input n
        print cr

        # Print requested number of Fibos
        j = 0  # Loop counter
        while j < n
            k = j
            print "F(";j;") = ";call fibo;cr
            j = j+1  # ++counter
        end
      ]], true, true,
      {STMTxLIST,{FUNCxSTMT,"fibo",{STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,
        "a"},{NUMLITxVAL,"0"}},{ASSNxSTMT,{SIMPLExVAR,"b"},{NUMLITxVAL,
        "1"}},{ASSNxSTMT,{SIMPLExVAR,"i"},{NUMLITxVAL,"0"}},{WHILExSTMT,
        {{BINxOP,"<"},{SIMPLExVAR,"i"},{SIMPLExVAR,"k"}},{STMTxLIST,
        {ASSNxSTMT,{SIMPLExVAR,"c"},{{BINxOP,"+"},{SIMPLExVAR,"a"},
        {SIMPLExVAR,"b"}}},{ASSNxSTMT,{SIMPLExVAR,"a"},{SIMPLExVAR,
        "b"}},{ASSNxSTMT,{SIMPLExVAR,"b"},{SIMPLExVAR,"c"}},{ASSNxSTMT,
        {SIMPLExVAR,"i"},{{BINxOP,"+"},{SIMPLExVAR,"i"},{NUMLITxVAL,
        "1"}}}}},{ASSNxSTMT,{SIMPLExVAR,"return"},{SIMPLExVAR,"a"}}}},
        {PRINTxSTMT,{STRLITxOUT,'"How many Fibos to print: "'}},
        {INPUTxSTMT,{SIMPLExVAR,"n"}},{PRINTxSTMT,{CRxOUT}},{ASSNxSTMT,
        {SIMPLExVAR,"j"},{NUMLITxVAL,"0"}},{WHILExSTMT,{{BINxOP,"<"},
        {SIMPLExVAR,"j"},{SIMPLExVAR,"n"}},{STMTxLIST,{ASSNxSTMT,
        {SIMPLExVAR,"k"},{SIMPLExVAR,"j"}},{PRINTxSTMT,{STRLITxOUT,
        '"F("'},{SIMPLExVAR,"j"},{STRLITxOUT,'") = "'},{CALLxFUNC,
        "fibo"},{CRxOUT}},{ASSNxSTMT,{SIMPLExVAR,"j"},{{BINxOP,"+"},
        {SIMPLExVAR,"j"},{NUMLITxVAL,"1"}}}}}},
      "Program: Example #2 from Assignment 4 description")

    -- Input number, print its square
    checkParse(t,
      [[#
        print 'Type a number: '
        input n
        print cr; cr
        print 'You typed: '
        print a; cr
        print 'Its square is: '
        print a*a; cr; cr
      ]], true, true,
      {STMTxLIST,{PRINTxSTMT,{STRLITxOUT,"'Type a number: '"}},
        {INPUTxSTMT,{SIMPLExVAR,"n"}},{PRINTxSTMT,{CRxOUT},{CRxOUT}},
        {PRINTxSTMT,{STRLITxOUT,"'You typed: '"}},{PRINTxSTMT,
        {SIMPLExVAR,"a"},{CRxOUT}},{PRINTxSTMT,{STRLITxOUT,
        "'Its square is: '"}},{PRINTxSTMT,{{BINxOP,"*"},{SIMPLExVAR,
        "a"},{SIMPLExVAR,"a"}},{CRxOUT},{CRxOUT}}},
      "Program: Input number, print its square")

    -- Input numbers, stop at sentinel, print even/odd
    checkParse(t,
      [[#
        continue = 1
        while continue
            print 'Type a number (0 to end): '
            input n
            print cr; cr
            if n == 0
                continue = 0
            else
                print 'The number '; n; ' is '
                if n % 2 == 0
                    print 'even'
                else
                    print 'odd'
                end
                print cr; cr
            end
        end
        print 'Bye!'; cr; cr
      ]], true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"continue"},{NUMLITxVAL,"1"}},
        {WHILExSTMT,{SIMPLExVAR,"continue"},{STMTxLIST,{PRINTxSTMT,
        {STRLITxOUT,"'Type a number (0 to end): '"}},{INPUTxSTMT,
        {SIMPLExVAR,"n"}},{PRINTxSTMT,{CRxOUT},{CRxOUT}},{IFxSTMT,
        {{BINxOP,"=="},{SIMPLExVAR,"n"},{NUMLITxVAL,"0"}},{STMTxLIST,
        {ASSNxSTMT,{SIMPLExVAR,"continue"},{NUMLITxVAL,"0"}}},
        {STMTxLIST,{PRINTxSTMT,{STRLITxOUT,"'The number '"},{SIMPLExVAR,
        "n"},{STRLITxOUT,"' is '"}},{IFxSTMT,{{BINxOP,"=="},
        {{BINxOP,"%"},{SIMPLExVAR,"n"},{NUMLITxVAL,"2"}},{NUMLITxVAL,
        "0"}},{STMTxLIST,{PRINTxSTMT,{STRLITxOUT,"'even'"}}},{STMTxLIST,
        {PRINTxSTMT,{STRLITxOUT,"'odd'"}}}},{PRINTxSTMT,{CRxOUT},
        {CRxOUT}}}}}},{PRINTxSTMT,{STRLITxOUT,"'Bye!'"},{CRxOUT},
        {CRxOUT}}},
      "Program: Input numbers, stop at sentinel, print even/odd")

    -- Input numbers, print them in reverse order
    checkParse(t,
      [[#
        howMany = 5  # How many numbers to input
        print 'I will ask you for '
        print howMany
        print ' values (numbers).'; cr
        print 'Then I will print them in reverse order.'; cr; cr
        i = 1
        while i <= howMany  # Input loop
            print 'Type value #'; i; ': '
            input v[i]
            print cr; cr
            i = i+1
        end
        print '----------------------------------------'; cr; cr
        print 'Here are the values, in reverse order:'; cr
        i = howMany
        while i > 0  # Output loop
            print 'Value #'; i; ': '; v[i]; cr
            i = i-1
        end
        print cr
      ]], true, true,
      {STMTxLIST,{ASSNxSTMT,{SIMPLExVAR,"howMany"},{NUMLITxVAL,"5"}},
      {PRINTxSTMT,{STRLITxOUT,"'I will ask you for '"}},{PRINTxSTMT,
      {SIMPLExVAR,"howMany"}},{PRINTxSTMT,{STRLITxOUT,
      "' values (numbers).'"},{CRxOUT}},{PRINTxSTMT,{STRLITxOUT,
      "'Then I will print them in reverse order.'"},{CRxOUT},{CRxOUT}},
      {ASSNxSTMT,{SIMPLExVAR,"i"},{NUMLITxVAL,"1"}},{WHILExSTMT,
      {{BINxOP,"<="},{SIMPLExVAR,"i"},{SIMPLExVAR,"howMany"}},
      {STMTxLIST,{PRINTxSTMT,{STRLITxOUT,"'Type value #'"},{SIMPLExVAR,
      "i"},{STRLITxOUT,"': '"}},{INPUTxSTMT,{ARRAYxVAR,"v",{SIMPLExVAR,
      "i"}}},{PRINTxSTMT,{CRxOUT},{CRxOUT}},{ASSNxSTMT,{SIMPLExVAR,"i"},
      {{BINxOP,"+"},{SIMPLExVAR,"i"},{NUMLITxVAL,"1"}}}}},{PRINTxSTMT,
      {STRLITxOUT,"'----------------------------------------'"},
      {CRxOUT},{CRxOUT}},{PRINTxSTMT,{STRLITxOUT,
      "'Here are the values, in reverse order:'"},{CRxOUT}},{ASSNxSTMT,
      {SIMPLExVAR,"i"},{SIMPLExVAR,"howMany"}},{WHILExSTMT,{{BINxOP,
      ">"},{SIMPLExVAR,"i"},{NUMLITxVAL,"0"}},{STMTxLIST,{PRINTxSTMT,
      {STRLITxOUT,"'Value #'"},{SIMPLExVAR,"i"},{STRLITxOUT,"': '"},
      {ARRAYxVAR,"v",{SIMPLExVAR,"i"}},{CRxOUT}},{ASSNxSTMT,{SIMPLExVAR,
      "i"},{{BINxOP,"-"},{SIMPLExVAR,"i"},{NUMLITxVAL,"1"}}}}},
      {PRINTxSTMT,{CRxOUT}}},
      "Program: Input numbers, print them in reverse order")

    -- Long program
    howmany = 50
    progpiece = "print 42\n"
    prog = progpiece:rep(howmany)
    ast = {STMTxLIST}
    astpiece = {PRINTxSTMT,{NUMLITxVAL,"42"}}
    for i = 1, howmany do
        table.insert(ast, astpiece)
    end
    checkParse(t, prog, true, true,
      ast,
      "Program: Long program")

    -- Very long program
    howmany = 10000
    progpiece = "input x print x; cr\n"
    prog = progpiece:rep(howmany)
    ast = {STMTxLIST}
    astpiece1 = {INPUTxSTMT,{SIMPLExVAR,"x"}}
    astpiece2 = {PRINTxSTMT,{SIMPLExVAR,"x"},{CRxOUT}}
    for i = 1, howmany do
        table.insert(ast, astpiece1)
        table.insert(ast, astpiece2)
    end
    checkParse(t, prog, true, true,
      ast,
      "Program: Very long program")
end


function test_parseit(t)
    io.write("TEST SUITES FOR MODULE parseit\n")
    test_simple(t)
    test_call_stmt(t)
    test_input_stmt(t)
    test_print_stmt_no_expr(t)
    test_func_stmt_no_expr(t)
    test_while_stmt_simple_expr(t)
    test_if_stmt_simple_expr(t)
    test_assn_stmt_simple_expr(t)
    test_expr_simple(t)
    test_print_stmt_with_expr(t)
    test_func_stmt_with_expr(t)
    test_expr_prec_assoc(t)
    test_expr_complex(t)
    test_prog(t)
end


-- *********************************************************************
-- Main Program
-- *********************************************************************


test_parseit(tester)
io.write("\n")
if tester:allPassed() then
    io.write("All tests successful\n")
else
    io.write("Tests ********** UNSUCCESSFUL **********\n")
    io.write("\n")
    io.write("**************************************************\n")
    io.write("* This test program is configured to execute all *\n")
    io.write("* tests, reporting success/failure for each. To  *\n")
    io.write("* make it exit after the first failing test, set *\n")
    io.write("* variable                                       *\n")
    io.write("*                                                *\n")
    io.write("*   EXIT_ON_FIRST_FAILURE                        *\n")
    io.write("*                                                *\n")
    io.write("* to true, near the start of the test program.   *\n")
    io.write("**************************************************\n")
end

-- Wait for user
io.write("\nPress ENTER to quit ")
io.read("*l")


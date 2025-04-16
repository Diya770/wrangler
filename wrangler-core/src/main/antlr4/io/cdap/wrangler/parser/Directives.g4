/*
 * Copyright © 2017-2019 Cask Data, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

grammar Directives;

options {
  language = Java;
}

@lexer::header {
/*
 * Grammar for CDAP Wrangler directives.
 * Modified to support parsing of byte size (e.g., 10MB, 1GB) and time duration (e.g., 5s, 2h).
 * These enhancements allow easier handling of configuration-like transformations.
 */
}

recipe
 : statements EOF // Entry point of the grammar
 ;

statements
 :  ( Comment | macro | directive ';' | pragma ';' | ifStatement)* // List of valid top-level statements
 ;

directive
 : command
   (  // Acceptable directive parameters (zero or more)
      codeblock
    | identifier
    | macro
    | text
    | number
    | bool
    | column
    | colList
    | numberList
    | boolList
    | stringList
    | numberRanges
    | properties
    | ByteSize  // New: Byte size unit like 10MB, 512KB
    | Duration  // New: Duration unit like 5s, 1h
  )*?
 ;

ifStatement
  : ifStat elseIfStat* elseStat? '}'
  ;

ifStat
  : 'if' expression '{' statements
  ;

elseIfStat
  : '}' 'else' 'if' expression '{' statements
  ;

elseStat
  : '}' 'else' '{' statements
  ;

expression
  : '(' (~'(' | expression)* ')' // Support nested parenthesis expressions
  ;

macro
 : Dollar OBrace (~OBrace | macro | Macro)*? CBrace // Macro syntax like ${macro}
 ;

pragma
 : '#pragma' (pragmaLoadDirective | pragmaVersion)
 ;

pragmaLoadDirective
 : 'load-directives' identifierList
 ;

pragmaVersion
 : 'version' Number
 ;

codeblock
 : 'exp' Space* ':' condition
 ;

identifier
 : Identifier
 ;

properties
 : 'prop' ':' OBrace (propertyList)+  CBrace
 // Handle common syntax errors for improved error feedback
 | 'prop' ':' OBrace OBrace (propertyList)+ CBrace { notifyErrorListeners("Too many start paranthesis"); }
 | 'prop' ':' OBrace (propertyList)+ CBrace CBrace { notifyErrorListeners("Too many start paranthesis"); }
 | 'prop' ':' (propertyList)+ CBrace { notifyErrorListeners("Missing opening brace"); }
 | 'prop' ':' OBrace (propertyList)+  { notifyErrorListeners("Missing closing brace"); }
 ;

propertyList
 : property (',' property)*
 ;

property
 : Identifier '=' ( text | number | bool ) // prop key=value pairs
 ;

numberRanges
 : numberRange ( ',' numberRange)*
 ;

numberRange
 : Number ':' Number '=' value
 ;

value
 : String
 | Number
 | Column
 | Bool
 | ByteSize   // New supported value type
 | Duration   // New supported value type
 ;

ecommand
 : '!' Identifier
 ;

config
 : Identifier
 ;

column
 : Column
 ;

text
 : String
 ;

number
 : Number
 ;

bool
 : Bool
 ;

condition
 : OBrace (~CBrace | condition)* CBrace
 ;

command
 : Identifier
 ;

colList
 : Column (','  Column)+
 ;

numberList
 : Number (',' Number)+
 ;

boolList
 : Bool (',' Bool)+
 ;

stringList
 : String (',' String)+
 ;

identifierList
 : Identifier (',' Identifier)*
 ;

/*
 * Lexer Rules (tokens for grammar)
 */

OBrace   : '{';
CBrace   : '}';
SColon   : ';';
Or       : '||';
And      : '&&';
Equals   : '==';
NEquals  : '!=';
GTEquals : '>=';
LTEquals : '<=';
Match    : '=~';
NotMatch : '!~';
QuestionColon : '?:';
StartsWith : '=^';
NotStartsWith : '!^';
EndsWith : '=$';
NotEndsWith : '!$';
PlusEqual : '+=';
SubEqual : '-=';
MulEqual : '*=';
DivEqual : '/=';
PerEqual : '%=';
AndEqual : '&=';
OrEqual  : '|=';
XOREqual : '^=';
Pow      : '^';
External : '!';
GT       : '>';
LT       : '<';
Add      : '+';
Subtract : '-';
Multiply : '*';
Divide   : '/';
Modulus  : '%';
OBracket : '[';
CBracket : ']';
OParen   : '(';
CParen   : ')';
Assign   : '=';
Comma    : ',';
QMark    : '?';
Colon    : ':';
Dot      : '.';
At       : '@';
Pipe     : '|';
BackSlash: '\\';
Dollar   : '$';
Tilde    : '~';

Bool
 : 'true'
 | 'false'
 ;

// Numeric value, optionally float
Number
 : Int ('.' Digit*)?
 ;

// NEW: Byte size units like 10KB, 1MB, 100GB
ByteSize
 : Int? (('K'|'M'|'G'|'T'|'P')? 'B')  // Optional prefix, then 'B'
 ;

// NEW: Duration values like 5s, 10m, 1h, 30d
Duration
 : Int (('ms' | 's' | 'm' | 'h' | 'd' | 'w' | 'mo' | 'y')) // Units from milliseconds to years
 ;

BYTE_SIZE : DIGIT+ ('.' DIGIT+)? BYTE_UNIT ;
TIME_DURATION : DIGIT+ ('.' DIGIT+)? TIME_UNIT ;

fragment BYTE_UNIT : [KkMmGgTt][Bb] ;
fragment TIME_UNIT : ('ms' | 's' | 'm' | 'h') ;


Identifier
 : [a-zA-Z_\-] [a-zA-Z_0-9\-]*  // Directive names and prop keys
 ;

Macro
 : [a-zA-Z_] [a-zA-Z_0-9]*      // Inside ${...}
 ;

Column
 : ':' [a-zA-Z_\-] [:a-zA-Z_0-9\-]* // Column references like :col_name
 ;

String
 : '\'' ( EscapeSequence | ~('\''))* '\''
 | '"'  ( EscapeSequence | ~('"'))* '"'
 ;

EscapeSequence
   :   '\\' ('b'|'t'|'n'|'f'|'r'|'"'|'\''|'\\')
   |   UnicodeEscape
   |   OctalEscape
   ;

fragment
OctalEscape
   :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
   |   '\\' ('0'..'7') ('0'..'7')
   |   '\\' ('0'..'7')
   ;

fragment
UnicodeEscape
   :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
   ;

fragment
HexDigit : ('0'..'9'|'a'..'f'|'A'..'F') ;

Comment
 : ('//' ~[\r\n]* | '/*' .*? '*/' | '--' ~[\r\n]* ) -> skip
 ;

Space
 : [ \t\r\n\u000C]+ -> skip
 ;

fragment Int
 : '-'? [1-9] Digit* [L]*  // Optional long/int support
 | '0'
 ;

fragment Digit
 : [0-9]
 ;

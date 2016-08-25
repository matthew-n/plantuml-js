
/*
 * Augmented BNF for Syntax Specifications: ABNF
 *
 * http://tools.ietf.org/html/rfc5234#appendix-B Core ABNF of ABNF 

 from GitHub project: core-pegjs <https://github.com/for-GET/core-pegjs>
  file: /src/ietf/rfc5234-core-abnf.pegjs
 
*/

LWSP
  = $(WSP / CRLF)* {}
  
WSP "Whitespace"
  = (SP / HTAB) {}

CRLF
  = CR LF

HEXDIG
  = DIGIT
  / "A"i
  / "B"i
  / "C"i
  / "D"i
  / "E"i
  / "F"i

BIT
  = "0"
  / "1"

CR
  = "\x0D"
  
HTAB
  = "\x09"

LF
  = "\x0A"

SP
 = "\x20"
 
ALPHA
  = [\x41-\x5A]
  / [\x61-\x7A]

CHAR
  = [\x01-\x7F]

CTL
  = [\x00-\x1F]
  / "\x7F"

DIGIT
  = [\x30-\x39]

DQUOTE
  = [\x22]

OCTET
  = [\x00-\xFF]

VCHAR
  = [\x21-\x7E]

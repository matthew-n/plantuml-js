
{
  var TYPES_TO_PROPERTY_NAMES = {
    CallExpression:   "callee",
    MemberExpression: "object",
  };

  function filledArray(count, value) {
    var result = new Array(count), i;

    for (i = 0; i < count; i++) {
      result[i] = value;
    }

    return result;
  }

  function extractOptional(optional, index) {
    return optional ? optional[index] : null;
  }

  function extractList(list, index) {
    var result = new Array(list.length), i;

    for (i = 0; i < list.length; i++) {
      result[i] = list[i][index];
    }

    return result;
  }

  function buildList(first, rest, index) {
    return [first].concat(extractList(rest, index));
  }

  function buildTree(first, rest, builder) {
    var result = first, i;

    for (i = 0; i < rest.length; i++) {
      result = builder(result, rest[i]);
    }

    return result;
  }

  function buildBinaryExpression(first, rest) {
    return buildTree(first, rest, function(result, element) {
      return {
        type:     "BinaryExpression",
        operator: element[1],
        left:     result,
        right:    element[3]
      };
    });
  }

  function buildLogicalExpression(first, rest) {
    return buildTree(first, rest, function(result, element) {
      return {
        type:     "LogicalExpression",
        operator: element[1],
        left:     result,
        right:    element[3]
      };
    });
  }

  function optionalList(value) {
    return value !== null ? value : [];
  }
}

start
 = instructions
 
instructions
  = first:instruction? rest:(EOS instruction)* EOS?  {
    return ( first ? [first] : []). concat(extractList(rest,1));
  }
  
instruction
  = Comment
  / BlockElement
  / Statment
  
/* ----- A.1 Lexical Grammar ----- */
SourceCharacter
  = !(LF/CR) .
  
IdentifierStart
  = ALPHA
  / "_"
 
IdentifierPart
  = DIGIT 
  / ALPHA
  / "_"
  / "."
  
LineTerminator
  = LF 
  / CR 
  / "\u2028"
  / "\u2029"
SQUOTE
  = "'"
  
LineTerminatorSequence "end of line"
  = $( LF / CRLF / CR /  "\u2028" / "\u2029" )
/*-- Skipped --*/
__
  = WSP+
_
  = WSP*
     
EOS
  = $(( LF / CRLF / CR / ";")+) // new-line or ; terminated statements
  / $(WSP* & "}" )              // new of enum/class body
  / $(WSP* &SQUOTE)             // begining of comment

IdentifierName "identifier"
  = first:IdentifierStart rest:IdentifierPart* {
      return {
        type: "Identifier",
        name: first + rest.join("")
      };
    }
    
Comment
  = SQUOTE comment:$(SourceCharacter*) {
      return {type:"comment", text:comment};
    }
  
/* Literals */
StringLiteral "string"
  = DQUOTE chars:$(DoubleStringCharacter)* DQUOTE {
      return { type: "Literal", value: chars };
    }
 
DoubleStringCharacter
  = !(DQUOTE / "\\") SourceCharacter
  / LineContinuation

LineContinuation
  = "\\" LineTerminatorSequence { return ""; }

NullLiteral
  = NullToken { return { type: "Literal", value: null }; }
  
EmptyLiteral
  = EmptyToken { return { type: "Literal", value: "empty" }; }
  
HexIntegerLiteral
  = "#"i digits:$HEXDIG+ {
      return { type: "Literal", value: parseInt(digits, 16) };
  }
  
/*-- Words --*/

ReservedWord 
  = RenderCommands
  / UMLObject
  / Annotation
  / NullLiteral
  / EmptyLiteral

RenderCommands 
  = HideToken
  / SetToken
  
UMLObject
  = ClassToken
  / EnumToken
  
Annotation
  = TitleToken
  / HeaderToken
  / FooterToken
  / LegendToken
  / NoteToken
  
/*-- Tokens --*/

/* litterals */
NullToken   = "null"   !IdentifierPart
EmptyToken  = "empty"  !IdentifierPart

/* UML Objects */
ClassToken   = "class"   !IdentifierPart
EnumToken    = "enum"    !IdentifierPart
PackageToken = "package" !IdentifierPart

/* Annotations */
TitleToken  = "title " !IdentifierPart
HeaderToken = "header" !IdentifierPart
FooterToken = "footer" !IdentifierPart
LegendToken = "legend" !IdentifierPart
NoteToken   = "note"   !IdentifierPart

/* Render Commands */
HideToken   = "hide"   !IdentifierPart
SetToken    = "set"    !IdentifierPart

/* Reserved Words */
EndToken    = "end"    !IdentifierPart

/* Symbols */
PrivateToken        = "-" 
ProtectedToken      = "#" 
PackagePrivateToken = "~" 
PublicToken         = "+"

StereotypeOpenToken  = "<<"
StereotypeCloseToken = ">>"

LeftExtendsToken  = "<|"
RightExtendsToken = "|>"
RightArrowToken   = ">"  
LeftArrowToken    = "<"
CompositionToken  = "o"  
AggregationToken  = "*"
InterfaceToken    =  "()"

SolidLineToken  = "-" 
BrokenLineToken = "." 

/* ----- A.2 Number Conversions ----- */

/* Irrelevant. */

/* ----- A.3 Expressions ----- */

RelationshipBody
  = a:$(SolidLineToken+) hint:RelationshipBodyHint b:$(SolidLineToken+) { return { type: "solid", len: a.length+b.length, hint:hint } }
  / a:$(BrokenLineToken+) hint:RelationshipBodyHint b:$(BrokenLineToken+) { return { type: "broken", len: a.length+b.length, hint:hint } }
  / a:$(SolidLineToken+) { return { type: "solid", len: a.length} }
  / a:$(BrokenLineToken+) { return { type: "broken", len: a.length} }

RelationshipBodyHint
  = ("up"/"down"/"left"/"right") 

ScopeModifier
  = PrivateToken {return {type:"scope modifier", value:"private"}; }
  / ProtectedToken {return {type:"scope modifier", value:"protected"}; }
  / PackagePrivateToken {return {type:"scope modifier", value:"package private"}; }
  / PublicToken {return {type:"scope modifier", value:"public"}; }
  
RelationshipLeftEnd
  = LeftExtendsToken {return {type:"relation end", value: "left extend"}}
  / LeftArrowToken {return {type:"relation end", value: "left arrow"}}
  / CompositionToken {return {type:"relation end", value: "composition"}}
  / AggregationToken {return {type:"relation end", value: "aggregation"}}
  / InterfaceToken {return {type: "relation end", value: "interface"}}

RelationshipRightEnd
  = RightExtendsToken {return {type:"relation end", value: "right extend"}}
  / RightArrowToken {return {type:"relation end", value: "right arrow"}}
  / CompositionToken {return {type:"relation end", value: "composition"}}
  / AggregationToken {return {type:"relation end", value: "aggregation"}}
  / InterfaceToken {return {type: "relation end", value: "interface"}}

RelationExpression 
  = left:RelationshipLeftEnd? body:RelationshipBody right:RelationshipRightEnd? {
    return {
      left: left,
      right: right,
      body: body
    };
  }
  
LabelExpression
 = !(":") _ text:( StringLiteral / $( (!( "<" / ">" / EOS) SourceCharacter)+)) {
   return {
        contents: text.trim()
   }
 }

AttributeExpression
  = "{" $(Identifier/NullLiteral) "}"

ArrayExpression
  = dtype:Identifier "[" size:$(DIGIT*)? "]"{
    return {
      type: "array",
      size: size
    }
  }
  
DatatypeExpression
  = ArrayExpression
  / Identifier
  
StereotypeSpotExpression
  = "(" id:IdentifierPart "," color:(HexIntegerLiteral/id:Identifier) ")" {
    return {
      shorthand:id,
      color: color
    };
  }
  
StereotypeExpression 
  = _ spot:(StereotypeSpotExpression _ )? id:$((Identifier)+) {
    return {
      name:id,
      spot: extractOptional(spot,1)
    };
  }
  
Stereotype
  = StereotypeOpenToken 
    first:StereotypeExpression  rest:("," StereotypeExpression)*
    StereotypeCloseToken {
    return buildList(first,rest,1)
  }
    
MethodExpression
  = _ scope:( ScopeModifier __ )? 
    dtype:DatatypeExpression __ id:Identifier _ "()" {
    return {
       type: "method",
       name: id,
       data_type: dtype,
       scope: extractOptional(scope,1)||undefined
     }
   }
  
PropertyExpression
   = _ scope:( ScopeModifier __)?
     id:Identifier ":" _ dtype:DatatypeExpression
     attrib:( _ AttributeExpression)?
     stereo:( _ Stereotype)? _ {
     return {
       type: "property",
       name: id,
       data_type: dtype,
       scope: extractOptional(scope,1)||undefined,
       stereotype: extractOptional(stereo,1)
     }
   }

/* ----- A.4 Statements ----- */
Statment
 = ElementRelationship
 / ConstantDefinition
 / DocFormatHide

ElementRelationship
  = lhs:Identifier 
    lhs_card:( _ StringLiteral)?
     _ rel:RelationExpression _
    rhs_card:(StringLiteral _ )?
    rhs:Identifier 
    lbl:( _ ":" _ LabelExpression _ ( "<" / ">" / EOS) )? {
    return {
        left: {ref: lhs, cardinality: extractOptional(lhs_card,1) },
        right: {ref: rhs, cardinality: extractOptional(rhs_card,0) },
        relationship: rel,
        label: extractOptional(lbl,3),
        direction: extractOptional(lbl,5)
    };
  }

ConstantDefinition
 = "!define" WSP key:Identifier WSP sub:$(SourceCharacter+) {
    return {
      type: "define",
      search: key,
      replacement: sub
    };
  }
 
 DocFormatHide 
  = HideToken _ selector:$( (UMLObject (_ Stereotype )?) / Annotation / EmptyLiteral ) 
    _ element:$( "stereotype"/"method")? {
    return {
      type: "hide",
      selector: selector,
      element: element
    }
  }

 
/* ----- A.5 Block Elements ----- */

BlockElement 
  = ClassDeclaration
  / EnumDeclaration
  / HeaderBlock
 
HeaderBlock
  = HeaderToken EOS 
    body:$( (!(EOS EndToken __ HeaderToken) SourceCharacter)*)
    EOS EndToken __ HeaderToken {
    return {
      type: "header block",
      body: body.trim()
    };
  }

ClassElements
  = member:MethodExpression {return member;}
  / prop:PropertyExpression {return prop;}
 
ClassBody
  = rest:( ClassElements EOS)* {
    return extractList(rest, 0)
  }
  
ClassDeclaration
  = ClassToken __ id:Identifier 
    stereotype:( _ Stereotype )? 
    body:( _ "{" LWSP ClassBody  LWSP "}" )?  {
    return {
      umlobjtype: "class",
      id: id,
      body:  extractOptional(body,3),
      stereotype: extractOptional(stereotype, 1)
    };
  }
    
EnumMembers
  = id:Identifier {
    return {
      type:"enum member",
      name: id
    };
  }

EnumBody 
  = rest:(EnumMembers EOS )* {
    return extractList(rest, 0)
  }  
 
EnumDeclaration
  = EnumToken __ id:Identifier 
    body:( _ "{" LWSP EnumBody LWSP "}" )?  {
    return {
      umlobjtype: "enum",
      id: id,
      body:  optionalList(extractOptional(body, 3)),
    };
  }
 
 
 /*
 * Augmented BNF for Syntax Specifications: ABNF
 *
 * http://tools.ietf.org/html/rfc5234
 */

/* http://tools.ietf.org/html/rfc5234#appendix-B Core ABNF of ABNF */
ALPHA
  = [\x41-\x5A]
  / [\x61-\x7A]

BIT
  = "0"
  / "1"

CHAR
  = [\x01-\x7F]

CR
  = "\x0D"

CRLF
  = CR LF

CTL
  = [\x00-\x1F]
  / "\x7F"

DIGIT
  = [\x30-\x39]

DQUOTE
  = [\x22]

HEXDIG
  = DIGIT
  / "A"i
  / "B"i
  / "C"i
  / "D"i
  / "E"i
  / "F"i

HTAB
  = "\x09"

LF
  = "\x0A"

LWSP
  = $(WSP / LF WSP / CRLF WSP)*

OCTET
  = [\x00-\xFF]

SP
  = "\x20"

VCHAR
  = [\x21-\x7E]

WSP
  = SP
  / HTAB
  
  
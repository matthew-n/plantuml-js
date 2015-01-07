
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
    return optional ? optional[index] : undefined;
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
  
Identifier
  = $(!ReservedWord IdentifierStart (IdentifierPart)*)

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
  = "\\" $( LF / CR / CRLF )
 
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

LabelText
  = $( !":" _ (StringLiteral / (!LabelTerminator SourceCharacter)+) )
  
LabelExpression
  =  ":" _ text:LabelText _ arrow:LabelTerminator {
    return { 
      text: text, 
      direction: arrow
    }
  }

AttributeMembers
  = item:$(_ Identifier)* _ {return item.trim() }

AttributeBody 
  = first:AttributeMembers rest:("," AttributeMembers)*  {
    return buildList(first,rest,1)
  }
  
AttributeExpression
  = "{" list:AttributeBody "}" { return list; }

ArrayExpression
  = dtype:Identifier "[" size:$(DIGIT*)? "]"{
    return {
      type: "array",
      basetype: dtype,
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
  = _ spot:(StereotypeSpotExpression _ )? id:$(Identifier+) {
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
       scope: extractOptional(scope,0)
     }
   }
  
PropertyExpression
   = _ scope:( ScopeModifier _)?
     id:Identifier ":" _ dtype:DatatypeExpression
     attrib:( _ AttributeExpression)?
     stereo:( _ Stereotype)? _ {
     return {
       type: "property",
       name: id,
       data_type: dtype,
	   attributes: extractOptional(attrib,1),
       scope: extractOptional(scope,0),
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
    lhs_card:( __ StringLiteral)?
     _ rel:RelationExpression _
    rhs_card:(StringLiteral __ )?
    rhs:Identifier 
    lbl:( _ LabelExpression) ? {
    return {
        left: {ref: lhs, cardinality: extractOptional(lhs_card,1) },
        right: {ref: rhs, cardinality: extractOptional(rhs_card,0) },
        relationship: rel,
        label: extractOptional(lbl,1)
    };
  }

ConstantDefinition
 = "!define" __ key:Identifier __ sub:$(SourceCharacter+) {
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
  = HeaderToken 
    LineBreak body:$( !EndHeaderToken SourceCharacter* ) LineBreak
    EndHeaderToken {
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
    body:( _ "{" LineBreak* ClassBody  LineBreak* "}" )?  {
    return {
      umlobjtype: "class",
      id: id,
      body:  extractOptional(body,3),
      stereotype: extractOptional(stereotype, 1)
    };
  }
    
EnumMembers
  = _ id:Identifier {
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
    body:( _ "{" LineBreak* EnumBody LineBreak* "}" )?  {
    return {
      umlobjtype: "enum",
      id: id,
      body:  optionalList(extractOptional(body, 3)),
    };
  }
 
/* -----         Literals           ----- */
StringLiteral "string"
  = DQUOTE chars:$(DoubleStringCharacter)* DQUOTE {
      return { type: "Literal", value: chars };
    }
 
DoubleStringCharacter
  = !(DQUOTE / BSLASH) SourceCharacter
  / LineContinuation
  
HexIntegerLiteral
  = "#" digits:$HEXDIG+ {
      return { type: "Literal", value: parseInt(digits, 16) };
  }
  
EmptyLiteral
  = EmptyToken { return { type: "Literal", value: "empty" }; }
  
/* -----      const strings         ----- */
/* litterals */
EmptyToken  = "empty"i    !IdentifierPart

/* UML Objects */
ClassToken   = "class"i   !IdentifierPart
EnumToken    = "enum"i    !IdentifierPart
PackageToken = "package"i !IdentifierPart

/* Annotations */
TitleToken  = "title "i   !IdentifierPart
HeaderToken = "header"i   !IdentifierPart
FooterToken = "footer"i   !IdentifierPart
LegendToken = "legend"i   !IdentifierPart
NoteToken   = "note"i     !IdentifierPart

/* Render Commands */
HideToken   = "hide"i  !IdentifierPart
SetToken    = "set"i   !IdentifierPart

/* Reserved Words */
EndToken    = "end"i   !IdentifierPart
EndHeaderToken = EndToken __ HeaderToken

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

SQUOTE
  = "'"
__
  = WSP+
_
  = WSP*
  
LineBreak
  = WSP* (CRLF  / LF  / CR ) WSP*
  
EOS
  = $(LineBreak / (WSP* ";" WSP*))+  // new-line or ; terminated statements
  / $(WSP* & "}" )                    // new of enum/class body
  / $(WSP* &SQUOTE)                   // begining of comment
 
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
  = $(WSP / CRLF WSP)*

OCTET
  = [\x00-\xFF]

SP
  = "\x20"

VCHAR
  = [\x21-\x7E]

WSP
  = SP
  / HTAB
  
  
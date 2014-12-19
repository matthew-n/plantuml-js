
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
  = ((statement:(Comment/UMLElements/Statments) __) { return statement; })*

/* ----- A.1 Lexical Grammar ----- */
SourceCharacter
  = .
  
IdentifierStart
  = [_a-z]i
 
IdentifierPart
  = [_a-z0-9\.]i
  
HexDigit
  = [0-9a-f]i
  
LineTerminator
  = [\n\r\u2028\u2029]
  
LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029"
  
WhiteSpace "whitespace"
  = "\t"
  / "\v"
  / "\f"
  / " "
  / "\u00A0"
  / "\uFEFF"
 
Identifier
  = !ReservedWord name:IdentifierName { return name; }

IdentifierName "identifier"
  = first:IdentifierStart rest:IdentifierPart* {
      return {
        type: "Identifier",
        name: first + rest.join("")
      };
    }
	
Comment
  = "'" comment:$(!LineTerminator SourceCharacter)* {return {type:"comment", text:comment};}
  
/* Literals */
StringLiteral "string"
  = '"' chars:DoubleStringCharacter* '"' {
      return { type: "Literal", value: chars.join("") };
    }
 
DoubleStringCharacter
  = !('"' / "\\" / LineTerminator) SourceCharacter { return text(); }
  / LineContinuation

SingleStringCharacter
  = !("'" / "\\" / LineTerminator) SourceCharacter { return text(); }
  / LineContinuation

LineContinuation
  = "\\" LineTerminatorSequence { return ""; }

NullLiteral
  = NullToken { return { type: "Literal", value: null }; }
  
EmptyLiteral
  = EmptyToken { return { type: "Literal", value: "empty" }; }
  
HexIntegerLiteral
  = "#"i digits:$HexDigit+ {
      return { type: "Literal", value: parseInt(digits, 16) };
  }
  
/* Skipped */
__
  = (WhiteSpace / LineTerminatorSequence / Comment)*
_
  = (WhiteSpace)*

EOS
  = __ ";"
  / _ Comment
  / _ &"}"
  / __ EOF
  
EOF
 = !.
  
/* Words */

ReservedWord 
  = Commands
  / UMLObject
  / Annotation
  / NullLiteral
  / EmptyLiteral

Commands 
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

ScopeModifier
  = PrivateToken {return {type:"modifier", scope:"private"}; }
  / ProtectedToken {return {type:"modifier", scope:"protected"}; }
  / PackagePrivateToken {return {type:"modifier", scope:"package private"}; }
  / PublicToken {return {type:"modifier", scope:"public"}; }
  
/* Tokens */

NullToken   = "null"   !IdentifierPart
EmptyToken  = "empty"  !IdentifierPart

HideToken   = "hide"   !IdentifierPart
SetToken    = "set"    !IdentifierPart
EndToken    = "end"    !IdentifierPart

ClassToken   = "class"   !IdentifierPart
EnumToken    = "enum"    !IdentifierPart
PackageToken = "package" !IdentifierPart

TitleToken  = "title " !IdentifierPart
HeaderToken = "header" !IdentifierPart
FooterToken = "footer" !IdentifierPart
LegendToken = "legend" !IdentifierPart
NoteToken   = "note"   !IdentifierPart

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
  = $(SolidLineToken+)
  / $(BrokenLineToken+)

  
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

/* todo: this is nonsensical for interfaces  */
RelationExpression 
  = left:RelationshipLeftEnd? body:RelationshipBody right:RelationshipRightEnd? {
    return {
	  left: left,
	  right: right,
	  body: body
	};
  }
  
LabelExpression
 = !(":") _ text:( StringLiteral / $( (![<>] SourceCharacter)+)) {
   return {
		contents: text
   }
 }

AttributeExpression
  = "{" $(Identifier/NullLiteral) "}"

ArrayExpression
  = dtype:Identifier "[" size:$([0-9]*)? "]"{
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
  = spot:( _ StereotypeSpotExpression _ )? id:Identifier {
    return {
      name:id,
      spot: extractOptional(spot,1)
    };
  }
  
Stereotype
  = StereotypeOpenToken 
    first:StereotypeExpression 
	rest:("," StereotypeExpression)* StereotypeCloseToken {
    return buildList(first,rest,1)
  }
    
MethodExpression
  = scope:( _ ScopeModifier)? 
    dtype:DatatypeExpression _ id:Identifier _ "()" {
    return {
	   type: "method",
	   name: id,
	   data_type: dtype,
	   scope: extractOptional(scope,1)||undefined
	 }
   }
  
PropertyExpression
   = scope:( _ ScopeModifier)? 
     _ id:Identifier ":" _ dtype:DatatypeExpression 
     attrib:( _ AttributeExpression)?
     stereo:( _ Stereotype)? {
     return {
	   type: "property",
	   name: id,
	   data_type: dtype,
	   scope: extractOptional(scope,1)||undefined,
	   stereotype: extractOptional(stereo,1)
	 }
   }

/* ----- A.4 Statements ----- */
Statments
 = ElementRelationship

ElementRelationship
  = lhs:Identifier 
    lhs_card:( _ StringLiteral)?
	 _ rel:RelationExpression _
	rhs_card:(StringLiteral _ )?
	rhs:Identifier 
    lbl:( _ ":" _ LabelExpression _ ([<>]))? {
    return {
		left: {ref: lhs, cardinality: extractOptional(lhs_card,1) },
		right: {ref: rhs, cardinality: extractOptional(rhs_card,0) },
		relationship: rel,
		label: extractOptional(lbl,3),
		direction: extractOptional(lbl,5)
	};
  }
 
/* ----- A.5 UMLElements ----- */

UMLElements 
  = ClassDeclaration
  / EnumDeclaration
  
ClassDeclaration
  = ClassToken _ id:Identifier 
    stereoType:( _ Stereotype )? 
	body:( _ "{" __ ClassBody __ "}" )?  {
    return {
      umlobjtype: "class",
      id: id,
      body:  extractOptional(body,3),
      stereotype: extractOptional(stereoType, 1)
    };
  }
  
ClassElements
  = member:MethodExpression {return member;}
  / prop:PropertyExpression {return prop;}
 
ClassBody
  = first:ClassElements rest:( __ ClassElements)* {
    return buildList(first,rest,1)
  }
  
EnumDeclaration
  = EnumToken _ id:Identifier 
    body:( _ "{" __ EnumBody __"}" )?  {
    return {
      umlobjtype: "enum",
      id: id,
      body:  optionalList(extractOptional(body, 3)),
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
  = first:EnumMembers rest:( __ EnumMembers)* {
    return buildList(first,rest,1)
  }
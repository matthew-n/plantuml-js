
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
  = first:instruction? rest:(EOS instruction)* EOS? {
    return ( first ? [first] : []). concat(extractList(rest,1));
  }
  
instruction
  = UMLStatment
  / AnnotaionElement
  / FormattingElement
  / ConstantDefinition
  / Comment

/* -----         Statements         ----- */

UMLStatment
  = ElementRelationship
  / ClassDeclaration
  / EnumDeclaration
  
ElementRelationship
  = lhs:Identifier 
    lhs_card:( WSP+ StringLiteral)?
     WSP* rel:RelationExpression WSP*
    rhs_card:(StringLiteral WSP+ )?
    rhs:Identifier 
    lbl:( WSP* LabelExpression) ? {
    return {
      type: "relation",
      left_node: {ref: lhs, cardinality: extractOptional(lhs_card,1) },
      right_node: {ref: rhs, cardinality: extractOptional(rhs_card,0) },
      edge: rel,
      label: extractOptional(lbl,1)
    };
  }

ClassDeclaration
  = ClassToken WSP+ id:Identifier 
    stereotype:( WSP* StereotypeExpression )? 
    body:( WSP* "{" NL* ClassBody  NL* "}" )?  {
    return {
      type: "class",
      id: id,
      body:  extractOptional(body,3),
      stereotype: extractOptional(stereotype, 1)
    };
  }
  
EnumDeclaration
  = EnumToken WSP+ id:Identifier 
    body:( WSP* "{" NL* EnumBody NL* "}" )?  {
    return {
      type: "enum",
      id: id,
      body:  optionalList(extractOptional(body, 3)),
    };
  }
  
/*** Formatting Elements ***/
FormattingElement
  = DocFormatHide
  / SetRenderElement
  
 DocFormatHide 
  = HideToken WSP+ selector:$( (UMLObject (WSP* StereotypeExpression)?) / Annotation / EmptyLiteral ) 
    WSP* element:$( "stereotype"/"method")? {
    return {
      type: "hide",
      selector: selector,
      element: element
    }
  }

SetRenderElement
  = SetToken WSP+ cmd:$(NSSepToken) WSP+ val:StringLiteral {
    return {
      type:"set",
      command: cmd,
      value: val
    };
  }

/*** Annotation Elements ***/
AnnotaionElement 
  = HeaderBlock
  / FooterBlock
  / TitleBlock
  / NoteBlock
  / LegendBlock
 
HeaderBlock
  = align:HAlignment? HeaderToken 
    NL body:$( !(NL EndHeaderToken) .)* NL
    EndHeaderToken {
    return {
      type: "header",
      body: body.trim(),
	  alignment: align
    };
  }
  
FooterBlock
  = align:HAlignment? FooterToken
    NL body:$( !(NL EndFooterToken) .)* NL
	EndFooterToken {
    return {
	    type: "footer",
		body: body.trim(),
		alignment: align
	}
  }

TitleBlock
  = TitleToken WSP+ title:$(SourceCharacter*) {
    return {
      type: "title",
      text: title.trim()
    };
  }

NoteBlock
  = NoteToken WSP* body:StringLiteral alias:( WSP* AsToken WSP+ Identifier)?
    {
      return {
        type: "note", 
        body: body, 
        alias: extractOptional(alias,2)
      }; 
    }
  / NoteToken alias:( WSP+ AsToken WSP+ Identifier)?
    NL body:$( !(NL EndToken WSP+ NoteToken) .)* NL
	EndToken WSP+ NoteToken
    {
      return {
        type: "note", 
        body: body.trim(), 
        alias: extractOptional(alias,2)
      }; 
    }
  / NoteToken WSP+ align:(NoteAlign WSP+)? id:Identifier WSP* ":" WSP* body:$(SourceCharacter*)
    {
      return {
        type: "note", 
        body: body.trim(), 
        alignment: extractOptional(align,0)
      }; 
    }
  / NoteToken WSP+ align:(NoteAlign WSP+)? id:Identifier 
    NL body:$( !(NL EndToken WSP+ NoteToken) .)* NL
	EndToken WSP+ NoteToken
    {
      return {
        type: "note", 
        body: body.trim(), 
        alignment: extractOptional(align,0)
      }; 
    }

LegendBlock
  = LegendToken meh:(WSP+ RelationHint)?
    NL txt:$( !(NL EndToken WSP+ LegendToken) .)* NL
    EndToken WSP+ LegendToken {
    return {
	  type: "legend",
	  text: txt,
	  direction: extractOptional(meh,1)
    };
  }

/*** Other ***/
ConstantDefinition
 = "!define" WSP+ key:Identifier WSP+ sub:$(SourceCharacter+) {
    return {
      type: "define",
      search: key,
      replacement: sub
    };
  }

Comment
  = SQUOTE comment:$(SourceCharacter*) {
      return {type:"comment", text:comment};
    }


/* -----       Expressions          ----- */
Identifier
  = $(!ReservedWord IdentifierStart (IdentifierPart)*)
  
LabelText
  = $( !":" WSP* (StringLiteral / (!LabelTerminator SourceCharacter)+) )

LabelExpression
  =  ":" WSP* text:LabelText WSP* arrow:LabelTerminator {
    return { 
      text: text, 
      direction: arrow
    }
  }
  
 /** Relation Expression**/ 
RelationExpression 
  = left:RelationshipLeftEnd? body:RelationshipBody right:RelationshipRightEnd? {
    return {
      left_end: left,
      right_end: right,
      body: body
    };
  }
 
RelationshipBody
  = lhs:$(SolidLineToken+) hint:RelationHint?  rhs:$(SolidLineToken*) { 
    return { 
      style: "solid", 
      len: lhs.length + rhs.length, 
      hint: hint||undefined
    } 
  }
  / lhs:$(BrokenLineToken+) hint:RelationHint?  rhs:$(BrokenLineToken*) { 
    return { 
      style: "broken", 
      len: lhs.length + rhs.length, 
      hint: hint||undefined
    } 
  }

/*** class expressions **/
ClassBody
  = rest:( (MethodExpression/PropertyExpression) EOS)* {
    return extractList(rest, 0)
  }
  
MethodExpression
  = WSP* scope:( ScopeModifier WSP+ )? 
    dtype:DatatypeExpression WSP+ id:Identifier WSP* "()" {
    return {
       type: "method",
       name: id,
       data_type: dtype,
       scope: extractOptional(scope,0)
     }
   }
  
PropertyExpression
   = WSP* scope:( ScopeModifier WSP*)?
     id:Identifier ":" WSP* dtype:DatatypeExpression
     attrib:( WSP* AttributeExpression)?
     stereo:( WSP* StereotypeExpression)? WSP* {
     return {
       type: "property",
       name: id,
       data_type: dtype,
       attributes: extractOptional(attrib,1),
       scope: extractOptional(scope,0),
       stereotype: extractOptional(stereo,1)
     }
   }
   
AttributeExpression
  = "{" list:AttributeBody "}" { return list; }

AttributeBody 
  = first:AttributeMembers rest:("," AttributeMembers)*  {
    return buildList(first,rest,1)
  }
  
AttributeMembers
  = item:$(WSP* Identifier)* WSP* {return item.trim() }
    

/*** Enum Expressions ***/
EnumMembers
  = WSP* id:Identifier {
    return {
      type:"enum member",
      name: id
    };
  }

EnumBody 
  = rest:(EnumMembers EOS )* {
    return extractList(rest, 0)
  }  

DatatypeExpression
  = ArrayExpression
  / Identifier
  
ArrayExpression
  = dtype:Identifier "[" size:$(DIGIT*)? "]"{
    return {
      type: "array",
      basetype: dtype,
      size: size
    }
  }

/*** Stereotype Expressions ***/
StereotypeExpression 
  = StereotypeOpenToken
    WSP* first: StereotypeTerm rest:("," StereotypeTerm)* WSP*
    StereotypeCloseToken 
  {
    return buildList(first,rest,1);
  }

StereotypeTerm
  = WSP* spot:(StereotypeSpotExpression WSP* )? id:$(WSP* Identifier)* WSP* {
    return {
	  name: id,
	  spot: extractOptional(spot,1)
	};
  }

StereotypeSpotExpression
  = "(" id:IdentifierPart "," color:(HexIntegerLiteral/id:Identifier) ")" {
    return {
      shorthand:id,
      color: color
    };
  }
  
/* -----         Literals           ----- */
StringLiteral "string"
  = DQUOTE chars:$(DoubleStringCharacter)* DQUOTE {
      return { type: "Literal", value: chars };
    }
 
DoubleStringCharacter
  = !(DQUOTE / Escape) SourceCharacter
  / LineContinuation

HexIntegerLiteral
  = "#" digits:$HEXDIG+ {
      return { type: "Literal", value: parseInt(digits, 16) };
  }
  
EmptyLiteral
  = EmptyToken { return { type: "Literal", value: "empty" }; }

ScopeModifier
  = PrivateToken   {return {type:"scope modifier", value:"private"        }; }
  / ProtectedToken {return {type:"scope modifier", value:"protected"      }; }
  / PackageToken   {return {type:"scope modifier", value:"package private"}; }
  / PublicToken    {return {type:"scope modifier", value:"public"         }; }
  
RelationshipLeftEnd
  = LeftExtendsToken {return {type:"relation end", value: "left extend"}; }
  / LeftArrowToken   {return {type:"relation end", value: "left arrow" }; }
  / CompositionToken {return {type:"relation end", value: "composition"}; }
  / AggregationToken {return {type:"relation end", value: "aggregation"}; }
  / InterfaceToken   {return {type:"relation end", value: "interface"  }; }

RelationshipRightEnd
  = RightExtendsToken {return {type:"relation end", value: "right extend"}; }
  / RightArrowToken   {return {type:"relation end", value: "right arrow" }; }
  / CompositionToken  {return {type:"relation end", value: "composition" }; }
  / AggregationToken  {return {type:"relation end", value: "aggregation" }; }
  / InterfaceToken    {return {type:"relation end", value: "interface"   }; }

  
/* -----      const strings         ----- */

/*-- Words --*/
ReservedWord 
  = RenderCommands
  / UMLObject
  / Annotation
  / EmptyLiteral

RenderCommands 
  = HideToken
  / SetToken
  / NSSepToken
  
UMLObject
  = ClassToken
  / EnumToken
  
Annotation
  = TitleToken
  / HeaderToken
  / FooterToken
  / LegendToken
  / NoteToken

/* Alignment */
RelationHint = UpToken / DownToken / LeftToken / RightToken

HAlignment = CenterToken / LeftToken / RightToken

NoteAlign = $(((TopToken / BottomToken / LeftToken / RightToken) WSP+ OfToken) / OverToken)

UpToken     = "up"i       !IdentifierPart
DownToken   = "down"i     !IdentifierPart
LeftToken   = "left"i     !IdentifierPart
RightToken  = "right"i    !IdentifierPart
TopToken    = "top"i      !IdentifierPart
BottomToken = "bottom"i   !IdentifierPart
OverToken   = "over"i     !IdentifierPart
CenterToken = "center"i   !IdentifierPart
OfToken     = "of"i       !IdentifierPart
  
/* litterals */
EmptyToken  = "empty"i    !IdentifierPart

/* UML Objects */
ClassToken   = "class"i   !IdentifierPart
EnumToken    = "enum"i    !IdentifierPart
PackageToken = "package"i !IdentifierPart

/* Annotations */
TitleToken  = "title"i    !IdentifierPart
HeaderToken = "header"i   !IdentifierPart
FooterToken = "footer"i   !IdentifierPart
LegendToken = "legend"i   !IdentifierPart
NoteToken   = "note"i     !IdentifierPart

/* Render Commands */
HideToken   = "hide"i     !IdentifierPart
SetToken    = "set"i      !IdentifierPart
NSSepToken
  = "namespaceSeparator"i !IdentifierPart

/* Reserved Words */
EndToken    = "end"i      !IdentifierPart
AsToken     = "as"i       !IdentifierPart

/* comaptiblity */
EndHeaderToken
  = EndToken WSP+ HeaderToken
  / "endheader"i
  
EndFooterToken
  = EndToken WSP+ FooterToken
  / "endfooter"i

/* Symbols */
PrivateToken   = "-" 
ProtectedToken = "#" 
PackageToken   = "~" 
PublicToken    = "+"

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


/* -----  common char seq and sets  ----- */
LabelTerminator
 = "<" 
 / ">"
 / EOS

LineContinuation
  = Escape $( LF / CR / CRLF )
 
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

Escape
  = "\\"

SQUOTE
  = "'"
  
NL = (CRLF/CR/LF)
  
EOS
  = $(NL / (WSP* ";" WSP*))+  // new-line or ; terminated statements
  / $(WSP* & "}" )                    // new of enum/class body
  / $(WSP* &SQUOTE)                   // begining of comment
 

 /*
 * Augmented BNF for Syntax Specifications: ABNF
 *
 * http://tools.ietf.org/html/rfc5234#appendix-B Core ABNF of ABNF 

 from GitHub project: core-pegjs <https://github.com/for-GET/core-pegjs>
  file: /src/ietf/rfc5234-core-abnf.pegjs
 
*/
LWSP
  = $(WSP / CRLF)* {}
  
WSP
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


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
 = (instructions)+
 
instructions
 = (WSP/NL)* foo:instruction EOS? {return foo}
 
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


ClassDeclaration
  = ClassToken WSP+ id:Identifier 
    stereotype:( WSP* StereotypeExpression )? 
	body:ClassBody?	
  {
    return {
      type: "class",
      id: id,
      body: body,
      stereotype: extractOptional(stereotype, 1)
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
    body:$( !EndHeaderToken .)+
    EndHeaderToken 
  		{ return { type: "header", body: body, alignment: align }}
  
FooterBlock
  = align:HAlignment? FooterToken 
    body:$( !EndFooterToken .)+
    EndFooterToken 
  		{ return { type: "footer", body: body, alignment: align } }

LegendBlock
  = LegendToken align:LegendAlignment? 
  	txt:$( !EndLegendToken .)+  
    EndLegendToken 
  		{ return { type: "legend", text: txt, direction: align }}

LegendAlignment 
  = (WSP+ RelationHint)

TitleBlock
  = TitleToken WSP+ title:$((CHAR)+) 
  		{ return { type: "title", text: title }; }
        
NoteBlock
  = NoteToken body:StringLiteral name:Alias? EOS
		{ return { type: "note", body: body,  alias: name };  } 
  /
	NoteToken align:NoteAlign? body:LabelExpression EOS
    	{return {type: "note",body: body, alignment:align }}
  /        
  	NoteToken name:Alias? body:NoteBody EOS
  		{return {type:"note", body: body, alias:name}}
  /
  	NoteToken align:NoteAlign? body:NoteBody EOS
    	{return {type: "note",body: body, alignment:align }}
 
EndNoteToken = EndToken WSP NoteToken

NoteBody 
  = (WSP/NL)* body:$( !EndNoteToken .)+ EndNoteToken 
    	{return {type:"block", value: body};}

Alias
  = WSP+ AsToken WSP+ id:Identifier {return id}

NoteAlign 
 = WSP+ align:$(((TopToken / BottomToken / LeftToken / RightToken) WSP+ OfToken) / OverToken)
   WSP+ id:Identifier
   		{return { ref:id, direction:align}}

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


/*** class expressions **/

ClassBody
 = WSP* "{" (WSP/NL)* 
	member:(MethodExpression/PropertyExpression)* 
   "}" 
   EOS 
   {return member}

MethodExpression
  = WSP* scope:( ScopeModifier WSP+ )? 
    dtype:DatatypeExpression WSP+ id:Identifier WSP* "()" (WSP/NL)*{
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
     stereo:( WSP* StereotypeExpression)? (WSP/NL)*{
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


/** Relation Expression**/ 
 ElementRelationship
  = lhs:RelationMember rel:RelationExpression 
    rhs:RelationMember lbl:LabelExpression? 
    WSP* arrow:(RightArrowToken / LeftArrowToken)? WSP* EOS
  {
    return {
      type: "relation",
      left_node: lhs,
      right_node: rhs,
      edge: rel,
      label: lbl,
      direction: arrow
    };
  }

RelationMember
  = WSP* lhs:Identifier card:StringLiteral? {return {ref:lhs, cardinality:card}}
  / card:StringLiteral? WSP* rhs:Identifier  {return {ref:rhs, cardinality:card}}
  
RelationExpression 
  = WSP* left:RelationshipLeftEnd? body:RelationshipBody right:RelationshipRightEnd? {
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


/*** Enum Expressions ***/
EnumDeclaration
  = EnumToken WSP+ id:Identifier body:EnumBody? EOS 
  		{ return { type: "enum", id: id, body:  body}; }
  
EnumBody 
  = WSP* "{" (NL/WSP)*  member:EnumMembers+ (NL/WSP)*  "}"  
  		{return member;}

EnumMembers
  = (NL/WSP)* id:Identifier EOS? 
  		{ return { type:"enum member", name: id }; }

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
  
/* -----       Expressions          ----- */
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

Identifier
  = $(!ReservedWord IdentifierStart (IdentifierPart)*)
 
LabelExpression
 = WSP* ":" lbl:(StringLiteral/LabelText)  {return lbl}

LabelText
  = WSP* txt:$(ALPHA/SP)+ {return txt}
 
/* -----         Literals           ----- */
StringLiteral "string"
  = WSP+ DQUOTE chars:$(DoubleStringCharacter)* DQUOTE {
      return { type: "Literal", value: chars };
    }
 
DoubleStringCharacter
  = !(DQUOTE)(Escape DQUOTE/ SourceCharacter)
  / NL
  / WSP

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
  = "endheader"i !IdentifierPart
  / EndToken WSP+ HeaderToken
  
EndFooterToken
  = "endfooter"i !IdentifierPart
  / EndToken WSP+ FooterToken

EndLegendToken 
  = EndToken WSP+ LegendToken

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
  = ( ";"?(WSP/NL)*
     / !(";").
    ) {}


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

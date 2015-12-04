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

  
/*** Formatting Elements ***/
FormattingElement
  = DocFormatHide
  / SetRenderElement
  
 DocFormatHide 
  = HideToken WSP+ selector:DocFormatSelector WSP* element:$( "stereotype"/"method")? {
    return {
      type: "hide",
      selector: selector,
      element: element
    }
  }

DocFormatSelector 
  = $( ((ClassToken/EnumToken) StereotypeExpression?) / Annotation / EmptyLiteral ) 

SetRenderElement
  = SetToken WSP+ cmd:$(NSSepToken) val:StringLiteral {
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
  		{ return { type: "header", body: body.trim(), alignment: align }}
  
FooterBlock
  = align:HAlignment? FooterToken 
    body:$( !EndFooterToken .)+
    EndFooterToken 
  		{ return { type: "footer", body: body.trim(), alignment: align } }

LegendBlock
  = LegendToken align:LegendAlignment? 
  	txt:$( !EndLegendToken .)+  
    EndLegendToken 
  		{ return { type: "legend", text: txt.trim(), direction: align }}

LegendAlignment 
  = (WSP+ RelationHint)

TitleBlock
  = TitleToken title:LabelText
  		{ return { type: "title", text: title.trim() }; }
        
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
    	{return {type:"block", value: body.trim()};}

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
ClassDeclaration
  = ClassToken WSP+ id:Identifier stereotype:StereotypeExpression? body:ClassBody?	
  		{ return { type: "class", id: id, body: body, stereotype: stereotype } }

ClassBody
 = WSP* "{" (NL/WSP)* member:(MethodExpression/PropertyExpression)* "}"  EOS 
		{return member}

MethodExpression
  = WSP* scope:ScopeModifier? dtype:DatatypeExpression WSP+ id:Identifier WSP* "()"  EOS
		{ return { type: "method", name: id, data_type: dtype, scope: scope } }
  
PropertyExpression
   = WSP* scope:ScopeModifier? 
     WSP* id:Identifier 
     dtype:DatatypeExpression
     attrib:AttributeExpression?
     stereo:StereotypeExpression? EOS{
     return {
       type: "property",
       name: id,
       data_type: dtype,
       attributes: attrib,
       scope: scope,
       stereotype: stereo
     }
   }
   
AttributeExpression
  =   WSP* "{" text:$(!"}".)+ "}" { return text; }

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
  = WSP* StereotypeOpenToken steroTypes:StereotypeTerm+ StereotypeCloseToken 
  		{ return steroTypes }

StereotypeTerm
  = WSP* spot:StereotypeSpotExpression? id:$(ALPHA/SP)+ ","?
  		{ return { name: id, spot: spot } }

StereotypeSpotExpression
  = WSP* "(" id:IdentifierPart "," color:(HexIntegerLiteral/id:Identifier) ")" 
  		{ return { shorthand:id, color: color } }
  
/* -----       Expressions          ----- */
DatatypeExpression
  = WSP* (":" WSP*)?  dtype:(ArrayExpression / Identifier) 
 	 {return dtype}
  
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
  = WSP* txt:$(!NL.)+ {return txt}
 
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

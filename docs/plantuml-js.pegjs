
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

/* 
 * Statements 
 *
 *
 */

UMLStatment 
  = ElementRelationship
  / ClassDeclaration
  / EnumDeclaration
  
/*** class expressions **/
ClassDeclaration
  = ClassToken WSP+ id:Identifier stereotype:StereotypeExpression? body:ClassBody?	
  		{ return { type: "class", id: id, body: body, stereotype: stereotype } }

ClassBody 
 = WSP* "{" LWSP member:(MethodExpression/PropertyExpression)* "}"  EOS 
		{return member}

MethodExpression 
  = LWSP scope:ScopeModifier? dtype:DatatypeExpression WSP+ id:Identifier WSP* "()"  EOS
		{ return { type: "method", name: id, data_type: dtype, scope: scope } }
  
PropertyExpression
   = LWSP scope:ScopeModifier? 
     WSP* id:Identifier 
     dtype:DatatypeExpression?
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
   
AttributeExpression "Attribute Expression"
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
EnumDeclaration "Enum Definition"
  = EnumToken WSP+ id:Identifier body:EnumBody? EOS 
  		{ return { type: "enum", id: id, body:  body}; }
  
EnumBody 
  = WSP* "{" LWSP  member:EnumMembers+ LWSP  "}"  
  		{return member;}

EnumMembers
  = LWSP id:Identifier EOS? 
  		{ return { type:"enum member", name: id }; }

/*** Stereotype Expressions ***/
StereotypeExpression "Stereo Expression"
  = WSP* StereotypeOpenToken steroTypes:StereotypeTerm+ StereotypeCloseToken 
  		{ return steroTypes }

StereotypeTerm
  = WSP* spot:StereotypeSpotExpression? id:$(ALPHA/SP)+ ","?
  		{ return { name: id, spot: spot } }

StereotypeSpotExpression
  = WSP* "(" id:(DIGIT/ALPHA/ "_"/ ".") "," color:(HexIntegerLiteral/id:Identifier) ")" 
  		{ return { shorthand:id, color: color } }
  
/* -----       Expressions          ----- */
DatatypeExpression 
  = (WSP* ":")? WSP*  dtype:(ArrayExpression / Identifier) 
 	 {return dtype}
  
ArrayExpression "Array"
  = dtype:Identifier "[" size:$(DIGIT*)? "]"{
    return {
      type: "array",
      basetype: dtype,
      size: size
    }
  }
/*
 *
 * Annotation Elements 
 *
 *
*/

AnnotaionElement
  = HeaderBlock
  / FooterBlock
  / TitleBlock
  / NoteBlock
  / LegendBlock
 
HeaderBlock "Document Header"
  = align:HAlignment? WSP* HeaderToken 
    body:BlockString
    EndHeaderToken 
  		{ return { type: "header", body: body, alignment: align }}
  
FooterBlock "Document Footer"
  = align:HAlignment? WSP* FooterToken
    body:BlockString
    EndFooterToken 
  		{ return { type: "footer", body: body, alignment: align } }

LegendBlock "Document Legend"
  = LegendToken WSP* align:HAlignment?
    txt:BlockString
    EndLegendToken 
  		{ return { type: "legend", text: txt, alignment: align }}

TitleBlock "Document Title"
  = TitleToken title:LabelText
  		{ return { type: "title", text: title.trim() }; }
        
NoteBlock "Note"
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
		
BlockString
	= LWSP body:$(!"end"i .)+ 
	{return {type:"block string", value: body}}

Alias
  = WSP+ AsToken WSP+ id:Identifier {return id}

NoteAlign 
 = WSP+ align:$(((TopToken / BottomToken / LeftToken / RightToken) WSP+ OfToken) / OverToken)
   WSP+ id:Identifier
   		{return { ref:id, direction:align}}
/*
 *
 * Formatting Elements 
 *
 *
 */
 
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
  /*
 * PlantUML gramar
 *
 * @append formatting.pegjs
 * @append annotations.pegjs
 * @append uml-statments.pegjs
 * @append rfc5234-core-abnf.pegjs
 *
*/

start 
 = DocStart LWSP stmts:(instructions)+ LWSP DocEnd {return stmts}
 
instructions
 = LWSP stmt:instruction EOS? {return stmt}
 
instruction
  = UMLStatment
  / AnnotaionElement
  / FormattingElement
  / ConstantDefinition
  / Comment
  
  

/*** Other ***/
ConstantDefinition 
 = ConstDefToken WSP+ key:Identifier WSP+ sub:$(SourceCharacter+) {
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


Identifier "Identifier"
  = $(!ReservedWord (ALPHA/ "_") (DIGIT/ALPHA/ "_"/ ".")*)
 
LabelExpression "Label"
 = WSP* ":" lbl:(StringLiteral/LabelText)  {return lbl}

LabelText
  = WSP* txt:$(SourceCharacter)+ {return txt}
 
/* -----         Literals           ----- */
StringLiteral "string"
  = WSP+ DQUOTE chars:$(DoubleStringCharacter)* DQUOTE {
      return { type: "Literal", value: chars };
    }
 
DoubleStringCharacter
  = !(DQUOTE)(Escape DQUOTE/ SourceCharacter)
  / NL
  / WSP

HexIntegerLiteral "Hex Literal"
  = "#" digits:$HEXDIG+ {
      return { type: "Literal", value: parseInt(digits, 16) };
  }
  
EmptyLiteral
  = EmptyToken { return { type: "Literal", value: "empty" }; }

ScopeModifier "Scope Modifier"
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
ReservedWord "reserved word"
  = RenderCommands
  / UMLObject
  / Annotation
  / EmptyLiteral

RenderCommands "Render Comand"
  = HideToken
  / SetToken
  / NSSepToken
  
UMLObject "UML Object"
  = ClassToken
  / EnumToken
  
Annotation "Annotation"
  = TitleToken
  / HeaderToken
  / FooterToken
  / LegendToken
  / NoteToken

/* Alignment */
RelationHint "Relative Alignment" = UpToken / DownToken / LeftToken / RightToken

HAlignment "Horizontal Alignment" = CenterToken / LeftToken / RightToken

DocStart "Start of Document" = "@startuml"
DocEnd "End of Document"  = "@enduml"
	
ConstDefToken "Constant definition" = "!define"

UpToken     = "up"i       
DownToken   = "down"i     
LeftToken   = "left"i     
RightToken  = "right"i    
TopToken    = "top"i      
BottomToken = "bottom"i   
OverToken   = "over"i     
CenterToken = "center"i   
OfToken     = "of"i       
  
/* litterals */
EmptyToken  = "empty"i    

/* UML Objects */
ClassToken   = "class"i   
EnumToken    = "enum"i    
PackageToken = "package"i 

/* Annotations */
TitleToken  = "title"i    
HeaderToken = "header"i   
FooterToken = "footer"i   
LegendToken = "legend"i   
NoteToken   = "note"i     

/* Render Commands */
HideToken   = "hide"i     
SetToken    = "set"i      
NSSepToken
  = "namespaceSeparator"i 

/* Reserved Words */
EndToken    = "end"i      
AsToken     = "as"i       

/* comaptiblity */
EndHeaderToken
  = "endheader"i 
  / EndToken WSP+ HeaderToken
  
EndFooterToken
  = "endfooter"i 
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
SourceCharacter
  = !(NL) .
  
Escape
  = "\\"

SQUOTE
  = "'"
  
NL = (CRLF/CR/LF)
  
EOS "EOS"
  = ( ";"? (WSP/NL)*
     / !(";").
    ) {}

LWSP  "Leading Whitespace" 
  = $(NL/WSP)* {}

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

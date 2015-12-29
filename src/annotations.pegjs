
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
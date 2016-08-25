
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
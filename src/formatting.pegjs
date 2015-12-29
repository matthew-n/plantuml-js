
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
  
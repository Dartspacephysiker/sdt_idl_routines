;+
;PROCEDURE:  str_element, struct,  name
;PURPOSE:  find an element within a structure
; Input:
;   struct,  generic structure
;   name,    string  (tag name)
; Purpose:
;   Retrieves the value of a structure element.  This function will not produce
;   an error if the tag and/or structure does not exist.  
;KEYWORDS:
;  VALUE: a named variable in which the value of the element is returned.
;  INDEX: a named variable in which the element index is returned.  The index
;     will be -2 if struct is not a structure,  -1 if the tag is not found, 
;     and >= 0 if successful.
;
;CREATED BY:	Davin Larson
;FILE:  str_element.pro  
;VERSION  1.3
;LAST MODIFICATION: 96/02/07
;-
pro str_element,struct,name,  $
   VALUE = value,   $
   INDEX = index
if data_type(struct) ne 8 then begin
   index = -2
   return
endif

tags = tag_names(struct)
n = where(strupcase(name) eq tags,count)

if count eq 0 then begin
   index = -1
   return
endif

index = n(0)
value = struct.(index)
return
end



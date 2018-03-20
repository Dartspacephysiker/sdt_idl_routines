;+
;PROCEDURE:   options, str, tag_name, value
;PURPOSE:
;  Add (or change) an element of a structure.
;  This routine is useful for changing plotting options for tplot, but can also
;  be used for creating limit structures for other routines such as "SPEC3D"
;  or "CONT2D"
;  
;INPUT: 
;  str:
;    Case 1:  String (or array of strings)  
;       The limit structure associated with the "TPLOT" handle name is altered.
;    Case 2:  Number (or array of numbers)
;       The limit structure for the given "TPLOT" quantity is altered.  The 
;       number/name association is given by "TPLOT_NAMES"
;    Case 3:  Structure or not set (undefined or zero)
;       Structure to be created, added to, or changed.
;  tag_name:     string,  tag name for value.
;  value:    (any type or dimension) value of new element.
;NOTES:
;  if VALUE is undefined then it will be DELETED from the structure.
;  if TAG_NAME is undefined, then the entire limit structure is deleted.
;   
;KEYWORDS:
;  DELETE:  If set, then the corresponding tag_name is removed.
;SEE ALSO:
;  "GET_DATA","STORE_DATA", "TPLOT", "XLIM", "YLIM", "ZLIM", "ADD_STR_ELEMENT"
;
;CREATED BY:	Jasper Halekas
;Modified by:   Davin Larson
;LAST MODIFICATION:	@(#)options.pro	1.15 97/02/05
;-

pro options, struct, tag_name, value, delete=delete,get=get,default=default
@tplot_com

if keyword_set(get) then begin
   n = n_elements(struct)
   value = value(0)
   for i=0,n-1 do begin
      get_data,struct(i),alimit=limit
      str_element,limit,tag_name,value=v
      value = [value,v]
   endfor
   value=value(1:n)
   return
endif  


if data_type(value) eq 0  then delete=1
dt = data_type(struct)
if (dt eq 8) or not keyword_set(struct) then begin 
    add_str_element, struct, tag_name, value  ,delete=delete, /replace
endif else begin                              ;  (tplot variable)
    for i=0,n_elements(struct)-1 do begin
        name = struct(i)
        if keyword_set(default) then $
           get_data,name,dlimit = limit     $        ;  get stored limit
        else  $
           get_data,name,limit = limit             ;  get stored limit
        add_str_element,limit,tag_name,value, delete=delete, /replace
        if keyword_set(default) then $
           store_data,name,dlimit = limit   $        ;  store new structure
        else  $
           store_data,name,limit = limit
    endfor
endelse
return 
end

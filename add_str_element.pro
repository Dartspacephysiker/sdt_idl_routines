;+
;PROCEDURE:   add_str_element, struct, tag_name, value
;PURPOSE:   add an element to a structure (or change an element)
;INPUT: 
;  struct:   structure to be created, added to, or changed
;  tag_name:     string,  tag name.
;  value:    (anything) value of new element.
;SEE ALSO:
;  "str_element"
;Warning:
;  This procedure is slow when adding elements to large structures.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)add_str_element.pro	1.16 97/02/05
;
;-
pro add_str_element,struct,tag_name,value,delete=delete,replace=replace
if keyword_set(delete) then begin
  new_struct = 0
  if data_type(tag_name) eq 7 then $
      extract_tags,new_struct,struct,except=tag_name
  struct=new_struct
  return
end
if n_elements(value) eq 0 then return
n = find_str_element(struct,tag_name)
case n of
     -2:   struct = create_struct(tag_name,value)       ; struct did not exist
     -1:   struct = create_struct(struct,tag_name,value)   ; tag did not exist
   else: begin                                  ;tag already exists
           if keyword_set(replace) then begin
             s1 = size(struct.(n))
             s2 = size(value)
             w = where(s1 ne s2,diff_type)
             if diff_type ne 0 then begin         ; different type; replace
                tags = tag_names(struct)
                ntags = n_elements(tags)
                new_struct=0
                if n gt 0 then extract_tags,new_struct,struct,tags=tags(0:n-1)
                if keyword_set(new_struct) then $
                   new_struct = create_struct(new_struct,tag_name,value) $
                else $
                   new_struct = create_struct(tag_name,value)
                if n lt ntags-1 then  $
                          extract_tags,new_struct,struct,tags=tags(n+1:ntags-1)
                struct = new_struct
;message,/info, 'Tag '+tag_name+' replaced
             endif  else struct.(n)=value         ;same type: change value
           endif else  struct.(n)=value        ;no replace
         end
endcase
return
end






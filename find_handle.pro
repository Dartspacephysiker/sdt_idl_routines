;+
;FUNCTION:  find_handle(name,tagname)
;
;PURPOSE:
;   Returns the index associated with a string name.
;   This function is used by the "TPLOT" routines.
;
;INPUT:     name  (scalar string)
;    name can also be the corresponding integer index to a TPLOT quantity, 
;    in which case name will be converted to the string handle.
;
;RETURN VALUE:   tplot index. (0 if not found)
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)find_handle.pro	1.11 07/02/08
;
;-
function find_handle,name,tagname
@tplot_com.pro
tagname=''
if n_elements(data_quants) eq 0 then begin
   message,'No Data stored yet!',/info
   return,0
endif
if n_elements(name) ne 1 then message,'name must be a scaler'
dt = data_type(name)
if dt eq 7 then begin
  if (!VERSION.RELEASE LE '5.4') then begin
    names = str_sep(name,'.')
  endif else begin
    names = strsplit(name,'.', /EXTRACT)
  endelse
  if n_elements(names) gt 1 then tagname=names(1)
  index = where(data_quants.name eq names(0),count)
  if count eq 0 then return,0
  return, index(0)
endif
if dt ge 1 or dt le 5 then begin
  index = round(name)
  if index gt 0 and index lt n_elements(data_quants) then $
     name = data_quants(index).name $
  else index = 0
  return,index 
endif
return,0
end

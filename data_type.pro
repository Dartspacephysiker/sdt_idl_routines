;+
;FUNCTION:  data_type(x)
;PURPOSE:
;   Returns the variable type (ignores dimension).
;INPUTS: x:   Any idl variable.
;OUTPUT: integer variable type:
;   0 = undefined
;   1 = byte
;   2 = integer
;   3 = long
;   4 = float
;   5 = double
;   6 = complex
;   7 = string
;   8 = structure
;   9 = double precision complex
;
;KEYWORDS:
;   STRUCTURE: When set and if input is a structure, then an array
;       of data types are returned.
;
;SEE ALSO:  "dimen", "ndimen"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)data_type.pro	1.5 96/12/16
;-
function data_type, val, STRUCTURE=str
if keyword_set(str) then begin
   n = n_tags(val)
   if n eq 0 then return,0
   t = lonarr(n)
   for i=0,n-1 do t(i)=data_type(val.(i))
   return,t
endif
s = size(val)
return, s( s(0) +1 )
end



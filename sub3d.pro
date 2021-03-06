;+
;FUNCTION: sub3d
;PURPOSE: Takes two 3D structures and returns a single 3D structure
;  whose data is the difference of the two.
;  This routine is useful for subtracting background counts.
;  Integration period is considered if units are in counts.
;INPUTS: d1,d2  each must be 3D structures obtained from the get_?? routines
;	e.g. "get_el"
;RETURNS: single 3D structure
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)sub3d.pro	1.7 95/12/11
;
;Notes: This is a very crude subroutine. Use at your own risk.
;-



function  sub3d, d1,d2
if data_type(d1) ne 8 then return,d2
if d1.data_name ne d2.data_name then begin
  print,'Incompatible data types'
  return,d1
endif
if d1.units_name ne d2.units_name then begin
  print,'Different Units'
  return,d1
endif

dif = d1

if strlowcase(d1.units_name) eq 'counts' then  trat = d1.integ_t/d2.integ_t  else trat = 1

dif.data = (d1.data - trat * d2.data)

if find_str_element(dif,'ddata') ge 0 then begin
;   print, "Computing Errors... "
   dif.ddata = sqrt( d1.ddata^2 + (trat * d2.ddata)^2 )
endif

return, dif
end



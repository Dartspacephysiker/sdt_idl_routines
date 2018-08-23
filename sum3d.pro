;+
;FUNCTION: sum3d
;PURPOSE: Takes two 3D structures and returns a single 3D structure
;  whose data is the sum of the two
;INPUTS: d1,d2  each must be 3D structures obtained from the get_?? routines
;	e.g. "get_el"
;RETURNS: single 3D structure
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)sum3d.pro	1.6 96/06/27
;
;Notes: This is a very crude subroutine. Use at your own risk.
;-


function  sum3d, d1,d2
if data_type(d1) ne 8 then return,d2
if d2.valid eq 0 then return,d1
if d1.valid eq 0 then return,d2
if d1.data_name ne d2.data_name then begin
  print,'Incompatible data types'
  return,d2
endif

IF d1.nbins NE d2.nbins THEN BEGIN
   PRINT,"Can't combine these"
   STOP
ENDIF

d1Units = d1.units_name
d1 = conv_units(d1,"COUNTS")
d2 = conv_units(d2,"COUNTS")

sum = d1
sum.data = sum.data+d2.data
sum.integ_t =  d1.integ_t + d2.integ_t
sum.end_time = d1.end_time > d2.end_time
sum.time     = d1.time     < d2.time
sum.valid  = d1.valid and d2.valid

sum = conv_units(sum,d1Units)

return, sum
end



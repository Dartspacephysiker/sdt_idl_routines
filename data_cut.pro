;+
;FUNCTION: A = data_cut(name, t)
;PURPOSE:  Interpolates data from a data structure.
;INPUT:
;  name:  Either a data structure or a string that can be associated with
;      a data structure.  (see "get_data" routine)
;      the data structure must contain the element tags:  "x" and "y"
;      the y array may be multi dimensional.
;  t:   (scalar or array)  x-values for interpolated quantities.
;RETURN VALUE:
;  a data array: the first dimention is the first dimention of t
;                the second dimention is the second dimention of name
;
; NOTE!!  keyword options have been temporarily removed!!!!
;
;KEYWORDS:
;  EXTRAPOLATE:  Controls interpolation of the ends of the data. Effects:
;                0:  Default action.  Set new y data to NAN or to MISSING.
;                1:  Extend the endpoints horizontally.
;                2:  Extrapolate the ends.  If the range of 't' is
;                    significantly larger than the old time range, the ends
;                    are likely to blow up.
;  INTERP_GAP:   Determines if points should be interpolated between data gaps,
;                together with the GAP_DIST.  IF the data gap  GAP_DIST, 
;                follow the action of INTERP_GAP
;                0:  Default action.  Set y data to MISSING.
;                1:  Interpolate gaps
;  GAP_DIST:     Determines the size of a data gap above which interpolation
;                is regulated by INTER_GAP.
;                Default value is 5, in units of the average time interval:
;                delta_t = (t(end)-t(start)/N)
;  MISSING:      Value to set the new y data to for data gaps.  Default is NAN.
;
;CREATED BY:	 Davin Larson
;LAST MODIFICATION:     @(#)data_cut.pro	1.12 96/05/28
;                Added the four keywords. (fvm 9/27/95)
;-
FUNCTION data_cut,name,t, $
   COUNT=count, $
   EXTRAPOLATE=EXTRAPOLATE,INTERP_GAP=INTERP_GAP,$
   GAP_DIST=GAP_DIST,MISSING=MISSING

if data_type(name) eq 7 then begin
  get_data,name,data=dat,index=h
  if h eq 0 then begin
    count = 0
    return,0
  endif
endif
 

if data_type(name) eq 8 then dat=name  

if not keyword_set(INTERP_GAP)  then INTERP_GAP  = 0
if n_elements(GAP_DIST) eq 0   then GAP_DIST    = 5.0 
if n_elements(MISSING) eq 0    then MISSING     = !values.f_nan 

nt = dimen1(t)
count = nt
nd1 = dimen1(dat.y)
nd2 = dimen2(dat.y)
y = fltarr(nt,nd2)

;do the interpolation, including the gaps and ends
for i=0,nd2-1 do begin 
  y(*,i) = interp(dat.y(*,i),dat.x,t)
endfor

if not keyword_set(EXTRAPOLATE) then begin
  tlim = minmax_range(dat.x)
  dt = (tlim(1)-tlim(0)) / (n_elements(dat.x)-1)
  tlim = tlim + [-dt,dt]
  outside = where( (t lt tlim(0)) or (t gt tlim(1)) ,c)
  if c ne 0 then y(outside,*) = MISSING
endif


return , reform(y)

d_t_ave = (t(nt-1)-t(0))/float(nt) ;average delta t
t_left_end  = where(t lt dat.x(0))
t_right_end = where(t gt dat.x(nd1-1))
if t_left_end(0)  eq -1 then t_l_e = 0 else t_l_e = 1
if t_right_end(0) eq -1 then t_r_e = 0 else t_r_e = 1
gaps = where(dat.x(1:nd1-1)-dat.x(0:nd1-2) gt GAP_DIST*d_t_ave)
;if 3 is an element of gaps, then there is a gap between dat.x points 3 & 4

;fix the ends of the data
if extrapolate eq 0 then BEGIN  ;set the ends to MISSING
  If t_l_e eq 1 then y(t_left_end,*)  = MISSING
  if t_r_e eq 1 then y(t_right_end,*) = MISSING
ENDIF else if extrapolate eq 1 then begin ;extend the ends horizontally
  if t_l_e eq 1 then y(t_left_end,*)  = dat.y(0,*)
  if t_r_e eq 1 then y(t_right_end,*) = dat.y(nd1-1,*)
endif 
;notice we don't need a test to see if extrapolate eq 2, because that is
;the action of the above for loop

;fix the gaps
if ((gaps(0) ne -1) and (INTERP_GAP eq 0)) then begin ;if gaps exits...
    for j=0,n_elements(gaps)-1 do begin 
      a = where(t gt dat.x(gaps(j)) and t lt dat.x(gaps(j)+1))
      IF a(0) NE -1 THEN y(a,*) = MISSING
    endfor 
endif 

y = reform(y)
return,y
end

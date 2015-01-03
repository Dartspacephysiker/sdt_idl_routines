;+
;FUNCTION:   interp(y,x,u)
;PURPOSE:
;  Linearly Interpolates vectors with an irregular grid.
;  INTERP is functionally the same as INTERPOL, however it is typically 
;  much faster for most applications.
;USAGE:
;  result = interp(y,x,u)
;INPUTS:
;       Y:      The input vector can be any type except string.
;
;       X:      The absicissae values for Y.  This vector must have same # of
;               elements as Y.  The values MUST be monotonically ascending 
;               or descending.
;
;       U:      The absicissae values for the result.  The result will have 
;               the same number of elements as U.  U does not need to be 
;               monotonic.
;
;CREATED BY:	Davin Larson  4-30-96
;FILE:  interp.pro
;VERSION:  1.8
;LAST MODIFICATION:  96/12/02
;-
function interp,y,x,u,index=i,no_check_monotonic=ch_mon

if n_params() eq 2 then begin
   nx = n_elements(y)
   return,interp(y,findgen(nx),findgen(x)/(x-1)*(nx-1),index=i)
endif

;check for invalid x values:

nx = n_elements(x)

good = where(finite(x),c )
if c lt 1 then begin
;   message,/info,'Not enough valid data points to interpolate.'
   return,replicate(!values.f_nan,n_elements(u))
endif
if c ne nx then return, interp(y(good),x(good),u,index=i)

if x(0) gt x(nx-1) then return,interp(reverse(y),reverse(x),u,index=i)

if not keyword_set(ch_mon) then begin
  dx = x-shift(x,1)
  dx(0) = 0
  bad = where(dx lt 0,c)
  if c ne 0 then message,/info,'Warning: Data not monotonic!'
endif

nu = n_elements(u)

mn = replicate(0l,nu)
mx = replicate(nx-1,nu)
repeat begin           ; This loop should execute approximately log2(nx) times
   i = (mx+mn)/2
   tst = x(i) lt u
   ntst = tst eq 0
   mn =  tst*i + ntst*mn
   mx = ntst*i +  tst*mx
endrep  until max(mx-mn) le 1
i = (mx+mn)/2
nv = y(i) + (u-x(i))/(x(i+1)-x(i))*(y(i+1)-y(i))

return,nv
end

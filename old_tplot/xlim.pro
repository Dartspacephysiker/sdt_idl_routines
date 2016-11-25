;+
;PROCEDURE:  xlim,lim, [min,max, [log]]
;PURPOSE:    
;   To set plotting limits for plotting routines.
;   This procedure will add the tags 'xrange', 'xstyle' and 'xlog' to the 
;   structure lim.  This structure can be used in other plotting routines such
;   as "SPEC3D".
;INPUTS: 
;   lim:     structure to be added to.  (Created if non-existent)
;   min:     min value of range
;   max:     max value of range
;KEYWORDS:
;   LOG:  (optional)  0: linear,   1: log
;See also:  "OPTIONS", "YLIM", "ZLIM"
;Typical usage:
;   xlim,lim,-20,100      ; create a variable called lim that can be passed to
;                         ; a plotting routine such as "SPEC3D".
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)xlim.pro	1.6 97/01/02
;-
pro xlim,lim,min,max,log,log=lg
if n_elements(lg) ne 0 then log=lg
if n_elements(min) eq 2 then max=0 
if n_elements(max) eq 0 then range = [0.,0.] else range = float([min,max])
add_str_element,lim,'xrange',range(0:1)
if range(0) eq range(1) then style=0 else style=1
add_str_element,lim,'xstyle',style
if n_elements(log) ne 0 then add_str_element,lim,'xlog',log
return
end



;+
;PROCEDURE:  zlim,lim, [min,max, [log]]
;PURPOSE:    
;   To set plotting limits for plotting routines.
;   This procedure will add the tags 'zrange', 'zstyle' and 'xlog' to the 
;   structure lim.  This structure can be used in other plotting routines.
;INPUTS: 
;   lim:     structure to be added to.  (Created if non-existent)
;   min:     min value of range
;   max:     max value of range
;   log:  (optional)  0: linear,   1: log
;If lim is a string then the limit structure associated with that "TPLOT" 
;   variable is modified.
;See also:  "OPTIONS", "YLIM", "XLIM", "SPEC"
;Typical usage:
;   zlim,'ehspec',1e-2,1e6,1   ; Change color limits of the "TPLOT" variable
;                              ; 'ehspec'.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)zlim.pro	1.1 96/02/19
;-
pro zlim,lim,min,max,log
if n_elements(max) eq 0 then range = [0.,0.] else range = float([min,max])
options,lim,'zrange',range
if range(0) eq range(1) then style=0 else style=1
options,lim,'zstyle',style
if n_elements(log) ne 0 then options,lim,'zlog',log
return
end



;+
;PROCEDURE:	get_timespan
;PURPOSE:	To get timespan from tplot_com or by using timespan, if 
;		tplot time range not set.
;INPUT:		
;	t, actually returned to you
;KEYWORDS:	
;	none
;
;SEE ALSO:	"timespan"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)get_timespan.pro	1.7 96/08/21
;
;-

pro get_timespan,t
@tplot_com.pro
if n_elements(trange_full) ne 2 then timespan
if trange_full(0) ge trange_full(1) then timespan
t = trange_full
return
end



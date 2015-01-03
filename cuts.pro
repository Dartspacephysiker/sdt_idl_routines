;+
;PROCEDURE:	cuts
;PURPOSE:	to show x cuts or y cuts of a 
;		"tplot" spectrogram
;		using the profiles routine
;INPUT:		none
;KEYWORDS:	name:	name of the variable you want cuts for
;
;CREATED BY:	Jasper Halekas
;LAST MODIFICATION:	@(#)cuts.pro	1.3 95/10/06
;
;-
pro cuts, name = name

@tplot_com

n = dimen1(tplot_y)

if not  keyword_set(name) then name = tplot_var(n-1)

plot = where(tplot_var eq name)

if dimen1(plot) gt 1 then plot = plot(0)

x = tplot_x.window
y = tplot_y(plot).window

low = convert_coord(x(0), y(0), /normal, /to_device)
high = convert_coord(x(1), y(1), /normal, /to_device)

t = tvrd(low(0), low(1), high(0) - low(0), high(1)-low(1))

profiles, t, sx = low(0), sy = low(1)

return 
end

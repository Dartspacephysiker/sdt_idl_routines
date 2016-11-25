;+
; PROCECURE:	pmplot
;
; PURPOSE:	Used for making log y-axis plots.  Preformats data for
;		use with mplot.  Plots negative data in red and positive
;		data in green.
;
; KEYWORDS:
;    DATA:	The data structure.
;    LIMITS:	The limit structure.
;-
pro pmplot, $
	DATA=dat, $
	LIMITS=lim, $
	OPLOT=oplot, $
	OVERPLOT=overplot, $
	LABELS = labels, $
	LABPOS = labpos, $
	LABFLAG = labflag, $
	NOXLAB = noxlab, $
	NOCOLOR = nocolor, $
	BINS = bins

extract_tags, pmdata, dat, except=['y']
pmy = [[dat.y], [-dat.y]]
add_str_element, pmdata, 'y', pmy
add_str_element, lim, 'colors', [4, 6]
mplot,	data=pmdata, $
	limits=lim, $
	oplot=oplot, $
	overplot=overplot, $
	labels=labels, $
	labpos=labpos, $
	labflag=labflag, $
	noxlab=noxlab, $
	nocolor=nocolor, $
	bins=bins

end

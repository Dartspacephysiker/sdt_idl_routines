;+
;PROGRAM:	fu_spec2d(funct,dat)
;INPUT:	
;	funct:	string,		function that operates on structures generated 
;					by get_eesa_surv, get_eesa_burst, etc.
;				funct   = 'n_2d','j_2d','v_2d','p_2d','t_2d',
;					  'vth_2d','ec_2d', or 'je_2d'
;	dat:	structure,	2d data structures
;				example: dat = get_fa_ees(t)
;KEYWORDS
;	LIMITS - structure,	A structure containing limits and display options.
;				see: "options", "xlim" and "ylim", to change limits
;	ANGLE:	fltarr(2),	optional, min,max pitch angle range for integration
;	ARANGE:	fltarr(2),	optional, min,max angle bin numbers for integration
;	BINS:	bytarr(nb),	optional, angle bins array for integration
;					0,1=exclude,include,  
;					nb = dat.ntheta
;	INTEG_F:	0,1	if set, plot forward integral
;	INTEG_R:	0,1	if set, plot reverse integral
;
;PURPOSE:
;	Plots the differential funct(dat) versus energy, funct(dat) is integrated over angle only
;
;CREATED BY:
;	J.McFadden	97/03/13
;LAST MODIFICATION:  97/03/13
;MOD HISTORY:	
;
;NOTES:	  
;	Current version only works for FAST
;-
pro fu_spec2d,funct,dat, $
	PSYM = psym, $
	LIMITS = limits, $
	ANGLE=an, $
	ARANGE=ar, $
	BINS=bins, $
	INTEG_F = integ_f, $
	INTEG_R = integ_r
	
if n_params() lt 2 then begin
	print,'Wrong Format, Use: fu_spec2d,funct,dat,[ANGLE=angle,...]'
	return
endif

nenergy=dat.nenergy
y=fltarr(nenergy)
for a=0,nenergy-1 do begin
	y(a) = call_function(funct,dat,ERANGE=[a,a],ANGLE=an,ARANGE=ar,BINS=bins)
endfor
x=reform(dat.energy(*,0))
if x(1) gt x(2) then begin
	y=reverse(y)
	x=reverse(x)
endif

title = dat.project_name+'  '+dat.data_name+' '+funct
ytitle='Differential '+funct
xtitle='Energy (eV)'
plot={title:title, $
     xtitle:xtitle,x:x,xlog:1, $
     ytitle:ytitle,y:y,ylog:1  }
pmplot,data=plot,limits=limits
if keyword_set(psym) then oplot,x,y,psym=psym

if keyword_set(integ_f) or keyword_set(integ_r) then begin
	ar1=fltarr(nenergy,nenergy)
	ar2=fltarr(nenergy,nenergy)
	for a=0,nenergy-1 do begin
		ar1(a,a:nenergy-1)=1.
		ar2(a:nenergy-1,a)=1.
	endfor
	if keyword_set(integ_f) then begin
		y1=ar1#y
		plot1={title:title, $
		xtitle:xtitle,x:x,xlog:1, $
		ytitle:ytitle,y:y1,ylog:1  }
		pmplot,data=plot1,overplot=1
	endif
	if keyword_set(integ_r) then begin
		y2=ar2#y
		plot2={title:title, $
		xtitle:xtitle,x:x,xlog:1, $
		ytitle:ytitle,y:y2,ylog:1  }
		pmplot,data=plot2,overplot=1
	endif
endif 

return
end


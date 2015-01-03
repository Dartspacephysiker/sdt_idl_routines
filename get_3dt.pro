;+
;PROGRAM:	get_3dt(funct,get_dat,ERANGE=erange,BINS=bins,NAME=name)
;INPUT:	
;	funct:	function,	function that operates on structures generated 
;					by get_pl, get_el, etc.
;				e.g. "get_el"
;
;				funct   = 'n_3d','j_3d','v_3d','p_3d','t_3d',
;					  'vth_3d', or 'c_3d'
;				"n_3d"
;				"j_3d"
;				"v_3d"
;				"p_3d"
;				"t_3d"
;				"vth_3d"
;				"c_3d"
;	get_dat:function,	function that returns 3d data structures
;				function name must be "get_"+"get_dat"  
;				get_dat = 'pl' for get_pl, 
;				get_dat = 'el' for get_el, etc.
;KEYWORDS:
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;	name:	string		New name of the Data Quantity
;				Default: funct+'_'+get_dat
;PURPOSE:
;	To generate time series data for "tplot" 
;NOTES:	
;	Program names time series data to funct+"_"+get_dat.
;		See "tplot_names".
;
;CREATED BY:    J.McFadden
;LAST MODIFICATION:  96/02/06
;                    2015/01/03 Spencer Hatch
;FILE:   @(#)get_3dt.pro	1.9
;-
pro get_3dt,funct,get_dat,ERANGE=er,BINS=bins,NAME=name

if n_params() lt 2 then begin
	return
endif 

n=0
;max = 12000
max = 30000
t=0.D
raw = call_function("get_"+get_dat,t)

if not keyword_set(er) then er=[0,-1]
if (not keyword_set(bins) and raw.valid eq 1) then begin
	bins=bytarr(raw.nbins)
	bins(*)=1
endif

if (raw.valid eq 1) then begin
	sum = call_function(funct,raw,ERANGE=er,BINS=bins)
	nargs = n_elements(sum)
	time = dblarr(max)
	data = fltarr(max,nargs)
endif else begin
	print," No Data! "
	return
endelse

while (raw.valid eq 1) and (n lt max) do begin
	sum = call_function(funct,raw,ERANGE=er,BINS=bins)
	data(n,*) = sum
	time(n) = (raw.time + raw.end_time)/2.
	n = n+1
;	raw = call_function("get_"+get_dat,t)
	raw = call_function("get_"+get_dat,t,/ad)
endwhile

print," number of data points = ",n

data = data(0:n-1,*)
time = time(0:n-1)
ytitle = funct+"_"+get_dat
if keyword_set(name) eq 0 then name=ytitle else ytitle=name
d3dt_str = {x:time,y:data,ytitle:ytitle}
store_data,name,data=d3dt_str

return
end


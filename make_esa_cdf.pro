;+
;PROCEDURE:	make_esa_cdf
;PURPOSE:	
;	Make a cdf file with esa data
;INPUT:		
;	data_str, 	a string (either 'fa_ees_c','fa_ess','fa_ies','fa_ieb' ...)
;			where get_'string' returns a 2D data structure
;KEYWORDS:
;	T1:		start time, seconds since 1970
;	T2:		end time, seconds since 1970		
;	NENERGY		number of energy bins
;	NBINS		number of angle bins
;	UNITS:		convert to these units if included
;	NAME:  		New name of the Data Quantity
;
;
;CREATED BY:	J.McFadden	99/01/19
;VERSION:	1
;LAST MODIFICATION:  		00-8-15	
;MOD HISTORY:
;	00-8-15	Added modifications involving "last_delta_time" to account for fast/slow survey transitions
;
;	04-4-19 Changed to handle 96 energy mode for EESA, put the retrace back in.
;
;NOTES:	  
;	Current version only works for FAST eesa and iesa data
;-

pro make_esa_cdf,data_str,  $
	T1=t1, $
	T2=t2, $
	NENERGY=nenergy, $ 
	NBINS=nbins, $
	units = units, $
	gap_time = gap_time

; Get the environment variables which set the output name and directory
; of the CDF

outputdir=getenv('IDL_HIRES_OUTDIR')
outputname=getenv('IDL_HIRES_CDFNAME')
help, outputdir
help, outputname

;	Time how long the routine takes

ex_start = systime(1)

;	Set defaults for keywords, etc.

n = 0
max = 5000        ; this could be improved (increased from 2000 - KRB)

routine = 'get_'+data_str

if keyword_set(t1) then begin
	t=t1
	dat = call_function(routine,t,/calib)
endif else begin
	t = 1000             ; get first sample
	dat = call_function(routine,t,/calib,/start)
endelse

if dat.valid eq 0 then begin no_data = 1 & return & end $
else no_data = 0

last_time = (dat.time+dat.end_time)/2.
last_delta_time=dat.end_time-dat.time
nenergy=dat.nenergy
;if dat.data_name eq 'Eesa Survey' then nenergy=47
if dat.data_name eq 'Eesa Survey' then nenergy=96
if dat.data_name eq 'Iesa Survey' then nenergy=48
;if dat.data_name eq 'Eesa Burst' then nenergy=47
if dat.data_name eq 'Eesa Burst' then nenergy=96
if dat.data_name eq 'Iesa Burst' then nenergy=48
if nenergy eq 47 then retrace=1 else retrace=0
nbins=dat.nbins
if dat.data_name eq 'Eesa Survey' then nbins=64
if dat.data_name eq 'Iesa Survey' then nbins=64
if not keyword_set(gap_time) then gap_time = 4.  ; for burst data gap_time should be 0.1
data=fltarr(nenergy,nbins)
energy=fltarr(nenergy)
angle=fltarr(nenergy,nbins)

darr=[1.d,1.d,1.d]
cdfdat0={time:dat.time,delta_time:dat.integ_t,data:data,$
	energy:energy,angle:angle,n_energy:nenergy,n_angle:nbins,$
	fa_pos:darr,fa_vel:darr,alt:1.d,ilat:1.d,mlt:1.d,orbit:3l,$
	b_model:darr,b_foot:darr,foot_lat:1.d,foot_lng:1.d}
cdfdat=replicate(cdfdat0,max)

if not keyword_set(units) then units = 'Eflux'

;	Collect the data - Main Loop
    
if keyword_set(t2) then tmax=t2 else tmax=1.e30

while (dat.valid ne 0) and (n lt max) do begin
if (dat.valid eq 1) then begin

; Test to see if a transition between fast and slow survey occurs, 
; ie delta_time changes, and skip some data if it does.
	if (abs((dat.end_time-dat.time) - last_delta_time) gt 1. ) then begin
		if routine eq 'fa_ees_c' then nskip=2 else nskip=3
		; if fast to slow, skip two or three arrays
		if (dat.end_time-dat.time) gt last_delta_time then begin
			for i=1,nskip do begin
				dat = call_function(routine,t,/calib,/ad)
			endfor
		endif else begin
			while dat.time lt last_time+7.5 do begin
				dat = call_function(routine,t,/calib,/ad)
			endwhile
		endelse
	endif
	
; Test for data gaps and add NAN if gaps are present.
	if abs((dat.time+dat.end_time)/2.-last_time) ge gap_time then begin
		if n ge 2 then dbadtime = cdfdat(n-1).time - cdfdat(n-2).time else dbadtime = gap_time/2.
		cdfdat(n).time = (last_time) + dbadtime
		cdfdat(n).delta_time = !values.f_nan
		cdfdat(n).data(*,*) = !values.f_nan
;		cdfdat(n).energy(*,*) = !values.f_nan
		cdfdat(n).energy(*) = !values.f_nan
		cdfdat(n).angle(*,*) = !values.f_nan
		cdfdat(n).n_energy = !values.f_nan
		cdfdat(n).n_angle = !values.f_nan
		n=n+1
		if ((dat.time+dat.end_time)/2. gt cdfdat(n-1).time + gap_time) and (n lt max) then begin
			cdfdat(n).time = (dat.time+dat.end_time)/2. - dbadtime
			cdfdat(n).delta_time = !values.f_nan
			cdfdat(n).data(*,*) = !values.f_nan
;			cdfdat(n).energy(*,*) = !values.f_nan
			cdfdat(n).energy(*) = !values.f_nan
			cdfdat(n).angle(*,*) = !values.f_nan
			cdfdat(n).n_energy = !values.f_nan
			cdfdat(n).n_angle = !values.f_nan
			n=n+1
		endif
	endif

	dat = conv_units(dat,units)
	data(*,*)=0.
;	data(0:nenergy-1,0:dat.nbins-1)=dat.data(retrace:nenergy-1+retrace,0:dat.nbins-1)
	data(0:dat.nenergy-1,0:dat.nbins-1)=dat.data
	energy(*,*)=0.
;	energy(0:nenergy-1,0:dat.nbins-1)=dat.energy(retrace:nenergy-1+retrace,0:dat.nbins-1)
	energy(0:dat.nenergy-1)=reform(dat.energy(*,0))
	angle(*,*)=0.
;	angle(0:nenergy-1,0:dat.nbins-1)=dat.theta(retrace:nenergy-1+retrace,0:dat.nbins-1)
	angle(0:dat.nenergy-1,0:dat.nbins-1)=dat.theta

	if n lt max then begin
		
	  cdfdat(n).time = (dat.time+dat.end_time)/2.
	  cdfdat(n).delta_time = dat.end_time-dat.time
	  cdfdat(n).data(*,*) = data
;	  cdfdat(n).energy(*,*) = energy
	  cdfdat(n).energy(*) = energy
	  cdfdat(n).angle(*,*) = angle
	  cdfdat(n).n_energy = dat.nenergy
	  cdfdat(n).n_angle = dat.nbins

	  last_time = cdfdat(n).time
	  last_delta_time = cdfdat(n).delta_time 
	  n=n+1
	endif

endif else begin
	print,'Invalid packet, dat.valid ne 1, at: ',time_to_str(dat.time)
endelse

	dat = call_function(routine,t,/calib,/ad)
	if dat.valid ne 0 then if dat.time gt tmax then dat.valid=0

endwhile

if n ge max then print, 'warning: reached maximum allocation -- data set returned may not be complete'

cdfdat=cdfdat(0:n-1)
time = cdfdat.time

; Get the orbit data

	orbit_file=fa_almanac_dir()+'/orbit/predicted'
	get_fa_orbit,time,/time_array,orbit_file=orbit_file,/all,status=status
	if status ne 0 then begin
	    print, 'get_fa_orbit failed--returned nonzero status = ', status
	    return
	endif

	get_data,'fa_pos',data=fapos
	get_data,'fa_vel',data=favel
	get_data,'B_model',data=bmodel
	get_data,'BFOOT',data=bfoot
	for i=0,2 do begin
		cdfdat(*).fa_pos(i)=fapos.y(*,i)
		cdfdat(*).fa_vel(i)=favel.y(*,i)
		cdfdat(*).b_model(i)=bmodel.y(*,i)
		cdfdat(*).b_foot(i)=bfoot.y(*,i)
	endfor

	get_data,'ALT',data=tmp
	cdfdat(*).alt=tmp.y(*)
	get_data,'ILAT',data=tmp
	cdfdat(*).ilat=tmp.y(*)
	get_data,'MLT',data=tmp
	cdfdat(*).mlt=tmp.y(*)
	get_data,'ORBIT',data=tmp
	cdfdat(*).orbit=tmp.y(*)
	orbit_num=strcompress(string(tmp.y(0)),/remove_all)
	get_data,'FLAT',data=tmp
	cdfdat(*).foot_lat=tmp.y(*)
	get_data,'FLNG',data=tmp
	cdfdat(*).foot_lng=tmp.y(*)

; Get the attitude data
;	to include attitude data, you must also change the line starting "cdfdat0={ ..."
;	to include attitude data, you must also change the line starting "tagsvary=[ ..."

;	print, 'Loading the attitude data...'
;	get_fa_attitude, time, /time_array, status=status
;	if status ne 0 then begin
;	    print, 'get_fa_attitude failed--returned nonzero status = ', status
;	    return
;	endif
;	get_data, 'fa_spin_ra',  data=tmp
;	cdfdat(*).fa_spin_ra=tmp.y(*)
;	get_data, 'fa_spin_dec', data=tmp
;	cdfdat(*).fa_spin_dec=tmp.y(*)

; Make the cdf file

	;makecdf,cdfdat,filename=data_str+'_2d_orbit_'+orbit_num,overwrite=1, $
	makecdf,cdfdat,filename=outputdir+outputname,overwrite=1, $
	tagsvary=['TIME','Delta_time',units,'energy','angle','n_energy','n_angle', $
	'fa_pos','fa_vel','ALT','ILAT','MLT','ORBIT','B_model','B_foot','Foot_LAT','Foot_LNG']


print,'   '
ex_time = systime(1) - ex_start
message,string(ex_time)+' seconds execution time.',/cont,/info
print,'Number of data points = ',n


return

end

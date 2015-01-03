;+
;PROCEDURE:	load_fa_k0_orb
;PURPOSE:	
;	Load summary data from the FAST orbit into tplot structure.
;
;		Loads orbit				number--normally increments by one for each successive orbit
;		Loads fa_spin_ra	Right Ascension of Spin Axis
;		Loads fa_spin_dec	Declination of Spin Axis
;		Loads r						Spacecraft Position
;		Loads v						Spacecraft Velocity
;		Loads alt					Spacecraft Altitude
;		Loads flat				Footprint Latitude
;		Loads flng				Footprint Longitude
;		Loads mlt					Magnetic Local Time
;		Loads ilat				Invariant Latitude
;	
;INPUT:	
;	none 
;KEYWORDS:
;	filenames	strarr(m), string array of filenames of cdf files to be entered
;				Files are obtained from "dir" if dir is set, 
;					otherwise files obtained from local dir.
;				If filenames not set, then orbit or trange keyword must
;					be set.
;	dir		string, directory where filenames can be found
;				If dir not set, default is "environvar" or local directory
;	environvar	string, name of environment variable to set "dir"
;				Used if filenames not set
;				Default environvar = '$FAST_CDF_HOME'
;	trange		trange[2], time range used to get files from index list
;	indexfile	string, complete path name for indexfile of times and filenames
;				Used if trange is set.
;				Default = indexfiledir+'/fa_k0_orb_files'
;				indexfiledir = '$CDF_INDEX_DIR' 
;	orbit		int, intarr, orbit(s) for file load
;	var		strarr(n) of cdf variable names
;			default=['orbit','fa_spin_ra','fa_spin_dec','r','v','alt','flat','flng','mlt','ilat']
;	dvar		strarr(n) of cdf dependent variable names
;			set dvar(n)='' if no dependent variable for variable
;			dvar must be same dimension as var
;			default=['','','','cartesian','cartesian','','','','','']
;	nodata		returns 1 if no data is found
;
;CREATED BY:	Tim Quinn 2009-09-01
;LAST MODIFICATION:  
;MOD HISTORY:
;-

pro load_fa_k0_orb, $
	filenames=filenames, $
	dir = dir, $
	environvar = environvar, $
	trange = trange, $
	indexfile = indexfile, $
	orbit = orbit, $
	var=var, $
	dvar=dvar, $
	nodata=nodata, $
        no_orbit = no_orbit                    

if not keyword_set(filenames) then begin
	if not keyword_set(environvar) then environvar = 'FAST_CDF_HOME'
	if not keyword_set(dir) then dir = getenv(environvar)
	if not keyword_set(dir) then begin
		print, ' Using local directory'
		dir=''
	endif else dir=dir+'/orb/'
	if not keyword_set(orbit) and not keyword_set(trange) then begin
		print,'Must enter filenames, trange, or orbit keyword!!'
		nodata=1
		return
	endif
	if keyword_set(orbit) then begin
		if dimen1(orbit) eq 1 then begin
			sorb = STRMID( STRCOMPRESS( orbit + 1000000, /RE), 2, 5)
			tmpnames = findfile(dir+'fa_k0_orb_'+sorb+'*.cdf',count=count)
			if count le 1 then filenames=tmpnames else begin
				print, ' Old versions of cdf files present, using latest version'
				filenames=tmpnames(count-1)
			endelse
		endif else begin
			filenames=strarr(dimen1(orbit))
			for a=0,dimen1(orbit)-1 do begin
				sorb = STRMID( STRCOMPRESS( orbit(a) + 1000000, /RE), 2, 5)
				tmpnames = findfile(dir+'fa_k0_orb_'+sorb+'*.cdf',count=count)
				if count le 1 then filenames(a)=tmpnames else begin
					print, ' Old versions of cdf files present, using latest version'
					filenames(a)=tmpnames(count-1)
				endelse
			endfor
		endelse
	endif else begin
		if keyword_set(trange) then begin
			if not keyword_set(indexfile) then begin
				indexfiledir = getenv('CDF_INDEX_DIR')	
				mfile = indexfiledir+'/fa_k0_orb_files'
			endif else mfile = indexfile
			get_file_names,filenames,TIME_RANGE=trange,MASTERFILE=mfile
		endif 
	endelse
endif else begin
	if keyword_set(dir) then filenames=dir+filenames
endelse

filenames=files_exist(filenames)
if filenames(0) eq '' then begin
	print,' Files do not exist!'
	nodata=1
	return
endif
	
if not keyword_set(var) then begin
	var=['orbit','fa_spin_ra','fa_spin_dec','r','v','alt','flat','flng','mlt','ilat']
	dvar=['','','','cartesian','cartesian','','','','','']
endif 
nvar=dimen1(var)
if not keyword_set(dvar) then dvar=strarr(nvar)
if dimen1(dvar) ne nvar then begin 
	print,' dvar and var must be same dimension'
	nodata=1
	return
endif

nfiles = dimen1(filenames)
	for d=0,nfiles-1 do begin
		print,'Loading file: ',filenames(d),'...'
		if cdf_var_exists(filenames(d),'TIME') then begin
			loadcdf,filenames(d),'TIME',tmp
		endif else if cdf_var_exists(filenames(d),'unix_time') then begin
			loadcdf,filenames(d),'unix_time',tmp
		endif else begin
			print,'ERROR: cdf structure element for time is missing!'
			nodata=1
			return
		endelse
		if d eq 0 then begin
			time=tmp 
		endif else begin
			ntime=dimen1(time)
			gaptime1=2.*time(ntime-1) - time(ntime-2)
			gaptime2=2*tmp(0) - tmp(1)
			time=[time,gaptime1,gaptime2,tmp]
		endelse
	endfor

for n=0,nvar-1 do begin

	for d=0,nfiles-1 do begin
		loadcdf,filenames(d),var(n),tmp
		if dvar(n) ne '' then loadcdf,filenames(d),dvar(n),tmpv
		if d eq 0 then begin
			tmp_tot  = tmp
			if dvar(n) ne '' then tmpv_tot = tmpv
		endif else begin
			gapdata=tmp_tot(0:1,*)
			gapdata(*,*)=!values.f_nan
			tmp_tot  = [tmp_tot,gapdata,tmp]
			if dvar(n) ne '' then tmpv_tot = [tmpv_tot,gapdata,tmpv]
		endelse
	endfor

	if dvar(n) ne '' then begin
		store_data,var(n),data={ytitle:var(n),x:time,y:tmp_tot,v:tmpv_tot}
		;;options,var(n),'spec',1	
		;;options,var(n),'panel_size',2
		;;zlim,var(n),1e6,1e9,1
		;;options,var(n),'ztitle','eV/cm!U2!N-s-sr-eV'
		;;if var(n) eq 'el_low' or var(n) eq 'el_high' then begin
			;;ylim,var(n),-100,280,0
			;;if var(n) eq 'el_low' then begin
				;;options,var(n),'ytitle','e- .1-1 keV!C!C Pitch Angle'
			;;endif else begin
				;;options,var(n),'ytitle','e- >1 keV!C!C Pitch Angle'
			;;endelse
		;;endif else begin
			;;ylim,var(n),3,40000,1
			;;if var(n) eq 'el_0' then begin
				;;options,var(n),'ytitle','e- 0!Uo!N-30!Uo!N!C!CEnergy (eV)'
			;;endif else begin
			;;if var(n) eq 'el_90' then begin
				;;options,var(n),'ytitle','e- 60!Uo!N-120!Uo!N!C!CEnergy (eV)'
			;;endif else begin
				;;options,var(n),'ytitle','e- 150!Uo!N-180!Uo!N!C!CEnergy (eV)'
			;;endelse
			;;endelse
		;;endelse
		;;options,var(n),'x_no_interp',1
		;;options,var(n),'y_no_interp',1
	endif else begin
		store_data,var(n),data={ytitle:var(n),x:time,y:tmp_tot}
		case var(n) of
			'fa_spin_ra': begin
					ylim,'fa_spin_ra',0,360,0
					options,'fa_spin_ra','ytitle','Spin RA'
					;options,'fa_spin_ra','tplot_routine','pmplot'
			end
			'fa_spin_dec': begin
					ylim,'fa_spin_dec',-90,90,0
					options,'fa_spin_dec','ytitle','Spin Dec'
					;options,'fa_spin_dec','tplot_routine','pmplot'
			end
			'alt': begin
					ylim,'alt',0,5000,0
					options,'alt','ytitle','ALT'
					;options,'alt','tplot_routine','pmplot'
			end
			'orbit': begin
					ylim,'alt',0,100000,0
					options,'alt','ytitle','SC Orbit'
					;options,'alt','tplot_routine','pmplot'
			end
			'flat': begin
					ylim,'flat',-90,90,0
					options,'flat','ytitle','FLAT'
					;options,'flat','tplot_routine','pmplot'
			end
			'flng': begin
					ylim,'flng',-180,180,0
					options,'flng','ytitle','FLNG'
					;options,'flng','tplot_routine','pmplot'
			end
			'mlt': begin
					ylim,'mlt',0,24,0
					options,'mlt','ytitle','MLT'
					;options,'mlt','tplot_routine','pmplot'
			end
			'ilat': begin
					ylim,'ilat',-90,90,0
					options,'ilat','ytitle','ILAT'
					;options,'ilat','tplot_routine','pmplot'
			end
			else : print, 'Unrecognized orbit variable'
		endcase
	endelse
endfor

; Zero the time range

	tplot_options,trange=[0,0]

nodata=0
return
end


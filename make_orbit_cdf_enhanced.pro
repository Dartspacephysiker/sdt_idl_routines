;+
; PROCEDURE: make_orbit_cdf_enhanced.pro
;
; PURPOSE: generate FAST summary data file for a given orbit with meta
;          data included (same meta included in daily cdf)
;
; INPUTS:     
;     dataset:
;         char string with value = 'ees', 'ies', 'dcf', 'acf', or 'tms'.  Case is ignored.
;         specifies whether EES, IES, DCF, ACF, or TMS data is created.
;     orbit:
; KEYWORDS:
;     versionnumber:
;         The ISTP version number to be written to the CDF file.  Although this version
;         number appears in the filename of the daily file in exactly the same way that
;         our local version number appears in the filename of our orbit CDF files, this
;         version number is NOT the same as our local version number--it is the ISTP
;         standard version number.  The first daily file sent to ISTP for each date must
;         have version number 1, regardless of how many versions have previously been
;         created for other dates.  Any daily file sent to ISTP, which is not the first
;         daily file sent to ISTP for that particular date, must have a version number
;         which is 1 greater than the last daily file sent to ISTP for that particular date.
;         This keyword parameter must be set--there is no default.
;     sktfile:
;         Pathname of the skt file to be used to initialize the output CDF.
;         Defaults sktfile is
;             skt = getenv('FASTLIB') + '/cdf_templates/fa_k0_' + dataset + '_day_template'.
;         (ie, for dataset='ees', index = getenv('FASTLIB') + /fa_k0_ees_day_template)
;     length:
;         Length in seconds of the file to be built, defaults to 86400.0 seconds, 1 day
;     status:
;         set to zero on return for success, nonzero otherwise
;     verbose:
;         Not for use by users.  For debugging/programming use only.  Functionality
;         changes unexpectedly.
;
; VERSION: @(#)make_day_cdf.pro	1.8 11/06/02
;-

pro make_orbit_cdf_enhanced, dataset, orbit, $
    versionnumber=versionnumber, $
    sktfile=sktfile, $
    length=length, $
    status=status, $
    verbose=verbose

if keyword_set(verbose) then verbose = fix(verbose) else verbose = fix(0)

dataset = strlowcase(dataset)
if dataset ne 'ees' and dataset ne 'ies' and dataset ne 'dcf' and $
  dataset ne 'acf' and dataset ne 'tms' and dataset ne 'orb' then begin
    print, "make_day_cdf: first argument (", dataset,  ") must be either 'ees', 'ies', 'dcf', 'acf', 'tms', or 'orb'."
    status = -1
    return
endif

fileNameOrbit = string(orbit,format='(i5.5)') 

if not keyword_set(versionnumber) then begin
    print, 'make_day_cdf: the keyword parameter versionnumber must be set.'
    status = -1
    return
endif
versionstring = 'v' + string(versionnumber, format='(i2.2)')

;; create the name of the output CDF file
;
cdffile = 'fa_k0_' + dataset + '_' + fileNameOrbit + '_' + versionstring
print, 'Generating the ' + strupcase(dataset) + ' summary data CDF: ', cdffile

;; Check if this is to be an orbit data cdf, and if so, skip loading
;; instrument data
;
if  dataset ne 'orb' then begin
	; get the main portion of the data
	print, 'Loading the orbit data file...'
	call_procedure, 'load_fa_k0_' + dataset, orbit=orbit
	case dataset of
  	'ees': begin
             	get_data, 'el_0',     data=el_0
             	get_data, 'el_90',    data=el_90
             	get_data, 'el_180',   data=el_180
             	get_data, 'el_low',   data=el_low
             	get_data, 'el_high',  data=el_high
             	get_data, 'JEe',      data=JEe
             	get_data, 'Je',       data=Je
             	default_time_array  = el_0.x
	 	end
  	'ies': begin
	     				get_data, 'ion_0',    data=ion_0
	     				get_data, 'ion_90',   data=ion_90
	     				get_data, 'ion_180',  data=ion_180
	     				get_data, 'ion_low',  data=ion_low
	     				get_data, 'ion_high', data=ion_high
	     				get_data, 'JEi',      data=JEi
	     				get_data, 'Ji',       data=Ji
	     				default_time_array  = ion_0.x
	 	end
  	'dcf': begin
	     				get_data, 'EX', data=EX
	     				get_data, 'EZ', data=EZ
	     				get_data, 'BX', data=BX
	     				get_data, 'BY', data=BY
	     				get_data, 'BZ', data=BZ
	     				get_data, 'S/C POTENTIAL', data=SC_POT
	     				get_data, 'SPIN ANGLE', data=SPIN_ANGLE
             	default_time_array  = EX.x
	 	end
  	'acf': begin
             	get_data, 'HF_E_SPEC',  data=HF_E_SPEC
             	get_data, 'VLF_E_SPEC', data=VLF_E_SPEC
             	get_data, 'ELF_E_SPEC', data=ELF_E_SPEC
             	get_data, 'HF_B_SPEC',  data=HF_B_SPEC
             	get_data, 'VLF_B_SPEC', data=VLF_B_SPEC
             	get_data, 'ELF_B_SPEC', data=ELF_B_SPEC
             	get_data, 'HF_PWR',     data=HF_PWR
             	get_data, 'VLF_PWR',    data=VLF_PWR
             	get_data, 'ELF_PWR',    data=ELF_PWR
             	default_time_array  = HF_E_SPEC.x
	 	end
  	'tms': begin
             	get_data, 'H+',          data=Hp
             	get_data, 'H+_low',      data=Hp_low
             	get_data, 'H+_high',     data=Hp_high
             	get_data, 'O+',          data=Op
             	get_data, 'O+_low',      data=Op_low
             	get_data, 'O+_high',     data=Op_high
             	get_data, 'He+',         data=Hep
             	get_data, 'He+_low',     data=Hep_low
             	get_data, 'He+_high',    data=Hep_high
             	default_time_array  = Hp.x
	 	end
	endcase

	time_array = default_time_array
	index_first = 0
	index_last  = n_elements(default_time_array) - 1

	if verbose then begin
    	print, 'size of time_array = ', n_elements(time_array)
    	print,' first time = ', time_array(0),format='(a,f20.6)'
    	print, 'first 10 time diffs from time_array follow:'
    	for i = 1,10 do begin
        	print, time_array(i) - time_array(i-1), format='(f15.6)'
    	endfor
	endif

	; get the orbit data
	print, 'Loading the orbit data...'
	get_fa_orbit, time_array, /time_array, /all, status=status
	if status ne 0 then begin
    	print, 'get_fa_orbit failed--returned nonzero status = ', status
    	return
	endif
	get_data, 'ORBIT',    data=orbit
	get_data, 'fa_pos',   data=fa_pos
	get_data, 'fa_vel',   data=fa_vel
	get_data, 'ALT',      data=alt
	get_data, 'FLAT',     data=flat
	get_data, 'FLNG',     data=flng
	get_data, 'MLT',      data=mlt
	get_data, 'ILAT',     data=ilat

	if verbose then begin
    	print, 'size of fa_pos.x = ', n_elements(fa_pos.x)
    	print,' first time = ', fa_pos.x(0),format='(a,f20.6)'
    	print, 'first 10 time diffs from fa_pos.x follow:'
    	for i = 1,10 do begin
        	print, fa_pos.x(i) - fa_pos.x(i-1), format='(f15.6)'
    	endfor
	endif

	; get the attitude data
	print, 'Loading the attitude data...'
	get_fa_attitude, time_array, /time_array, status=status
	if status ne 0 then begin
    	print, 'get_fa_attitude failed--returned nonzero status = ', status
    	return
	endif
	get_data, 'fa_spin_ra',  data=fa_spin_ra
	get_data, 'fa_spin_dec', data=fa_spin_dec
	
	if verbose then begin
    	print, 'size of fa_spin_ra.x = ', n_elements(fa_spin_ra.x)
    	print,' first time = ', fa_spin_ra.x(0),format='(a,f20.6)'
    	print, 'first 10 time diffs from fa_spin_ra.x follow:'
    	for i = 1,10 do begin
        	print, fa_spin_ra.x(i) - fa_spin_ra.x(i-1), format='(f15.6)'
    	endfor
	endif

	;;Obsolete code;;
	; generate the indices of all these variables that correspond to times that
	; are strictly within the interval from tstart to tend, so that we can include
	; only those times that are between 00:00:00 and 24:00:00 on the given day.
	;togood = where(time_array ge tstart and time_array lt tend, count)
	;if count le 0 then begin
    	;print, 'No ', strupcase(dataset), ' data found for date ', datestring2
    	;status = -1
    	;return
	;endif

	count  = n_elements(time_array) 

endif else begin

	;; Running just for orbit data - get 
	;; orbit start and stop times
	;
	spawn,'orbittime ' + orbit, times, /sh
	times = substr(times,'/','-',2)
	if strmid(times(0),0,4) ne '0000' then begin
		tstart = str_to_time(times(0))
		tstop = str_to_time(times(1))
		status = 1
		return,status
	endif

	;; get the orbit data
	print, 'Loading the orbit data...'
	get_fa_orbit, tstart, tstop, /all, status=status
	if status ne 0 then begin
    	print, 'get_fa_orbit failed--returned nonzero status = ', status
    	return
	endif
	get_data, 'ORBIT',    data=orbit
	get_data, 'fa_pos',   data=fa_pos
	get_data, 'fa_vel',   data=fa_vel
	get_data, 'ALT',      data=alt
	get_data, 'FLAT',     data=flat
	get_data, 'FLNG',     data=flng
	get_data, 'MLT',      data=mlt
	get_data, 'ILAT',     data=ilat
 	default_time_array  = orbit.x

	time_array = default_time_array
	index_first = 0
	index_last  = n_elements(default_time_array) - 1

	count  = n_elements(time_array) 

	; get the attitude data
	print, 'Loading the attitude data...'
	get_fa_attitude, time_array, /time_array, status=status
	if status ne 0 then begin
    	print, 'get_fa_attitude failed--returned nonzero status = ', status
    	return
	endif
	get_data, 'fa_spin_ra',  data=fa_spin_ra
	get_data, 'fa_spin_dec', data=fa_spin_dec

endelse

; build the data structure that is to be written to the CDF
print, 'Building the data structure that is to be written to the CDF...'
case dataset of
'ees': begin
data = $
{dummy00: {name:'unix_time',     value:time_array(*,*,*),           recvary:1, fill:0}, $
 dummy01: {name:'el_0',          value:el_0.y(*,*,*),               recvary:1, fill:1}, $
 dummy02: {name:'el_90',         value:el_90.y(*,*,*),              recvary:1, fill:1}, $
 dummy03: {name:'el_180',        value:el_180.y(*,*,*),             recvary:1, fill:1}, $
 dummy04: {name:'el_en',         value:el_0.v(*,*,*),               recvary:1, fill:1}, $
 dummy05: {name:'el_low',        value:el_low.y(*,*,*),             recvary:1, fill:1}, $
 dummy06: {name:'el_low_pa',     value:el_low.v(*,*,*),             recvary:1, fill:1}, $
 dummy07: {name:'el_high',       value:el_high.y(*,*,*),            recvary:1, fill:1}, $
 dummy08: {name:'el_high_pa',    value:el_high.v(*,*,*),            recvary:1, fill:1}, $
 dummy09: {name:'JEe',           value:JEe.y(*,*,*),                recvary:1, fill:1}, $
 dummy10: {name:'Je',            value:Je.y(*,*,*),                 recvary:1, fill:1}, $
 dummy50: {name:'orbit',         value:orbit.y(*,*,*),              recvary:1, fill:1}, $
 dummy51: {name:'fa_spin_ra',    value:float(fa_spin_ra.y(*,*,*)),  recvary:1, fill:1}, $
 dummy52: {name:'fa_spin_dec',   value:float(fa_spin_dec.y(*,*,*)), recvary:1, fill:1}, $
 dummy53: {name:'r',             value:float(fa_pos.y(*,*,*)),      recvary:1, fill:1}, $
 dummy54: {name:'v',             value:float(fa_vel.y(*,*,*)),      recvary:1, fill:1}, $
 dummy55: {name:'alt',           value:float(alt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy56: {name:'flat',          value:float(flat.y(*,*,*)),        recvary:1, fill:1}, $
 dummy57: {name:'flng',          value:float(flng.y(*,*,*)),        recvary:1, fill:1}, $
 dummy58: {name:'mlt',           value:float(mlt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy59: {name:'ilat',          value:float(ilat.y(*,*,*)),        recvary:1, fill:1} $
}
       end
'ies': begin
data = $
{dummy00: {name:'unix_time',     value:time_array(*,*,*),           recvary:1, fill:0}, $
 dummy01: {name:'ion_0',         value:ion_0.y(*,*,*),              recvary:1, fill:1}, $
 dummy02: {name:'ion_90',        value:ion_90.y(*,*,*),             recvary:1, fill:1}, $
 dummy03: {name:'ion_180',       value:ion_180.y(*,*,*),            recvary:1, fill:1}, $
 dummy04: {name:'ion_en',        value:ion_0.v(*,*,*),              recvary:1, fill:1}, $
 dummy05: {name:'ion_low',       value:ion_low.y(*,*,*),            recvary:1, fill:1}, $
 dummy06: {name:'ion_low_pa',    value:ion_low.v(*,*,*),            recvary:1, fill:1}, $
 dummy07: {name:'ion_high',      value:ion_high.y(*,*,*),           recvary:1, fill:1}, $
 dummy08: {name:'ion_high_pa',   value:ion_high.v(*,*,*),           recvary:1, fill:1}, $
 dummy09: {name:'JEi',           value:JEi.y(*,*,*),                recvary:1, fill:1}, $
 dummy10: {name:'Ji',            value:Ji.y(*,*,*),                 recvary:1, fill:1}, $
 dummy50: {name:'orbit',         value:orbit.y(*,*,*),              recvary:1, fill:1}, $
 dummy51: {name:'fa_spin_ra',    value:float(fa_spin_ra.y(*,*,*)),  recvary:1, fill:1}, $
 dummy52: {name:'fa_spin_dec',   value:float(fa_spin_dec.y(*,*,*)), recvary:1, fill:1}, $
 dummy53: {name:'r',             value:float(fa_pos.y(*,*,*)),      recvary:1, fill:1}, $
 dummy54: {name:'v',             value:float(fa_vel.y(*,*,*)),      recvary:1, fill:1}, $
 dummy55: {name:'alt',           value:float(alt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy56: {name:'flat',          value:float(flat.y(*,*,*)),        recvary:1, fill:1}, $
 dummy57: {name:'flng',          value:float(flng.y(*,*,*)),        recvary:1, fill:1}, $
 dummy58: {name:'mlt',           value:float(mlt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy59: {name:'ilat',          value:float(ilat.y(*,*,*)),        recvary:1, fill:1} $
}
       end
'dcf': begin
data = $
{dummy00: {name:'unix_time',     value:time_array(*,*,*),           recvary:1, fill:0}, $
 dummy01: {name:'EX',            value:EX.y(*,*,*),                 recvary:1, fill:1}, $
 dummy02: {name:'EZ',            value:EZ.y(*,*,*),                 recvary:1, fill:1}, $
 dummy04: {name:'BX',            value:BX.y(*,*,*),                 recvary:1, fill:1}, $
 dummy05: {name:'BY',            value:BY.y(*,*,*),                 recvary:1, fill:1}, $
 dummy06: {name:'BZ',            value:BZ.y(*,*,*),                 recvary:1, fill:1}, $
 dummy07: {name:'S/C POTENTIAL', value:SC_POT.y(*,*,*),             recvary:1, fill:1}, $
 dummy08: {name:'SPIN ANGLE',    value:SPIN_ANGLE.y(*,*,*),         recvary:1, fill:1}, $
 dummy50: {name:'orbit',         value:orbit.y(*,*,*),              recvary:1, fill:1}, $
 dummy51: {name:'fa_spin_ra',    value:float(fa_spin_ra.y(*,*,*)),  recvary:1, fill:1}, $
 dummy52: {name:'fa_spin_dec',   value:float(fa_spin_dec.y(*,*,*)), recvary:1, fill:1}, $
 dummy53: {name:'r',             value:float(fa_pos.y(*,*,*)),      recvary:1, fill:1}, $
 dummy54: {name:'v',             value:float(fa_vel.y(*,*,*)),      recvary:1, fill:1}, $
 dummy55: {name:'alt',           value:float(alt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy56: {name:'flat',          value:float(flat.y(*,*,*)),        recvary:1, fill:1}, $
 dummy57: {name:'flng',          value:float(flng.y(*,*,*)),        recvary:1, fill:1}, $
 dummy58: {name:'mlt',           value:float(mlt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy59: {name:'ilat',          value:float(ilat.y(*,*,*)),        recvary:1, fill:1} $
}
       end
'acf': begin
data = $
{dummy00: {name:'unix_time',     value:time_array(*,*,*),           recvary:1, fill:0}, $
 dummy01: {name:'HF_E_SPEC',     value:HF_E_SPEC.y(*,*,*),          recvary:1, fill:1}, $
 dummy02: {name:'HF_E_FREQ',     value:HF_E_SPEC.v,                     recvary:0, fill:1}, $
 dummy03: {name:'VLF_E_SPEC',    value:VLF_E_SPEC.y(*,*,*),         recvary:1, fill:1}, $
 dummy04: {name:'VLF_E_FREQ',    value:VLF_E_SPEC.v,                    recvary:0, fill:1}, $
 dummy05: {name:'ELF_E_SPEC',    value:ELF_E_SPEC.y(*,*,*),         recvary:1, fill:1}, $
 dummy06: {name:'ELF_E_FREQ',    value:ELF_E_SPEC.v,                    recvary:0, fill:1}, $
 dummy07: {name:'HF_B_SPEC',     value:HF_B_SPEC.y(*,*,*),          recvary:1, fill:1}, $
 dummy08: {name:'HF_B_FREQ',     value:HF_B_SPEC.v,                     recvary:0, fill:1}, $
 dummy09: {name:'VLF_B_SPEC',    value:VLF_B_SPEC.y(*,*,*),         recvary:1, fill:1}, $
 dummy10: {name:'VLF_B_FREQ',    value:VLF_B_SPEC.v,                    recvary:0, fill:1}, $
 dummy11: {name:'ELF_B_SPEC',    value:ELF_B_SPEC.y(*,*,*),         recvary:1, fill:1}, $
 dummy12: {name:'ELF_B_FREQ',    value:ELF_B_SPEC.v,                    recvary:0, fill:1}, $
 dummy13: {name:'HF_PWR',        value:HF_PWR.y(*,*,*),             recvary:1, fill:1}, $
 dummy14: {name:'VLF_PWR',       value:VLF_PWR.y(*,*,*),            recvary:1, fill:1}, $
 dummy15: {name:'ELF_PWR',       value:ELF_PWR.y(*,*,*),            recvary:1, fill:1}, $
 dummy50: {name:'orbit',         value:orbit.y(*,*,*),              recvary:1, fill:1}, $
 dummy51: {name:'fa_spin_ra',    value:float(fa_spin_ra.y(*,*,*)),  recvary:1, fill:1}, $
 dummy52: {name:'fa_spin_dec',   value:float(fa_spin_dec.y(*,*,*)), recvary:1, fill:1}, $
 dummy53: {name:'r',             value:float(fa_pos.y(*,*,*)),      recvary:1, fill:1}, $
 dummy54: {name:'v',             value:float(fa_vel.y(*,*,*)),      recvary:1, fill:1}, $
 dummy55: {name:'alt',           value:float(alt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy56: {name:'flat',          value:float(flat.y(*,*,*)),        recvary:1, fill:1}, $
 dummy57: {name:'flng',          value:float(flng.y(*,*,*)),        recvary:1, fill:1}, $
 dummy58: {name:'mlt',           value:float(mlt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy59: {name:'ilat',          value:float(ilat.y(*,*,*)),        recvary:1, fill:1} $
}
       end
'tms': begin
data = $
{dummy00: {name:'unix_time',     value:time_array(*,*,*),           recvary:1, fill:0}, $
 dummy01: {name:'H+',            value:Hp.y(*,*,*),                 recvary:1, fill:1}, $
 dummy02: {name:'H+_en',         value:Hp.v(*,*,*),                 recvary:1, fill:1}, $
 dummy03: {name:'H+_low',        value:Hp_low.y(*,*,*),             recvary:1, fill:1}, $
 dummy04: {name:'H+_low_pa',     value:Hp_low.v(*,*,*),             recvary:1, fill:1}, $
 dummy05: {name:'H+_high',       value:Hp_high.y(*,*,*),            recvary:1, fill:1}, $
 dummy06: {name:'H+_high_pa',    value:Hp_high.v(*,*,*),            recvary:1, fill:1}, $
 dummy07: {name:'O+',            value:Op.y(*,*,*),                 recvary:1, fill:1}, $
 dummy08: {name:'O+_en',         value:Op.v(*,*,*),                 recvary:1, fill:1}, $
 dummy09: {name:'O+_low',        value:Op_low.y(*,*,*),             recvary:1, fill:1}, $
 dummy10: {name:'O+_low_pa',     value:Op_low.v(*,*,*),             recvary:1, fill:1}, $
 dummy11: {name:'O+_high',       value:Op_high.y(*,*,*),            recvary:1, fill:1}, $
 dummy12: {name:'O+_high_pa',    value:Op_high.v(*,*,*),            recvary:1, fill:1}, $
 dummy13: {name:'He+',           value:Hep.y(*,*,*),                recvary:1, fill:1}, $
 dummy14: {name:'He+_en',        value:Hep.v(*,*,*),                recvary:1, fill:1}, $
 dummy15: {name:'He+_low',       value:Hep_low.y(*,*,*),            recvary:1, fill:1}, $
 dummy16: {name:'He+_low_pa',    value:Hep_low.v(*,*,*),            recvary:1, fill:1}, $
 dummy17: {name:'He+_high',      value:Hep_high.y(*,*,*),           recvary:1, fill:1}, $
 dummy18: {name:'He+_high_pa',   value:Hep_high.v(*,*,*),           recvary:1, fill:1}, $
 dummy50: {name:'orbit',         value:orbit.y(*,*,*),              recvary:1, fill:1}, $
 dummy51: {name:'fa_spin_ra',    value:float(fa_spin_ra.y(*,*,*)),  recvary:1, fill:1}, $
 dummy52: {name:'fa_spin_dec',   value:float(fa_spin_dec.y(*,*,*)), recvary:1, fill:1}, $
 dummy53: {name:'r',             value:float(fa_pos.y(*,*,*)),      recvary:1, fill:1}, $
 dummy54: {name:'v',             value:float(fa_vel.y(*,*,*)),      recvary:1, fill:1}, $
 dummy55: {name:'alt',           value:float(alt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy56: {name:'flat',          value:float(flat.y(*,*,*)),        recvary:1, fill:1}, $
 dummy57: {name:'flng',          value:float(flng.y(*,*,*)),        recvary:1, fill:1}, $
 dummy58: {name:'mlt',           value:float(mlt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy59: {name:'ilat',          value:float(ilat.y(*,*,*)),        recvary:1, fill:1} $
}
       end
'orb': begin
data = $
{dummy00: {name:'unix_time',     value:time_array(*,*,*),           recvary:1, fill:0}, $
 dummy01: {name:'orbit',         value:orbit.y(*,*,*),              recvary:1, fill:1}, $
 dummy02: {name:'fa_spin_ra',    value:float(fa_spin_ra.y(*,*,*)),  recvary:1, fill:1}, $
 dummy03: {name:'fa_spin_dec',   value:float(fa_spin_dec.y(*,*,*)), recvary:1, fill:1}, $
 dummy04: {name:'r',             value:float(fa_pos.y(*,*,*)),      recvary:1, fill:1}, $
 dummy05: {name:'v',             value:float(fa_vel.y(*,*,*)),      recvary:1, fill:1}, $
 dummy06: {name:'alt',           value:float(alt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy07: {name:'flat',          value:float(flat.y(*,*,*)),        recvary:1, fill:1}, $
 dummy08: {name:'flng',          value:float(flng.y(*,*,*)),        recvary:1, fill:1}, $
 dummy09: {name:'mlt',           value:float(mlt.y(*,*,*)),         recvary:1, fill:1}, $
 dummy10: {name:'ilat',          value:float(ilat.y(*,*,*)),        recvary:1, fill:1} $
}
       end
endcase

if verbose then begin
    print, 'structure data:'
    for i = 0, n_tags(data) - 1 do begin
        print, 'field name: ', data.(i).name, '      array size: ', n_elements(data.(i).value)
    endfor
endif

secs1970min = time_array(index_first)
secs1970max = time_array(index_last)

spawn, "date -u '+%Y''%m''%d'", today

; define the data structure that will hold the new global attr values
data_version = strcompress(versionnumber, /remove_all)
file_id = strcompress(cdffile, /remove_all)
today_date = strcompress(today, /remove_all)
gattr = {Data_version:   {name:'Data_version',   value:data_version, replace:1}, $
         Logical_file_id:{name:'Logical_file_id',value:file_id,      replace:1}, $
         Generation_date:{name:'Generation_date',value:today_date,   replace:1} $
        }
if verbose then begin
    print, 'gattr:'
    print, gattr
endif

; define the data structure that will hold the new variable attr values
pb5min = time_pb5(secs1970min)
pb5max = time_pb5(secs1970max)
orbitmin = orbit.y(index_first)
orbitmax = orbit.y(index_last)
vattr = {dummy1: {name:'SCALEMIN',  entry:'Time_PB5',  value:pb5min}, $
         dummy2: {name:'SCALEMAX',  entry:'Time_PB5',  value:pb5max}, $
         dummy3: {name:'SCALEMIN',  entry:'unix_time', value:secs1970min}, $
         dummy4: {name:'SCALEMAX',  entry:'unix_time', value:secs1970max}, $
         dummy5: {name:'SCALEMIN',  entry:'orbit',     value:orbitmin}, $
         dummy6: {name:'SCALEMAX',  entry:'orbit',     value:orbitmax} $
        }
if verbose then begin
    print, 'vattr:'
    print, vattr
endif

; write the CDF
if verbose then begin
    print, 'helps on data follow:'
    help,data
    help,data,/str
    for i = 0, n_tags(data) - 1 do begin
        print, 'data tag number ', i
        help,data.(i),/str
    endfor
endif

if not keyword_set(sktfile) then begin
    tempdir = getenv('FASTLIB')
    if not keyword_set(tempdir) then begin
        print, 'Environment variable FASTLIB is not set--can not find cdf templates.'
        status = -1
        return
    endif
    sktfile = tempdir + '/cdf_templates/fa_k0_' + dataset + '_day_template'
endif

if verbose then begin
    for i=0,20-1 do begin
        print, 'i = ', i, ' name = ', data.(i).name
        help,data.(i).value,/str
    endfor
endif

; generate statistics on the orbit files comprising the daily CDF
;print, 'List of orbit CDFs and their sizes:'
;print, '*************************************************************'
; if any orbit CDF has less than 30 times in it, treat this as an error
; if any orbit CDF has less than 100 times in it, treat this as a warning
; obviously, these two thresholds can be adjusted as desired
;orbsizeerror = 30
;orbsizewarning = 100
;orberror = 0
;orbwarning = 0
;;orbstart = what_orbit_is(tstart)
;orbend   = what_orbit_is(tend)
;norbfiles = n_elements(orbitfilelist)
;for orb = orbstart, orbend do begin
;    orbfilepiece = 'fa_k0_' + dataset + '_' + string(orb, format='(i5.5)') + '_v'
    ;present = 0
    ;for j = 0, norbfiles - 1 do begin
        ;if (strpos(orbitfilelist(j), orbfilepiece) ne -1) then begin
            ;present = 1
            ;whichorbit = j
            ;goto, continue
        ;endif
    ;endfor
    ;continue:
    ;if present eq 1 then begin
        ;stats = countcdfrvarrecs(orbitfilelist(whichorbit), count=count)
        ;if stats(0).size < orbsizeerror then orberror = 1
        ;if stats(0).size < orbsizewarning then orbwarning = 1
        ;print, orbitfilelist(whichorbit), stats(0).size
    ;endif else begin
        ;orbwarning = 1
        ;print, orbfilepiece + 'xx', ' ', 'ORBIT MISSING'
    ;endelse
;endfor
;print, '*************************************************************'
;if orberror eq 1 then begin
    ;print, 'orbit CDF status = ', 'ERROR--one or more orbit CDFs has < ', orbsizeerror, ' elements', format='(a,a,i3,a)'
;endif else if orbwarning eq 1 then begin
    ;print, 'orbit CDF status = ', 'WARNING--one or more orbit CDFs is missing or has < ', orbsizewarning, ' elements', format='(a,a,i3,a)'
;endif else begin
    ;print, 'orbit CDF status = ', 'OK--all orbits present and with > ', orbsizewarning, ' elements', format='(a,a,i3,a)'
;endelse
;if orberror eq 1 then begin
    ;print, 'Because of orbit CDF status of ERROR, not generating the CDF.'
    ;status = -1
;endif else begin
    print, 'Generating the CDF...'
    makecdf2, data, $
        sktfile=sktfile, $
        cdffile=cdffile, $
        gattr=gattr, $
        vattr=vattr, $
        verbose=verbose, $
        status=status, /overwrite
    if status eq 0 then begin
        print, 'Finished the CDF successfully with status = 0.'
    endif else begin
        print, 'make_day_cdf: ERROR: makecdf2 failed to build CDF--status = ', status
        return
    endelse
;endelse

return
end


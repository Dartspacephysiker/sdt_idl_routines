;+
;PROCEDURE:	make_mag_cdf
;PURPOSE:	
;	Make a cdf file with mag data	
;INPUT:		
;	data_str  - 'dcmag' -- for compatibility (not used)
;
;KEYWORDS:
;
;
;CREATED BY:	Ken Bromund	01/05/07
;VERSION:	1
;LAST MODIFICATION:  		01/05/07
;MOD HISTORY:
;
;
;NOTES:	
;  data_str:		'dcmag'
;  sdt plot config:	Mag_Survey 
;  apids:		1032 1080
;	

pro make_mag_cdf, data_str

; 
; Get the environment variables which set the output name and directory
; of the CDF
; This is for running under hires_cdf for batch hires cdf production

outputdir=getenv('IDL_HIRES_OUTDIR')
if outputdir eq '' then outputdir='.'
outputname=getenv('IDL_HIRES_CDFNAME')
if outputname eq '' then outputname = 'dcmag.cdf'
help, outputdir
help, outputname



ucla_mag_despin

get_data, 'dB_fac', data=tmp

;darr=[1.d,1.d,1.d]
;cdfdat0={time:tmp.x(0),dB_fac_o:tmp.y(0,0),dB_fac_e:tmp.y(0,0),$
;	dB_fac_b:tmp.y(0,0),$
;	fa_pos:darr,fa_vel:darr,alt:1.d,ilat:1.d,mlt:1.d,orbit:3l,$
;	b_model:darr,b_foot:darr,foot_lat:1.d,foot_lng:1.d}

cdfdat0={time:tmp.x(0),dB_fac_o:tmp.y(0,0),dB_fac_e:tmp.y(0,0),$
	dB_fac_b:tmp.y(0,0)}

cdfdat=replicate(cdfdat0,n_elements(tmp.x))

	cdfdat(*).time = tmp.x(*)
	cdfdat(*).dB_fac_o = tmp.y(*,0)
	cdfdat(*).dB_fac_e = tmp.y(*,1)
	cdfdat(*).dB_fac_b = tmp.y(*,2)

; leave out orbit data - resolution ridiculously high!
; Get the orbit data

;	orbit_file=fa_almanac_dir()+'/orbit/predicted'
;	get_fa_orbit,tmp.x(*),/time_array,orbit_file=orbit_file,/all,status=status
;	if status ne 0 then begin
;	    print, 'get_fa_orbit failed--returned nonzero status = ', status
;	endif
;
;	get_data,'fa_pos',data=fapos
;	get_data,'fa_vel',data=favel
;	get_data,'B_model',data=bmodel
;	get_data,'BFOOT',data=bfoot
;	for i=0,2 do begin
;		cdfdat(*).fa_pos(i)=fapos.y(*,i)
;		cdfdat(*).fa_vel(i)=favel.y(*,i)
;		cdfdat(*).b_model(i)=bmodel.y(*,i)
;		cdfdat(*).b_foot(i)=bfoot.y(*,i)
;	endfor
;
;	get_data,'ALT',data=tmp
;	cdfdat(*).alt=tmp.y(*)
;	get_data,'ILAT',data=tmp
;	cdfdat(*).ilat=tmp.y(*)
;	get_data,'MLT',data=tmp
;	cdfdat(*).mlt=tmp.y(*)
;	get_data,'ORBIT',data=tmp
;	cdfdat(*).orbit=tmp.y(*)
;	orbit_num=strcompress(string(tmp.y(0)),/remove_all)
;	get_data,'FLAT',data=tmp
;	cdfdat(*).foot_lat=tmp.y(*)
;	get_data,'FLNG',data=tmp
;	cdfdat(*).foot_lng=tmp.y(*)


    makecdf,cdfdat,file=outputdir+'/'+outputname,/overwrite



return


end

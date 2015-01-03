;+
;PROCEDURE:	make_orbit_cdf
;PURPOSE:	
;	Make a cdf file with orbit data	
;INPUT:		
;	data_str: 'orbit' by default, not used.
;
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
;NOTES:	all we really need from sdt is a timespan, but since the hiresd needs
;       a plot config and an APID, we use one which is always available
;       and has low data rate.
;  
;  data_str:		orbit
;  sdt plot config:	Mag_Survey   
;  apids:		1080
;	

pro make_orbit_cdf, data_str

; 
; Get the environment variables which set the output name and directory
; of the CDF
; This is for running under hires_cdf for batch hires cdf production

if n_params() eq 0 then data_str = 'orbit'

outputdir=getenv('IDL_HIRES_OUTDIR')
if outputdir eq '' then outputdir='.'
outputname=getenv('IDL_HIRES_CDFNAME')
if outputname eq '' then outputname = data_str+'.cdf'
help, outputdir
help, outputname


tmp=get_ts_from_sdt('AttitudeCtrl',2001,/all)

; Get the orbit data  -- we do it as in ucla_mag_despin, but because
; the time tags are different than the mag data, we make a separate
; cdf file.

	; this just gets us the start and end times we are interested in
	get_fa_orbit,tmp.start_time,tmp.end_time,/all,status=status,delta=1.,/definitive,/drag_prop

	if status ne 0 then begin
	    print, 'get_fa_orbit failed--returned nonzero status = ', status
	endif

	get_data,'fa_pos',data=fapos
	get_data,'fa_vel',data=favel
	get_data,'B_model',data=bmodel
	get_data,'BFOOT',data=bfoot

darr=[1.d,1.d,1.d]
cdfdat0={time:fapos.x(0), $
	fa_pos:darr,fa_vel:darr,alt:1.d,ilat:1.d,mlt:1.d,orbit:3l,$
	b_model:darr,b_foot:darr,foot_lat:1.d,foot_lng:1.d}


cdfdat=replicate(cdfdat0,n_elements(fapos.x))

	cdfdat(*).time = fapos.x(*)

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


    makecdf,cdfdat,file=outputdir+'/'+outputname,/overwrite



return


end
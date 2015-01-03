;+
;PROCEDURE:	make_dsp_cdf
;PURPOSE:	
;	Make a cdf file with dsp OMNI electric fields data	
;INPUT:		
;	data_str
;		see notes for valid values. default 'dsp_omni'
;
;KEYWORDS:
;	T1:		start time, seconds since 1970
;	T2:		end time, seconds since 1970		
;
;
;CREATED BY:	Ken Bromund	01/05/07
;VERSION:	1
;LAST MODIFICATION:  		01/05/07
;MOD HISTORY:
;
;
;NOTES:	
;  data_str:	'dsp_omni'
;  sdt config:  DSP_EFI
;  apids:	1037
;  Fmodes:
;	
;  data_str:	'dsp_mag'
;  sdt config:  DSP_Mag
;  apids:	1037
;  Fmodes:      all
;
;  data_str:	'dsp_v58'
;  sdt config:  DSP_EFI
;  apids:	1037
;  Fmodes:
;
;  data_str:	'dsp_v14'
;  sdt config:  DSP_EFI
;  apids:	1037
;  Fmodes:
;	

pro make_dsp_cdf, data_str, t1=t1, t2=t2

; 
; Get the environment variables which set the output name and directory
; of the CDF
; This is for running under hires_cdf for batch hires cdf production

if n_params() eq 0 then data_str = 'dsp_omni'

outputdir=getenv('IDL_HIRES_OUTDIR')
if outputdir eq '' then outputdir='.'
outputname=getenv('IDL_HIRES_CDFNAME')
if outputname eq '' then outputname = data_str+'.cdf'
help, outputdir
help, outputname



; get efields -- ergun's routine will figure out what to get from just
; about any sensible data_str

fa_fields_dsp, data_str, t1=t1, t2=t2 ;will automatically get HG if necessary


; the tplot data name must be exactly right, including capitolization
CASE strlowcase(data_str) OF
	'dsp_omni' : tpname = 'DSP_OMNI'
	'dsp_mag'  : tpname = 'DSP_Mag3a'
	'dsp_v14'  : tpname = 'DSP_V1-V4'
	'dsp_v58'  : tpname = 'DSP_V5-V8'
	ELSE: BEGIN
		print, 'unknown data type: ', data_str
		return
		END
ENDCASE

get_data, tpname, data=tmp

darr=[1.d,1.d,1.d]


; find duplicated time tags or time reversals and remove them
; note: this algorithm will not produce a monotonically increasing
; result if there is a time overlap of more than one point.

n = n_elements(tmp.x)
if n lt 2 then begin
	print, 'no good data found'
	return
end
goodtmp = where(tmp.x(1:n-1)-tmp.x(0:n-2) gt 0.0, nGoodDt)

if nGoodDt eq 0 then begin
	print, 'no good data found'
	return
end

goodt = lindgen(nGoodDt+1)
goodt(1:nGoodDt) = goodtmp+1  ; these are the indexes of the good data

yx = transpose(tmp.y(goodt,*))  ; transpose y array so we get the correct
				; dimensionality in the cdf

cdfdat0={time:tmp.x(0),dsp:yx(*, 0),$
	fa_pos:darr,fa_vel:darr,alt:1.d,ilat:1.d,mlt:1.d,orbit:3l,$
	b_model:darr,b_foot:darr,foot_lat:1.d,foot_lng:1.d}
cdfdat=replicate(cdfdat0,nGoodDt+1)

	cdfdat(*).time = tmp.x(goodt)

	cdfdat(*).dsp(*) = yx

	yx = 0   ; deallocate the temporary yx variable

cdfdatnovary={freq:tmp.v(*)}


; Get the orbit data

	orbit_file=fa_almanac_dir()+'/orbit/predicted'
	get_fa_orbit,tmp.x(goodt),/time_array,orbit_file=orbit_file,/all,status=status
	if status ne 0 then begin
	    print, 'get_fa_orbit failed--returned nonzero status = ', status
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


    makecdf,cdfdat,file=outputdir+'/'+outputname,overwrite=1, datanovary=cdfdatnovary



return


end
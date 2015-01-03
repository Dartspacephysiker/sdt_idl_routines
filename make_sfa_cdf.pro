;+
;PROCEDURE:	make_sfa_cdf
;PURPOSE:	
;	Make a cdf file with sfa OMNI electric fields data	
;INPUT:		
;	data_str
;		see notes for valid values. default 'sfa_omni'
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
;  data_str:	'Sfa_omni'
;  sdt config:  SfaAve_EFI
;  apids:	1036
;  Fmodes:
;	
;  data_str:	'Sfa_58'
;  sdt config:  SfaAve_EFI
;  apids:	1036
;  Fmodes:
;	
;  data_str:	'Sfa_14'
;  sdt config:  SfaAve_EFI
;  apids:	1036
;  Fmodes:
;	
;  data_str:	'Sfa_12'
;  sdt config:  SfaAve_EFI
;  apids:	1036
;  Fmodes:
;	
;  data_str:	'Sfa_mag'
;  sdt config:  SfaAve_Mag
;  apids:	1036
;  Fmodes:      all
;
;  data_str:	'SfaB_omni'
;  sdt config:  Sfa_EFI
;  apids:	1057
;  Fmodes:
;	
;  data_str:	'SfaB_58'
;  sdt config:  Sfa_EFI
;  apids:	1057
;  Fmodes:
;	
;  data_str:	'SfaB_14'
;  sdt config:  Sfa_EFI
;  apids:	1057
;  Fmodes:
;	
;  data_str:	'SfaB_12'
;  sdt config:  Sfa_EFI
;  apids:	1057
;  Fmodes:
;	
;  data_str:	'SfaB_mag'
;  sdt config:  Sfa_Mag
;  apids:	1057
;  Fmodes:      all
;
;	

pro make_sfa_cdf, data_str, t1=t1, t2=t2

; 
; Get the environment variables which set the output name and directory
; of the CDF
; This is for running under hires_cdf for batch hires cdf production

if n_params() eq 0 then data_str = 'sfa_omni'

outputdir=getenv('IDL_HIRES_OUTDIR')
if outputdir eq '' then outputdir='.'
outputname=getenv('IDL_HIRES_CDFNAME')
if outputname eq '' then outputname = data_str+'.cdf'
help, outputdir
help, outputname


store = 1

; the tplot data name must be exactly right, including capitolization
CASE strlowcase(data_str) OF
	'sfa_omni' : begin 
			tpname = 'SFA_OMNI'
			burst=0
			mag=0
			end
	'sfa_58' : begin 
			tpname = 'SFA_58'
			burst=0
			mag=0
			store=2
			end
	'sfa_14' : begin 
			tpname = 'SFA_14'
			burst=0
			mag=0
			store=2
			end
	'sfa_12' : begin 
			tpname = 'SFA_12'
			burst=0
			mag=0
			store=2
			end
	'sfa_mag'  : begin
			tpname = 'SFA_MAG'
			burst=0
			mag=1
			end
	'sfab_omni' : begin 
			tpname = 'SFAB_OMNI'
			burst=1
			mag=0
			end
	'sfab_58' : begin 
			tpname = 'SFAB_58'
			burst=1
			mag=0
			store=2
			end
	'sfab_14' : begin 
			tpname = 'SFAB_14'
			burst=1
			mag=0
			store=2
			end
	'sfab_12' : begin 
			tpname = 'SFAB_12'
			burst=1
			mag=0
			store=2
			end
	'sfab_mag'  : begin
			tpname = 'SFA_MAG_B'
			burst=1
			mag=1
			end
	ELSE: BEGIN
		print, 'unknown data type: ', data_str
		return
		END
ENDCASE

; get efields -- ergun's routine will figure out what to get from just
; about any sensible data_str

fa_fields_sfa,  burst=burst, mag=mag, store=store, t1=t1, t2=t2


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

cdfdat0={time:tmp.x(0),sfa:yx(*, 0),$
	fa_pos:darr,fa_vel:darr,alt:1.d,ilat:1.d,mlt:1.d,orbit:3l,$
	b_model:darr,b_foot:darr,foot_lat:1.d,foot_lng:1.d}
cdfdat=replicate(cdfdat0,nGoodDt+1)

	cdfdat(*).time = tmp.x(goodt)

	cdfdat(*).sfa(*) = yx

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
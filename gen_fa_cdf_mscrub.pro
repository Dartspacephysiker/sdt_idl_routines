;+
; PROCEDURE	make_fa_cdf_mscrub
;
; PURPOSE	Creates CDF files containing the two FAST quantities, 
;		MScrub_SumMultipleErrs and Mscrub_SumSingleErrs.  
;		Variables available in the CDF will be 'time', 'mult', 'sing'.
;
;		This procedure calls get_fa_mscrub_multerrs and 
;		get_fa_mscrub_singerrs to extract these quantities from 
;		SDT shared memory buffers.
;
;		Creates files in the current dir with names like
;		biterr_07_04_76.cdf, where '07_04_76' is the day on which
;		The Fourth of July falls.
;
; CAUTION	In SDT, the DQDs for single and multiple errors are switched,
;		so the above get routines will retreive couterintuitive
;		quantities.  This routine assumes the DQDs are wrong.
;
; NOTE		You can load the variables in the created CDF files using
;		load_fa_biterr.pro.
;
; INPUTS	none
;
;		Originally written by S.Wittenbrock
;		Modified by J.Rauchleiba
;-
pro gen_fa_cdf_mscrub

; Get the data from the SDT buffers
; Make a structure out of the data. 
; x is time. y is errors.
; Store the data as tplot structures

sing_data = get_fa_mscrub_multerrs(/all)	; DQD switched !!
if sing_data.valid NE 1 then message, 'Single-error data not valid.'
sing_st = {x:sing_data.time, y:sing_data.memerrors, v:['memerrors_v']}
store_data, 'sing', data=sing_st

mult_data = get_fa_mscrub_singerrs(/all)	; DQD switched !!
if mult_data.valid NE 1 then message, 'Multiple-error data not valid.'
mult_st = {x:mult_data.time, y:mult_data.memerrors, v:['memerrors_v']}
store_data, 'mult', data=mult_st

; Create time-tagged array of structures

make_cdf_structs, ['sing', 'mult'], datavary, datanovary

; Construct the name of the output CDF file

stt = time_to_str(mult_data.start_time)
if (!VERSION.RELEASE LE '5.4') then begin
    date_time = str_sep(stt, '/')
    yr_mo_da = str_sep(date_time(0), '-')
endif else begin
    date_time = strsplit(stt, '/', /EXTRACT)
    yr_mo_da = strsplit(date_time(0), '-', /EXTRACT)
endelse
file = 'biterr_' + strmid(yr_mo_da(0),2,2) +'_'+ yr_mo_da(1) +'_'+ yr_mo_da(2)

; Make the CDF.

print, 'Creating CDF file: ' + file
makecdf, file=file, datavary, tagsvary=['time', 'sing', 'mult'], /overwrite


end

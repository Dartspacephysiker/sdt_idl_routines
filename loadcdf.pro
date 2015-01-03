;+
;PROCEDURE:	loadcdf
;PURPOSE:	
;   Loads one type of data from specified cdf file.
;INPUT:		
;	CDF_file:	the file to load data from  (or the id of an open file)
;	CDF_var:	the variable to load
;	x:		the variable to load data into
;
;KEYWORDS:
;	zvar:	 	must be set if variable to be loaded is a zvariable
;       append:         appends data to the end of x instead of overwriting it.
;       nrecs:           number of records to be read.
;
;CREATED BY:	Jim Byrnes, heavily modified by Davin Larson 
;MODIFICATIONS:
;  96-6-26  added APPEND keyword
;LAST MODIFICATION:	@(#)loadcdf.pro	1.10 96/12/02
;-

; The following program will load all of the data for a specific CDF file and
; variable into IDL. 
; 
;(Jim Byrnes)

pro loadcdf,CDF_file,CDF_var,x0, zvar = zvar, $
   append=append,no_shift=no_shift,nrecs = nrecs

;ON_ERROR,1

;
; Open CDF file  (if neccesary)
;
if data_type(cdf_file) eq 7 then id = cdf_open(cdf_file) else id = cdf_file

;
; Get file CDF structure information
; 

inq = cdf_info(id)

;
; Get variable structure information
;

vinq = cdf_varinq(id,CDF_var, zvariable = zvar)
zvar = vinq.is_zvar
;help, vinq,/st
;help,zvar

if not keyword_set(nrecs) then nrecs = inq.num_recs
if vinq.recvar eq 'NOVARY' then nrecs = 1

dims = total(vinq.dimvar)

if keyword_set(zvar) then begin
  CDF_varget,id,CDF_var,x,REC_COUNT=nrecs,zvariable = zvar
endif else begin
  dimc = vinq.dimvar * inq.dim
  dimw = where(dimc eq 0,c)
  if c ne 0 then dimc(dimw) = 1
  CDF_varget,id,CDF_var,x,COUNT=dimc,REC_COUNT=nrecs
endelse

;help,cdf_var,x


if vinq.recvar eq 'VARY' and dims ne 0 and not keyword_set(no_shift) then $
   x = dimen_shift(x,1) 

if ndimen(x) gt 0 then x = reform(x)

;help,cdf_var,x

if keyword_set(append) and keyword_set(x0)  then x0=[x0,x] else x0=x

if data_type(cdf_file) eq 7 then cdf_close,id
return
end



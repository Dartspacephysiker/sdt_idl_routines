; IDL BATCH FILE
;
; call_compare_cdf_db.pro
;
; PURPOSE
;
; Gets envronment variables defined in shell script and calls
; IDL procedure compare_cdf_db.pro with proper parameters.  Also handles
; some output of the procedure
;

; Get parameters from environment

first_orbit = getenv('first_orbit')
last_orbit = getenv('last_orbit')
orbit_list = getenv('orbit_list')
compare_out = getenv('compare_out')
inst_turnons = getenv('inst_turnons')
bad_orbits = getenv('bad_orbits')
qty = getenv('qty')
version = getenv(strupcase(qty)+'VERSION')

; Determine if orbits are an interval or an array

if orbit_list NE '' then orbarray = 1 
if (!VERSION.RELEASE LE '5.4') then begin
    if orbit_list NE '' then first_orbit = fix(str_sep(orbit_list, ' ')) else orbarray=0
endif else begin
    if orbit_list NE '' then first_orbit = fix(strsplit(orbit_list, ' ', /EXTRACT)) else orbarray=0
endelse

; Compare CDF times to nominal collection times

compare_cdf_db, QTY=qty, VERSION=version, ONTIMES=inst_turnons, $
  OUT=compare_out, first_orbit, last_orbit, orbarray=orbarray, TROUBLE=trouble

; Make "troubled orbits" list available to calling script by writing file

openw, unit, /get_lun, bad_orbits
printf, unit, format='(A,:,/)', strtrim(trouble, 2)
close, unit

exit


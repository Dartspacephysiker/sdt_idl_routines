;+
;PROCEDURE:	convert_esa_units2
;PURPOSE:	
;	To convert FAST ESA data units to counts,eflux,flux,df,rate, or crate
;
;	'COUNTS' :  #						
;	'RATE'   :  #/sec
;	'CRATE'  :  #/sec		(dead time corrected)
;	'EFLUX'  :  eV/(cm^2-s-sr-eV)	(dead time corrected)
;	'FLUX'   :  #/(cm^2-s-sr-eV)	(dead time corrected)
;	'DF'     :  #/(km^3-(cm/s)^3)	(dead time corrected)
;INPUT:		
;	data:	A 3d structure such as those generated by get_el,get_pl,etc.
;	units:	A string telling the procedure which units to convert to, such
;		as ncounts,rate,nrate,eflux,flux,df
;
;KEYWORDS:
;	scale:	A named variable that will return the scale used to convert
;
;CREATED BY:	J. McFadden (modified from convert_esa_units - D.Larson)
;LAST MODIFICATION:	97/03/03
;MOD HISTORY:
;		97/03/03	Changed to accept 1-D or 2-D GEOM structure element
;-

pro convert_esa_units2, data,units, $
  SCALE = scale

if strupcase(units) eq strupcase(data.units_name) then return

nbins = data.nbins		; number of bins       
nenergy = data.nenergy		; number of energies   
energy = data.energy		; in eV			(nenergy,nbins)
geom = data.geom		; relative geometric factor of bins (nenergy,nbins)
	if ndimen(geom) eq 0 then geom = [geom]
	if ndimen(geom) eq 1 then geom = replicate(1.,nenergy) # geom
;eff = data.eff 		; energy efficiency, currently not used	(nenergy,nbins)
;	if ndimen(eff) eq 0 then eff = [eff]
;	if ndimen(eff) eq 1 then eff = eff # replicate(1.,nbins)
dt = data.integ_t		; integration time (sec)	scalar or (nenergy,nbins)
gf = data.geomfactor		; geometric factor of smallest bin, scaler (cm^2-sr)
				; (nbins) or (nenergy,nbins)
mass = data.mass		; scaler eV/(km/s)^2
dead = .11e-6			; dead time, (sec) FAST AMPTEK A121

case strupcase(data.units_name) of 
'COUNTS' :  scale = 1.						
'RATE'   :  scale = dt
'CRATE'  :  scale = dt
'EFLUX'  :  scale = (gf * geom)
'FLUX'   :  scale = (gf * geom) * energy
'DF'     :  scale = (gf * geom) * energy^2 * 2./mass/mass*1e5
else: begin
        print,'Unknown starting units: ',data.units_name
	return
      end
endcase

; convert to COUNTS
tmp = scale * data.data

; take out dead time correction
if strupcase(data.units_name) ne 'COUNTS' and strupcase(data.units_name) ne 'RATE' then $
	tmp = round(dt*tmp/(1.+tmp*dead))

; determine scale factor
scale = 0.
case strupcase(units) of 
'COUNTS' :  scale = 1. 
'RATE'   :  scale = 1. / (dt)
'CRATE'  :  scale = 1. / (dt)
'EFLUX'  :  scale = 1. / (dt * gf * geom)
'FLUX'   :  scale = 1. / (dt * gf * geom * energy)
'DF'     :  scale = 1. / (dt * gf * geom  * energy^2 * 2./mass/mass*1e5 )
else: begin
        print,'Undefined units: ',units
	return
      end
endcase

; dead time correct data if not counts or rate
if strupcase(units) ne 'COUNTS' and strupcase(units) ne 'RATE' then begin
	denom = 1.- dead*tmp/dt
;	print,min(denom)
	void = where(denom lt .1,count)
	if count gt 0 then begin
		print,min(denom,ind)
		denom = denom>.1 
		print,' Error: convert_esa_units2 dead time error.'
		print,' Dead time correction limited to x10 for ',count,' bins'
		print,' Time= ',time_to_str(data.time,/msec)
	endif
	tmp2 = tmp/denom
endif else tmp2 = tmp

; scale to new units
data.units_name = units
if find_str_element(data,'ddata') ge 0 then data.ddata = scale * tmp2^.5
data.data = scale * tmp2

return
end
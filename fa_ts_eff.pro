FUNCTION FA_TS_EFF, en, pac, spec, mode, spin_section, eff_version, time, $
	debug=debug
;+
; FUNCTION:
;        FA_TS_EFF
;
; DESCRIPTION:
;
;        function to calculate teams survey efficiency.
;
; INPUT:
;        en:   Arrary (nnrgs, nbins) of energy 
;	 pac:  A number for the calculation of post acceleration voltage
;	 spec: Species for which the effciency is calculated. (0--3)
;	 mode: Teams instrument mode. (0--9)
;	 spin_section: The spin section of data readout (0--2)
;		      0: don't care section.1: first half spin, 2: 2nd half spin
; RETURN:
;	 eff(nnrgs, nbins): Efficiency
;	 eff_version:       The version number of calibration data
;
; CREADED BY:
;	     Li Tang,  University of New Hampshire
;
; LAST MODIFICATION:     2005-09-16	EJL
;
; MODIFICATION HISTORY:
;	2005-09-16 EJL	Allow one side of instrument to be effectively
;			disabled
;	2003-10-09 EJL	Time dependence added to calibration
;			Angle bin 0 treated as average efficiency
;	1996-10-22 LT	Original version	
;-	
; FUNCTION FA_TS_EFF, energy, pac, spec, mode, spin_section, version


  ang2pix =[ [3, 4, 2, 3, 4, 5, 3, 4, 0, 1, 2, 3, 4, 5, 6, 7,		$
            12,11,13,12,11,10,12,11,15,14,13,12,11,10, 9, 8,		$
             3, 4, 2, 3, 4, 5, 3, 4, 0, 1, 2, 3, 4, 5, 6, 7,		$
            12,11,13,12,11,10,12,11,15,14,13,12,11,10, 9, 8],		$
            [12,11,13,12,11,10,12,11,15,14,13,12,11,10, 9, 8, 		$
             3, 4, 2, 3, 4, 5, 3, 4, 0, 1, 2, 3, 4, 5, 6, 7,		$
            12,11,13,12,11,10,12,11,15,14,13,12,11,10, 9, 8,		$
             3, 4, 2, 3, 4, 5, 3, 4, 0, 1, 2, 3, 4, 5, 6, 7]] 

        eff0 = FLTARR(48, 64)
        eff1 = FLTARR(48, 64)
        eff2 = FLTARR(48, 64)
;  pix1 = INTARR(16)
;  pix2 = INTARR(16)

  tof_eff = FA_TTOF_CALIBRATION(en, spec, pac, eff_version, time)
  pix1 = ang2pix(*,0)
  pix2 = ang2pix(*,1)

  ;;;modified 2005-09-16 by EJL--this code replaces commented out CASE block
  if (spec eq 0 or spec eq 3) and mode gt 5 then begin
	if spin_section ge 2 then ret_eff = tof_eff(*,pix1) else $
		ret_eff = tof_eff(*,pix2)
  endif else begin
	status = 2 * (tof_eff(*,pix2) lt 1e10) + (tof_eff(*,pix1) le 1e10)
	bothgood = where(status eq 3, count)
	bothbad = where(status eq 0, countbad)
	; EJL: if pixel disabled on one side, use calibration from other
	; side (if bad on both sides, it doesn't really matter)
	ret_eff = tof_eff(*,pix1) * (status mod 2 eq 1) + $
		tof_eff(*,pix2) * (status ge 2)
	if count gt 0 then ret_eff(bothgood) = ret_eff(bothgood) / 2
	if countbad gt 0 then ret_eff(bothbad) = 1e30
  endelse

  ;CASE spec OF
      ;0: BEGIN
          ;IF mode GT 5 THEN BEGIN
            ;IF spin_section GE 2 THEN ret_eff = tof_eff(*,pix1) ELSE ret_eff =  tof_eff(*,pix2)
          ;ENDIF ELSE ret_eff = (tof_eff(*,pix1) + tof_eff(*,pix2))/2.
	 ;END
      ;1: ret_eff = (tof_eff(*,pix1) + tof_eff(*,pix2))/2.
      ;2: ret_eff = (tof_eff(*,pix1) + tof_eff(*,pix2))/2.
      ;3: BEGIN
          ;IF mode GT 5 THEN BEGIN
            ;IF spin_section GE 2 THEN ret_eff = tof_eff(*,pix1) ELSE ret_eff = tof_eff(*,pix2)
          ;ENDIF ELSE ret_eff = (tof_eff(*,pix1) + tof_eff(*,pix2))/2.
	 ;END
   ;ENDCASE

; The following lines assign an average efficiency value to pixel 0
for i = 0, 47 do begin
	i_nonzero = where(tof_eff(i,*) lt 1e10, count)
	if count gt 0 then begin
		sum_nonzero = total(tof_eff(i,i_nonzero))
		ret_eff(i,0) = sum_nonzero / count 
	endif else ret_eff(i,0) = 1e30
endfor
if keyword_set(debug) then print, ret_eff(0,*)
return, ret_eff
END

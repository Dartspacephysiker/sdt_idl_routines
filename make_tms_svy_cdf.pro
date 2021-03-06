;+
;PROCEDURE:	make_tms_svy_cdf
;PURPOSE:	
;	Make a cdf file with TEAMS survey data
;KEYWORDS:
;	SPECIES		String indicating ion species to use: 'p'(rotons),
;			'a'(lphas), 'h'(elium), or 'o'(xygen)
;	T1		Start time, seconds since 1970
;	T2		End time, seconds since 1970		
;	NENERGY		Number of energy bins
;	NBINS		Number of angle bins
;	UNITS		Convert to these units if included
;	NAME  		New name of the data quantity
;	GAP_TIME	Time interval to flag a data gap
;
;CREATED BY:	E. J. Lund	2001/05/18
;VERSION:	1.0
;LAST MODIFICATION:  		2001/05/18
;MODIFICATION HISTORY:
;	none
;-

pro make_tms_svy_cdf, SPECIES = species, T1=t1, T2=t2, $
                      NENERGY=nenergy, NBINS=nbins, UNITS = units, $
                      NAME = name, GAP_TIME = gap_time,ALL = all, $
                      RETURN_STRUCT=return_struct,struct=struct

;	Time how long the routine takes
  ex_start = systime(1)

;	Set defaults for keywords, etc.

  n = 0
  max = 1440                    ; allows 1 hour of fast survey H+/O+

  routine = 'get_fa_ts' + species

  if keyword_set(t1) then begin
     t = t1
     dat = call_function(routine, t, /calib)
  endif else begin
     t = 1000                   ; get first sample
     dat = call_function(routine, t, /calib, /start)
  endelse

if dat.valid eq 0 then begin no_data = 1 & return & end $
else no_data = 0

   last_time = (dat.time + dat.end_time) / 2.
   last_delta_time = dat.end_time - dat.time
   nenergy = 47
   if nenergy eq 47 then retrace = 1 else retrace = 0
   nbins = dat.nbins
   if not keyword_set(gap_time) then gap_time = 64.
   data = fltarr(nenergy, nbins)
   energy = data
   theta = data
   phi = data

   darr = [1.d, 1.d, 1.d]
   cdfdat0 = {time:dat.time, delta_time:dat.integ_t, data:data,$
              energy:energy, theta:theta, phi:phi, nenergy:nenergy, nbins:nbins,$
              fa_pos:darr, fa_vel:darr, alt:1.d, ilat:1.d, mlt:1.d, orbit:3l,$
              b_model:darr, b_foot:darr, foot_lat:1.d, foot_lng:1.d, $ ;20190624 previously didn't include fa_spin_ra,fa_spin_dec
              fa_spin_ra:1.d,fa_spin_dec:1.d}

   IF KEYWORD_SET(all) THEN BEGIN

      cdfdat0ext = {data_name: '', valid: 0S, PROJECT_NAME: 'FAST', UNITS_NAME: '', $
                    UNITS_PROCEDURE: '', END_TIME: 1.D, INTEG_T: 1.D, $
                    GEOM: data, DENERGY: data, $
                    dTheta: fltarr(nBins), $
                    dPhi: fltarr(nBins), $
                    dOmega: fltarr(nBins), $
                    PT_limits: fltarr(4), $
                    EFF: data, $
                    spin_fract: data, $
                    mass:1.d, $
                    geomfactor: dat.geomfactor, $
                    header_bytes: byte(intarr(86)), $
                    eff_version: 1.d}

      cdfdat0 = CREATE_STRUCT(cdfdat0,cdfdat0ext)

   ENDIF

   cdfdat = replicate(cdfdat0, max)

   if not keyword_set(units) then units = 'Eflux'

;	Collect the data - Main Loop
   
   if keyword_set(t2) then tmax = str_to_time(t2) else tmax = 1.e30

   while (dat.valid ne 0) and (n lt max) do begin
      if (dat.valid eq 1) then begin

; Test to see if a transition between fast and slow survey occurs, 
; ie delta_time changes, and skip some data if it does.
         if (abs((dat.end_time - dat.time) - last_delta_time) gt 1. ) then begin
            if routine eq 'fa_ees_c' then nskip = 2 else nskip = 3
                                ; if fast to slow, skip two or three arrays
            if (dat.end_time - dat.time) gt last_delta_time then begin
               for i = 1, nskip do begin
                  dat = call_function(routine,t,/calib,/ad)
               endfor
            endif else begin
               while (dat.time lt last_time + 7.5) do begin
                  dat = call_function(routine,t,/calib,/ad)
               endwhile
            endelse
         endif
         
; Test for data gaps and add NAN if gaps are present.
         ;; IF ~dat.valid THEN stop
         str_element,dat,'time',success=s
         IF ~s THEN CONTINUE

         if abs((dat.time+dat.end_time)/2. - last_time) ge gap_time then begin
            if n ge 2 then dbadtime = cdfdat(n-1).time - cdfdat(n-2).time else dbadtime = gap_time/2.
            cdfdat(n).time = (last_time) + dbadtime
            cdfdat(n).delta_time = !values.f_nan
            cdfdat(n).data(*,*) = !values.f_nan
            cdfdat(n).energy(*,*) = !values.f_nan
            cdfdat(n).theta(*,*) = !values.f_nan
            cdfdat(n).phi(*,*) = !values.f_nan
            cdfdat(n).nenergy = !values.f_nan
            cdfdat(n).nbins = !values.f_nan

            IF KEYWORD_SET(all) THEN BEGIN

               cdfdat(n).valid = 0
               cdfdat(n).units_name = dat.units_name
               cdfdat(n).units_procedure = dat.units_procedure
               cdfdat(n).end_time = dat.end_time
               cdfdat(n).integ_t = dat.integ_t
               cdfdat(n).geom(0:nenergy-1,0:dat.nbins-1) = dat.geom(retrace:nenergy-1+retrace,0:dat.nbins-1)
               cdfdat(n).denergy(0:nenergy-1,0:dat.nbins-1) = dat.denergy(retrace:nenergy-1+retrace,0:dat.nbins-1)
               cdfdat(n).dtheta(0:dat.nbins-1) = dat.dtheta(0:dat.nbins-1)
               cdfdat(n).dphi(0:dat.nbins-1) = dat.dphi(0:dat.nbins-1)
               cdfdat(n).domega(0:dat.nbins-1) = dat.domega(0:dat.nbins-1)
               cdfdat(n).pt_limits(*) = dat.pt_limits(*)
               cdfdat(n).eff(0:nenergy-1,0:dat.nbins-1) = dat.eff(retrace:nenergy-1+retrace,0:dat.nbins-1)
               cdfdat(n).spin_fract(0:nenergy-1,0:dat.nbins-1) = dat.spin_fract(retrace:nenergy-1+retrace,0:dat.nbins-1)
               cdfdat(n).mass = dat.mass
               cdfdat(n).geomfactor = dat.geomfactor
               cdfdat(n).header_bytes = dat.header_bytes
               cdfdat(n).eff_version = dat.eff_version

            ENDIF

            n = n + 1

            if (dat.time+dat.end_time)/2. gt cdfdat(n-1).time + gap_time then begin
               cdfdat(n).time = (dat.time+dat.end_time)/2. - dbadtime
               cdfdat(n).delta_time = !values.f_nan
               cdfdat(n).data(*,*) = !values.f_nan
               cdfdat(n).energy(*,*) = !values.f_nan
               cdfdat(n).theta(*,*) = !values.f_nan
               cdfdat(n).phi(*,*) = !values.f_nan
               cdfdat(n).nenergy = !values.f_nan
               cdfdat(n).nbins = !values.f_nan

               IF KEYWORD_SET(all) THEN BEGIN

                  cdfdat(n).valid = 0
                  cdfdat(n).units_name = dat.units_name
                  cdfdat(n).units_procedure = dat.units_procedure
                  cdfdat(n).end_time = dat.end_time
                  cdfdat(n).integ_t = dat.integ_t
                  cdfdat(n).geom(0:nenergy-1,0:dat.nbins-1) = dat.geom(retrace:nenergy-1+retrace,0:dat.nbins-1)
                  cdfdat(n).denergy(0:nenergy-1,0:dat.nbins-1) = dat.denergy(retrace:nenergy-1+retrace,0:dat.nbins-1)
                  cdfdat(n).dtheta(0:dat.nbins-1) = dat.dtheta(0:dat.nbins-1)
                  cdfdat(n).dphi(0:dat.nbins-1) = dat.dphi(0:dat.nbins-1)
                  cdfdat(n).domega(0:dat.nbins-1) = dat.domega(0:dat.nbins-1)
                  cdfdat(n).pt_limits(*) = dat.pt_limits(*)
                  cdfdat(n).eff(0:nenergy-1,0:dat.nbins-1) = dat.eff(retrace:nenergy-1+retrace,0:dat.nbins-1)
                  cdfdat(n).spin_fract(0:nenergy-1,0:dat.nbins-1) = dat.spin_fract(retrace:nenergy-1+retrace,0:dat.nbins-1)
                  cdfdat(n).mass = dat.mass
                  cdfdat(n).geomfactor = dat.geomfactor
                  cdfdat(n).header_bytes = dat.header_bytes
                  cdfdat(n).eff_version = dat.eff_version

               ENDIF

               n = n + 1

            endif
         endif

                                ; Get the magnetic field direction from the header
         last_hdr_time = dat.time - (dat.end_time - dat.time)/2.0
         hdr_mag = get_fa_tsop_hdr(last_hdr_time) ;call previous data header
                                ;to average mag-direction
         if hdr_mag.valid eq 0 then last_hdr_bytes = dat.header_bytes $
         else last_hdr_bytes = hdr_mag.bytes
         if (where(dat.header_bytes))(0) eq -1 then $
            dat.header_bytes = last_hdr_bytes
         magdir1 = (ISHFT(last_hdr_bytes(2), -4) + $ 
                    ISHFT((1 * last_hdr_bytes(3)), 4)) * 360.0 / 4096.0
         magdir2 = (ISHFT(dat.header_bytes(2), -4) + $ 
                    ISHFT((1 * dat.header_bytes(3)), 4))*360.0/4096.0
         magdir = (magdir1 + magdir2) / 2.0
         IF abs(magdir1 - magdir2) gt 180.0 then $
            magdir = (magdir + 180.) mod 360.


         dat = conv_units(dat, units)
         data(*,*) = 0.
         data(0:nenergy-1,0:dat.nbins-1)=dat.data(retrace:nenergy-1+retrace,0:dat.nbins-1)
         energy(*,*) = 0.
         energy(0:nenergy-1,0:dat.nbins-1)=dat.energy(retrace:nenergy-1+retrace,0:dat.nbins-1)
         theta(*,*) = 0.
         theta(0:nenergy-1,0:dat.nbins-1)=dat.theta(retrace:nenergy-1+retrace,0:dat.nbins-1)
         phi(*,*) = 0.
         phi(0:nenergy-1,0:dat.nbins-1)=dat.phi(retrace:nenergy-1+retrace,0:dat.nbins-1) + magdir
         
         cdfdat(n).time = (dat.time + dat.end_time) / 2.
         cdfdat(n).delta_time = dat.end_time - dat.time
         cdfdat(n).data(*,*) = data
         cdfdat(n).energy(*,*) = energy
         cdfdat(n).theta(*,*) = theta
         cdfdat(n).phi(*,*) = phi
         cdfdat(n).nenergy = nenergy
         cdfdat(n).nbins = dat.nbins

         IF KEYWORD_SET(all) THEN BEGIN

            cdfdat(n).valid = dat.valid
            cdfdat(n).units_name = dat.units_name
            cdfdat(n).units_procedure = dat.units_procedure
            cdfdat(n).end_time = dat.end_time
            cdfdat(n).integ_t = dat.integ_t
            cdfdat(n).geom(0:nenergy-1,0:dat.nbins-1) = dat.geom(retrace:nenergy-1+retrace,0:dat.nbins-1)
            cdfdat(n).denergy(0:nenergy-1,0:dat.nbins-1) = dat.denergy(retrace:nenergy-1+retrace,0:dat.nbins-1)
            cdfdat(n).dtheta(0:dat.nbins-1) = dat.dtheta(0:dat.nbins-1)
            cdfdat(n).dphi(0:dat.nbins-1) = dat.dphi(0:dat.nbins-1)
            cdfdat(n).domega(0:dat.nbins-1) = dat.domega(0:dat.nbins-1)
            cdfdat(n).pt_limits(*) = dat.pt_limits(*)
            cdfdat(n).eff(0:nenergy-1,0:dat.nbins-1) = dat.eff(retrace:nenergy-1+retrace,0:dat.nbins-1)
            cdfdat(n).spin_fract(0:nenergy-1,0:dat.nbins-1) = dat.spin_fract(retrace:nenergy-1+retrace,0:dat.nbins-1)
            cdfdat(n).mass = dat.mass
            cdfdat(n).geomfactor = dat.geomfactor
            cdfdat(n).header_bytes = dat.header_bytes
            cdfdat(n).eff_version = dat.eff_version

         ENDIF

         last_time = cdfdat(n).time
         last_delta_time = cdfdat(n).delta_time 
         n = n + 1

      endif else begin
         print,'Invalid packet, dat.valid ne 1, at: ',time_to_str(dat.time)
      endelse

      dat = call_function(routine,t, /calib, /ad)
      if dat.valid ne 0 then if dat.time gt tmax then dat.valid = 0

   endwhile

   cdfdat = cdfdat(0:n-1)
   time = cdfdat.time

; Get the orbit data

   orbit_file = fa_almanac_dir() + '/orbit/predicted'
   get_fa_orbit, time, /time_array, orbit_file=orbit_file, $
                 /all, status = status
   if status ne 0 then begin
      print, 'get_fa_orbit failed--returned nonzero status = ', status
      return
   endif

   get_data, 'fa_pos', data = fapos
   get_data, 'fa_vel', data = favel
   get_data, 'B_model', data = bmodel
   get_data, 'BFOOT', data = bfoot
   for i=0,2 do begin
      cdfdat(*).fa_pos(i) = fapos.y(*, i)
      cdfdat(*).fa_vel(i) = favel.y(*, i)
      cdfdat(*).b_model(i) = bmodel.y(*, i)
      cdfdat(*).b_foot(i) = bfoot.y(*, i)
   endfor

   get_data, 'ALT', data = tmp
   cdfdat(*).alt = tmp.y(*)
   get_data, 'ILAT', data = tmp
   cdfdat(*).ilat = tmp.y(*)
   get_data, 'MLT', data = tmp
   cdfdat(*).mlt = tmp.y(*)
   get_data, 'ORBIT', data = tmp
   cdfdat(*).orbit = tmp.y(*)
   orbit_num = strcompress(string(tmp.y(0)), /remove_all)
   get_data, 'FLAT', data = tmp
   cdfdat(*).foot_lat = tmp.y(*)
   get_data, 'FLNG', data = tmp
   cdfdat(*).foot_lng = tmp.y(*)

; Get the attitude data
;	to include attitude data, you must also change the line starting "cdfdat0={ ..."
;	to include attitude data, you must also change the line starting "tagsvary=[ ..."

   ;; print, 'Loading the attitude data...'
   ;; get_fa_attitude, time, /time_array, status=status
   ;; if status ne 0 then begin
   ;;    print, 'get_fa_attitude failed--returned nonzero status = ', status
   ;;    return
   ;; endif
   ;; get_data, 'fa_spin_ra',  data=tmp
   ;; cdfdat(*).fa_spin_ra=tmp.y(*)
   ;; get_data, 'fa_spin_dec', data=tmp
   ;; cdfdat(*).fa_spin_dec=tmp.y(*)


   IF KEYWORD_SET(return_struct) THEN BEGIN
      struct = cdfdat
      RETURN
   ENDIF

; Make the cdf file

                                ;makecdf,cdfdat,filename=data_str+'_2d_orbit_'+orbit_num,overwrite=1, $
   makecdf, cdfdat, filename = name, overwrite = 1, $
            ;; tagsvary=['TIME','Delta_time',units,'energy','theta','phi','nenergy','nbins', $
            ;; 'fa_pos','fa_vel','ALT','ILAT','MLT','ORBIT','B_model','B_foot','Foot_LAT','Foot_LNG']
            tagsvary=['TIME','Delta_time',units,'energy','theta','phi','nenergy','nbins', $
                      'fa_pos','fa_vel','ALT','ILAT','MLT','ORBIT','B_model','B_foot','Foot_LAT','Foot_LNG', $
                      'fa_spin_ra','fa_spin_dec']


   print,'   '
   ex_time = systime(1) - ex_start
   message, string(ex_time) + ' seconds execution time.', /cont, /info
   print, 'Number of data points = ', n


   return

end


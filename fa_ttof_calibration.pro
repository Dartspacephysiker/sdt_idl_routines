;+
; FUNCTION:
;	 FA_TTOF_CALIBRATION
;
; DESCRIPTION:
;	 
;	 to calculate the teams Time Of Flight(TOF)
;
; INPUT:
;	energy:	Array (nnrgs, nbins) of energy
;	spec:	0=H+, 1=He++, 2=He+, 3=O+
;	pac:	A number for the calculation of post acceleration voltage
;	time:	Time requested
;
; RETURN:
;	 TOF_EFF(nenergy, pixels, species)
;        version:  version of calibration data.
;
; KEYWORD:
;	debug:	If set, gives a verbose transcript
;
; COMMON BLOCK:
;	tmscal:	Remembers calibration data so we don't have to read the
;		calibration file every time
;
; CREATED BY:
;	     Li Tang,  University of New Hampshire, Space Physics Lab
;
; LAST MODIFICATION:	2003-10-01
;
; MODIFICATION HISTORY:
;	1996-08-14	LT	original version
;	2003-10-06	YC/EJL	added time dependence
;
;- 

function fa_ttof_calibration, energy, spec, pac, version, time, $
	debug = debug

common tmscal, called, sf, pac_a, pac_b, m0, m1, m2, m3, mh0, mh1, cal_data, $
	last_data, cal_time, last_time, eff_version

; set up arrays on first call
if n_elements(called) eq 0 then begin
	called = 1
	sf  = [2, 1, 1]  ;spec factor for energy: sf(0): He++, sf(1): He+, sf(2): O+
	m0 = fltarr(3)
	m1 = fltarr(3)
	m2 = fltarr(3)
	m3 = fltarr(3)
	mh0 = fltarr(16)
	mh1 = fltarr(16)
	cal_data = fltarr(4,16)  
	last_data = fltarr(4,16)
	cal_time = 0.D
	last_time = 0.D
endif
pix_adjus = fltarr(4, 16)
ebin = dimen1(energy)
tof_eff = float(replicate(1.,ebin,16))
   
; set time to launch if needed
if not keyword_set(time) then time = str_to_time('1996-08-21/10:30:00')

; read calibration file if needed
if data_type(time) eq 7 then time = str_to_time(time)
if time lt 8.4e8 then begin
	; We should never get here, but just in case...
	message, 'Requested time is before launch'
	tof_eff(*) = !values.f_nan
	return, tof_eff
endif
if not (time le cal_time and time ge last_time) then begin
	blank_line =''
	cal_timestr = '(A19)'  
 
	; change as needed to match test/released file location
	;openr, 6, '/home/lund/idl_work/fa_tms_calibrationdata'    
	openr,6,getenv('FASTCONFIG')+'/tms_cfg/fa_tms_calibrationdata'
	readf, 6, version, pac_a, pac_b, m0, m1, m2,  m3, mh0, mh1
	print, 'Reading TEAMS calibration file version ', version
	if version gt 2.0 then begin
		readf, 6, blank_line, cal_timestr, cal_data
		cal_time = str_to_time(cal_timestr)  
	endif else begin
		readf, 6, cal_data
		print, 'WARNING--using launch calibration--may be wildly wrong!!!' + string(7B) + string(7B) + string(7B)
	endelse
      
	if keyword_set(debug) then begin
               	print,""
             	print, "Read data from the to_be_calibrated data file"
             	print, " designed by E. Lund"
        	print, "/home/ycao/idl/cao_calibration_test_data"
        	print, "as following ------"
        	print, "   "
		print, "pac_a is:", pac_a	
		print, "pac_b is:", pac_b
		print, "   m0 is:", m0
		print, "   m1 is:", m1
		print, "   m2 is:", m2
		print, "   m3 is:", m3
		print, "  mh0 is:"
		print, mh0
		print, "  mh1 is:"
		print, mh1
		print, ""
		print, "Cal_timestr from the data file above is:   "
		print, "    ", cal_timestr
		print, " "
		print, "cal_data is:"
		print, "   ",cal_data
		print, "  "
               	print, "OK, cal_time is: ", cal_time
       		print, "Time and date given when calling this function is: "
		print, "i.e. timestring (double precision number)"
		print, time
		print, ""
               	print, "Time is:", time
               	print, " Cal_time is:", cal_time
	endif
                
      	while cal_time lt time and version gt 2.0 do begin  	
		if keyword_set(debug) then begin
               		print, "If cal_time less than time then last time is:"
               		print, cal_time
  			print, ""
  			print, "and last data is:"
			print,"", cal_data
			print, ""
		endif
		last_time = cal_time
		last_data = cal_data
			
       		readf, 6, blank_line, cal_timestr, cal_data  
       		cal_time = str_to_time(cal_timestr)   
		if keyword_set(debug) then begin
    			print, "The time and date for the to_be_calibrated data is:"
    			print, cal_time
    			print, ""
			print, "To be calibrated data is:" 
			print, "", cal_data
			print, ""
		endif
       	endwhile
	eff_version = version
	close, 6         ;  OK, here to close file     
endif else begin ; done reading file
	version = eff_version
endelse

if version gt 2.0 then begin
       	pix_adjus = (last_data*cal_time - last_time*cal_data)/  $
                      (cal_time - last_time) + $
       	              time*(cal_data - last_data)/  $
                      (cal_time - last_time)
endif else begin
	pix_adjus = cal_data
	last_data = cal_data
	last_time = 8.4e8
	cal_time = 9.9e9
endelse

if keyword_set(debug) then begin
       	print, "Last_data is:"
       	print, last_data
       	print, ""
       	print, "last_time is:"
       	print, last_time
       	print, ""
	print, "After the interpolation, the Output data: " 
	print, "", output_data
	print, ""
	print, "That is, here Pix_adjus "
	print, "-- but check to see if this is right!"
	print, "", pix_adjus 
	print, "Check the result!! "
	print, ""
endif 

E_pac = pac*pac_a + pac_b
 
if spec gt 0 then begin
	sp = spec - 1
	for en = 0, ebin-1 do begin
		TOF_Energy = energy(en, 0)/1000. + E_pac
       
		Effi_Curve = m0(sp) + m1(sp)*sf(sp)*TOF_Energy		$
				+ m2(sp)*(sf(sp)*TOF_Energy)^2	$
				+ m3(sp)*(sf(sp)*TOF_Energy)^3
		tof_eff(en,*)=Effi_Curve/pix_adjus(spec,*)
       endfor     
endif else begin		; For H+
	for en = 0, ebin-1 do begin
		TOF_Energy = energy(en, 0)/1000. + E_pac
         tof_eff(en, *)=(mh0+ mh1*TOF_Energy)/pix_adjus(0,*)
	endfor
endelse

return, tof_eff

end

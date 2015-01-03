;+
; PROCEDURE: FA_FIELDS_DESPIN_4k, V58, V14, V1458, phase=phase, fudge=fudge,
;     shadow_notch=shadow_notch, mag_notch=mag_notch, store=store, time=time,
;     save_mem=save_mem, spec=spec
;       
;
; PURPOSE: A high level routine which produces despun DC efield
;          data from sdt _4k data in SDT.
;
; INPUT: 
;       V58 -         If blank, program will get V5-V8_4k. 
;       V14 -         If blank, program will get V1-V4_4k
;       V1458 -       If blank, program will get V1+V4-V5-V8_4k
;
; KEYWORDS: 
;       shadow -      Notch out shadow pulses.           DEFAULT = 0
;       mag -         Notch out mag pulses.              DEFAULT = 0
;       store -       Store data as a tplot file.        DEFAULT = 1
;       time -        OPTIONAL. The time range of data.  DEFAULT = /all
;       save_mem -    BLOWS AWAY ARRAYS THAT ARE NO
;                     LONGER NEEDED                      DEFAULT = 0
;                     DEFAULT = 1 if V58, V14, V1458, 
;                     and phase are not given.
;
;       spec -        Will create a FFT spectra.         DEFAULT = 0
;
; CALLING: fa_fields_despin_4k
;       That's easy! Now you can plot E_near_B and E_along_V.
;
; IMPORTANT! SDT SETUP: Need to have: V5-V8_4k, V1-V4_4k, and
;                       V1458_4k, 1032_spinphase, 1032_spinnum, and
;                       1032_magphase.
;
; OUTPUT: Dat is IDL fields time series data structure with multiple
;         components. This  
;
; SIDE EFFECTS: Need lots of memory.
;
; INITIAL VERSION: REE 97-03-25
; MODIFICATION HISTORY: 
; Space Sciences Lab, UCBerkeley
; 
;-
pro fa_fields_despin_4k, V58, V14, V1458, phase=phase, fudge=fudge, $
    shadow_notch=shadow_notch, mag_notch=mag_notch, store=store, $
    time=time, save_mem=save_mem, spec=spec

; Set up constants.
two_pi = 2.d*!dpi
if not keyword_set(V58) AND not keyword_set(V14) AND $
    not keyword_set(V1458) AND not keyword_set(phase) then save_mem=1
if n_elements(time) NE 2 then time=0
 
; First set up V58.
IF not keyword_set(V58) then BEGIN
    if keyword_set(time) then $
        V58 = get_fa_fields('V5-V8_4k',time(0),time(1),/repair) else $
        V58 = get_fa_fields('V5-V8_4k',/all,/rep)
    IF data_type(V58) ne 8 then BEGIN
        message, /info, "Cannot get V5-V8_4k. Check SDT setup."
        return
    ENDIF
ENDIF

; Next set up V14.
IF not keyword_set(V14) then BEGIN
    if keyword_set(time) then $
        V14 = get_fa_fields('V1-V4_4k',time(0),time(1),/repair) else $
        V14 = get_fa_fields('V1-V4_4k',/all,/repair)
    IF data_type(V14) ne 8 then BEGIN
        message, /info, "Cannot get V1-V4_4k. Check SDT setup."
        return
    ENDIF
ENDIF

; Next set up V1458.
IF not keyword_set(V1458) then BEGIN
    if keyword_set(time) then $
      V1458 = $
      get_fa_fields('V1+V4-V5+V8_4k',time(0),time(1),/repair) else $
      V1458 = get_fa_fields('V1+V4-V5+V8_4k',/all,/repair)
    IF data_type(V1458) ne 8 then BEGIN
        message, /info, "Cannot get V1+V4-V5-V8_4k. Check SDT setup."
        return
    ENDIF
ENDIF


; Set up the phase.
IF not keyword_set(phase) then BEGIN
    phase = get_fa_fields('SMPhase_1055',/all)
    phase = fa_fields_phase(phase, freq=0.01)
    IF data_type(phase) ne 8 then BEGIN
        message, /info, "Cannot get 1055 phase. Check SDT setup."
        return
    ENDIF
ENDIF

; SET UP FUDGE FACTOR
if not keyword_set(fudge) then fudge = 0.4209d

;
; Begin the combine process. Do not add to structure. Save some space.
; 
time_offset = 9.1552734e-05 < (v14.time(0) - v58.time(0))

; Combine V14
fa_fields_combine,V58,V14,result=v14_dat, time_offset=time_offset
if keyword_set(save_mem) then V14 = 0

; Combine V1458
fa_fields_combine,V58,V1458,result=v158_dat, time_offset=time_offset 
if keyword_set(save_mem) then V1458 = 0
V158_dat = (v14_dat + v158_dat) * fudge
if keyword_set(save_mem) then V14_dat = 0

; Check to see if phases are needed.
fa_fields_combine, V58, phase, result=Bphase, /interp, delt=1000.

if keyword_set(shadow_notch) then fa_fields_combine, $
    V58, phase, tag_2='comp2', result=Sphase, /interp, delt=1000.

; Save some space
start_time = v58.start_time
time = v58.time-start_time
v58_dat = v58.comp1
npts=v58.npts
if keyword_set(save_mem) then v58 = 0

; We now have time, V58_dat, V158_dat, Bphase, and Sphase
; Notch the data
if keyword_set(mag_notch) then $
    notch58 = ff_notch('V58',V58_dat,Bphase=Bphase,/Binterp)
if keyword_set(mag_notch) then $
    notch158 = ff_notch('V158',V158_dat,Bphase=Bphase,/Binterp)
if keyword_set(shadow_notch) then $
    notch58 = ff_notch('V58',V58_dat,Sphase=Sphase,/Snan)
if keyword_set(shadow_notch) then $
    notch158 = ff_notch('V158',V158_dat,Sphase=Sphase,/Snan)
notch58 = 0
notch158 = 0

;
; DO THE DESPIN
;

dphi = 2.d*!dpi*52.d/360.d
e1 = -v58_dat*cos(Bphase-dphi) - v158_dat*sin(Bphase-dphi)
e2 = -v58_dat*sin(Bphase-dphi) + v158_dat*cos(Bphase-dphi)

; STORE THE DATA IN TPLOT FORMAT
data = {x:time+start_time, y:e1}
store_data,'E_NEAR_B_4k', data=data
dlimit = {spec:0, ystyle:1, yrange:[-1000.,1000.],  $
          ytitle:'E NEAR B!C!C(mV/m)',$
          panel_size:3}
store_data,'E_NEAR_B_4k', dlimit=dlimit

data = {x:time+start_time, y:e2}
store_data,'E_ALONG_V_4k', data=data
dlimit = {spec:0, ystyle:1, yrange:[-1000.,1000.],  $
          ytitle:'E ALONG V!C!C(mV/m)',$
          panel_size:3}
store_data,'E_ALONG_V_4k', dlimit=dlimit

tplot,['E_NEAR_B_4k','E_ALONG_V_4k']


; 
; OPTIONAL SPECTRA SECTION
;
if not keyword_set(spec) then return

;
; FIRST PARALLEL COMPONENT
;

e4k = {time: time+start_time, units_name: 'mV/m', comp1: e1, valid: 1l,$
        data_name: 'Eparl', project_name: 'FAST', calibrated: 1l}

result = fa_fields_fft(e4k, nave=nave, slide=slide, npts=nfft)

data   = {x:result.time, y:alog10(result.comp1), v:result.yaxis}
store_data,'VLF_EPAR_4k', data=data

options,'VLF_EPAR_4k','spec',1
options,'VLF_EPAR_4k','panel_size',5
options,'VLF_EPAR_4k','ystyle',1
options,'VLF_EPAR_4k','ylog',1
options,'VLF_EPAR_4k','yrange',[0.008, 4.0]
options,'VLF_EPAR_4k','ytitle','LF EnearB!C!C(kHz)'
options,'VLF_EPAR_4k','zstyle',1
options,'VLF_EPAR_4k','zrange',[-12,-2]
options,'VLF_EPAR_4k','ztitle','Log (V/m)!U2!N/Hz'
options,'VLF_EPAR_4k','y_no_interp',1
options,'VLF_EPAR_4k','x_no_interp',1


store_data,'VLF_EPAR_4k_FCH',data=['VLF_EPAR_4k','FCH']
options,'VLF_EPAR_4k_FCH','panel_size',5

;
; NEXT PERP COMPONENT
;

e4k = {time: time+start_time, units_name: 'mV/m', comp1: e2, valid: 1l,$
        data_name: 'Eperp', project_name: 'FAST', calibrated: 1l}

result = fa_fields_fft(e4k, nave=nave, slide=slide, npts=nfft)

data   = {x:result.time, y:alog10(result.comp1), v:result.yaxis}
store_data,'VLF_EPERP_4k', data=data

options,'VLF_EPERP_4k','spec',1
options,'VLF_EPERP_4k','panel_size',5
options,'VLF_EPERP_4k','ystyle',1
options,'VLF_EPERP_4k','ylog',1
options,'VLF_EPERP_4k','yrange',[0.008, 4.0]
options,'VLF_EPERP_4k','ytitle','LF Eperp!C!C(kHz)'
options,'VLF_EPERP_4k','zstyle',1
options,'VLF_EPERP_4k','zrange',[-12,-2]
options,'VLF_EPERP_4k','ztitle','Log (V/m)!U2!N/Hz'
options,'VLF_EPERP_4k','y_no_interp',1
options,'VLF_EPERP_4k','x_no_interp',1


store_data,'VLF_EPERP_4k_FCH',data=['VLF_EPERP_4k','FCH']
options,'VLF_EPERP_4k_FCH','panel_size',5


tplot, ['VLF_EPAR_4k_FCH','VLF_EPERP_4k_FCH']
return
end

;+
; PROCEDURE: FA_FIELDS_DESPIN_16k, V58, V14, V1458, phase=phase, fudge=fudge,
;     shadow_notch=shadow_notch, mag_notch=mag_notch, store=store,
;     save_mem=save_mem, t1=t1, t2=t2, nave=nave, slide=slide, nfft=nfft,
;     spec=spec
;       
;
; PURPOSE: A high level routine which produces despun DC efield
;          data from sdt _16k data in SDT.
;
; INPUT: 
;       V58 -         If not set, program will get V5-V8_16k. 
;       V14 -         If not set, program will get V1-V4_16k
;       V1458 -       If not set, program will get V1+V4-V5-V8_16k
;
; KEYWORDS: 
;       t1 -          Optional start time.
;       t2 -          Optional end time.
;       shadow -      Notch out shadow pulses.           DEFAULT = 0
;       mag -         Notch out mag pulses.              DEFAULT = 0
;       store -       Store data as a tplot file.        DEFAULT = 1
;       time -        OPTIONAL. The time range of data.  DEFAULT = /all
;       save_mem -    BLOWS AWAY ARRAYS THAT ARE NO
;                     LONGER NEEDED                      DEFAULT = 0
;                     DEFAULT = 1 if V58, V14, V1458, 
;                       and phase are not given.
;       spec -        Will create a FFT spectra.         DEFAULT = 0
;       nave -        FFT spectra.        		 DEFAULT = 4
;       slide -       FFT spectra.        		 DEFAULT = 0.5
;       nfft -        FFT spectra.        		 DEFAULT = 1024
;
; CALLING: fa_fields_despin_16k
;       That's easy! Now you can plot E_near_B and E_along_V.
;
; IMPORTANT! SDT SETUP: Need to have: V5-V8_16k, V1-V4_16k, and
;                       V1458_16k, 1048_spinphase, 1048_spinnum, and
;                       1048_magphase.
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
pro fa_fields_despin_16k, V58, V14, V1458, phase=phase, fudge=fudge, $
    shadow_notch=shadow_notch, mag_notch=mag_notch, store=store, $
    t1=t1, t2=t2, save_mem=save_mem, nave=nave, slide=slide, nfft=nfft, $
    spec=spec

; Set up constants.
two_pi = 2.d*!dpi
if not keyword_set(V58) AND not keyword_set(V14) AND $
    not keyword_set(V1458) AND not keyword_set(phase) then save_mem=1
if n_elements(time) NE 2 then time=0
 
; First set up V58.
IF not keyword_set(V58) then BEGIN
    V58 = get_fa_fields('V5-V8_16k',t1,t2,/repair)
    IF V58.valid ne 1 then BEGIN
        message, /info, "Cannot get V5-V8_16k. Check SDT setup."
        return
    ENDIF
ENDIF

; Next set up V14.
IF not keyword_set(V14) then BEGIN
    V14 = get_fa_fields('V1-V4_16k',t1,t2,/repair)
    IF V14.valid ne 1 then BEGIN
        message, /info, "Cannot get V1-V4_16k. Check SDT setup."
        return
    ENDIF
ENDIF

; Next set up V1458.
IF not keyword_set(V1458) then BEGIN
    V1458 = get_fa_fields('V1+V4-V5+V8_16k',t1,t2,/repair)
    IF V1458.valid ne 1 then BEGIN
        message, /info, "Cannot get V1+V4-V5-V8_16k. Check SDT setup."
        return
    ENDIF
ENDIF


; Set up the phase.
IF not keyword_set(phase) then BEGIN
    phase = get_fa_fields('SMPhase_1048',/all)
    phase = fa_fields_phase(phase, freq=0.01)
    IF phase.valid ne 1 then BEGIN
        message, /info, "Cannot get 1048 phase. Check SDT setup."
        return
    ENDIF
ENDIF

; SET UP FUDGE FACTOR
if not keyword_set(fudge) then fudge = 0.4209d

;
; Begin the combine process. Do not add to structure. Save some space.
; 
time_offset = 0.0d

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
store_data,'E_NEAR_B_16k', data=data
dlimit = {spec:0, ystyle:1, yrange:[-2000.,2000.],  $
          ytitle:'E NEAR B!C!C(mV/m)',$
          panel_size:3}
store_data,'E_NEAR_B_16k', dlimit=dlimit
options,'E_NEAR_B_16k','yticks',4
options,'E_NEAR_B_16k','ytickname',['-2000','-1000','0','1000','2000']
options,'E_NEAR_B_16k','ytickv',[-2000, -1000, 0, 1000, 2000]


data = {x:time+start_time, y:e2}
store_data,'E_ALONG_V_16k', data=data
dlimit = {spec:0, ystyle:1, yrange:[-2000.,2000.],  $
          ytitle:'E PERP-SP!C!C(mV/m)',$
          panel_size:3}
store_data,'E_ALONG_V_16k', dlimit=dlimit
options,'E_ALONG_V_16k','yticks',4
options,'E_ALONG_V_16k','ytickname',['-2000','-1000','0','1000','2000']
options,'E_ALONG_V_16k','ytickv',[-2000, -1000, 0, 1000, 2000]


tplot,['E_NEAR_B_16k','E_ALONG_V_16k']

; 
; OPTIONAL SPECTRA SECTION
;
if not keyword_set(spec) then return

;
; SPEC - FIRST PARALLEL COMPONENT
;

e16k = {time: time+start_time, units_name: 'mV/m', comp1: e1, valid: 1l,$
        data_name: 'Eparl', project_name: 'FAST', calibrated: 1l}

result = fa_fields_fft(e16k, nave=nave, slide=slide, npts=nfft)

data   = {x:result.time, y:alog10(result.comp1), v:result.yaxis}
store_data,'VLF_EPAR', data=data

options,'VLF_EPAR','spec',1
options,'VLF_EPAR','panel_size',5
options,'VLF_EPAR','ystyle',1
options,'VLF_EPAR','ylog',1
options,'VLF_EPAR','yrange',[0.032, 16.0]
options,'VLF_EPAR','ytitle','VLF Epar!C!C(kHz)'
options,'VLF_EPAR','zstyle',1
options,'VLF_EPAR','zrange',[-14,-4]
options,'VLF_EPAR','ztitle','Log (V/m)!U2!N/Hz'
options,'VLF_EPAR','y_no_interp',1
options,'VLF_EPAR','x_no_interp',1
options,'VLF_EPAR','yticks',2
options,'VLF_EPAR','ytickname',['0.1','1.0','10.0']
options,'VLF_EPAR','ytickv',[0.1,1.0,10.0]


store_data,'VLF_EPAR_FCH',data=['VLF_EPAR','FCH']
options,'VLF_EPAR_FCH','panel_size',6

;
; NEXT PERP COMPONENT
;

e16k = {time: time+start_time, units_name: 'mV/m', comp1: e2, valid: 1l,$
        data_name: 'Eperp', project_name: 'FAST', calibrated: 1l}

result = fa_fields_fft(e16k, nave=nave, slide=slide, npts=nfft)

data   = {x:result.time, y:alog10(result.comp1), v:result.yaxis}
store_data,'VLF_EPERP', data=data

options,'VLF_EPERP','spec',1
options,'VLF_EPERP','panel_size',5
options,'VLF_EPERP','ystyle',1
options,'VLF_EPERP','ylog',1
options,'VLF_EPERP','yrange',[0.032, 16.0]
options,'VLF_EPERP','ytitle','VLF Eperp!C!C(kHz)'
options,'VLF_EPERP','zstyle',1
options,'VLF_EPERP','zrange',[-14,-4]
options,'VLF_EPERP','ztitle','Log (V/m)!U2!N/Hz'
options,'VLF_EPERP','y_no_interp',1
options,'VLF_EPERP','x_no_interp',1
options,'VLF_EPERP','yticks',2
options,'VLF_EPERP','ytickname',['0.1','1.0','10.0']
options,'VLF_EPERP','ytickv',[0.1,1.0,10.0]


store_data,'VLF_EPERP_FCH',data=['VLF_EPERP','FCH']
options,'VLF_EPERP_FCH','panel_size',6


tplot, ['VLF_EPAR_FCH','VLF_EPERP_FCH']

return
end

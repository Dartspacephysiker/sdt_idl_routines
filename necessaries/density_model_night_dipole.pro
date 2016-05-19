;;2016/05/15
;;Here are the variables that differ between dayside and nightside
;;Night
;;  nh=1000.0
;;  no_FF=8.0e4
;;  scale_upper_h=70.0
;;  scale_upper_o_e=70.0
;;  scale_upper_o_f=70.0
;;  n_out_o=6000.0
;;  scale_upper_out_o=400.

;;day
;;  nh=2000.0
;;  no_FF=1.0e5
;;  scale_upper_h=140.0
;;  scale_upper_o_e=140.0
;;  scale_upper_o_f=210.0
;;  n_out_o=4000.0
;;  scale_upper_out_o=600.

function density_model_night_dipole,r
;used this function for dayside density profile using Chapman profiles

Re=6370.0;km
altitude=r;(r-Re)
nh=1000.0
no_E=1.0e4
no_FF=8.0e4
E_alt=110.0
F_alt=200.0
scale_lower_h=30.0
scale_upper_h=70.0

scale_lower_o_e=5.0
scale_upper_o_e=70.0

scale_lower_o_f=10.0
scale_upper_o_f=70.0

scale_lower_ps=20000.0
scale_upper_ps=20000.0

power_law_h=-2.0
power_law_o=-2.0
power_law_ps=-2

n_out_h=1000.0
out_alt_h=500.0
scale_lower_out_h=1000.
scale_upper_out_h=800.

n_out_o=6000.0
out_alt_o=500.0
scale_lower_out_o=1000.
scale_upper_out_o=400.


cluster_alt=5.4*Re
nh_f=1.0

;HYDROGEN
    ;Hydrogen ionospheric
    if altitude GE F_alt then begin
       nh_ionos=nh*exp(1-abs(altitude-F_alt)/scale_upper_h-exp(-abs(altitude-F_alt)/scale_upper_h))
    endif else begin
       nh_ionos=nh*exp(1-abs(altitude-F_alt)/scale_lower_h-exp(-abs(altitude-F_alt)/scale_lower_h))
    endelse

    ;hydrogen outflow

    if altitude GE out_alt_h then begin
       nh_ionos_out=n_out_h*exp(1-abs(altitude-out_alt_h)/scale_upper_out_h-exp(-abs(altitude-out_alt_h)/scale_upper_out_h))
    endif else begin
       nh_ionos_out=n_out_h*exp(1-abs(altitude-out_alt_h)/scale_lower_out_h-exp(-abs(altitude-out_alt_h)/scale_lower_out_h))
    endelse


    nh_ionos=nh_ionos+nh_ionos_out

    ;hydrogen plasmasheet
    ;nh_ps=1.0*tanh((altitude-100.)/(2.*6371.2))
    ;if r GE sp_r-6370.0 then nh_ps=nh_f*(r/sp_r)^power_law_ps else nh_ps=nh_f*((sp_r-6370.0)/sp_r)^(power_law_ps)
   ; if altitude GE cluster_alt then begin
    ;   nh_ps=nh_f*exp(1-abs(altitude-cluster_alt)/scale_upper_ps-exp(-abs(altitude-cluster_alt)/scale_upper_ps))
    ;endif else begin
    ;   nh_ps=nh_f*exp(1-abs(altitude-cluster_alt)/scale_lower_ps-exp(-abs(altitude-cluster_alt)/scale_lower_ps))
    ;endelse
    nh_ps=1.0

    ;OXYGEN
    ;E-region
    if altitude GE E_alt then begin
       no_ionos=no_E*exp(1-abs(altitude-E_alt)/scale_upper_o_e-exp(-abs(altitude-E_alt)/scale_upper_o_e))
    endif else begin
       no_ionos=no_E*exp(1-abs(altitude-E_alt)/scale_lower_o_e-exp(-abs(altitude-E_alt)/scale_lower_o_e))
    endelse
    ;print,no_ionos
    ;F-region
       if altitude GE F_alt then begin
       no_ionos=no_ionos+no_FF*exp(1-abs(altitude-F_alt)/scale_upper_o_f-exp(-abs(altitude-F_alt)/scale_upper_o_f))

    endif else begin
       no_ionos=no_ionos+no_FF*exp(1-abs(altitude-F_alt)/scale_lower_o_f-exp(-abs(altitude-F_alt)/scale_lower_o_f))
    endelse

    ;ionospheric ooutflow
    if altitude GE out_alt_o then begin
       no_ionos_out=n_out_o*exp(1-abs(altitude-out_alt_o)/scale_upper_out_o-exp(-abs(altitude-out_alt_o)/scale_upper_out_o))
    endif else begin
       no_ionos_out=n_out_o*exp(1-abs(altitude-out_alt_o)/scale_lower_out_o-exp(-abs(altitude-out_alt_o)/scale_lower_out_o))
    endelse
no_ionos=no_ionos_out+no_ionos


return,[no_ionos,nh_ps,nh_ionos]
end

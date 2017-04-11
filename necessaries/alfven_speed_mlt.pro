function alfven_speed_mlt,alt,mlt, $
                          HPLASMAF=hplasmaf, $
                          OPLASMAF=oplasmaf, $
                          HCYCF=hcycf, $
                          OCYCF=ocycf


c=3.0e5
me=9.1e-31;     electron mass in kg
mp=1.67e-27;        proton mass in kg
mox=16.*1.67e-27
qe=1.6e-19;     electron charge in C
qp=1.6e-19;




density_func_night='density_model_night_dipole'
density_func_day='density_model_day_dipole'
    dheight=call_function(density_func_night,alt)
    bheight=dipolefield(alt*1000.0)
    hplasmaf=sqrt((total(dheight(1:2))*1.0e6*(1.0*qe)^2)/(8.85e-12*1.0*mp))
    oplasmaf=sqrt((dheight(0)*1.0e6*(1.0*qe)^2)/(8.85e-12*16.0*mp))
    hcycf=(1.0*qe*bheight)/(1.0*mp)
    ocycf=(1.0*qe*bheight)/(16.0*mp)
    va=c*1./sqrt((hplasmaf/hcycf)^2+(oplasmaf/ocycf)^2)
    va_km_per_sec_night=va/sqrt(1+va^2/c^2)

    dheight=call_function(density_func_day,alt)
    hplasmaf=sqrt((total(dheight(1:2))*1.0e6*(1.0*qe)^2)/(8.85e-12*1.0*mp))
    oplasmaf=sqrt((dheight(0)*1.0e6*(1.0*qe)^2)/(8.85e-12*16.0*mp))
    hcycf=(1.0*qe*bheight)/(1.0*mp)
    ocycf=(1.0*qe*bheight)/(16.0*mp)
    va=c*1./sqrt((hplasmaf/hcycf)^2+(oplasmaf/ocycf)^2)
    va_km_per_sec_day=va/sqrt(1+va^2/c^2)

    va_mlt=va_km_per_sec_night*abs(mlt-12.)/12.+va_km_per_sec_day*(1.-abs(mlt-12.)/12.)


return,va_mlt
end
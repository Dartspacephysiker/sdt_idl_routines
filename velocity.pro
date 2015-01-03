function velocity,nrg,mass,true_veloc=tv,momen_on_mass=mom,electron=el

c2 = 2.99792d5^2

if keyword_set(el) then mass= 511000.d/c2

E0 = mass*c2

if keyword_set(tv) then begin
   gamma = (nrg+e0)/e0   
   vmag  = sqrt((1.-1./gamma^2)*c2)
   return,vmag
endif
if 1 then begin    ;  momentum over mass
   vmag = sqrt(2*nrg/mass * (1 +nrg/e0))
   return ,vmag
endif
end




  

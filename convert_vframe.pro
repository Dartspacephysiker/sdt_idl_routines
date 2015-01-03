;+
;NAME:	
;	transform_velocity
;
;PROCEDURE:   transform_velocity,  vel, theta, phi,  deltav
;PURPOSE:  used by the convert_vframe routine to transform arrays of velocity
;    thetas and phis by the offset deltav
;INPUT:
;  vel:  array of velocities
;  theta: array of theta values
;  phi:   array of phi values
;  deltav: [vx,vy,vz]  (transformation velocity)
;KEYWORDS:
;	vx,vy,vz:	return vx,vy,vz separately as well as in vector form
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)convert_vframe.pro	1.12 97/01/16
;-
pro transform_velocity, vel,theta,phi,deltav, $
   VX=vx,VY=vy,VZ=vz,sx=sx,sy=sy,sz=sz

c = cos(!dpi/180.*theta)
sx = c * cos(!dpi/180.*phi)
sy = c * sin(!dpi/180.*phi)
sz = sin(!dpi/180.*theta)

vx = (vel*sx) - deltav(0)
vy = (vel*sy) - deltav(1)
vz = (vel*sz) - deltav(2)

vxxyy = vx*vx + vy*vy
vel = sqrt(vxxyy + vz*vz)
phi = 180./!dpi*atan(vy,vx)
theta = 180./!dpi*atan(vz/sqrt(vxxyy))

return
end



;+
;NAME:	
;	convert_vframe
;
;FUNCTION:  convert_vframe ,  dat,  velocity
;PURPOSE:   Change velocity frames 
;INPUT: 
;  dat: 3d data structure
;  velocity: SW velocity vector  [VX,VY,VZ]
;OUTPUT:  3d data structure.  Data will be in a different coordinate frame.
;    (data will also be in units of distrubution function.)
;KEYWORDS:
;   ETHRESH:  Threshold energy for interpolation.
;   BINS:     Angle bins to be used
;   EVALUES:
;   INTERPOLATE:  set to non-zero value to have the data evaluated 
;   (interpolated) at the original energy steps.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)convert_vframe.pro	1.12 97/01/16
;-

function  convert_vframe,tdata,vframe  $
  ,EVALUES = evalues $
  ,INTERPOLATE = interp,EXTRAPOLATE = extrapolate $
  ,ethresh=ethresh,dfdv=dfdv,bins=bins

if tdata.valid eq 0 then  begin
   print,'Invalid Data' 
   return,tdata
endif

data = conv_units(tdata,'df')
o_data= data.data
o_energy = data.energy

if n_params() lt 2 then vframe = data.vsw
sc_pot = 0.
str_element,data,'sc_pot',value = sc_pot

energy = data.energy - sc_pot
vel = velocity(energy,data.mass)
theta = data.theta
phi = data.phi

if keyword_set(ethresh) and keyword_set(dfdv) eq 0 then begin
   if keyword_set(bins) then ind = where(bins) else ind = indgen(data.nbins)
   dfavg = total(o_data(*,ind),2,/nan)/total(finite(o_data(*,ind)),2)
   vavg = total(vel(*,ind),2,/nan)/total(finite(vel(*,ind)),2)
   dfdv = deriv(vavg,alog(dfavg))
endif


transform_velocity,vel,theta,phi,vframe,sx=sx,sy=sy,sz=sz
data.energy = .5*data.mass*vel*vel
data.theta = theta
data.phi = phi
add_str_element,data,'vframe',vframe

if keyword_set(interp) or keyword_set(evalues) then begin
   if ndimen(evalues) ne 1 then $
      evalues = total(data.energy,2)/data.nbins
   range = minmax_range(data.data,/POS)
   for i=0,data.nbins-1 do begin
      temp = data.data(*,i)
      nrg = data.energy(*,i)
      w = where(finite(temp) eq 0,count)
      if count ne 0 then temp(w) = 0
      ind = where(temp gt 0,count)
      
      if count gt 1 then $
          temp = interpol(alog(temp(ind)),nrg(ind),evalues)
      if not keyword_set(extrapolate) then begin
         w = where(evalues lt min(nrg),count)
         if count ne 0 then temp(w) = !values.f_nan
      endif
      data.data(*,i) = exp(temp)
   endfor
   data.energy = evalues # replicate(1.,data.nbins)
   if keyword_set(Ethresh)  then begin
      ind = where(tdata.energy gt ethresh)
      bdfdv = dfdv # replicate(1.,data.nbins)
      o_data = o_data*(1.+(sx*vframe(0)+sy*vframe(1)+sz*vframe(2))*bdfdv )
      data.data(ind) = o_data(ind)
   endif
endif

return,data
end


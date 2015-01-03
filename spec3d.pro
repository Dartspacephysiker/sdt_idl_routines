	
;+
;PROCEDURE: spec3d,data
;   Plots 3d data as energy spectra.
;INPUTS:
;   data   - structure containing 3d data  (obtained from get_??() routine)
;		e.g. "get_el"
;KEYWORDS:
;   LIMITS - A structure containing limits and display options.
;             see: "options", "xlim" and "ylim", to change limits
;   UNITS  - convert to given data units before plotting
;   COLOR  - array of colors to be used for each bin
;   BINS   - array of bins to be plotted  (see "edit3dbins" to change)
;   OVERPLOT  - Overplots last plot if set.
;   LABEL  - Puts bin labels on the plot if set.
;
;See "plot3d" for another means of plotting data.
;See "conv_units" to change units.
;See "time_stamp" to turn time stamping on and off.
;
;
;CREATED BY:	Davin Larson  June 1995
;FILE:  spec3d.pro
;VERSION 1.21
;LAST MODIFICATION: 97/01/26
;-
pro spec3d,tempdat,   $
  LIMITS = limits, $
  UNITS = units,   $         ; obsolete.  Use units function 
  COLOR = col,     $
  BDIR = bdir,     $
  PHI = phi,       $
  THETA = theta,   $
  PITCHANGLE = pang,   $
  VECTOR = vec,    $
  SUNDIR = sundir, $
  LABEL = label,   $
  BINS = bins,     $
  VELOCITY = vel, $
  OVERPLOT = oplot
;@wind_com.pro

if data_type(tempdat) ne 8 or tempdat.valid eq 0 then begin
  print,'Invalid Data'
  return
endif

str_element,limits,'pitchangle',value=pang
str_element,limits,'sundir',value=sundir
str_element,limits,'thetadir',value=theta


str_element,limits,'units',value=units
data3d = conv_units(tempdat,units)

str_element,limits,'color',value=col

nb = data3d.nbins

title = data3d.project_name+'  '+data3d.data_name
title = title+'!C'+trange_str(data3d.time,data3d.end_time)

ytitle = data3d.units_name

ydat = data3d.data

str_element,limits,'velocity',value=vel
if keyword_set(vel) then begin
   xdat = velocity(data3d.energy,data3d.mass)
   xtitle = "Velocity'  (km/s)"
;help,xdat
;print,minmax_range(xdat)
endif else begin
   xdat = data3d.energy
   xtitle = 'Energy  (eV)'
endelse

;print,minmax_range(xdat)

if n_elements(bins) ne 0 then begin
   i = where(bins,count)
   ydat = ydat(*,i)
   xdat = xdat(*,i)
endif else  i = indgen(data3d.nbins)

if keyword_set(phi) then begin
   phi = reform(data3d.phi(0,*))
   col = bytescale(phi,range=[-180.,180.])
endif 

if keyword_set(theta) then begin
   theta = reform(data3d.theta(0,*))  ; average theta
   col = bytescale(theta,range=[-90.,90.])
endif

if keyword_set(pang) then str_element,data3d,'magf',value=vec
if keyword_set(sundir) then vec = [-1.,0.,0.]

if keyword_set(vec)  then begin
   phi = total(data3d.phi,1)/data3d.nenergy   ; average phi
   theta = total(data3d.theta,1)/data3d.nenergy  ; average theta
   xyz_to_polar,vec,theta=bth,phi=bph
   p = pangle(theta,phi,bth,bph)
   col = bytescale(180.-p,range=[0.,180.])   
endif


if keyword_set(col) then shades  = col(i)
if keyword_set(label) then labels = strcompress(i)



plot={title:title, $
     xtitle:xtitle,x:xdat,xlog:1, $
     ytitle:ytitle,y:ydat,ylog:1  }

str_element,data3d,'ddata',value =ddata
if keyword_set(ddata) then $
     add_str_element,plot,'dy',data3d.ddata(*,i)

wi,lim=limits

mplot,data=plot,COLORS=shades,limits=limits,LABELS=labels,OVERPLOT=oplot

time_stamp

end

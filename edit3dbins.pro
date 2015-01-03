;+
;PROCEDURE:  edit3dbins,dat,bins
;PURPOSE:   Interactive procedure to produce a bin array for selectively 
;    turning angle bins on and off.  Works on a 3d structure (see 
;    "3D_STRUCTURE" for more info)
;
;INPUT:
;   dat:  3d data structure.  (will not be altered)
;   bins:  a named variable in which to return the results.
;KEYWORDS:
;   EBINS:     Specifies energy bins to plot.
;   SUM_EBINS: Specifies how many bins to sum, starting with EBINS.  If
;              SUM_EBINS is a scaler, that number of bins is summed for
;              each bin in EBINS.  If SUM_EBINS is an array, then each
;              array element will hold the number of bins to sum starting
;              at each bin in EBINS.  In the array case, EBINS and SUM_EBINS
;              must have the same number of elements.
;SEE ALSO:  "PLOT3D" and "PLOT3D_OPTIONS"
;CREATED BY:	Davin Larson
;FILE: edit3dbins.pro
;VERSION:  1.11
;LAST MODIFICATION: 96/02/16
;-
pro edit3dbins,dat,bins,lat,lon, $
  EBINS=ebins,           $
;  SPEC_WINDOW=spwindow,  $
  SUM_EBINS=sum_ebins

if(dat.valid eq 0) then begin
  print,'Invalid data'
  return
endif

nb = dat.nbins
n_e= dat.nenergy
phi = total(dat.phi,1)/n_e
theta = total(dat.theta,1)/n_e

;  Convert from flow direction to look direction
;phi = phi-180.
;theta =  - theta

if keyword_set(ebins) then ebins=ebins(0)  $
else ebins=0

if keyword_set(sum_ebins) then sum_ebins=sum_ebins(0) $
else sum_ebins=dat.nenergy

plot3d,dat,lat,lon,ebins=ebins,sum_ebins=sum_ebins

state = ['off','on']
colorcode = [!p.background,!p.color]

if n_elements(bins) ne dat.nbins then bins = bytarr(nb)+1
lab=strcompress(indgen(dat.nbins),/rem)
xyouts,phi,theta,lab,align=.5,COLOR=colorcode(bins)

print, 'ON: Button1;    OFF: Button2;   QUIT: Button3'
cursor,ph,th
button = !err
while button ne 4 do begin
  if th ge 1000. then goto, ctnu
  pa = pangle(theta,phi,th,ph)
  minpa = min(pa,b)
  current = bins(b)
  if button eq 1 then bins(b)=1 else bins(b)=0
  if current ne bins(b) then begin
    print,ph,th,b,'  ',state(bins(b))
    xyouts,phi(b),theta(b),lab(b),align=.5,COLOR=colorcode(bins(b))
;    if n_elements(spwindow) then begin
;       w = !d.window
;       wi,spwindow
;       spec3d,dat,bins=bins,lim=spec_lim
;       wi,w
;    endif
  endif
ctnu:
  cursor,ph,th
  button = !err
endwhile

return
end



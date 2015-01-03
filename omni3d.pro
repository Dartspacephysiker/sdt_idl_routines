;+
;FUNCTION:  omni3d
;PURPOSE:  produces an omnidirectional spectrum structure by summing
; over the non-zero bins in the keyword bins.
; this structure can be plotted with "spec3d"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)omni3d.pro	1.9 96/04/17
;
; WARNING:  This is a very crude structure; use at your own risk.
;-

function omni3d,dat,  $
   bins=bins            ;not finished !!!
units = dat.units_name
if data_type(dat) ne 8 then return,0
if dat.valid eq 0 then return,{valid:0}
tags = ['project_name','data_name','valid','units_name','units_procedure',  $
  'time','end_time', 'integ_t',  'nbins','nenergy',  $
    'mass', 'eff','geomfactor']
extract_tags,omni,dat,tags=tags
if keyword_set(bins) eq 0 then bins = replicate(1b,dat.nbins)
ind = where(bins,count)
if count eq 0 then return,omni

omni.nbins = 1

if units eq 'Counts' then norm =1 else norm = count

str_element,dat,'feff',value=feff
if n_elements(feff) ne 0 then $
   add_str_element,omni, 'feff',total(dat.feff(*,ind),2)/count

add_str_element,omni, 'denergy',total(dat.denergy(*,ind),2)/count
add_str_element,omni, 'data'   ,total(dat.data(*,ind),2)/norm
add_str_element,omni, 'energy' ,total(dat.energy(*,ind),2)/count
add_str_element,omni, 'geom'   ,total(dat.geom(ind))
add_str_element,omni, 'domega' ,total(dat.domega(ind))

str_element,dat,'ddata',value=ddata
if n_elements(ddata) ne 0 then $
   add_str_element,omni,'ddata', sqrt(total(ddata(*,ind)^2,2))/norm


;if units eq 'Counts' then $
;  add_str_element,omni, 'ddata'  ,sqrt(omni.data > .7)/norm

omni.nbins = 1

return,omni
end


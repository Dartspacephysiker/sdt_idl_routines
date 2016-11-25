PRO timebar,t1,color=color,linestyle=linestyle,thick=thick,quiet=quiet
;+
;NAME:                  timebar
;PURPOSE:               
;                       plot vertical lines on tplots at specified times
;CALLING SEQUENCE:      timebar,t
;INPUTS:                t: dblarr of times at which to draw vertical lines,
;				seconds since Jan, 1, 1970.
;KEYWORD PARAMETERS:    
;			COLOR:  byte or bytarr of color values
;			LINESTYLE:  int or intarr of linestyles
;			THICK: int or intarr of line thicknesses
;		for any of the keywords, a scalar input will apply to all times
;OUTPUTS:               
;OPTIONAL OUTPUTS:      
;COMMON BLOCKS:         tplot_com
;EXAMPLE:               load_3dp_data,'95-01-01',2 & get_pmom
;			tplot,['Np','Tp','Vp']
;			t=str_to_time('95-01-01/1:12')
;			timebar,t ;put a white line at 1:12 am, Jan, 1, 1995
;			ctime,t1,t2 ;select two times from the plot
;			timebar,[t1,t2],color=!d.n_colors-2 ;plot them in red
;SEE ALSO:
;  "CTIME","TPLOT"
;CREATED BY:            Frank V. Marcoline
;Modified by: Davin Larson
;LAST MODIFICATION:     98/10/01 
;FILE:                  1.4 
;VERSION:               timebar.pro
;-
@tplot_com
  t = time_double(t1)
  nt = n_elements(t)
  if not keyword_set(color) then begin 
    if !p.background eq 0 then color = !d.n_colors-1 else color = 0
  endif 
  if n_elements(color) ne nt then color = make_array(nt,value=color)
  if not keyword_set(linestyle) then linestyle = 0
  if n_elements(linestyle) ne nt then linestyle = make_array(nt,value=linestyle)
  if not keyword_set(thick) then thick = 1
  if n_elements(thick) ne nt then thick = make_array(nt,value=thick)

  if !d.name eq 'X' then begin
    current_window= !d.window > 0
    wset,tplot_window
;    wshow,icon=0
  endif
  xp = tplot_x.window
  xr = tplot_x.crange
  nd = n_elements(tplot_y)
  nt = n_elements(t)
  yp = fltarr(2)
  yp(0) = tplot_y(nd-1).window(0)
  yp(1) = tplot_y(0).window(1)
  for i=0,nt-1 do begin 
    tp = t(i) - time_offset
    tp = xp(0) + (tp-xr(0))/(xr(1)-xr(0)) * (xp(1)-xp(0))
    if tp ge xp(0) and tp le xp(1) then begin 
      plots,[tp,tp],yp,color=color(i),linestyle=linestyle(i),thick=thick(i),/normal
  endif else begin
      if not keyword_set(quiet) then  $
        print,'Time '+time_to_str(t(i))+' is out of trange.'
  endelse
  
  endfor 
  if !d.name eq 'X' then begin
    wset,current_window
  endif
  return
END 

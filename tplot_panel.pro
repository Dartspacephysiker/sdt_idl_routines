;+
;PROCEDURE: tplot_panel
;KEYWORDS:
;   VARIABLE:  (string) name of previously plotted tplot variable.
;   OPLOTVAR:  Data that will be plotted on top of the selected panel
;   DELTATIME: Named variable in which time offset is returned.
;PURPOSE:
;  Sets the graphics parameters to the specified tplot panel.
;  The time offset is returned through the optional keyword DELTATIME.
;-

pro tplot_panel,time,y,panel=pan,deltatime=dt,variable=var,oplotvar=opvar ,$
  psym=psym

@tplot_com.pro

;help
dt = 0.

wi,tplot_window
if keyword_set(var) then begin
   i = where(tplot_var eq var,n)
   if n ne 0 then pan=i
endif

if not keyword_set(pan) then begin
   message,/info,var+' Not plotted yet!'
   return
endif

!p.clip = tplot_clip(*,pan)
!x = tplot_x
!y = tplot_y(pan)
dt = time_offset

if n_params() eq 2 then  opvar = {x:time,y:y}

if keyword_set(opvar) then begin
   if data_type(opvar) eq 7 then  get_data,opvar,data=d,alimi=l
   if data_type(opvar) eq 8 then  d =opvar
   if data_type(d) eq 8 then begin
      d.x = (d.x-time_offset)
      add_str_element,l,'psym',psym
      mplot,data=d,limit=l,/overplot
   endif
endif


end

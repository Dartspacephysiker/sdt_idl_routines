;+
;PROCEDURE:   ctime,time,y
;INPUT:  
;    time: Named variable in which to return the selected time (seconds
;          since 1970)
;    y:    Named variable in which to return the y value
;KEYWORDS:  
;    PROMPT:  Optional prompt string
;    NPOINTS: Max number of points to return
;    PSYM:    If set to a psym number, the cooresponding psym is plotted at
;             selected points
;    SILENT:  Do not print data point information
;    PANEL:   Set to a named variable to return an array of tplot panel numbers
;             coresponding to the variables points were chosen from.
;    APPEND:  If set, points are appended to the input arrays, 
;             instead of overwriting the old values.
;    VNAME:   Set to a named variable to return an array of tplot variable names,
;             cooresponding to the variables points were chosen from.
;    COLOR:   An alternative color for the crosshairs.  0<=color<=!d.n_colors-1
;    SLEEP:   Sleep time (seconds) between polling the cursor for events.
;             Defaults to 0.1 seconds.  Increasing SLEEP will slow ctime down,
;             but will prevent ctime from monopolizing cpu time.
;    INDS:    Return the indices into the data arrays for the points nearest the
;             recorded times to this named variable.
;    EXACT:   Get the time and y from the data arrays.  If on a multi-line plot,
;             get the value from the line closest to the cursor along y.
;	      In addition, exact returns dimen2(data.y)
;             This means TIME(i) equals data.x(INDS(i)) and
;                        Y(i)    equals data.y(INDS(i),EXACT(i))
;             for get_data,VNAME(i),data=data             
;PURPOSE:  Interactively uses the cursor to select a time (or times)
;NOTES:	      If you use the keyword EXACT, ctime may run noticeablly slower.
;	      Reduce the number of time you cross panels, especially with
;	      tplots of large data sets.
;SEE ALSO:  "crosshairs"
;
;CREATED BY:	Davin Larson & Frank Marcoline
;LAST MODIFICATION:     @(#)ctime.pro	1.24 97/01/09
;WARNING!
;  If ctime crashes, you may need to call:
;  IDL> device,set_graph=3,/cursor_crosshair
;-
pro ctime,time,value,$
   PROMPT=prompt    ,$
   npoints=npoints  ,$
   psym=psym        ,$
   silent=silent    ,$
   panel=panel      ,$
   append=append    ,$
   vname=vname      ,$
   color=color      ,$
   sleep=sleep      ,$    
   inds=inds        ,$
   exact=exact

@tplot_com.pro
;;;;;; make sure we have the correct window
if tplot_d.name ne !d.name then $
   message,'Last tplot was not made with same device!'
current_window = !d.window
wset, tplot_window
if tplot_d.x_size ne !d.x_size or tplot_d.y_size ne !d.y_size then begin
   wset,current_window
   message,'TPLOT window has been resized!'
endif
wshow,icon=0                    ;open the window
;;;;;;


;;;;;; check keywords and set defaults
if data_type(prompt) ne 7   then $
    prompt='Use button 1 to select time, 2 to erase time, and 3 to quit.'
if     keyword_set(prompt)  then print,prompt
if not keyword_set(exact)   then exact_ = 0       else exact_ = 1
if not keyword_set(silent)  then silent = 0
if     keyword_set(npoints) then max    = npoints else max    = 2000
if     max le 0             then max    = 2000
if data_type(sleep) eq 0    then sleep  = 0.01 ;this allows sleep to be set to 0
;;;;;;                                         ;and still defaults to 0.01


;;;;;; set graphics function, move cursor to screen, and plot original crosshairs
;the graphics function is set to (bitwise) "xor" rather than standard "copy"
;((a xor b) xor b) = a,  lets call your plot "a" and the crosshairs "b"
;plot "a", set the graphics function to "xor", and plot "b" twice and you get "a"
;this way we don't damage your plot
device, get_graphics = old, set_graphics = 6   ;Set xor graphics function
if not keyword_set(color) then color = !d.n_colors-1 $
else color = (color > 0) < (!d.n_colors-1)
px = 0.5                        ;Pointer (cursor) x and y positions
py = 0.5
hx = 0.5                        ;crossHairs       x and y positions
hy = 0.5                     
;when cursor,x,y,/dev is called and the cursor is off of the plot, (x,y)=(-1,-1)
cursor,testx,testy,/dev,/nowait               ;find current cursor location
if (testx eq -1) and (testy eq -1) then begin ;if cursor not on current window
  tvcrs,px,py,/norm                             ;move cursor to middle of window
endif else begin                              ;cursor is on window.
  pxpypz = convert_coord(testx,testy,/dev,/to_norm) ;find normal coords
  px = pxpypz(0)
  py = pxpypz(1)
  hx = px
  hy = py
endelse
plots,[0,1],[hy,hy], color=color,/norm,/thick,lines=0 
plots,[hx,hx],[0,1], color=color,/norm,/thick,lines=0 
opx = px                        ;store values for later comparison
opy = py
ohx = hx                        ;store values for later crossHairs deletion
ohy = hy
;if EXACT set, px & py will differ from hx & hy, else they will be the same
;use p{x,y} when working with pointer and h{x,y} when working with crosshairs
;;;;;;


;;;;;; set up output formats
if !d.name eq 'X' then begin 
  cr = string("15b)             ;a carriage return (no new line)
  form1 = "(4x,a15,': ',6x,a19,x,g,a,$)"         ;transient output line
  form2 = "(4x,a15,': (',i2,')  ',a19,x,g,a,$)"  ;transient output line for EXACT
  form3 = "(i4,a15,': ',6x,a19,x,g)"             ;recorded point output line
  form4 = "(i4,a15,': (',i2,')  ',a19,x,g)"      ;recorded point line for EXACT
endif else begin                ;these are for compatibility with MS-Windows
  cr = ''
  form1 = "(4x,a15,': ',6x,a19,x,g,a,TL79,$)"    ;same as above
  form2 = "(4x,a15,': (',i2,')  ',a19,x,g,a,TL79,$)"
  form3 = "(i4,a15,': ',6x,a19,x,g)"
  form4 = "(i4,a15,': (',i2,')  ',a19,x,g)"
endelse
;;;;;;

 
;;;;;; get and print initial position and panel in tplot data coordinates
pan = where(py ge tplot_y(*).window(0) and py le tplot_y(*).window(1))
pan = pan(0)
t =  normal_to_data(px,tplot_x) * time_scale + time_offset
if pan ge 0 then begin
  v =  normal_to_data(py,tplot_y(pan))
  var = tplot_var(pan)
endif else begin
  v =  !values.f_nan
  var = "Null"
endelse
print,form=form1,var,time_to_str(t),v,cr
;;;;;;

;;;;;; create an error handling routine
catch,myerror                   
if myerror ne 0 then begin      ;begin error handler
  plots,[0,1],[ohy,ohy], color=color,/norm,/thick,lines=0 ;erase crosshairs
  plots,[hx,hx],[0,1],   color=color,/norm,/thick,lines=0 
  print                         
  print,'Error: ',!error        ;report problem
  print,!err_string
  tvcrs,0                       ;turn off cursor
  device,set_graphics=old       ;restore old graphics state
  wset,current_window           ;restore old window
  return                        ;exit on error
endif                           ;end error handler
;;;;;;


;;;;;; set the initial values for internal and output variables
button=0
if not keyword_set(append) then begin
  time = 0
  value = 0
  panel = 0
  vname = ''
  exact = 0
endif
n = 0
lastvalidvar = var              ;record previous data variable (not "Null")
oldbutton    = 0                ;record last button pressed
if (exact_ ne 0) and (var ne "Null") then get_data,var,data=data
;;;;;;

;;;;;; here we are:  the main loop...
while n lt max do begin
  ;the main loop calls cursor, 
  ;which waits until there is a button press or cursor movement
  ;the old crosshairs are reploted (erased), the new crosshairs are ploted

  ;;;; get new position, update crosshairs
  cursor,px,py,/change,/norm    ;get the new position 
  button = !err                 ;get the new button state
  hx = px                       ;correct   assignments in the case of EXACT eq 0
  hy = py                       ;temporary assignments in the case of EXACT ne 0
  plots,[0,1],[ohy,ohy], color=color,/norm,/thick,lines=0 ;unplot old cross
  plots,[ohx,ohx],[0,1], color=color,/norm,/thick,lines=0 
  if button eq 4 then goto,quit ;yikes! i used a goto!
  if exact_ eq 0 then begin
    plots,[0,1],[hy,hy], color=color,/norm,/thick,lines=0 ;plot new crosshairs
    plots,[hx,hx],[0,1], color=color,/norm,/thick,lines=0 
  endif
  
  ;;;; Get new data values and crosshair positions from pointer position values, 
  ;;;; if we are not deleting the last data point.
  if (opx ne px) or (opy ne py) or (button ne 2) then begin 
    t =  normal_to_data(px,tplot_x) * time_scale + time_offset
    pan = (where(py ge tplot_y(*).window(0) and py le tplot_y(*).window(1)))(0)
    if pan ge 0 then begin
      v =  normal_to_data(py,tplot_y(pan))
      var = tplot_var(pan)
    endif else begin
      v =  !values.f_nan
      var = "Null"
    endelse
    yind = -1
    if exact_ ne 0 then begin 
      if var ne "Null" then begin ;get data points
        tind = 0l               ;zero the time index
        if var ne lastvalidvar then get_data,var,data=data ;don't reload data!
        dt = abs(data.x-t)      ;find the closest data.x to t, using a 
        mini = min(dt,tind)     ;trick to get the index of the min dt
        t = data.x(tind)
        if dimen2(data.y) gt 1 then begin ;if y 2D, get nearest line
          if finite(v) then begin 
            if tplot_y(pan).type eq 0 then dy = abs(data.y(tind,*)-v) $ ;lin plot
            else dy = abs(alog(data.y(tind,*))-alog(v)) ;log scale plot
            mini = min(dy,yind) ;get index of nearest y
            v = data.y(tind,yind)
          endif 
        endif else v = data.y(tind,0)
        hx = data_to_normal((t-time_offset)/time_scale,tplot_x)
        hy = data_to_normal(v,tplot_y(pan))
      endif
      plots,[0,1],[hy,hy], color=color,/norm,/thick,lines=0 ;plot new crosshairs
      plots,[hx,hx],[0,1], color=color,/norm,/thick,lines=0       
    endif
    if not silent then begin    ;print the new data
      if yind eq -1 then print,form=form1,var,     time_to_str(t),v,cr $
      else               print,form=form2,var,yind,time_to_str(t),v,cr 
    endif 
  endif 
  ;;;; got the current data

  ;;;; if a button state changes, take action:
  if button ne oldbutton then begin 
    case button of 
      1: begin                  ;record the new data and print output line
        append_array,time,t
        append_array,value,v
        append_array,vname,var
        append_array,panel,pan  
        np = n_elements(time)
        if not silent then begin 
          if exact_ then begin 
            if (dimen2(data.y) gt 1) and (var ne 'Null') then begin 
              print,form=form4,np-1,var,yind,time_to_str(t),v
              append_array,exact,yind
            endif else begin 
              print,form=form3,np-1,var,time_to_str(t),v 
              append_array,exact,0
            endelse 
          endif else begin 
            print,form=form3,np-1,var,time_to_str(t),v 
            append_array,exact,0
          endelse 
        endif 
        if keyword_set(psym) then plots,t-time_offset,v,psym = psym
        n = n + 1
      end
      2: begin                  ;delete last data and print output line
        np = n_elements(time)
        if np ge 2 then begin
          time  =  time(0:np-2)
          value = value(0:np-2)
          vname = vname(0:np-2)
          panel = panel(0:np-2)
          exact = exact(0:np-2)
          if not silent then $ 
            print,form="(60x,a,TL79,'last sample (',i0,') deleted.')",cr,np-1
          n = n-1
        endif else if (np ne 0) and (time(0) ne 0) then begin 
          time = 0
          value = 0
          panel = 0
          vname = ''
          exact = 0
          if not silent then $ 
            print,form="(60x,a,TL79,'Zero sample (',i0,') set to zero.')",cr,np-1
          n = (n-1) > 0
        end
      end 
      else:                     ;do nothing (if 4 then we exited already)
    endcase 
  endif 

  ;;;; store the current information, and pause (reduce interrupts on cpu)
  if var ne "Null" then lastvalidvar = var 
  oldpanel  = pan
  oldbutton = button
  opx = px
  opy = py
  ohx = hx
  ohy = hy
  wait, sleep                   ;Be nice

endwhile ;;;;;; end main loop

;;;;;; erase the crosshairs
plots,[0,1],[hy,hy], color=color,/norm,/thick,lines=0 
plots,[hx,hx],[0,1], color=color,/norm,/thick,lines=0 

;;;;;; return life to normal
quit: 
print,cr,format='(65x,a,TL79,$)'
tvcrs                           ;turn off cursor
device,set_graphics=old         ;restore old graphics state
wset,current_window             ;restore old window
wshow

;;;;;; if asked for, get the indicies of the data points
if keyword_set(inds) and (time(0) ne 0) then begin 
  np = n_elements(time)
  inds = lindgen(np)
  for i=0,np-1 do begin 
    if vname(i) ne "Null" then inds(i) = nn(vname(i),time(i)) else inds(i) = -1
  endfor
endif 

return
end




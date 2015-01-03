pro crosshairs,x,y,color=color,legend=legend
;+
;Routine adapted from IDL's box_cursor.pro
;-
device, get_graphics = old, set_graphics = 6  ;Set xor
if not keyword_set(color) then color = !d.n_colors -1
if not keyword_set(legend) then $
  legend = [!d.x_size-22*!d.x_ch_size,!d.y_size-6*!d.y_ch_size] $
else legend = convert_coord(legend(0),legend(1),/data,/to_dev)

flag  = 0 

x0 = !d.x_size/2                ;crosshairs initially in middle of window
y0 = !d.y_size/2

data = convert_coord(x0,y0,/dev,/to_data)
button = 0
goto, middle

while 1 do begin
  old_button = button
  cursor, xd, yd, 2, /dev         ;Wait for a button
  data = convert_coord(xd,yd,/dev,/to_data)
  button = !err
  x0 = xd
  y0 = yd
  if (!err eq 1) and (old_button eq 0) then begin 
    if flag eq 0 then begin 
      x = data(0)
      y = data(1)
      flag = 1
    endif else begin 
      x = [x,data(0)]
      y = [y,data(1)]
    endelse 
    ndp = n_elements(x)
    numstr = strcompress(string('(',ndp,')'),/re)
    print,numstr,x(ndp-1),y(ndp-1),format='(a8,3x,"x: ",g,"      y: ",g)'
  endif 
  plots,[0,!d.x_size-1],[py,py], color=color, /dev, thick=1, lines=0 
  plots,[px,px],[0,!d.y_size-1], color=color, /dev, thick=1, lines=0 
  xyouts,legend(0),legend(1),                  s1, color=color, /dev, size=1.4
  xyouts,legend(0),legend(1) - 3*!d.y_ch_size, s2, color=color, /dev, size=1.4
  empty				;Decwindow bug
  if !err eq 2 then begin ;move legend
    legend = [xd,yd]
  endif
  
  if !err eq 4 then begin       ;Quitting
    device,set_graphics = old
    return
  endif
middle:
  
  px = x0
  py = y0
  plots,[0,!d.x_size-1],[py,py], color=color, /dev, thick=1, lines=0 
  plots,[px,px],[0,!d.y_size-1], color=color, /dev, thick=1, lines=0 
  s1 = string('x:',data(0))
  s2 = string('y:',data(1))
  xyouts,legend(0),legend(1),                  s1, color=color, /dev, size=1.4
  xyouts,legend(0),legend(1) - 3*!d.y_ch_size, s2, color=color, /dev, size=1.4
  wait, .01                      ;Dont hog it all
endwhile
end

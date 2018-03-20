;+
;PROCEDURE:   draw_color_scale
;NAME:
;  draw_color_scale
;Purpose:
;  Procedure to draw a color scale.
;Documentation not finished!
;-
pro draw_color_scale,range=range,brange=brange,log=log, $
         position=pos,offset=offset,charsize = charsize,title=title

;@colors_com
if keyword_set(brange) eq 0 then begin
;   brange=[bottom_c,top_c]
   brange=[7,!d.table_size-2]
endif

if not keyword_set(charsize) then charsize = !p.charsize
if charsize eq 0. then charsize=1.0
if not keyword_set(title)    then title=''


if not keyword_set(pos) then begin
  if not keyword_set(offset) then offset = [2.,4.]
  space = charsize * !d.x_ch_size/!d.x_size   
  xw = !x.window(1) + offset * space
  yw = !y.window  
  pos = [xw(0),yw(0),xw(1),yw(1)]
endif else begin
  xw = pos([0,2])
  yw = pos([1,3])
endelse

xt = !x    ; save previous plot parameters
yt = !y
clipt = !p.clip
plot,[0,1],range,yrange=range,/nodata,/noerase, $
   pos=pos,xstyle=1+4,ystyle=1+4,ylog=log

pixpos = round(convert_coord(!x.window,!y.window,/norm,/to_device))
npx = pixpos(0,1)-pixpos(0,0)
npy = pixpos(1,1)-pixpos(1,0)
xposition = pixpos(0,0)
yposition = pixpos(1,0)

if !d.name eq 'PS' then scale = 40./1000. else scale = 1.

nypix = round(scale*npy)

y = findgen(nypix)*(!y.crange(1)-!y.crange(0))/(nypix-1) + !y.crange(0)
if keyword_set(log) then y = 10.^y
y = bytescale(y,bottom=brange(0),top=brange(1),range=range,log=log)

image = replicate(1b,npx) # y

tv,image,xposition,yposition,xsize=npx,ysize=npy

axis,yaxis=1,ystyle=1,yrange=range ,ylog=log,ytitle=title,  $
    yticks=1,charsize=charsize
xbox = [xw(0),xw(1),xw(1),xw(0),xw(0)]
ybox = [yw(0),yw(0),yw(1),yw(1),yw(0)]
plots,xbox,ybox,/normal,/noclip

!x = xt     ; restore previous plot parameters
!y = yt
!p.clip = clipt

end





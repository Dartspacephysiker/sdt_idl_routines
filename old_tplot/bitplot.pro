;+
;NAME:
;  bitplot
;PURPOSE:
;  Plots 'ON' bits for housekeeping type data.
;  Can be used by "tplot". 
;  See "_tplot_example" and "_get_example_dat" for an example.
;-
pro bitplot,x,y,psyms=psyms,overplot=overplot,di=di,limits=lim,data=data
if keyword_set(data) then begin
  x = data.x
  y = data.y
  extract_tags,stuff,data,except=['x','y','dy']
endif
extract_tags,stuff,lim
extract_tags,plotstuff,stuff,/plot
extract_tags,oplotstuff,stuff,/oplot
str_element,stuff,'labels',val=labels
labsize = 1.
str_element,stuff,'labsize',val=labsize
chsize = !p.charsize
if not keyword_set(chsize) then chsize = 1.


case data_type(y) of
  1: nb = 8
  2: nb = 16
  3: nb = 32
  else: nb = 0
endcase
if n_elements(di) eq 0 then di = 1
if not keyword_set(psyms) then psyms = replicate(3,nb)
if not keyword_set(overplot) then $
   plot,/nodata,x,y,yrange=[-1+di,nb+di],/ystyle,_extra=plotstuff

bit = 1l
for i=0,nb-1 do begin
  ind = where(y and bit,c)
  if c ne 0 then $
     oplot,x(ind),replicate(i+di,n_elements(ind)),psym=psyms(i)
  bit = bit * 2
endfor

if keyword_set(labels) then begin
   n = n_elements(labels)
   yp = indgen(n) + di
   xp = replicate(!x.crange(1),n)
   xyouts,xp,yp,"  "+labels,charsize=labsize*chsize
endif

end

pro strplot,x,y,overplot=overplot,di=di,limits=lim,data=data
if keyword_set(data) then begin
  x = data.x
  y = data.y
  extract_tags,stuff,data,except=['x','y']
endif

extract_tags,stuff,lim
extract_tags,plotstuff,stuff,/plot
extract_tags,xyoutstuff,stuff,/xyout
str_element,stuff,'labels',val=labels
labsize = 1.
str_element,stuff,'labsize',val=labsize
chsize = !p.charsize
if not keyword_set(chsize) then chsize = 1.

n = n_elements(x)
if not keyword_set(overplot) then $
   plot,/nodata,x,findgen(n)/n,yrange=[0,1],/ystyle,_extra=plotstuff

z = fltarr(n)

xyouts,x,z,y,charsize=chsize,orien=90.,noclip=0,_extra=xyoutstuff


end

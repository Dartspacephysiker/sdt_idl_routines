pro box,limits,x,y,data=d

wi,lim=limits

xlog=0
ylog=0
xr = [0.,0.]
yr = [0.,0.]
overplot = 0


str_element,limits,'xlog',value=xlog
str_element,limits,'ylog',value=ylog
str_element,limits,'xrange',value=xr
str_element,limits,'yrange',value=yr
str_element,limits,'overplot',value=overplot

if (n_elements(x) ne 0) and (xr(0) eq xr(1)) then xr = minmax_range(x,pos=xlog)
if (n_elements(y) ne 0) and (yr(0) eq yr(1)) then yr = minmax_range(y,pos=ylog)

extract_tags,plotstuff,limits,/plot

if not keyword_set(overplot) then plot,xr,yr,/nodata,_extra=plotstuff


end

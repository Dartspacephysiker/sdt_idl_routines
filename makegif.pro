;+
;PROCEDURE:  makegif, filename
;NAME:
;  makegif
;PURPOSE:
;  Creates a GIF file from the currently displayed image.
;NOTES:
;  extension '.gif' is added automatically
;Restrictions:
;  Current device should have readable pixels (ie. 'x' or 'z')
;
;Created by:  Davin Larson
;FILE:  makegif.pro
;VERSION:  1.2
;LAST MODIFICATION:  96/10/15
;-
pro makegif,filename
if not keyword_set(filename) then filename = 'plot'
tvlct,r,g,b,/get
write_gif,filename+'.gif',tvrd(),r,g,b
end

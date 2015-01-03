;+
;  PROCEDURE
;  oplot_err
;
;  PURPOSE
;  plot error bars on data.
;
;  EXAMPLE
;  x = findgen( 10)
;  y = 2.*x + 1.
;  dy = 0.1*randomn( seed, 10)
;  lower = y - dy
;  upper = y + dy
;  plot, x, y
;  oplot_err, x, lower, upper
;
;  INPUTS
;  xt
;  float[ N], array of abscissa values.
;
;  lower, upper
;  float[ N], arrays of lower and upper ordinates for the error bars.
;
;  OUTPUTS
;  none.
;
;  SIDE EFFECTS
;  will attempt to overplot error bars on the current plot panel.
;
;  NOTES
;  replaces original (and presumably lost) version of OPLOT_ERR in the
;  FADT IDL library.
;
;  HISTORY
;  v. 1.0 John Bonnell, UCBSSL, January 2001.
;  initial version, reverse-engineered from call in MPLOT.
;-
pro oplot_err, xt, lower, upper

n = n_elements( xt)
for i=0L,n-1L do begin
    oplot, xt[ i]*[ 1., 1.], [ lower[ i], upper[ i]]
endfor

return
end

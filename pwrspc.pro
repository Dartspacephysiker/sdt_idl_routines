pro pwrspc,tp,xp,gnu,xs,nohanning=nohanning,bin = bin, psd = psd
;
;  Called with times TP and data XP, PWRSPC returns an power
;    spectrum XS at frequencies GNU. A Hanning window is applied to
;    the input data, and its power is divided out of the returned
;    spectrum.  The keyword PSD, when set, divides by the frequency bin
;    width, so that Power Spectral Density is returned. 
;
t = tp
x = xp

if keyword_set(bin) then begin
    binsize = bin
endif else begin
    binsize = 3
endelse

if not(keyword_set(nohanning)) then begin
    window = hanning(n_elements(x))
    x = x * window
endif

nt = n_elements(t)
bign = nt
if (bign-(bign/2l)*2l ne 0) then begin
    t = t(0:nt-2)
    x = x(0:nt-2)
    bign = bign - 1
endif
;
; following Numerical recipes in Fortran, p. 421, sort of...
;

fbign = float(bign)
k = [0,findgen(bign/2)+1]
fk = k/(bign*(t(1)-t(0)))

xs2 = abs(fft(x,1))^2


pwr = fltarr(bign/2+1)
pwr(0) = xs2(0)/fbign^2
pwr(1:bign/2-1) = (xs2(1:bign/2-1) + xs2(bign - findgen(bign/2)))/fbign^2
pwr(bign/2) = xs2(bign/2)/fbign^2

if not keyword_set(nohanning) then begin
    wss = fbign*total(window^2)
    pwr = fbign^2*pwr/wss
endif
; 
; Now reduce variance by summing near neighbors...
;
npwr = n_elements(pwr)
nfinal=long(npwr/binsize)
iarray=lindgen(nfinal)
xs = fltarr(nfinal)

gnu = fk((iarray+0.5)*binsize)

for i=0,binsize-1 do begin
    xs = xs+pwr(iarray*binsize+i)
endfor

if keyword_set(psd) then begin
    fbin = (gnu(nfinal-1) - gnu(0))/float(nfinal-1)
    xs = xs/fbin
endif

return
end



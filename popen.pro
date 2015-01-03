;+
;PROCEDURE: popen, filename
;PURPOSE: 
;  Change plot device to postscript.
;INPUT:    optional;  if:
;  string   :  string used as filename,  '.ps' extension is added automatically
;  integer X:  filename set to 'plotX.ps'.  value of x is incremented by 1.
;  none:       filename set to 'plot.ps'
;KEYWORDS: See print_options for info.
;  COPY:    pass COPY keyword to set_plot
;  INTERP:  pass INTERP keyword to set_plot  (default is to have interp on)
;
;SEE ALSO:	"pclose",
;		"print_options",
;		"popen_com"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)popen.pro	1.18 97/02/05
;-

pro popen,n,          $
  port=port,          $
  land=land,          $
  color=color,        $
  bw=bw,              $
  printer=printer,    $
  directory=printdir, $
  font = font,        $
  aspect = aspect,    $
  xsize = xsize,      $
  ysize = ysize,      $
  interp = interp,    $
  ctable = ctable,    $
  copy = copy,        $
  encapsulated = encap
@popen_com.pro

print_options,directory=printdir,land=land,port=port

;if keyword_set(encap) then 

if n_params() ne 0 then begin
  if data_type(n) eq 0 then n = 1
  if data_type(n) eq 2 then begin
    fname = strcompress('plot'+string(n)+'.ps',/REMOVE_ALL)
    n = n+1
  endif
  if data_type(n) eq 7 then fname=n+'.ps'
endif
if data_type(fname) ne 7 then fname = 'plot.ps'
if print_directory ne '' then fname = print_directory+'/'+fname

if n_elements (old_device) eq 0 then popened = 0
if popened then  pclose,printer=printer

print ,'Opening postscript file '+fname+'.  Use PCLOSE to close'

old_device = !d.name
old_fname  = fname
old_color  = !p.color
old_font   = !p.font
old_bckgrnd= !p.background

if n_elements(interp) eq 0 then interp = 0
if n_elements(copy) eq 0 then copy =0

set_plot,'PS',interp=interp,copy=copy

if n_elements(ctable) ne 0 then loadct2,ctable

print_options,port=port,land=land,color=color,bw=bw, $
    printer=printer,font = font,aspect=aspect,xsize=xsize,ysize=ysize

if keyword_set(bw) then begin  ; force all colors to black
  tvlct,r,g,b,/get
  r(*) = 100 & g(*)=200 & b(*)=30
  tvlct,r,g,b
endif

device,file=old_fname

popened = 1

return
end



;+
;PROCEDURE:   pclose
;INPUT:  none
;PURPOSE: Close postscript file opened with popen, and change device back to 
;  default.
;  If common block string 'printer_name' is set, then file is sent to that
;  printer.
;SEE ALSO: 	"print_options"
;		"popen"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)pclose.pro	1.7 97/02/05
;-



pro pclose,printer=printer
@popen_com.pro

if !d.name eq 'PS' then begin
   device,/close
   set_plot,old_device
   !p.background = old_bckgrnd
   !p.color      = old_color
   !p.font       = old_font
   print,"Closing plot ",old_fname
endif

if n_elements(printer) then printer_name = string(printer)

if keyword_set(printer_name) then begin
   maxque = 2
   command = 'lpq -P'+printer_name+' | grep -c '+getenv('USER')
   repeat begin
   spawn,command,res
   n = fix(res(n_elements(res)-1))
   if n ge maxque  then begin
      print,systime(),': ',n,' plots in the que.  Waiting...'
      wait, 60.
   endif
   endrep until n lt maxque

   command = 'lpr -P'+printer_name+' '+old_fname
   print,command
   spawn,command
   print,old_fname,' has been sent to printer '+printer_name
endif

popened = 0

return
end


;	@(#)startfast.pro	1.14	
!quiet = 1

fhguess = '/disks/fast/software/integration/'  ; could change someday...

fh = ''
fh = getenv('FASTHOME')
if fh eq '' then begin & message,' FASTHOME not defined, setting to ' + $
  fhguess,/continue & fh = fhguess & endif
    
path = ''
path =  expand_path('+$IDL_DIR/lib') + $
  ':' + expand_path(fh+'/idl') + $
  ':' + expand_path('+~/FAST/idl')   + $
  ':' + expand_path('+~/idl')

if (!VERSION.RELEASE LE '5.4') then begin
    sspath = str_sep(path,':')
endif else begin
    sspath = strsplit(path,':',/EXTRACT)
endelse

ok = where((strpos(sspath,'SCCS') lt 0) and  $
           (strpos(sspath,'obsolete_leave_it_in') lt 0),nok)

!path = ''
for i=0,nok-1l do !path = !path + sspath(ok(i))+':'
;
; following is for Greek letters, from Frank Marcoline
;
old_device=!d.name		;save current device
set_plot,'PS'			;change to postscript so we can edit the PS font mapping
device,/symbol,font_index=19	;set font !19 to Symbol 
set_plot,old_device		;revert to old device



setenv,'IDL_CT_FILE=${FASTCONFIG}/idl_ctables/colors1.tbl'

loadct2,39

!prompt = 'fast>'

!quiet = 0

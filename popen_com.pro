;+
;COMMON BLOCK:	popen_com
;PURPOSE:	Common block for print routines
;
;SEE ALSO:	"popen","pclose",
;		"print_options"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)popen_com.pro	1.8 96/10/04
;-


common hardcopy_stuff,old_device, $
    old_fname, $
    old_color, $
    old_bckgrnd, $
    old_font,  $
    portrait,  $
    in_color,  $
    print_aspect,  $
    printer_name,  $
    print_directory, $
    print_font, $
    popened

;+
;PROCEDURE:	make_po_cdf_mastfiles
;PURPOSE:	
;   Update cdf master files in the polar cdf area.  Note that the
;   following environment variables must be set for this procedure to 
;   work properly: POLAR_CDF_HOME and POLAR_CDF_MAST_DIR.  Any zero
;   length files are removed from the hierarchy (they're an error anyway).
;
;
;   Every month the directories need to be updated.
;
;INPUT:	
;	dirnames:  A string array containing the directories to look in for
;		   the cdf files.	
;
;KEYWORDS:
;
;CREATED BY: J. Loran     Feb '97
;
;LAST MODIFICATION:	
;	@(#)make_fa_cdf_mastfiles.pro	1.1 02/08/97
; 	Revised for Polar data by S. Wittenbrock 02/10/97
;	Revised to include directory names by S. Wittenbrock 06/03/97
;-
;

PRO make_po_cdf_mastfiles

; set the directory to put the index files

cdfmastdir=getenv('CDF_INDEX_DIR')

; open and read the file that contains the data directories.
; this file will need to be updated as more directories are created

get_lun,unit
fname = getenv('FASTCONFIG') + '/po_orb_data/orb_dirs'
openr, unit, fname
dirnames=''
readf, unit, dirnames
while not eof(unit) do begin
	dir = ''
	readf, unit, dir
	dirnames = [dirnames, dir]
endwhile
close, unit
free_lun,unit

    make_cdf_index, 'po_at_*cdf', index_filename = cdfmastdir + $
		    '/polar_mast/po_at_def_index',    $
                    data_direc = dirnames
    make_cdf_index, 'po_or_*cdf', index_filename = cdfmastdir + $
		    '/polar_mast/po_or_def_index',    $
		    data_direc = dirnames

END

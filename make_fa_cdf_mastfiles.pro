;+
;PROCEDURE:	make_fa_cdf_mastfiles
;PURPOSE:	
;   Update cdf master files in the fast cdf area.  Note that the
;   following environment variables must be set for this procedure to 
;   work properly: FAST_CDF_HOME and CDF_INDEX_DIR.  Any zero
;   length files are removed from the hierarchy (they're an error anyway).
;
;   The directories given in the dirnames parameter are searched for
;   cdf files in the FAST_CDF_HOME directory.  
;
;INPUT:		
;   dirnames:   An array of directories under FAST_CDF_HOME that will
;               searched for cdf's.  Note that the mastfiles will be
;               named:
;                      ${CDF_INDEX_DIR}/fa_k0_<dirname>_files
;               for each <dirname> given.
;
;KEYWORDS:
;
;CREATED BY:	J. Loran     Feb '97
;LAST MODIFICATION:	@(#)make_fa_cdf_mastfiles.pro	1.4 03/31/97
;-


PRO make_fa_cdf_mastfiles, dirnames 

cdfhome = getenv('FAST_CDF_HOME')
cdfmastdir = getenv('CDF_INDEX_DIR')

IF (strlen(cdfhome) EQ 0) OR (strlen(cdfmastdir) EQ 0) THEN BEGIN
    PRINT, 'make_fa_cdf_mastfiles.pro: FAST_CDF_HOME and CDF_INDEX_DIR environment variables'
    PRINT, '  must be set.'
    RETURN
ENDIF

IF N_ELEMENTS (dirnames) LT 1 THEN BEGIN
        PRINT, 'make_fa_cdf_mastfiles.pro: A list of directory names must be given'
        RETURN
ENDIF

; loop through directories now

FOR i = 0, N_ELEMENTS(dirnames)-1 DO BEGIN
    
    ; remove zero length files

    PRINT, 'Removing zero length files:'
    spawn, 'find ' + cdfhome + '/' + dirnames(i) + ' -type f -size 0 '$ 
                + '-exec /bin/rm -f {} \; -print '
          
    ; catch cdf errors so we can try to continue

    CATCH, errno
    
    ; and build cdf index

    IF errno EQ 0 THEN  BEGIN
        make_cdf_index, index_filename = cdfmastdir + '/fa_k0_' +    $
                        dirnames(i) + '_files' $
                        ,data_direc = cdfhome + '/' + dirnames(i)
    ENDIF ELSE BEGIN
        PRINT, 'make_fa_cdf_mastfiles.pro: An error occured processing CDF files in directory:'
        PRINT, '   ', cdfhome + '/' + dirnames(i)
    ENDELSE

ENDFOR

END

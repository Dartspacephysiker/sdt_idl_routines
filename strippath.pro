;+
; FUNCTION:
; 	 STRIPPATH
;
; DESCRIPTION:
;
;	Function that strips off any directory components from a full
;	file path, and returns the file name and directory components
;	seperately in the structure:
;		{file_cmp_str,file_name:'file',dir_name:'dir'}
;	This is only implemented for UNIX at this time.
;
; USAGE (SAMPLE CODE FRAGMENT):
; 
;   ; find file component of /usr/lib/sendmail.cf
;	stripped_file = STRIPPATH('/usr/lib/sendmail.cf')
; 
;  The variable stripped_file would contain:
;
;	stripped_file.file_name = 'sendmail.cf'
;	stripped_file.dir_name  = '/usr/lib/'
;
; NOTES:
;
;	This function is only implemented for UNIX at this time.  It could
;	easily be adapted for VMS
;
;	It is assumed that the length of the filename component is less than
;	or equal to 128 characters
;
;	This routine cannot distinguish between a file and a directory name
;	if it occurs in the last component.  Therefore, the file_name value
;	could refer to a subdirectory.  To prevent this, directories should
;	be appended with a / before this rountine is called.
;
; REVISION HISTORY:
;
;	@(#)strippath.pro	1.1 06/04/95 	
; 	Originally written by Jonathan M. Loran,  University of 
; 	California at Berkeley, Space Sciences Lab.   Oct. '92
;
;-

FUNCTION strippath, full_path

; start with input file path and find the last directory seperator
; (/ for UNIX)

file_comp= REPLICATE(                                                      $
	{file_cmp_str,file_name:'file',dir_name:'dir'}                     $
	,N_ELEMENTS(full_path) )

; for each full_path given, get the file component

FOR i=0,N_ELEMENTS(full_path)-1 DO   BEGIN
	sep_pos = 0
	cur_pos = 0
	WHILE sep_pos GE 0 DO BEGIN
		sep_pos = STRPOS(full_path(i),'/',sep_pos+1) 
		IF sep_pos GE 0 THEN cur_pos = sep_pos+1
	ENDWHILE
	file_comp(i).dir_name  = STRMID(full_path(i),0,cur_pos)
	file_comp(i).file_name = STRMID(full_path(i),cur_pos,128)
ENDFOR

; return the file names found, being careful to keep scalers as scalers

IF N_ELEMENTS(file_comp) GT 1 THEN   RETURN, file_comp                      $
ELSE                                 RETURN, file_comp(0)

END

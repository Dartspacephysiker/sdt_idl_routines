; File: cdfhires.pro
; called by hires_cdf from an sdt batch process to do IDL processing to 
; create a CDF file (or potentially any IDL readable format file), 
; using data in SDT shared memory buffers.
; 
; cdfhires calls an IDL routine specified in the environment to do the
; actual processing specific to the data type requested.  The name of the
; IDL procedure used to process the datatype is configured in the file
; /disks/plasma2/www/fast/hires/config/hires_cdf.cfg 
;
; cdfhires.pro expects the following environment variables to be set:
;   IDLSCRIPT  The name of the idl procedure to call (without .pro suffix)
;   DATATYPE   The name of the data type to generate -- will be passed
;              as the argument to IDLSCRIPT -- see below.
;
; The idl procedure called must accept a single argument: a string
; containing the name of the data type to be produced. 
;   For make_esa_cdf, we
;   make a special case and prepend 'fa_' to the DATATYPE name.  
;   For now, all other procedures are assumed to be FAST specific, so they
;   are only passed the DATATYPE name from the FAST hires_cdf.cfg 
;   configuration file, without the 'fa_' prefix added, 
; The idl procedure should read the following environment variables
; to determine the pathname for the output file:
;   IDL_HIRES_OUTDIR   directory in which to place the ouput file. (will
;                      include a final '/') 
;   IDL_HIRES_CDFNAME  the name of the file which should be created.
; 
;

; Get the environment variables
script=getenv('IDLSCRIPT')
typeenv=getenv('DATATYPE')
typeenv=strlowcase(typeenv)
type='fa_'+typeenv

; Run the appropriate IDL routine to generate the CDF

if (script eq 'make_esa_cdf') then call_procedure, script, type else $
call_procedure, script, typeenv

help

exit

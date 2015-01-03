;
; Procedure:
; 	 GET_IDL_VERSION
;
; DESCRIPTION:
;
;	function to return the VERSION.RELEASE of the currently
;       running IDL
;
; CALLING SEQUENCE:
;
; 	vers = get_idl_Version
;


   print, 'IDLVersion: ', !VERSION.RELEASE
   exit


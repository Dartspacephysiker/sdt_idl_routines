;+
; FUNCTION:
; 	 GET_LEFT_FROM_SDT
;
; DESCRIPTION:
;
;	function to get the current position of the SDT LEFT fiducial
;
;	A structure of the following format is returned:
;
;	   DATA_NAME    STRING    'QTY'           ; Data Quantity name
;	   VALID        INT       1               ; Data valid flag
;	   TYPE         INT       0               ; 0 -> Left fiducial
;	   VALUE        DOUBLE    8.0118726e+08   ; Time of left fid.
;	
; CALLING SEQUENCE:
;
; 	zoom = get_left_from_sdt(data_name, sat_code)
;
;                   or
;
; 	zoom = get_left_from_sdt()
;
; ARGUMENTS:
;
;	data_name      STRING:  The SDT data quantity name.  If not USED, 
;                               then the left fid. of the first quantity
;                               found in SDT will be returned.
;
;	sat_code       INT:     The SDT satellite code - used only if
;                               "data_name" is also used.  Current know
;                               codes are:
;			              CRRES            1
;			              ISEE             2
;			              ISEE2            3
;			              GEOTAIL          24
;			              WIND             25
;			              POLAR            26
;			              CLUSTER          30
;			              GEOTAIL_SURVEY   241
;			              CRRES_SURVEY     1001
;			              FAST             2001
;
; KEYWORDS:
;
;       none
;
; RETURN VALUE:
;
;	Upon success, the above structure is returned, with the valid tag
;	set to 1.  Upon failure, the valid tag will be 0.
;
; REVISION HISTORY:
;
;	@(#)get_left_from_sdt.pro	1.3 01/09/07
; 	Originally written by	 Jack Vernetti,  University of 
; 	California at Berkeley, Space Sciences Lab.   Sep 2003
;-

FUNCTION get_left_from_sdt, data_name, sat_code

   ; Check that we know the SDT session:
   sdt_idx = get_sdt_run_idx()
   if sdt_idx LT 0 then begin
       RETURN, -1
   endif

   ; initialize times and dates

   lineTime = double(0.0)

   nps = n_params()

   if nps LT 2 THEN BEGIN
       data_name = 'NULL'
       sat_code = 0
   ENDIF

   flg64 = 1
   lmdl = STRING ('loadSDTBufLib3264.so')
   if (!VERSION.RELEASE LE '5.4') then begin
       flg64 = 0
       lmdl = STRING ('loadSDTBufLib.so')
   endif

   len = CALL_EXTERNAL (lmdl, 'getLeftFromSDT',              $
                        long(sat_code),					   $
                        data_name,					   $
                        double(lineTime))

   IF len EQ 0 THEN BEGIN       ; trouble so bail out now
      RETURN, {data_name: 'Null', valid: 0}
   ENDIF
   
   dat = 								  $
     {data_name:	data_name, 					  $
       valid: 		1, 						  $
       type:	        0,                                                $
       value:	lineTime}

   RETURN,  dat
END 

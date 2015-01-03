;+
; FUNCTION:
; 	 get_fast_esa_mdata_bundled
;
; DESCRIPTION:
;
;	Implemented:  2011/04/04
;
;       Upgraded SDT/IDL interface routine to specifically get
;       FAST E/I/S Esa data to improve speed and robustness.
;       In particular, it makes a minimal set of SDT/IDL RPC
;       calls and SDT SHM attachments/detachments by acting
;       on an entire array of data.  In the old SDT/IDL interface,
;       several RPC calls and SHM attachments/detachments were
;       required to extract EACH ESA distribution.  This call only
;       requires one or two for the entire data set.
;
; CALLING SEQUENCE:
;
; 	data =  get_fast_esa_mdata_bundled(dqi_name, [STIME=stime, ETIME=etime, SINDEX=sidx, EINDEX=eidx, ALL=all])
;
; ARGUMENTS:
;
;	dqi_name:  The following 11 FAST data quantities are supported:
;
;                     Eesa Burst
;                     Eesa Survey
;                     Iesa Burst
;                     Iesa Survey
;                     Sesa 1 Burst
;                     Sesa 2 Burst
;                     Sesa 3 Burst
;                     Sesa 4 Burst
;                     Sesa 5 Burst
;                     Sesa 6 Burst
;                     Sesa Survey
;
;	adesc1:  If defined, the argument into which the
;                array descriptions for the energies will
;                be returned.
;
;	adesc2:  If defined, the argument into which the
;                array descriptions for the angles will
;                be returned.
;
;	Note:  To get the energy and angle array descriptions,
;              both "adesc1" and "adesc2" must be defined.
;              There is no way to get one or the other but
;              not both.
;
; KEYWORDS:
;
;	adesc1:	If defined, then return, in "adesc1", then
;               "Energy" array descriptions.  Note that
;               "adesc2" must also be defined, for the energy
;               descriptions to be returned.
;	adesc2:	If defined, then return, in "adesc2", then
;               "Angle" array descriptions.  Note that
;               "adesc1" must also be defined, for the angle
;               descriptions to be returned.
;	stime:	If defined, make a timespan query.  This is
;               the starting time of the timespan and "etime"
;               must also be defined.  "stime" will be a DOUBLE
;               in Unix time (secs since 00:00 UT, 1970/01/01)
;	etime:	The end time of a timespan query.  This must
;               be defined if "stime" is.  "etime" will be a DOUBLE
;               in Unix time (secs since 00:00 UT, 1970/01/01)
;
;	sidx:	If defined, make an index range query.  This is
;               the starting index and "eidx" must also be
;               defined.  "sidx" will be a LONG
;	eidx:	The end index of an index range query.  This must
;               be defined if "sidx" is.  "eidx" will be a LONG
;
;	all:	If defined, return data for all of the elements
;               that exist in the corresponding SDT DQI. 
;
;
;  Calling examples:
;
;    stime = gettime('2004-02-18/02:30:00')
;    etime = gettime('2004-02-18/03:03:20')
;    dat = get_fast_esa_mdata_bundled('Sesa 1 Burst', STime=stime, ETime=etime)
;
;
;    dat = get_fast_esa_mdata_bundled('Eesa Survey', SINDEX=200, EINDEX=7800)
;
;
;    dat = get_fast_esa_mdata_bundled('Sesa Survey', ALL=all)
;
;
;    dat = get_fast_esa_mdata_bundled('Sesa Survey', ADESC1=adesc1, $
;              ADESC2=adesc2, ALL=all)
;
;
; RETURN VALUE:
;
;	Upon failure, a scalar -1 is returned, else a structure
;
;       On success, an array of structures of the following
;	format is returned:
;
;		{ DQI_NAME	STRING  ;
;                 VALID         INT     ; 1 -> data is good.
;		  PROJECT_NAME	STRING  ;
;		  UNITS_NAME	STRING  ;
;		  UNITS_PROCEDURE STRING  ;
;		  TIME		DOUBLE  ; Unix Start Time of the data.
;		  END_TIME	DOUBLE  ; Unix End Time of the data.
;		  INTEG_T	DOUBLE  ; Integration time (secs)
;		  NBINS		INT     ; number angles
;		  NENERGY	INT     ; number energies
;		  DATA		FLOAT(NENERGY,NBINS) ; the counts
;		  ENERGY	FLOAT(NENERGY,NBINS) ; energies
;		  THETA		FLOAT(NENERGY,NBINS) ; angles
;		  GEOM		FLOAT(NBINS) ; (not computed)
;		  DENERGY	FLOAT(NENERGY,NBINS) ; energy diffs
;		  DTHETA	FLOAT(NBINS) ; angle diffs
;		  EFF		FLOAT(NENERGY) ; (set to 1)
;		  MASS		DOUBLE ;
;		  GEOMFACTOR	DOUBLE ;
;		  HEADER_BYTES	BYTE(44) ;  header bytes
;		  INDEX		LONG 	 ;  index of this data in the DQI.
;		  ADESC_IDX1	LONG 	 ;  index into the energy array
;                                           description array returned
;                                           in adesc1, if that has
;                                           been requested.  Othewise,
;                                           it is set to -1.
;		  ADESC_IDX2	LONG 	 ;  index into the angle array
;                                           description array returned
;                                           in adesc1, if that has
;                                           been requested.  Othewise,
;                                           it is set to -1.
;		  SPIN_PHASE	DOUBLE   ; Spin phase  (Sesa's only)
;		  SPIN_NUM   	LONG	 ; Spin number  (Sesa's only)
;		  SPIN_PH_HDR	SHORT	 ; (unsigned)  (Sesa's only)
;		  SWEEP_NUM	SHORT	 ; (unsigned)  (Sesa's only)
;		  SWPS_PER_SET	SHORT	 ; (unsigned)  (Sesa's only)
;		}
;
; Note that the SPIN_PHASE, ..., SWPS_PER_SET are only filled with
; real data for the Sesa's (and are set to 0 for the E and I Esa's).
;
; Note:  A successful call will return an array with quite possibly
;        a large amount of memory.   When the caller finishes using
;        the returned array ("dat"), the memory should be free'ed up
;        by resetting its value and type in IDL, for instance, with
;        the command:
;
;            dat = 0L
;
;
; RETURN ARGUMENTS:
;       On success, and if the energy and angle array descriptions
;       are requested by the "adesc1", "adesc2" keywords, then two
;       arrays of structures of the form:
;
;	        { NBINS       LONG  ;  Nmb of bins in the arr desc.
;	          NSUBDIMS    LONG  ;  Nmb of sub-dimensions.
;		  DELTA	      FLOAT(NBINS * NDIMS) ; full deltas
;		  MIDP	      FLOAT(NBINS * NDIMS) ; Midpoints
;		}
;
;       Note that "NBINS" is the number of bins in the array
;       description and "NSUBDIMS" is the number of sub-dimensions
;       for each "bin".  For all of the Esa's (and most of the
;       SDT multi-dimensional quantities), "NSUBDIMS" is just "1".
;       The only case in FAST were "NSUBDIMS" is > "1", are the
;       3-D TEAMS quantities, where the solid angle dimension has
;       2 sub-dimensions, "theta", and "phi".
;
; Note:  A successful call will return these arguments with possibly
;        a large amount of memory.   When the caller finishes using
;        the returned arguments "adesc1" and "adesc", the memory
;        should be free'ed up by resetting their values and types
;        in IDL, for instance, with the command:
;
;            adesc1 = 0L
;            adesc2 = 0L
;
;
; REVISION HISTORY:
;
;	@(#)get_fast_esa_mdata_bundled.pro	1.5 04/25/11
; 	Originally written by JB Vernetti,  University of 
; 	California at Berkeley, Space Sciences Lab.   April, 2011
;-

FUNCTION get_fast_esa_mdata_bundled, dqi, $
ADESC1=adesc1, ADESC2=adesc2, ADESC3=adesc3, $
SINDEX=sidx, EINDEX=eidx, STIME=stime, ETIME=etime, ALL=all

   ; check for data type

   ; Check that we know the SDT session:
   sdt_idx = get_sdt_run_idx()

   if sdt_idx LT 0 then begin
       RETURN, -1
   endif

   IF N_ELEMENTS(dqi) EQ 0 THEN BEGIN
      PRINT, '@(#)get_fast_esa_mdata_bundled.pro	1.5: Input parameter "dqi_name" must be filled.'
      RETURN, -1
   ENDIF 
   
   ; the following structure must remain in sync with the C code in 
   ; sdtDataToIdl.h

   args = {sat_code:		2001L,					$
           dqi_name:		'',					$
           year:		0L,					$
           month:		0L,					$
           day:			0L,					$
           stSec:		0.D,					$
           enSec:		0.D,					$
           dType:		0L,					$
           GetRangeInfo:	1L,					$
           byTSpan:		-1L,					$
           RetMDimInfo:	        1L,					$
           TypeMDimInfo:	0L,					$
           npts:		0L,					$
           done:		0,					$
           index:		0L,					$
           time:		0.D,					$
           findIdxTime:		0,					$
           start_index:		0L,					$
           end_index:		0L,					$
           pts_in_range:	0L,					$
           sidx_time:		0.D,					$
           eidx_time:		0.D,					$
	   n_dimensions:        0L,                                     $
	   mxdim:               lonarr(3),                              $
	   mndim:               lonarr(3),                              $
	   nadesc:              lonarr(3),                              $
	   nsubdims:            lonarr(3)                               $
          }

   ; and load the values into this struct

   args.sat_code = long(2001)
   args.dqi_name = dqi
   if defined(all) then begin
       args.byTSpan = -1
   endif else begin
   endelse

   if defined(sidx) then begin
       args.start_index = sidx
       args.end_index = eidx
       args.byTSpan = 0
   endif else begin
   endelse
   
   if defined(stime) then begin
       args.stSec = stime
       args.enSec = etime
       args.byTSpan = 1
   endif else begin
   endelse

   ; selection by time takes presidence
   
   IF n_elements(idx) GT 0 THEN BEGIN
       IF idx GE 0 THEN BEGIN
           args.time = -1
           args.index = idx
           args.findIdxTime = 2              ; 2 means use index for time
       ENDIF
   ENDIF

   IF n_elements(tselection) GT 0 THEN BEGIN
       IF tselection GT 0 THEN BEGIN 
           args.index = -1
           args.time = gettime(tselection)
           args.findIdxTime = 1              ; 1 means use time for index
       ENDIF 
   ENDIF

   flg64 = 1
   lmdl = STRING ('loadSDTBufLib3264.so')
   if (!VERSION.RELEASE LE '5.4') then begin
       flg64 = 0
       lmdl = STRING ('loadSDTBufLib.so')
   endif

   ; Based on the inputs, get the index, etc. information:
   valid = CALL_EXTERNAL (lmdl, 'getDQIInformationExt', args)

   IF NOT valid THEN BEGIN
       print, '@(#)get_fast_esa_mdata_bundled.pro	1.5: error getting DQI info.'
       IF n_elements(tselection) GT 0 THEN idx = -1
       return, -1.
   ENDIF

   ; build up the return struct array.  We now know exactly how
   ; many array elements to allocate:
   dim1 = 0L
   dim2 = 0L
   narr = 0L
   dim1 = args.mxdim(0)
   dim2 = args.mxdim(1)
   narr = args.pts_in_range

   ndesc1 = 0L
   ndesc2 = 0L
   ndesc1 = args.nadesc(0)
   ndesc2 = args.nadesc(1)

   nsubdims1 = 0L
   nsubdims2 = 0L
   nsubdims1 = args.nsubdims(0)
   nsubdims2 = args.nsubdims(1)

   dat_arr = REPLICATE(                                                 $
   	{data_name:	'data_name',					$
              valid: 		1, 					$
              project_name:	'FAST', 				$
              units_name: 	'counts', 				$
              units_procedure:  'units_procedure',			$
              time: 		1.D, 					$
              end_time: 	2.D, 					$
              integ_t: 		3.D,					$
              nbins: 		fix(dim2),				$
              nenergy: 		fix(dim1),				$
              data: 		fltarr(dim1,dim2),	                $
              energy: 		fltarr(dim1,dim2),	                $
              theta: 		fltarr(dim1,dim2),	                $
              geom: 		fltarr(dim2),		                $
              denergy: 		fltarr(dim1,dim2),	                $
              dtheta: 		fltarr(dim2),		                $
              eff: 		fltarr(dim1), 				$
              mass: 		5.0D,					$
              geomfactor: 	4.0D,					$
              header_bytes: 	bytarr(44),				$
              index:		1L,                                     $
	      adesc_idx1:       0L,                                     $
	      adesc_idx2:       0L,                                     $
              spin_phase:	0.0D,                                   $
              spin_num:		0L,                                     $
              spin_ph_hdr:	0,                                      $
              sweep_num:	0,                                      $
              swps_per_set:	0},                                     $
	      narr)

   ; "dat_siz" is the size of the individual IDL structures.
   ; We need to use this value in the C-routine to navigate
   ; from structure to structure within "dat_arr".
   dat_siz = N_Tags(dat_arr, /Length)

   if defined(adesc1) then begin
       arr_desc1 = REPLICATE(                                           $
	         {nbins:            long(dim1),                         $
	          nsubdims:         long(nsubdims1),                    $
                  delta: 	    fltarr(dim1 * nsubdims1),	        $
                  midp: 	    fltarr(dim1 * nsubdims1) 	        $
		  },                                                    $
	          ndesc1)

       ad1_siz = N_Tags(arr_desc1, /Length)
   endif else begin
       ad1_siz = 0L
   endelse

   if defined(adesc1) then begin
       arr_desc2 = REPLICATE(                                           $
	         {nbins:            long(dim2),                         $
	          nsubdims:         long(nsubdims2),                    $
                  delta: 	    fltarr(dim2 * nsubdims2),	        $
                  midp: 	    fltarr(dim2 * nsubdims2) 	        $
		  },                                                    $
	          ndesc2)
        ad2_siz = N_Tags(arr_desc2, /Length)
    endif else begin
        ad2_siz = 0L
    endelse

    if ((ad1_siz * ad2_siz) GE 1L) then begin

       ;  This is the case where array descriptions ARE
       ;  returned.

       valid = CALL_EXTERNAL (lmdl, 'getSdtMDimDataFromIndices', args, $
   		    dat_arr, dat_siz, 1L, 2L, ad1_siz, ad2_siz, $
		arr_desc1, arr_desc2)

       adesc1 = arr_desc1

       adesc2 = arr_desc2

   endif else begin

       ;  This is the case where array descriptions are NOT
       ;  returned.

       valid = CALL_EXTERNAL (lmdl, 'getSdtMDimDataFromIndices', args, $
   		    dat_arr, dat_siz, 0L)

   endelse

   return, dat_arr
end



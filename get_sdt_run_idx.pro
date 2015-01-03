;+
; FUNCTION:
; 	 GET_SDT_RUN_IDX
;
; DESCRIPTION:
;
;	function to return the SDT multi-run index, if it can be
;       determined.
;	
; CALLING SEQUENCE:
;
;	sdt_idx= get_sdt_run_idx 
;
; ARGUMENTS:
;
;	none
;
; RETURN VALUE:
;
;	Upon success, a non-negative index is returned.  This index
;       represents the SDT index that the IDL program should use.
;
;       If an error occurred, the following negative integers
;       are returned.
;
;	   -1
;
; REVISION HISTORY:
;
;	@(#)get_sdt_run_idx.pro	1.2, 01/23/07
; 	Originally written by Jack B. Vernetti,  University of 
; 	California at Berkeley, Space Sciences Lab.   March 2004
;-


FUNCTION get_sdt_run_idx

 ; "SDT_IDL_MRUN_IDX" is the env variable that the SDT-to-IDL
 ; interface uses to store the SDT Index.
 test_sdt_ridx = getenv ('SDT_IDL_MRUN_IDX')

 if test_sdt_ridx eq '' then begin

   ; The SDT index for this invocation of IDL has not yet been set.
   ; Check "SDT_MRUN_IDX" - if this invocation of IDL is from "sdt_batch",
   ; it will have already been set to the SDT index:

   sdt_ridx = getenv ('SDT_MRUN_IDX')

   if sdt_ridx eq '' then begin

      ; We do not yet have the SDT multi-run index.  That means this is
      ; probably a UI invocation of SDT, and not a batch SDT:
      ;
      ; Call the C-routine:
      ;
      ;   get_mrun_sdt_idx
      ;
      ; to get a list of currently used UserInterface (non-batch)
      ; indices from which the user can choose.  If there is only
      ; one, we don't even have to prompt the user.

      flg64 = 1
      lmdl = STRING ('loadSDTBufLib3264.so')
      if (!VERSION.RELEASE LE '5.4') then begin
          flg64 = 0
          lmdl = STRING ('loadSDTBufLib.so')
      endif

      iret = 0
      njobs = long(0)
      sdt_idx0 = long(0)
      sdt_idx1 = long(0)
      sdt_idx2 = long(0)
      sdt_idx3 = long(0)
      sdt_idx4 = long(0)
      sdt_idx5 = long(0)
      sdt_idx6 = long(0)
      sdt_idx7 = long(0)
      sdt_idx8 = long(0)
      sdt_idx9 = long(0)
      desc_arr0 = bytarr(100)
      desc_arr1 = bytarr(100)
      desc_arr2 = bytarr(100)
      desc_arr3 = bytarr(100)
      desc_arr4 = bytarr(100)
      desc_arr5 = bytarr(100)
      desc_arr6 = bytarr(100)
      desc_arr7 = bytarr(100)
      desc_arr8 = bytarr(100)
      desc_arr9 = bytarr(100)

      iret = CALL_EXTERNAL (lmdl, 'get_mrun_sdt_idx',     $
		njobs,                                    $
		sdt_idx0,                                 $
		sdt_idx1,                                 $
		sdt_idx2,                                 $
		sdt_idx3,                                 $
		sdt_idx4,                                 $
		sdt_idx5,                                 $
		sdt_idx6,                                 $
		sdt_idx7,                                 $
		sdt_idx8,                                 $
		sdt_idx9,                                 $
		desc_arr0,                                $
		desc_arr1,                                $
		desc_arr2,                                $
		desc_arr4,                                $
		desc_arr5,                                $
		desc_arr6,                                $
		desc_arr7,                                $
		desc_arr8,                                $
		desc_arr9)

      if iret EQ 255 then begin
	      ; This is a SINGLE-session SDT - just return now.
              RETURN, iret
      endif

      if iret EQ 1 then begin

          if njobs EQ 0 then begin
	      ; There are no SDT's up right now - tell the user:

	      print, ' '
	      print, 'There are no SDT sessions in progress.
	      print, ' '

	      RETURN, -1

          endif

          if njobs EQ 1 then begin

	      ; There is only one session, so use it.  We call:
	      ;
	      ;   set_sdt_index
	      ;
	      ; to set "SDT_IDL_MRUN_IDX" and make sure that C-load
	      ; module knows the value.  Then we return the index to
	      ; the caller.

	      ret_idx = long(sdt_idx0)
	      set_sdt_index, ret_idx

              RETURN, ret_idx
          endif

	  print, ' '
	  print, 'There are multiple sessions of SDT and you must select,'
	  print, 'by Index from the following list of current SDT sessions,'
	  print, 'the one from which you wish to load data into IDL.'
	  print, 'Note that the title for main menu of each SDT ends with:'
	  print, '   idx=N  (where N is 0 through 9)'
	  print, 'and N indicates the Index for that invocation of SDT.'
	  print, 'These are the currently running SDTs:'
	  print, ' '
	  print, 'Index:  User:   Started At:'
	  print, ' '
	  for i1 = 0, njobs - 1  do begin
	      if i1 EQ 0 then begin
		  desc_rec = string(desc_arr0)
	      endif
	      if i1 EQ 1 then begin
		  desc_rec = string(desc_arr1)
	      endif
	      if i1 EQ 2 then begin
		  desc_rec = string(desc_arr2)
	      endif
	      if i1 EQ 3 then begin
		  desc_rec = string(desc_arr3)
	      endif
	      if i1 EQ 4 then begin
		  desc_rec = string(desc_arr4)
	      endif
	      if i1 EQ 5 then begin
		  desc_rec = string(desc_arr5)
	      endif
	      if i1 EQ 6 then begin
		  desc_rec = string(desc_arr6)
	      endif
	      if i1 EQ 7 then begin
		  desc_rec = string(desc_arr7)
	      endif
	      if i1 EQ 8 then begin
		  desc_rec = string(desc_arr8)
	      endif
	      if i1 EQ 9 then begin
		  desc_rec = string(desc_arr9)
	      endif
	      print, desc_rec
	  endfor
	  print, ' '

	  READ, sdt_ridx, PROMPT = 'Choose the appropriate Index from the above list: '
          ret_idx = long(sdt_ridx)

          set_sdt_index, ret_idx

          RETURN, ret_idx
      endif

      RETURN, -1

   endif else begin

      ; We already know the SDT multi-run index - so this is probably
      ; an "sdt_batch" invocation.  We get the index into "ret_idx",
      ; then call:
      ;
      ;   set_sdt_index
      ;
      ; to set "SDT_IDL_MRUN_IDX" and make sure that C-load module
      ; knows the value.  Then we return the index to the caller.

      ret_idx = long(sdt_ridx)

      set_sdt_index, ret_idx

      RETURN, ret_idx

   endelse

 endif else begin

   ; We already know the SDT-to-IDL multi-run index.  Return it
   ; to the caller.

   ret_idx = long(test_sdt_ridx)

   RETURN, ret_idx

 endelse
   
END


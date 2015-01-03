;+
;LAST MODIFICATION:	@(#)set_sdt_index.pro	1.1, 01/09/07
;-
pro set_sdt_index, InSdtRunIdx

   SdtIdxStr = 'SDT_IDL_MRUN_IDX=' + string(InSdtRunIdx)
   setenv, SdtIdxStr

   new_sdt_idx = long(InSdtRunIdx) ;

   lmdl = STRING ('loadSDTBufLib3264.so')
   if (!VERSION.RELEASE LE '5.4') then begin
       lmdl = STRING ('loadSDTBufLib.so')
   endif

   iret = CALL_EXTERNAL (lmdl, 'set_mrun_sdt_idx', new_sdt_idx)

   ; diags
   ; test_sdt_ridx = getenv ('SDT_IDL_MRUN_IDX')
   ; print, 'SDT run index set to: ', test_sdt_ridx
   ; end diags

return
end

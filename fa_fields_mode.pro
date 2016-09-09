;2016/09/09
FUNCTION FA_FIELDS_MODE,t1,t2

  COMPILE_OPT idl2

  IF N_ELEMENTS(t1) EQ 0 THEN BEGIN
     RETURN,-1
  ENDIF


  fieldsHdrDQD = ['DataHdr_1032','DataHdr_1048']

  haveIt = 0
  FOR k=0,N_ELEMENTS(fieldsHdrDQD)-1 DO BEGIN
     IF ~MISSING_DQDS(fieldsHdrDQD[k]) THEN BEGIN
        haveIt   = 1
        selected = k
        BREAK
     ENDIF
  ENDFOR

  IF ~haveIt THEN BEGIN
     PRINT,"Need one of these DQDs to get fields mode: " + fieldsHdrDQD
     PRINT,"(Hint: Load FastFieldsMode_10{32,48} into SDT)"
     RETURN,-1
  ENDIF

  fields_mode = REFORM((GET_FA_FIELDS(fieldsHdrDQD[k],t1,t2)).comp1[13,*])

  RETURN,fields_mode

END
;+
; PROCEDURE:
; 	 SHOW_DQIS
;
; DESCRIPTION:
;
;	Procedure to show what sdt data quantities are loaded into 
;	local shared memory.  These quantities should be accessable
;	from the loadSDTBuf package.
;
; CALLING SEQUENCE:
;
;	show_dqis
;
; REVISION HISTORY:
;
;	@(#)show_dqis.pro	1.7 09/08/09
; 	Originally written by Jonathan M. Loran,  University of 
; 	California at Berkeley, Space Sciences Lab.   Sep '95
;       Added RESULT keyword 19-Aug-97, Bill Peria
;-

pro show_dqis, result = result

; Check that we know the SDT session.  We do NOT need to consider
; a negative return as an error.
sdt_idx = get_sdt_run_idx()

sdt_idx_str=string(sdt_idx,format='(I3)')

prog = getenv('FASTBIN') + '/showDQIs ' + sdt_idx_str

if defined(result) then begin
    spawn, prog, result
endif else begin
    spawn, prog
endelse

end

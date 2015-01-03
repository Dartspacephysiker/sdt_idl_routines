;+
; NAME: FIND_GAPS
;
; NOTE: This routine is essentially made obsolete by FA_FIELDS_BUFS,
;       or by the /REPAIR option in GET_FA_FIELDS. 
;
; PURPOSE: to find times in tplot-like structures where there is a gap
; in time. The usual reason for this is to know where to insert
; !values.f_nan into some data, so that IDL won't draw a line across
; the gap. 
;
; CALLING SEQUENCE: gaps = find_gaps(my_data, ngaps)
;
;
; 
; INPUTS: the structure MY_DATA, which must have a tag TIME
;
;
; OUTPUTS: GAPS is an array of indices into MY_DATA.TIME. These
;          indices mark the *beginnings* of unusually large gaps in
;          MY_DATA.TIME. NGAPS is set to the number of gaps found. If
;          there are no gaps, GAPS will be -1, and NGAPS will be
;          zero.
;
; SLOP: If not zero, SLOP is added to 1.0 and used as a tolerance for
;       determining whether or not two time increments are equal. For
;       example, the HSBM on FAST works best if slop is 0.13. 
;
; SPIKE: If set, causes a 3 point median filter to be applied to the
;        input time increments. This also helps handle the FAST HSBM data. 
;
;
; MODIFICATION HISTORY: Written 18-July-1996 by Bill Peria
;
;-
function find_gaps,data,ngaps,slop=slop,spike=spike

fudge = 1.0d
if keyword_set(slop) then begin
    fudge = fudge + double(slop)
endif

maxchk = 100

intype = idl_type(data)
if intype ne 'structure' then begin
    ok_types=['integer','long','float','double']
    if (where(ok_types eq intype))(0) gt 0 then begin
        t = data - data(0)
    endif else begin
        message,'input type '+intype+' is not allowed!',/continue
        return,-1
    endelse
endif else begin
    tags = strlowcase(tag_names(data))
    if not (where(tags eq 'time'))(0) then begin
        message,'required tag TIME is missing!',/continue
        return,-1
    endif

    t = float(data.time - data.start_time)
endelse



nt = n_elements(t)
fnt = float(nt)

fdt = fltarr(nt)
rdt = fltarr(nt)
fdt(0:nt-2) = t(1:nt-1) - t(0:nt-2)
rdt(1:nt-1) = t(1:nt-1) - t(0:nt-2)
if keyword_set(spike) then begin
    fdt= median(fdt,3)
    rdt = median(rdt,3)
endif

dtmin = min(fdt(0:nt-2))
;
; diagnose nasty conditions...set dtmin to smallest sensible value
;
if (dtmin lt 0.0) then begin
    neg_incs = where(fdt lt 0,nni)
    if nni gt 1 then begin
        incs = 'increments'
    endif else begin
        incs = 'increment'
    endelse    
    message,'found '+strcompress(nni)+ ' negative time '+incs+'!',/continue
endif

if (dtmin le 0.0) then begin
    pos = where(fdt gt 0.0)
    dtmin = min(fdt(pos))
endif
;
; integerize the delta t's...
;

fsteps = round(fdt/dtmin)       ; ROUND returns a longword, time step
rsteps = round(rdt/dtmin)       ; scaled by minimum time step.

;
; deal with ends...
;
if (rsteps(1) eq rsteps(2)) then rsteps(0) = fsteps(0)
if (fsteps(nt-2) eq fsteps(nt-1)) then fsteps(nt-1) = rsteps(nt-1)

maybe_gaps = where(fsteps gt rsteps*fudge,nmg)
;
; eliminate increases in sample time, which are not gaps...
;
if (nmg gt 0) then begin
    gaps = maybe_gaps(where((fsteps(maybe_gaps+1) gt $
                             fsteps(maybe_gaps)*fudge) or $
                            (fsteps(maybe_gaps+1) lt $
                             fsteps(maybe_gaps)/fudge),ngaps))
endif else begin
    ngaps = 0l
    gaps = -1l
endelse

return,gaps
end




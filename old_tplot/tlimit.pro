;+
;PROCEDURE:   tlimit,t1,t2
;PURPOSE:  defines time range for "tplot"
;	   (tplot must be called first)
;INPUTS:  Starting and Ending times.  These can be string, double (seconds
;   since 1970), or hours since refdate.  If no Input is given then the cursor
;   is used to select times from the most recent time plot.
;EXAMPLES:
;   tlimit                     ; Use the cursor
;   tlimit,'12:30','14:30'
;   tlimit, 12.5, 14.5
;   tlimit,t,t+3600            ; t must be set previously
;   tlimit,/FULL               ; full limits
;   tlimit,/LAST               ; previous limits
;
;CREATED BY:	Davin Larson
;FILE:  tlimit.pro
;VERSION:  1.15
;LAST MODIFICATION:  97/02/05
;-
pro tlimit,d1,d2,  $
FULL = full,  $
LAST = last,  $
ZOOM = zoom,  $
REFDATE = refdate

@tplot_com.pro
if data_type(refdate) eq 7 then tplot_refdate = refdate

n = n_params()
temp       = trange
tr         = tplot_x.crange * time_scale + time_offset

if keyword_set(zoom) then begin
   tmid = (tr(0)+tr(1))/2
   tdif = (tr(1)-tr(0))/2
   trange = tmid+ zoom*[-tdif,tdif]
   n = -1
endif

if keyword_set(full) then begin
  trange = trange_full
  n = -1
endif

if keyword_set(last) then begin
  trange = trange_old
  n = -1
endif

if n eq 0 then begin
  ctime,t,npoints=2,prompt="Use cursor to select a begin time and an end time"
  if n_elements(t) eq 0 then return
  t1 = t(0)
  t2 = t(1)
  delta = tr(1) - tr(0)
  case 1 of
    (t1 lt tr(0)) and (t2 gt tr(1)):  trange = trange_full      ; full range
    (t1 gt tr(1)) and (t2 gt tr(1)):  trange = tr + delta       ; pan right
    (t1 lt tr(0)) and (t2 lt tr(0)):  trange = tr - delta       ; pan left
    t2 lt t1:                         trange = trange_old       ; last limits
;    t2 gt tr(1):                      trange = tr + (t1-tr(0))  ; pan right
;    t1 lt tr(0):                      trange = tr + (tr(1)-t2)  ; pan left
    else:                             trange = [t1,t2]          ; new range
  endcase
endif
if n eq 1 then begin
    if n_elements(d1) eq 2 then trange = gettime(d1) $
    else trange = [gettime(d1),gettime(d1)+tr(1)-tr(0)]
endif
if n eq 2 then   trange = gettime([d1,d2])

tplot
trange_old = temp
return
end


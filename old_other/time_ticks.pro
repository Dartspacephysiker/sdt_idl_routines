;+
;FUNCTION:  time_tk_str = time_ticks(timerange,offset)
;NAME:
;  time_ticks
;PURPOSE:
;  Returns a structure that can be used to create time ticks for a plot.
;  See "timetick" for more info
;INPUT:  
;  timerange: Two element vector specifying the time range of the plot
;      this input can be obtained from: "time_double", "time_struct"
;      or "time_string"
;  offset: named variable in which offset time is placed.
;KEYWORDS:
;  NUM_LAB_MIN:   minimum number of labels for bottom axis.
;
;OUTPUT:
;  a structure that can be used with the _EXTRA keyword of the PLOT routine
;
;See Also: "box", "tplot"
;       
; NOTES:
;
;     The returned time_tk_str has tags named so that it can be used
;     with the special _EXTRA keyword in the call to PLOT or OPLOT.
;
;     The offset value that is returned from timetick must be
;     subtracted from the time-axis data values before plotting.
;     This is to maintain resolution in the PLOT routines, which use
;     single precision floating point internally.  Remember that if
;     the CURSOR routine is used to read a cursor position from the
;     plot, this offset will need to be added back to the time-axis
;     value to get seconds since  1970-01-01/00:00:00.
;
;NOTE:
;  This routine is an enhanced version of the routine "timetick"
;  See this routine for more info on usage
;
;WARNING!:
;  This routine does not yet work on very small time scales.
;
;CREATED BY:	Davin Larson  Oct 1996
;FILE:  time_ticks.pro
;VERSION:  1.8
;LAST MODIFICATION:  97/12/16
;-
function time_ticks,timerange,offset $
  ,help=help   $
  ,tickinterval=tickinterval $
  ,side_label=side_string   $
  ,xtitle=xtitle   $
  ,num_lab_min=num_lab_min

units = ['year','month','date','hour','minute','second','millisecond']
d = 3600. * 24.
dtime = [365.25*d, 30.*d, d,3600.,60.,1.,0.001]

labels = ['Year','Year','Month','Date','hhmm','Seconds','Seconds','Date',$
	'Milliseconds']
pos   =  [0, 0, 5, 9, 12, 17, 19, 5, 19]
width =  [0, 4, 3, 2,  4,  2,  4, 6,  5]
yyyy =1
mmm  =2
dd   =3
hhmm = 4
ss   = 5
iii  = 8
mmm_dd = 7

tick_format = {tick_info,dt:0.,unit:0,inc:1,nminor:0,fld1:0,unit2:0,fld2:0}

setup = [ $
{tick_info, 0.,  0,1000, 10, yyyy   , 0,  0}, $
{tick_info, 0.,  0, 500, 5, yyyy   , 0,  0}, $
{tick_info, 0.,  0, 200, 2, yyyy   , 0,  0}, $
{tick_info, 0.,  0, 100, 10, yyyy   , 0,  0}, $
{tick_info, 0.,  0,  50, 5, yyyy   , 0,  0}, $
{tick_info, 0.,  0,  20, 2, yyyy   , 0,  0}, $
{tick_info, 0.,  0,  10, 10, yyyy   , 0,  0}, $
{tick_info, 0.,  0,   5, 5, yyyy   , 0,  0}, $
{tick_info, 0.,  0,   2, 2, yyyy   , 0,  0}, $
{tick_info, 0.,  0,   1, 12, yyyy   , 0,  0}, $
{tick_info, 0.,  1,   6, 6, mmm    , 0,  yyyy}, $
{tick_info, 0.,  1,   4, 4, mmm    , 0,  yyyy}, $
{tick_info, 0.,  1,   3, 3, mmm    , 0,  yyyy}, $
{tick_info, 0.,  1,   2, 2, mmm    , 0,  yyyy}, $
{tick_info, 0.,  1,   1, 2, mmm    , 0,  yyyy}, $
{tick_info, 0.,  2,  20, 20, mmm_dd , 0,  yyyy}, $
{tick_info, 0.,  2,  10, 10, mmm_dd , 0,  yyyy}, $
{tick_info, 0.,  2,   5, 5, dd     , 1,  mmm}, $
{tick_info, 0.,  2,   2, 2, dd     , 1,  mmm}, $
{tick_info, 0.,  2,   1, 4, dd     , 1,  mmm}, $
{tick_info, 0.,  3,   12, 12, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  3,   8, 8, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  3,   4, 4, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  3,   2, 2, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  3,   1, 6, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  4,  30, 3, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  4,  20, 2, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  4,  10, 10, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  4,   5, 5, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  4,   2, 2, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  4,   1, 6, hhmm   , 2,  mmm_dd}, $
{tick_info, 0.,  5,  30, 6, ss     , 4,  hhmm}, $
{tick_info, 0.,  5,  20, 4, ss     , 4,  hhmm}, $
{tick_info, 0.,  5,  10, 10, ss     , 4,  hhmm}, $
{tick_info, 0.,  5,   5, 5, ss     , 4,  hhmm}, $
{tick_info, 0.,  5,   2, 2, ss     , 4,  hhmm}, $
{tick_info, 0.,  5,   1, 10, ss     , 4,  hhmm}, $
{tick_info, 0., 11, 200, 2, iii	   , 5, ss}, $
{tick_info, 0., 11, 100,10, iii	   , 5, ss}, $
{tick_info, 0., 11, 50, 5, iii	   , 5, ss}, $
{tick_info, 0., 11, 20, 2, iii	   , 5, ss}, $
{tick_info, 0., 11, 10,10, iii	   , 5, ss}, $
{tick_info, 0., 11, 5, 5, iii	   , 5, ss}, $
{tick_info, 0., 11, 2, 2, iii	   , 5, ss}, $
{tick_info, 0., 11, 1,10, iii	   , 5, ss} $
      ]

n = n_elements(setup)

setup.dt = dtime(setup.unit) * setup.inc

if keyword_set(help) then begin
  s = time_string(8.3d8,/format)
  print,s
  for i=0,n_elements(pos)-1 do print,';',i,'  <',strmid(s,pos(i),width(i)),'>'
  return,setup.dt
endif

range = minmax_range( time_double(timerange) )

if not keyword_set(num_lab_min) then  num_lab_min = 3.

deltatime = (range(1)-range(0))/num_lab_min
;help,deltatime,num_lab_min

if keyword_set(tickinterval) then deltatime=tickinterval

w = where(setup.dt le deltatime,count)
if count eq 0 then begin
   message,/info,"Time range too small"
   return,0
endif
i = w(0)

if i lt 0 then begin
  x = alog10(deltatime)
  e = floor(x)
  n = [1,2,5]
  n = n(fix((x-e)*3))
  dt = n * 10.d^e
  help,deltatime,n,e,dt
  stop
endif

set = setup(i)
unit = set.unit
inc  = set.inc
fld1 = set.fld1
fld2 = set.fld2


st = time_struct(range(0))
str_element,st,'ms',st.fsec*1000,/add

clear=[0,1,1,0,0,0,0,0,0,0,0,0]
st.(unit) = floor((st.(unit)-clear(unit)) / inc) * inc + clear(unit)
for i= unit+1,6  do st.(i)=clear(i)

nst =30
sts = replicate(st,nst)
sts.(unit) = sts.(unit) + indgen(nst) * inc
sts.fsec = sts.ms/1000d0

times   = time_double(sts)
offset = times(0)

if data_type(xtitle) ne 7 then xtitle = ''
xtitle = '!C'+xtitle
;Time (UT)' + time_string(times(0),/form)

w = where(times ge range(0) and times le range(1),nlabs)
if nlabs le 1 then stop
times=times(w)
struct  = time_struct(times)
strings = time_string(times,/format,prec=4)


strings1 = strmid(strings,pos(fld1),width(fld1))
strings2 = strmid(strings,pos(fld2),width(fld2))
side_string = ''


if fld2 ne 0 then begin
   u = set.unit2
   ch = struct.(u)
   dch = ch - shift(ch,1)
   w = where(dch eq 0,count0)
   if count0 ne 0 then  strings2(w) = ''

   w = where(dch ne 0,count1)
   if count1 eq 0 then begin
      side_string = strmid(strings(0),0,pos(fld1) )
                          ; high level does change
;print,'case 1 '
   endif else begin
;print,'case 2 '
      side_string = strmid(strings(0),0,pos(fld2) )
                                ; high level does not change (full string)
   endelse
endif
str = strings1+'!C'+strings2

;print,fld1,labels(fld1)
side_string= labels(fld1)+'!C'+side_string

tick_str = { $
  XTICKNAME: str, $
  XTICKV: times -offset, $
  XTICKS: n_elements(times)-1, $
  XMINOR: set.nminor, $
  XRANGE: range - offset, $
  XSTYLE: 1, $
  XTITLE: xtitle $
}
return,tick_str
end



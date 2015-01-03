;+
;PROCEDURE:	load_wi_wav
;PURPOSE:	
;   loads WIND WAVES Experiment key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;RESTRICTIONS:
;  This routine expects to find the master file: 'wi_k0_wav_files'
;  In the directory specified by the environment variable: 'CDF_DATA_DIR'
;  See "make_cdf_index" for more info.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_wav.pro
;LAST MODIFICATION: 97/02/05
;-
pro load_wi_wav,time_range=trange,data=d,nvdata=nd $
   ,masterfile=masterfile $
   ,moon=moon

indexfile = 'wi_k0_wav_files'
cdfnames = ['Ne','Ne_Quality',  'E_Average','Moon_pos']
tagnames = ['Nel','Ne_Quality', 'E_A','moon_pos']
novarnames = ['E_freq_val']

d=0

loadallcdf,time_range=trange,indexfile=indexfile, $
   cdfnames=cdfnames,tagnames=tagnames,data=d, $
   novarnames=novarnames,novard=nd

if not keyword_set(d) then return

n = d.nel
w = where((d.ne_quality lt 100) or (n lt 0.) or (n gt 300.),nw)
if nw ne 0 then n(w)=!values.f_nan

px = 'wi_wav_'

store_data,px+'Ne',data={x:d.time,y:d.nel}
store_data,px+'Pow',data={x:d.time,y:dimen_shift(d.e_a,1),v:nd.E_freq_val}$
  ,min=-0.1 $
  ,dlim={ytitle:'Freq (Hz)',spec:1,ylog:1,ystyle:1,panel_size:2.  $
  ,yrange:[4e3,1.2e7],zrange:[0.,80.],ztitle:'WAVES Power'}
if keyword_set(moon) then $
  store_data,'moon_pos',data={x:d.time,y:d.moon_pos},min=-1e30

end

;+
;PROCEDURE:	load_wi_mfi
;PURPOSE:	
;   loads WIND MAGNETOMETER Experiment key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  POLAR:       Also computes the B field in polar coordinates.
;  TIME_RANGE:  2 element vector specifying the time range
;  DATA:        Data returned in this named variable
;RESTRICTIONS:
;  This routine expects to find the master file: 'wi_k0_mfi_files'
;  In the directory specified by the environment variable: 'CDF_DATA_DIR'
;  See "make_cdf_index" for more info.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_mfi.pro
;LAST MODIFICATION: 97/02/05
;-
pro load_wi_mfi,time_range=trange,data=d,nvdata=nd,polar=polar, $
   prefix= prefix, $
   masterfile=masterfile

indexfile = 'wi_k0_mfi_files'
cdfnames = ['BGSEc','RMS','DQF']

loadallcdf,indexfile=indexfile,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange


bad = where(d.dqf,nbad)
if nbad ne 0 then begin
   tags = tag_names(d)
   for i=0,n_tags(d)-1 do begin
;      help,  tags(i), d(bad).(i)
      dt = data_type(d.(i))
      if tags(i) eq 'TIME' then dt=0
      if (dt eq 4) or (dt eq 5) then d(bad).(i)=!values.f_nan
   endfor
endif


if data_type(prefix) eq 7 then px=prefix else px = 'wi_'

;name = px+'B'

store_data,px+'B',data={x:d.time,y:dimen_shift(d.BGSEc,1)},max=900. $
  , dlim={labels:['Bx','By','Bz']}
store_data,px+'B_rms',data={x:d.time,y:dimen_shift(d.RMS,1)},max=900. 

if keyword_set(polar) then begin
   xyz_to_polar,px+'B'
   options,px+'B_mag','ytitle','|B|'
   options,px+'B_th','ytitle','!9Q!X!DB!U'
   ylim,px+'B_th',-90.,90.,0
   
   options,px+'B_phi','ytitle','!9F!X!DB!U'
   ylim,px+'B_phi',-180.,180.
   options,px+'B_phi','psym',3
endif

end

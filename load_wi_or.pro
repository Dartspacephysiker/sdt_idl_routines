;+
;PROCEDURE:	load_wi_or
;PURPOSE:	
;   loads WIND 3D Plasma Experiment orbit data for "tplot".
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  POLAR:       Computes polar coordinates if set.
;  TIME_RANGE:  2 element vector specifying the time range
;RESTRICTIONS:
;  This routine expects to find the master file: 'wi_or_def_files'
;  In the directory specified by the environment variable: 'CDF_DATA_DIR'
;  See "make_cdf_index" for more info.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_or.pro
;LAST MODIFICATION: 97/02/05
;-
pro load_wi_or,time_range=trange,data=d,polar=polar,pre=pre,nodata=nodat

if keyword_set(pre) then indexfile='wi_or_pre_files' $
else indexfile = 'wi_or_def_files'

cdfnames = ['GSE_POS']

d=0
nodat=0
loadallcdf,indexfile=indexfile,cdfnames=cdfnames,data=d,time_range=trange

if keyword_set(d) eq 0 then begin
   message,'No WIND orbit data during this time. Aborting.',/info
   nodat=1
   return
endif


pos = dimen_shift(d.gse_pos/6370.,1)
lab = ['X','Y','Z']

store_data,'wi_pos',data={x:d.time,y:pos}, dlim={labels:lab},min=-1e30

if keyword_set(polar) then begin
   xyz_to_polar,'wi_pos',/ph_0_360
   options,'wi_pos_mag','ytitle','D (R!dE!n)',/default
   options,'wi_pos_th','ytitle','!9Q!X!DSC!U',/default
   options,'wi_pos_phi','ytitle','!9F!X!DSC!U',/default
   options,'wi_pos_phi','format','(f4.0)',/default
endif

end

;+
;PROCEDURE:	load_wi_swe
;PURPOSE:	
;   loads WIND Solar Wind Experiment key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;RESTRICTIONS:
;  This routine expects to find the master file: 'wi_k0_swe_files'
;  In the directory specified by the environment variable: 'CDF_DATA_DIR'
;  See "make_cdf_index" for more info.
;  
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_swe.pro
;LAST MODIFICATION: 97/01/26
;-
pro load_wi_swe,time_range=trange,data=d,polar=polar;,prefix=prefix

indexfile = 'wi_k0_swe_files'
cdfnames = ['Np','THERMAL_SPD','V_GSE'];,'Alpha_Percent']

loadallcdf,time_range=trange,indexfile=indexfile,cdfnames=cdfnames,data=d

nan = !values.f_nan
bad = where(d.np lt 0,c)
if c gt 0 then for i=1,n_tags(d)-1 do d(bad).(i) = nan


;if c gt 0 then begin
;   d(bad).np = nan
;   d(bad).thermal_spd = nan
;   d(bad).v_gse = nan
;   d(bad).alphapercent = nan
;endif

tp = .00522 * d.thermal_spd^2

d.V_GSE(1) = d.V_GSE(1) + 29.86  ;remove Earth motion correction

store_data,'wi_swe_Np',data={x:d.time,y:d.NP}
store_data,'wi_swe_Vp',data={x:d.time,y:dimen_shift(d.V_GSE,1)}
store_data,'wi_swe_Tp',data={x:d.time,y:tp}
store_data,'wi_swe_VTHp',data={x:d.time,y:d.thermal_spd}
;store_data,'wi_swe_A/P',data={x:d.time,y:d.alpha_percent}
if keyword_set(polar) then xyz_to_polar,'wi_swe_Vp',/ph_0_360


end

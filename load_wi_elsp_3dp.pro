;+
;PROCEDURE:	load_wi_elsp_3dp
;PURPOSE:	
;   loads WIND 3D Plasma Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  TIME_RANGE:  2 element vector specifying the time range
;RESTRICTIONS:
;  This routine expects to find the master file: 'wi_elsp_3dp_files'
;  In the directory specified by the environment variable: 'CDF_INDEX_DIR'
;  See "make_cdf_index" for more info.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_elsp_3dp.pro
;LAST MODIFICATION: 97/01/20
;-
pro load_wi_elsp_3dp $
   ,time_range=trange $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,prefix = prefix $
   ,polar=polar

indexfile = 'wi_elsp_3dp_files'

cdfnames = ['FLUX',  'ENERGY' ]

loadallcdf,indexfile=indexfile,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange

if data_type(prefix) eq 7 then px=prefix else px = 'elsp'


store_data,px,data={x:d.time,y:dimen_shift(d.flux,1),v:dimen_shift(d.energy,1)}$
  ,min=-1e30,dlim={ylog:1}

end

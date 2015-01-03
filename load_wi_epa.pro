;+
;PROCEDURE:	load_wi_epa
;PURPOSE:	
;   loads WIND Energetic Particle Analyser key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;SEE ALSO: 
;  "make_cdf_index"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_epa.pro
;LAST MODIFICATION: 96/08/23
;
;-
pro load_wi_epa

indexfile = 'wi_k0_epa_files'
cdfnames = ['LEMT1','LEMT2','APEB1','APEB2','APEB3','APEB4','APEB5', $
   'STEP1','STEP2','STEP3','STEP4','STEP5','STEP6']

loadallcdf,indexfile=indexfile,cdfnames=cdfnames,/tplot

end

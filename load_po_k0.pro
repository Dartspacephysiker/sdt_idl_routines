;+
;PROCEDURE:	load_po_k0,starttime,endtime
;PURPOSE:
;    Load cdf files contain polar data into tplot structures.
;
;
;
;INPUT:  Starttime, Endtime  These must be strings, and thus surrounded by ''.
;            '1997-01-11/12:12:00', '1997-01-11/23:10:00'
;
;KEYWORDS:
;
;CREATED BY: S. Wittenbrock	Feb '97
;
;LAST MODIFICATION:	make_po_k0.pro		1.0 02/12/97
;
;

PRO load_po_k0, starttime, endtime

cdfmastdir = getenv('CDF_INDEX_DIR')

; use loadallcdf to bring cdf data into tplot structures

loadallcdf, masterfile= cdfmastdir + '/polar_mast/po_at_def_index', $
	time_range=[ string(starttime), string(endtime) ], /tplot

loadallcdf, masterfile= cdfmastdir + '/polar_mast/po_or_def_index', $
	time_rang=[ string(starttime), string(endtime) ], /tplot

END

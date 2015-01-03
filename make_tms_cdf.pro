;+
;PROCEDURE: make_tms_cdf
;PURPOSE:
;	Make a CDF file with TEAMS data
;
;INPUT:
;	data_str:       'TSP', 'TSA', 'TSH', 'TSO', or 'TBP', 'TBA', 'TBH', 
;			'TBO', etc.
;			That is, the format is 'TXY', where T stands for 
;			teams, X is the TYPE, Y is the SPECIES (see keywords
;			below.
;			if given, TYPE and SPECIES keywords overridden.
;KEYWORDS:
;	TYPE		String indicating type of data to use: 's'(urvey),
;			'b'(urst), 'h'(iMass), or 'p'(ole)
;	SPECIES		String indicating ion species to use: 'p'(rotons),
;			'a'(lphas), 'h'(elium), or 'o'(xygen)
;	T1		Start time, seconds since 1970
;	T2		End time, seconds since 1970
;	NENERGY		Number of energy bins
;	NBINS		Number of angle bins
;	NMASS		Number of mass bins
;	UNITS		Convert to these units if included
;	NAME		Filename to which data are saved
;	GAP_TIME	Time interval to flag a data gap
;
;NOTES:
;	If HiMass data are requested, the SPECIES keyword is ignored.
;	The NMASS keyword is only meaningful for HiMass data.
;
;	for www Hires cdf production:
;	data_str: 	TSP, TSO, TSH, TSA
;	sdt config:	Tms_Survey
;	APIDs:		1027, 1080
;
;CREATED BY:	E. J. Lund	2001/05/18
;VERSION:	1.0
;LAST MODIFICATION:		2001/05/19
;MODIFICATION HISTORY:
;	KRBromund  -  added data_str argument
;-
pro make_tms_cdf, data_str, TYPE = type, SPECIES = species, T1 = t1, T2 = t2, $
	NENERGY = nenergy, NBINS = nbins, NMASS = nmass, $
	UNITS = units, NAME = name, GAP_TIME = gap_time

if n_params() gt 0 then begin ; NOTE: overrides TYPE and SPECIES keywords
	type = strmid(data_str,1,1)
	species = strmid(data_str,2,1)
endif  else begin
	data_str = ''
endelse

; Construct the output filename: Default is
; $IDL_HIRES_OUTDIR/$IDL_HIRES_CDFNAME. If NAME keyword contains a /,
; put the file in that location; otherwise put the file in
; $IDL_HIRES_OUTDIR (to put it in the current directory, begin NAME with
; ./).
outdir = getenv('IDL_HIRES_OUTDIR')
outname = getenv('IDL_HIRES_CDFNAME')
;if outdir eq '' then outdir = './' else outdir = outdir + '/'
if outname eq '' then outname = 'fa_tms'+data_str+'.cdf'
if keyword_set(name) then begin
   if  strpos(name, '/') eq -1 then name = outdir + name
endif
if not keyword_set(name) then name = outdir + outname

; Determine the species from the first letter of the SPECIES keyword.
; Default is 'p' (protons).
if keyword_set(species) then species = strlowcase(strmid(species, 0, 1)) $
else species = 'p'

; Determine the data type from the first letter of the TYPE keyword.
; Default is 's' (survey).
if keyword_set(type) then type = strlowcase(strmid(type, 0, 1)) $
else type = 's'

; Set default units if needed: RATE for HiMass, Eflux for other types
if not keyword_set(units) then begin
	if type eq 'h' then units = 'RATE' else units = 'Eflux'
endif

; Construct the appropriate CDF file
case type of
	's': begin ; survey data
		make_tms_svy_cdf, species = species, t1 = t1, t2 = t2, $
			nenergy = nenergy, nbins = nbins, units = units, $
			name = name, gap_time = gap_time
	     end
	'b': begin ; burst data
		make_tms_bst_cdf, species = species, t1 = t1, t2 = t2, $
			nenergy = nenergy, nbins = nbins, units = units, $
			name = name, gap_time = gap_time
	     end
	'h': begin ; HiMass data
		make_tms_hm_cdf, t1 = t1, t2 = t2, nenergy = nenergy, $
			nbins = nbins, nmass = nmass, units = units, $
			name = name, gap_time = gap_time
	     end
	'p': begin ; pole data
		make_tms_pol_cdf, species = species, t1 = t1, t2 = t2, $
			nenergy = nenergy, nbins = nbins, units = units, $
			name = name, gap_time = gap_time
	     end
	else: message, 'Unrecognized TEAMS data type'
endcase
return
end


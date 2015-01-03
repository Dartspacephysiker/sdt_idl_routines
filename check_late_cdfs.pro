;+
; IDL BATCHFILE:
;
;   check_late_cdfs.pro
;
; PURPOSE:
;
;   Calls compare_cdf_ats.pro to check timespans of recently produced
;   CDFs.  Meant to be called from a script run as a daily cron job.
;
; CALLING SEQUENCE:
;
;   idl check_late_cdfs
;
; ENVIRONMENT VARIABLES:
;
;   QUANTITY    'ees', 'ies', 'tms', 'acf', 'dcf'
;   ONTIMES     Full path to file containing nominal data collection
;               periods against which to compare CDF timespans.
;   FIRSTORB    The first orbit in the interval to check.
;   LASTORB     The last orbit to check.
;   DANETDIR    Required to build the name of the output file.
;-

@startup

ontimes = getenv('ONTIMES')
qty = getenv('QUANTITY')
firstorb = fix(getenv('FIRSTORB'))
lastorb = fix(getenv('LASTORB'))
danetdir = getenv('DANETDIR')
outputfile = danetdir + '/check_' + qty

compare_cdf_ats, qty=qty, ontimes=ontimes, firstorb, lastorb, out=outputfile

exit


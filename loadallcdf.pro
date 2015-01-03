;+
;PROCEDURE: loadallcdf
;PURPOSE:
;  Loads selected CDF file variables into tplot variables.
;KEYWORDS:  (all keywords are optional)
;  FILENAMES:   string (array); full pathname of file(s) to be loaded.
;     (INDEXFILE, ENVIRONVAR, MASTERFILE and TIME_RANGE are ignored 
;     if this is set.)
;
;  MASTERFILE:  Full Pathname of indexfile. (INDEXFILE and ENVIRONVAR are 
;     ignored if this is set)
;
;  INDEXFILE:   File name (without path) of indexfile. This file should be
;     located in the directory given by ENVIRONVAR.  If not given then 
;     "PICKFILE" is used to select an index file. see "make_cdf_index" for
;     information on producing this file.
;  ENVIRONVAR:  Name of environment variable containing directory of indexfiles
;     (default is 'CDF_INDEX_DIR')
;
;  TIME_RANGE:  Two element vector specifying time range (default is to use
;     trange_full; see "TIMESPAN" or "GET_TIMESPAN" for more info)
;
;  CDFNAMES     Names of CDF variables to be loaded. (string array)
;  DATA:        Named variable that data is returned in.
;
;  NOVARNAMES:  Names of 'novary' variables to be loaded
;  NOVARDATA:   Named variable that 'novary' data is returned in.
;
;  TPLOT:       If set then data is also put in "TPLOT" format.
;SEE ALSO:
;  "loadcdf","loadcdfstr","makecdf","make_cdf_index","get_file_names"
;VERSION:  07/02/12  loadallcdf.pro  1.13
;Created by Davin Larson,  August 1996
;Documentation still incomplete.
;-
pro loadallcdf, $
   FILENAMES  = filenames, $
   MASTERFILE = mfile, $
   cdfnames=cdfnames, $
   tagnames=tagnames, $
   indexfile=indexfile, $
   time_range=trange, $
   environvar=environvar, $
   data=data, novardata=novardata, $
   tplot=tplot, $
   novarnames=novarnames, $
   param=param

;if keyword_set(indexfile) then no_dup = strpos(indexfile,'_files')+9

if not keyword_set(filenames) then begin
  if not keyword_set(mfile) then begin
    if not keyword_set(environvar) then environvar = 'CDF_INDEX_DIR'

    dir = getenv(environvar)
    if not keyword_set(dir) then $
       message,'Environment variable '+environvar+' is not defined!' ,/info

    if not keyword_set(indexfile) then mfile = dialog_pickfile(path=dir) $
    else mfile = filepath(indexfile,root_dir=dir)
  endif

  get_file_names,filenames,TIME_RANGE=trange,MASTERFILE=mfile,nfiles=ndays $
     ,no_dup=no_dup

if ndays eq 0 then begin
;   tstr = time_string(trange)
;   print,'No data available from ',tstr(0), ' to ',tstr(1),' in ',mfile
;   filenames=''
   data=0
   novardata=0
   return
endif

endif


if keyword_set(pickcdfnames) then begin
   print_cdf_info,filenames(0)
   print,'Choose data quantities:'
   repeat begin
     s = ''
     read,s
     if keyword_set(s) then if keyword_set(cdfnames) then $
         cdfnames = [cdfnames,s] else cdfnames=s
   endrep until keyword_set(s) eq 0
endif

loadcdfstr,data,novardata  $
  ,file=filenames,varnames=cdfnames,tagna=tagnames,novarnames=novarnames,/time

if keyword_set(tplot) then begin
  message,/info,'Storing in tplot variables'
  tagnames = tag_names(data)
  for n = 1,n_elements(tagnames)-1 do begin
    dat = {x:data.time, y:dimen_shift(data.(n),1)}
    store_data,tagnames(n),data=dat
  endfor
endif


end


;+
;PROCEDURE:	load_wi_sp_mfi
;PURPOSE:	
;   loads WIND MAGNETOMETER 3 second data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;  POLAR:       Also computes the B field in polar coordinates.
;  DATA:        Data returned in this named variable
;RESTRICTIONS:
;  This routine expects to find the master file: 'wi_sp_mfi_files'
;  In the directory specified by the environment variable: 'CDF_DATA_DIR'
;  See "make_cdf_index" for more info.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_sp_mfi.pro
;VERSION: 1.10
;LAST MODIFICATION: 97/02/05
;-


pro load_wi_sp_mfi,time_range=trange,polar=polar,data=d,  $
  nodata=nodat, $
  prefix = prefix, $
  name = bname, $
  masterfile=masterfile
     
indexfile = 'wi_sp_mfi_files'
cdfnames = ['B3GSE','B3RMSGSE']

d=0
nodat = 0

loadallcdf,time_range=trange,indexfile=indexfile,masterfile=masterfile, $
    cdfnames=cdfnames,data=d

if keyword_set(d) eq 0 then begin
   message,'No 3 second MFI data during this time. Aborting.',/info
   nodat=1
   return
endif


if data_type(prefix) eq 7 then px=prefix else px = 'wi_'
if data_type(bname) eq 7 then px = bname else px = px+'B3'

labs=['B!dx!n','B!dy!n','B!dz!n']


ndat = n_elements(d.time)

t = replicate(1.,20) # d.time
dt = (findgen(20)*3.-28.5) # replicate(1.,ndat)
t = t+dt
time  = reform(t,ndat*20)
b3gse = transpose(reform(d.b3gse,3,ndat*20))
b3rmsgse = transpose(reform(d.b3rmsgse,3,ndat*20))

store_data,px,data={x:time,y:b3gse},min= -1e30, lim={labels:labs}
store_data,px+'_rms',data={x:time,y:b3rmsgse},min= -1e30 

if keyword_set(polar) then begin
   xyz_to_polar,px

;for postscript
   options,px+'_mag','ytitle','|B|',/def
   options,px+'_th','ytitle','!9Q!X!DB!U',/def
   ylim,px+'_th',-90,90,0,/def
   options,px+'_phi','ytitle','!9F!X!DB!U',/def
   options,px+'_phi','psym',3,/def
   ylim,px+'_phi',-180,180,0,/def

;for xwindows
;   options,px+'_mag','ytitle','|B|'
;   options,px+'_th','ytitle','!7H!X!DB!U'
;   options,px+'_phi','ytitle','!7U!X!DB!U'
endif


end


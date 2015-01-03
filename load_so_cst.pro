;+
;PROCEDURE:	load_so_cst
;PURPOSE:	
;   loads SOHO CST key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;
;CREATED BY:	Davin Larson
;FILE:  load_so_cst.pro
;LAST MODIFICATION: 96/10/15
;
;-
pro load_so_cst,TIME_RANGE=trange

fname = 'so_k0_cst_files'
environvar = 'CDF_INDEX_DIR'
dir = getenv(environvar)
if not keyword_set(dir) then $
   message,'Environment variable '+environvar+' is not defined!' 

get_file_names,filenames,TIME_RANGE=trange,MASTERFILE=fname,ROOT=dir,nfile=ndays

if ndays eq 0 then begin
   print,"No so_k0_cst data available from ",time_to_str(trange(0)), ' to ', $
   time_to_str(trange(1))
   return
endif



for d=0,ndays-1 do begin
   print,'Loading file: ',filenames(d)
   id = cdf_open(filenames(d))
   loadcdf,id,'Time_PB5', pb5 ,/append 
   loadcdf,id,'Electron', n_e,/append 
   loadcdf,id,'Proton', n_p,/append 
   loadcdf,id,'Helium', n_a,/append
   loadcdf,id,'E_Energy', e_e
   loadcdf,id,'P_Energy', e_p
   loadcdf,id,'He_Energy', e_a

   cdf_close,id
endfor
;help,pb5,n_e,n_p,e_e,e_p,e_a

t = pb5_to_time(pb5)

;bad = where(n_e lt 0,count)
;if count ne 0 then n_e(bad) = !values.f_nan
store_data,'so_cst_elec',data={x:t,y:n_e,v:e_e, $
      labels:string(e_e,form='(f5.2)'),labflag:-1,ylog:1}
store_data,'so_cst_proton',data={x:t,y:n_p,v:e_p, $
      labels:string(e_p,form='(f5.2)'),labflag:-1,ylog:1}
store_data,'so_cst_alpha',data={x:t,y:n_a,v:e_a, $
      labels:string(e_a,form='(f5.2)'),labflag:-1,ylog:1}



end


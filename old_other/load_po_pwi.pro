;+
;PROCEDURE:	load_po_pwi
;PURPOSE:	
;  Loads Polar Plasma Wave Instrument key parameter data into "tplot" variables.
;
;INPUTS:
;   none, but will call "timespan" if time range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  TIME_RANGE:  2 element vector specifying the time range
;
;RESTRICTIONS:
;  This routine expects to find the master file: 'po_k0_pwi_files'
;  In the directory specified by the environment variable: 'CDF_DATA_DIR'
;  See "make_cdf_index" for more info.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_po_pwi.pro
;LAST MODIFICATION: 96/08/30
;
;-
pro load_po_pwi,TIME_RANGE=range,data=d

indexfile = 'po_k0_pwi_files'
cdfnames = ['Fce','Fcp','FcO','MLAT','EDMLT','L_Shell','GR_DIST','SFRA_Av_E','SFRA_Av_M' $
  ,'SFRB_Av_E','SFRB_Av_M','SFRA_Pk_E','SFRA_Pk_M','SFRB_Pk_E','SFRB_Pk_M']
novarnames= ['Frequency']

loadallcdf,indexfile=indexfile,cdfnames=cdfnames,novarnames=novarnames, $
   data=d,novardata=nd

if n_elements(d) eq 0 then return

px = 'po_pwi_'
l = {spec:1,ylog:1,zlog:1}
store_data,px+'A_Av_E',data={x:d.time,y:dimen_shift(d.sfra_av_e,1),v:nd.frequency}, lim=l, min=-1e30
store_data,px+'A_Av_M',data={x:d.time,y:dimen_shift(d.sfra_av_m,1),v:nd.frequency}, lim=l, min=-1e30
store_data,px+'B_Av_E',data={x:d.time,y:dimen_shift(d.sfrb_av_e,1),v:nd.frequency}, lim=l, min=-1e30
store_data,px+'B_Av_M',data={x:d.time,y:dimen_shift(d.sfrb_av_m,1),v:nd.frequency}, lim=l, min=-1e30
store_data,px+'A_Pk_E',data={x:d.time,y:dimen_shift(d.sfra_Pk_e,1),v:nd.frequency}, lim=l, min=-1e30
store_data,px+'A_Pk_M',data={x:d.time,y:dimen_shift(d.sfra_Pk_m,1),v:nd.frequency}, lim=l, min=-1e30
store_data,px+'B_Pk_E',data={x:d.time,y:dimen_shift(d.sfrb_Pk_e,1),v:nd.frequency}, lim=l, min=-1e30
store_data,px+'B_Pk_M',data={x:d.time,y:dimen_shift(d.sfrb_Pk_m,1),v:nd.frequency}, lim=l, min=-1e30


end


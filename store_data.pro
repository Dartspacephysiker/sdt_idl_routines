;+
;PROCEDURE:  store_data,name,DATA=data,LIMITS=limits
;PURPOSE:  
;   Store time series structures in static memory for later retrieval
;   by the tplot routine.  Three structures can be associated with the 
;   string 'name':  a data structure (DATA) that typically contains the x and
;   y data. A default limits structure (DLIMITS) and a user limits structure
;   (LIMITS) that will typically contain user defined limits and options
;   (typically plot and oplot keywords).  The data structure and the default
;   limits structure will be
;   over written each time a new data set is loaded.  The limit structure
;   is not over-written.
;INPUT:
;   name:   string name to be associated with the data structure and/or
;     the limits structure.
;KEYWORDS:
;    DATA:  variable that contains the data structure.
;    LIMITS; variable that contains the limit structure.
;    DLIMITS; variable that contains the default limits structure.
;
;SEE ALSO:    "GET_DATA", "TPLOT_NAMES",  "TPLOT", "OPTIONS"
;
;CREATED BY:	Davin Larson
;VERSION: 97/01/02 1.16 store_data.pro
;-
pro store_data,name, $
   data = data, $
   limits= limits, $
   dlimits = dlimits, $
   min=min, max=max, $
   delete = delete
@tplot_com.pro

if data_type(name) ne 7 then $
   message,' You must supply a name!' 

dq = {tplot_quant,name:'NULL', dh:0, lh:0, dl:0,  $
    ytitle:'', trange:dblarr(2), panel_size:1.}
if n_elements(data_quants) eq 0 then data_quants = [dq]

index = find_handle(name)

if keyword_set(delete) then begin
   if index eq 0 then begin
       print ,'Unable to delete non-existent variable: ',name
       return
   endif
   dq = data_quants(index)
   handle_free,dq.dh
   handle_free,dq.dl
   handle_free,dq.lh
   ind = where(data_quants.name ne name,count)
   if count ne 0 then data_quants = data_quants(ind)
   return
endif


if index eq 0 then begin        ; new variable
  dq.name = name
  dq.lh = handle_create()
  dq.dl = handle_create(dq.lh)
  dq.dh = handle_create(dq.lh)
  dq.panel_size =1.
  data_quants = [data_quants,dq]
  index = n_elements(data_quants) - 1
endif else dq = data_quants(index)

if keyword_set(min) then begin
   bad = where(data.y lt min,c)
   if c ne 0 then data.y(bad) = !values.f_nan
endif

if keyword_set(max) then begin
   bad = where(data.y gt max,c)
   if c ne 0 then data.y(bad) = !values.f_nan
endif


; set values:
if n_elements(limits) ne 0 then handle_value,dq.lh,limits,/set
if n_elements(dlimits)ne 0 then handle_value,dq.dl,dlimits,/set
if n_elements(data)   ne 0 then handle_value,dq.dh,data,/set

extract_tags,dstr,data
extract_tags,dstr,dlimits
extract_tags,dstr,limits

str_element,dstr,'panel_size',value=panel_size
if n_elements(panel_size) ne 0 then dq.panel_size = panel_size

str_element,dstr,'x',value=time
if n_elements(time) ne 0  then dq.trange = minmax_range(time)

str_element,dstr,'ytitle',value=ytitle
if n_elements(ytitle) ne 0 then dq.ytitle = ytitle

data_quants(index) = dq

end

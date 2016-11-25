;+
;PROCEDURE:  get_data , name, time, data, values
;PURPOSE:   
;   Retrieves the data and or limit structure associated with a name handle.
;   This procedure is used by the "TPLOT" routines.
;INPUT:  name    (scaler string)
;KEYWORDS:   
;   DATA:   named variable to hold the data structure.
;   LIMITS: named variable to hold the limits structure.
;   INDEX:  named variable to hold the name index.  This value will be 0
;     if the request was unsuccesful.
;
;SEE ALSO:	"STORE_DATA", "TPLOT_NAMES", "TPLOT"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)get_data.pro	1.13 97/02/05
;
;-
pro get_data,name, time, data, values, $
    data_str = data_str, $
    limits_str = lim_str, $
    alimits_str = alim_str, $
    dlimits_str = dlim_str, $
    index = index
@tplot_com.pro
time = 0 
data = 0
values = 0
data_str = 0
lim_str = 0
alim_str = 0
dlim_str = 0

index = find_handle(name,tagname)

;if index eq 0 then begin
;   auto_load,name,success=s
;   if s ne 0 then index = find_handle(name,tagname)
;endif

if index ne 0 then begin
   dq = data_quants(index)
   handle_value,dq.lh,lim_str
   handle_value,dq.dl,dlim_str
   handle_value,dq.dh,data_str

   extract_tags,alim_str,dlim_str
   extract_tags,alim_str,lim_str

   if data_type(data_str) eq 7 and ndimen(data_str) eq 0 then $
      get_data,data_str+'',data=data_str ; get links

; Old style: get x,y and v tag names:
   str_element,data_str,'x',value= time
   str_element,data_str,'y',value= data
   str_element,data_str,'v',value= values
; New style: get time, data tag names:
   str_element,data_str,'time',value= time
   str_element,data_str,'data',value= data
   if keyword_set(tagname) then begin
       str_element,data_str,tagname,value=data
       str_element,data_str,tagname+'_v',value=values
       data_str = {x:time,y:data}
   endif
endif
return
end


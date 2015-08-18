;+
;FUNCTION:	conv_units
;
;PURPOSE:	To convert from counts to any other unit which is supported.
;		This procedure is just a shell that calls whatever conversion
;		procedure is specified in data.units_procedure.
;		right now the only conversion procedures are
;		"convert_esa_units" and
;		"convert_sst_units" 
;INPUT:		
;	data:	A 3d data structure such as those generated by get_el, get_eh,
;		get_pl,get_ph,etc.
;		e.g. "get_el"
;	units:	The units you wish to convert to, such as eflux,flux,df,ncounts,
;		rate,nrate.
;KEYWORDS:	
;	scale:	a dummy keyword, returns the scale used to convert.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION: 	@(#)conv_units.pro	1.8 95/11/07
;-

function conv_units, data,units, $
  SCALE = scale

new_data = data
if not keyword_set(units) then units = 'Eflux'
call_procedure,data.units_procedure,new_data,units,SCALE=scale
return,new_data
end


;+
;PROCEDURE:  tplot_names [, datanames ]
;PURPOSE:    
;   Lists current stored data names that can be plotted with the TPLOT routines.
;INPUT: Optional array of strings.  Each string should be associated with a data
;       quantity.  (see the "store_data" and "get_data" routines)
;KEYWORDS:
;  TIME_RANGE: set this keyword to print out the time range for each quantity.
;  NAMES:   Named variable in which the array of valid data names is returned.
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)tplot_names.pro	1.10 97/01/02
;-
pro tplot_names, datanames , time_range=times, names=names
@tplot_com.pro

if n_elements(data_quants) eq 0 then begin
   print,"No data has been saved yet"
   return
endif

if n_elements(datanames) eq 0 then begin
  format1='($,i3," ",a,T??," ")'
  format2='($,a,"  ",a)'
  format3='("  ",a)'
  mx = max(strlen(data_quants.name))
  ps = strtrim((mx+5 < 40) > 10,2)
  strput,format1,ps,strpos(format1,'??')
  for i=1,n_elements(data_quants)-1 do begin
     tr = time_to_str(data_quants(i).trange)
     n  = data_quants(i).name
     ytitle = data_quants(i).ytitle
     print,i,n ,format=format1
     if keyword_set(times) then  print,tr(0),tr(1),format=format2
     print,ytitle,format=format3
  endfor
endif else begin
  if data_type(datanames) le 3 then datanames = data_quants(datanames).name
  for i=0,n_elements(datanames)-1 do begin
      data = 0
      limit = 0
      dlimit = 0
      get_data,datanames(i),data=data,limits=limit,dlimit=dlimit
      print,'User Limit Structure for ',datanames(i),':'
      help,limit,/str
      print,'Default Limit Structure for ',datanames(i),':'
      help,dlimit,/str
      print,'Data Structure for ',datanames(i),':'
      help,data,/str
  endfor
endelse
names = data_quants.name
end




;+
;FUNCTION:  gettime(x)
;INPUTS:   x: Null or double or string or integer
;OUTPUT:   double,  seconds since Jan 1, 1970
;Examples:
;  t = gettime('95-7-4/12:34')
;  t = gettime('12:34:56')     (get time on reference date)
;  t = gettime(t+300.)         (assumes t is a double)
;  t = gettime(10)             (t = 10 am on reference date)
;  t = gettime(/key)           (prompts user for time on reference date)
;  t = gettime(key='Enter time: ')
;  t = gettime(/curs)          (select time using cursor in tplot routine)
;KEYWORDS:
;   KEYBOARD:  If non-zero then user is prompted to enter a time.  If KEYBOARD
;      is a string then that string is used as a prompt.
;   CURSOR:  if non-zero then user can select a time with the cursor.
;   REFDATE:  Sets the reference date if REFDATE is a string with
;       format: "yyyy-mm-dd". 
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)gettime.pro	1.14 96/08/09 
;-

function gettime,x        $
   ,KEYBOARD=key          $
   ,CURSOR=curs           $
   ,values=vals           $
   ,REFDATE = refdate

@tplot_com.pro

IF n_elements(x) NE 0 THEN t = x

if keyword_set(refdate) then $
   tplot_refdate = strmid(time_to_str(str_to_time(refdate)),0,10)

if keyword_set(key) then begin                             ; from keyboard
  if data_type(key) ne 7 then key='Enter time for '+tplot_refdate+': (hh:mm:ss) '
  t='' 
  read,t,prompt=key
endif

if keyword_set(curs) then   ctime,t,vals,npoints=curs

if n_elements(t) eq 0 then return,str_to_time(tplot_refdate)      ; default

if data_type(t) eq 7 then begin     ; strings
   IF strpos(t(0),'/') EQ -1 and strpos(t(0),'-') EQ -1 THEN  t=tplot_refdate + '/'+ t
   t = str_to_time(t) 
endif else t = double(t)

if t(0) lt 1e8 then t = str_to_time(tplot_refdate) + t * 3600.   ; hours

IF N_ELEMENTS(tplot_refdate) EQ 0 THEN tplot_refdate = '1970-1-1'

if n_elements(t) eq 1 then t=t(0)

return,t
end



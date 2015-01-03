;       @(#)what_orbit_is.pro	1.10 08/17/10

function what_orbit_is,timec
;+
; NAME: WHAT_ORBIT_IS
;
; PURPOSE: To quickly determine the orbit number at a particular time. 
;
; CALLING SEQUENCE: ORBIT = what_orbit_is(TIME)
; 
; INPUTS: TIME - a string (YYYY-MM-DD/HH:MM) or a double precision
;         number of seconds since 1970. If TIME is not defined, then
;         the orbit number of the current orbit is given (provided
;         your computers clock is set right. Check if
;         time_to_str(systime(1)) gives you the current UT. 
;        
;
; OUTPUTS: ORBIT - the orbit number, as defined by ORBGEN. 
;
; EXAMPLE: my_orbit = what_orbit_is('1996-08-21/12:00') (Note
;                   that the correct answer is 1!)
;
; MODIFICATION HISTORY: Written 4-Mar-97 by Bill Peria UCB/SSL
;       Re-written to use fast_archive database by Ken Bromund UCB/SSL
;       Modified to be SQL-indepedent by Jack Vernetti (2010/08/17)
;          to prepare for the Sybase to MySQL transition.
;
;-

if not defined(timec) then timec = systime(1)

time = time_double(timec)

if data_type(time) ne 5 then return, 0

t1 = min(time,/nan,max=t2)

con = sybcon()

; Note (JBV 2010/08/17):  we replace use of the general "con->send"
; with a specific query method, "con->queryorbit",
; to induce SQL-neutrality.
ret = con->queryorbit(time_string(t1, /sql), time_string(t1, /sql))

ret = con->fetch(min_orb)

ret = con->queryorbit(time_string(t2, /sql), time_string(t2, /sql))

ret = con->fetch(max_orb)

sybclose, con

if min_orb.orbit eq max_orb.orbit then begin
    return,  long(min_orb.orbit)
endif else begin
    return, long([min_orb.orbit, max_orb.orbit])
endelse

end


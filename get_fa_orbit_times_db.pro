;+
;FUNCTION: get_fa_orbit_times_db(orbit)
;NAME:
;  get_fa_orbit_times_db
;PURPOSE:
;  Obtains orbit start, stop, north and south pole crossing times
;  from the fast_archive database given an orbit number.
;
;INPUT:  input(s) can be scalers or arrays of any dimension of type:
;  integer        orbit number.
;
;OUTPUT:
;  structure: {orbit_times, start:limits.start, finish:limits.finish, $
;              north:north.time, south:south.time}
;
;SEE ALSO:
;  what_orbit_is
;
;CREATED BY:	Ken Bromund  Dec 1997
;MODIFIED BY:   Jack Vernetti, Aug 2010 to make IDL SQL-neutral,
;   in order to ease the transition from Sybase to MySQL.
;FILE:  get_fa_orbit_times_db.pro
;VERSION:  1.3
;LAST MODIFICATION:  10/08/18
;-

FUNCTION get_fa_orbit_times_db, orbit

con = obj_new('sybcon')

; Note (JBV 2010/08/18):  we replace use of the general "con->send"
; with a specific query method, "con->queryorbittspan",
; to induce SQL-neutrality.
ret = con->queryorbittspan(string(orbit))

ret = con->fetch(limits)

; Note (JBV 2010/08/18):  we replace use of the general "con->send"
; with a specific query method, "con->queryorbitnscrossings",
; to induce SQL-neutrality.
ret = con->queryorbitnscrossings(time_string(limits.start, /sql), $
    time_string(limits.finish, /sql))

ret = con->fetch(north)
ret = con->fetch(south)

obj_destroy, con
return, {orbit_times, start:limits.start, finish:limits.finish, $
         north:north.time, south:south.time}

end

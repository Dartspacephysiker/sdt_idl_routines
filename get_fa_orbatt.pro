;+
; inputs:
;   start    start time in any format accepted by time_double
;   finish   end time in any format accepted by time_double
;   qtylist  string containing comma separated list of desired columns from
;            the events_data table.  e.g. 'X, Y, Z'
;
;MODIFIED BY:   Jack Vernetti, Aug 2010 to make IDL SQL-neutral,
;   in order to ease the transition from Sybase to MySQL.
;-

function get_fa_orbatt, start, finish, qtylist

con = sybcon()

if not obj_valid(con) then return, -1

; Note (JBV 2010/08/17):  we replace use of the general "con->send"
; with a specific query method, "con->queryorbattcnt",
; to induce SQL-neutrality.
ret = con->queryorbattcnt(time_string(start, /sql), $
	time_string(finish, /sql))

ret = con->fetch(row)
count = row.col1
ret = con->fetch(row)
count = count+row.col1

; create structure name from column list by removing all spaces and
; commas.
if (!VERSION.RELEASE LE '5.4') then begin
    strname = 'gfa_' + strcompress(string(str_sep(qtylist, ','),  $
                                      /print),  $
                               /remove_all)
endif else begin
    strname = 'gfa_' + strcompress(string(strsplit(qtylist, ',', /EXTRACT),  $
                                      /print),  $
                               /remove_all)
endelse

; Note (JBV 2010/08/17):  we replace use of the general "con->send"
; with a specific query method, "con->queryorbattres",
; to induce SQL-neutrality.
if con->queryorbattres(time_string(start, /sql), $
	time_string(finish, /sql), qtylist, strname) le 0 $
  then begin
    sybclose, con
    return, -1
end

ret = execute('rowarr = make_array(value={' + strname + $
              '}, dim=count)')

i = 0

while con->fetch(row) eq 1 do begin
    rowarr(i) = row
    i = i + 1
end

sybclose, con

return, rowarr
end

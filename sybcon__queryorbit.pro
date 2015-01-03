;+
;FUNCTION: sybcon::queryorbit(comm, name)
; Class:  sybcon
; Method: queryorbit
;
; In order to port all of the FAST software to the MySQL
; version of the FastDB (replacing Sybase), we need to
; make the IDL code SQL-neutral, because Sybase SQL and
; MySQL SQL are not compatible.   Therefore all IDL calls
; to "sybcon->send" are being replaced by calls to more
; specific methods, which push the responsibility for
; SQL generation to the "libsybidl.so" module.
;
; "sybcon::queryorbit" replaces the "sybcon->send" calls
; from "what_orbit_is.pro".
;

FUNCTION sybcon::queryorbit, sdatetime, edatetime, name

if data_type(sdatetime) ne 7 then begin
    message,/info,'start_date_time must be a string'
    return, -1
end
if data_type(edatetime) ne 7 then begin
    message,/info,'end_date_time must be a string'
    return, -1
end

flg64 = 1
lmdls6 = STRING ('libsybidl_3264.so')
if (!VERSION.RELEASE LE '5.4') then begin
    flg64 = 0
    lmdls6 = STRING ('libsybidl.so')
endif

self.ncols = call_external(lmdls6, 'sybqueryorbit', self.dbproc, $
	sdatetime, edatetime)

if self.ncols gt 0 then begin
                                ; there are results to bind
    ptr_free, self.datatype
    ptr_free, self.datasize
    ptr_free, self.nullind
    ptr_free, self.row

    self.datatype = ptr_new(lonarr(self.ncols))
    self.datasize = ptr_new(lonarr(self.ncols))
    self.nullind = ptr_new(lonarr(self.ncols))
    structdef = ""

    retval = call_external(lmdls6, 'sybdesc_row', $
                           self.dbproc, structdef,  $
                           *self.datatype, *self.datasize, self.ncols)

    ; define the structure which defines the columns for the row.
    if n_params() eq 2 then begin 
        ; anonymous structure
        ret = execute( 'self.row = ptr_new({' + structdef +'})')
    end else begin
        ; named structure
        ret = execute( 'self.row = ptr_new({' + name + ', ' + structdef +'})')
    end        

    retval = call_external(lmdls6, 'sybbind_row', self.dbproc, $
                           *self.row, *self.datatype, *self.datasize, $
                           *self.nullind, self.ncols)
endif

return, self.ncols
end

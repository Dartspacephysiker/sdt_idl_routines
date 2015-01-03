;+
; PROCEDURE:  compare_cdf_ats
;
; PURPOSE:    Compares timespans of CDf files to instrument turnons
;             and checks them for gaps.  Works on any given array of
;             orbits, or a specified range of orbits.
;
; KEYWORDS:
;
;   QTY       String: ees, ies, tms, acf, dcf.
;
;   ONTIMES   (OPTIONAL) The name of the file containing the
;             instrument turnon times.  The file is searched for in
;             the directory: $FAST_CDF_HOME/cdf_status/timespans
;             If not set, a timespan/gap characterization is done
;             for the CDFs, without the comparison to turnon times.
;   ORBARRAY  If set, the first argument is taken as an array of
;             orbits instead of the first orbit in a range. The
;             second argument is ignored. 
;   TROUBLE   Set this to a named variable which will be set to an
;             array of orbits for which CDFs 
;   OUT       If set, the name of the output file.
;   APPEND    Appends to the output file instead of overwriting it.
;
; ARGUMENTS:
;
;   FIRST     The first orbit in the range.
;   LAST      The last orbit in the range.
;
; OUTPUT:
;
;   The timespan of the CDF; the total number of minutes occupied by
;   actual data; the deviation of start and finish times from
;   instrument turnons; data gaps.
;
;   The three numbers after the "NAN" label describe the data gaps in
;   the CDF file.  The first number is the total number of gaps,
;   however small.  This number should be less than about 20 for a
;   good CDF.  The second is the total number of gaps lasting between
;   1 and 20 minutes.  A good CDF has zero such gaps.  The third
;   number is the number of gaps longer than 20 minutes.  Any gap this
;   long almost always represents the interval between northern and
;   southern data collection periods.  Thus, there should never be
;   more than one such gap in a CDF file.
;
;   Example:
;
;   orbit     CDF date   start    finish   data stt dev. fin dev. Gap(n,1,20min)
;   ----      ---------- -------- -------- ---- -------- -------- -----------
;   4038  TS: 1997-08-29 19:22:23 20:42:46 (80) beg: -63 end:   0 NAN: 11,0,1
;   4039  TS: 1997-08-29 21:35:01 22:06:17 (31) beg:   0 end: -46 NAN: 11,0,0
;   4040  CDF not found
;   4041  TS: 1997-08-30 01:56:15 03:15:06 (78) beg:   0 end:   0 NAN: 12,1,1
;   4042  TS: 1997-08-30 04:06:04 05:27:54 (81) beg:   0 end:   0 NAN:  4,0,1
;
; CREATED:    By J.Rauchlieba
;-
pro compare_cdf_ats, $
           qty = qty, $
           ontimes = file, $
           orbarray = orbarray, $
           trouble = trouble, $
           first, $
           last, $
           out=out, $
           append=app

; Output

if keyword_set(out) then openw, append=keyword_set(app), unit, /get_lun, out $
else unit=-1

; Make the orbit array

if NOT keyword_set(orbarray) then begin
    if NOT keyword_set(last) then last=first
    n_orbits = last - first + 1
    check_orbits = indgen(n_orbits) + fix(first)
endif else begin
    check_orbits = fix(first)
    n_orbits = n_elements(check_orbits)
endelse

; CDF file location

cdfhome = getenv('FAST_CDF_HOME')
if NOT keyword_set(cdfhome) then message, 'FAST_CDF_HOME not set.'
dir = cdfhome + '/' + qty             ; CDF file location

; Get comparison information from supplied file.

if keyword_set(file) then begin
    ontimes = findfile(file)
    if NOT keyword_set(ontimes) $
      then ontimes = (findfile(cdfhome + '/cdf_status/timespans/' + file))(0)
    if NOT keyword_set(ontimes) then message, 'File '+file+' nonexistent'
    command = 'cat ' + ontimes
    spawn, command, ts_recs     ; ts_recs is array with all lines
    r = n_elements(ts_recs)     ; # records in file
    ts_fields = strarr(r,10)    ; array to hold a parsed line
    for I = 0, r-1 do begin
        tmp_fields = strarr(10) ; reallocate the temporary array
        if (!VERSION.RELEASE LE '5.4') then begin
            tmp_fields = str_sep(ts_recs(I),'	') ; TAB delimited
        endif else begin
            tmp_fields = strsplit(ts_recs(I),'	', /EXTRACT) ; TAB delimited
        endelse
        if n_elements(tmp_fields) EQ 10 then begin
            ts_fields(I,*) = tmp_fields
        endif else if n_elements(tmp_fields) EQ 7 then begin
            ts_fields(I,*) = [tmp_fields, '0', '0', '0'] ; fill rest
        endif
    endfor
endif else begin
    ts_fields = strarr(1)       ; dummy array
endelse

bad_iters = intarr(n_orbits)
for iter = 0, (n_orbits - 1) DO begin
    orbit = check_orbits(iter)
    sorb=strcompress(string(orbit),/remove_all)
    filenames = findfile(dir+'/fa_k0_'+qty+'_*'+sorb+'*.cdf')
    
    err = 0
    if NOT keyword_set(filenames(0)) then begin
        err = 1
        goto, CDFERROR
    endif
    
    catch, errstat
    if errstat NE 0 then begin
        err = 2
        goto, CDFERROR
    endif
    
    loadcdf, filenames(0), 'TIME', time
    ntime = dimen1(time)
    if (!VERSION.RELEASE LE '5.4') then begin
        date_time = str_sep(time_to_str(time(0)), '/')
    endif else begin
        date_time = strsplit(time_to_str(time(0)), '/', /EXTRACT)
    endelse
    date = date_time(0)
    t0 = date_time(1)
    
    ;; Find differences between start times
    
    index = where(ts_fields EQ orbit)
    
    ;; GOTO statement acts as a CONTINUE
    ;; Should still allow NAN checking if no ATS info
    if index(0) EQ -1 then begin
        if (!VERSION.RELEASE LE '5.4') then begin
            date_time = str_sep(time_to_str(time(ntime-1)), '/')
        endif else begin
            date_time = strsplit(time_to_str(time(ntime-1)), '/', /EXTRACT)
        endelse
        t1 = date_time(1)
        sdiff = '???'
        ediff = '???'
        goto, NO_INFO
    endif
    
    ind = index(0)
    stime = ts_fields(ind, 3)
    stime = stime(0)            ; convert to scalar string
    if (!VERSION.RELEASE LE '5.4') then begin
        hhmmss = str_sep(stime, ':')
    endif else begin
        hhmmss = strsplit(stime, ':', /EXTRACT)
    endelse
    ton = datesec_doy(ts_fields(ind,1), ts_fields(ind,2)) + $
      hhmmss(0)*3600.D + hhmmss(1)*60.D + hhmmss(2)
    sdiff = fix((time(0) - ton)/60.)
    
    if (!VERSION.RELEASE LE '5.4') then begin
        date_time = str_sep(time_to_str(time(ntime-1)), '/')
    endif else begin
        date_time = strsplit(time_to_str(time(ntime-1)), '/', /EXTRACT)
    endelse
    t1 = date_time(1)
    
    ;; Differences between end times
    
    if ts_fields(ind,9) EQ '0' then begin ; One turnon
        etime_ind = 6           ; Index to off time
        yy_ind = 4              ; Index to off year
        doy_ind = 5             ; index to off day of year
    endif else begin            ; Two turnons
        etime_ind = 9
        yy_ind = 7
        doy_ind = 8
    endelse
    etime = ts_fields(ind, etime_ind)
    etime = etime(0)            ; conver to scalar string
    if (!VERSION.RELEASE LE '5.4') then begin
        hhmmss = str_sep(etime, ':')
    endif else begin
        hhmmss = strsplit(etime, ':', /EXTRACT)
    endelse
    toff = datesec_doy(ts_fields(ind,yy_ind), ts_fields(ind,doy_ind)) + $
      hhmmss(0)*3600.D + hhmmss(1)*60.D + hhmmss(2)
    ediff = fix((time(ntime-1) - toff)/60.)
    
    ;; Total time
    
    NO_INFO:
    totalmin = (time(ntime - 1) - time(0))/60d
    
    ;; Percent NAN values
    
    case qty of
        'ees' : pig = 'el_0'
        'ies' : pig = 'ion_0'
        'tms' : pig = 'H+'
        'acf' : pig = 'VLF_E_SPEC'
        'dcf' : pig = 'EX'
        ELSE  : message, 'Invalid data quantity: '+qty
    endcase
    loadcdf, filenames(0), pig, guinea
    data = guinea(*,0)
    n_pts = n_elements(data)
    nan_ind = where(finite(data) NE 1, n_nan)
    nan_st_ind=0
    nan_en_ind=0
    if n_nan GE 2 then begin
        gaptime=0d
        nan_st_ind = make_array(n_nan, /int, value=-1)
        nan_en_ind = make_array(n_nan, /int, value=-1)
        for i=0, (n_nan-1) do begin
            if  (nan_ind(i)+1) LE (n_pts-1) then begin
                if NOT finite(data(nan_ind(i)+1)) then begin
                    nan_st_ind(i) = nan_ind(i)
                    nan_en_ind(i) = nan_ind(i)+1
                endif
            endif
        endfor
        good_gap_st = where(nan_st_ind NE -1)
        good_gap_en = where(nan_en_ind NE -1)
        if (good_gap_st(0) NE -1) AND (good_gap_en(0) NE -1) then begin
            nan_st_ind = nan_st_ind(good_gap_st)
            nan_en_ind = nan_en_ind(good_gap_en)
            if n_elements(nan_st_ind) NE n_elements(nan_en_ind) $
              then message, 'Gaptime start and stop arrays unequal sizes.'
            ;;for j=0, (n_elements(nan_st_ind)-1) do begin
            ;;    print, time_to_str(time(nan_st_ind(j))), $
            ;;      ' ', time_to_str(time(nan_en_ind(j))) 
            ;;endfor
        endif
    endif
    if keyword_set(nan_st_ind) then begin
        ;; Number of NANs not including 2nd of pairs
        n_gp_nan = n_nan - n_elements(nan_st_ind)
        ;; Intermediate duration gaps
        m1_nan_ind = where( ((time(nan_en_ind)-time(nan_st_ind)) GT 60) AND $
                            ((time(nan_en_ind)-time(nan_st_ind)) LT 1200), $
                            n_m1_nan )
        ;; Long duration gaps (inter-hemisphere period)
        m5_nan_ind =where((time(nan_en_ind)-time(nan_st_ind)) GE 1200,n_m5_nan)
        gaplens = (time(nan_en_ind) - time(nan_st_ind))/60d
        datamin = fix(totalmin - total(gaplens, /double))
    endif else begin
        n_gp_nan = n_nan
        n_m1_nan = 0
        n_m5_nan = 0
        datamin = fix(totalmin)
    endelse
    
    ;; Print report line for this orbit
    ;; Print Header to SDTERR
    
    if (iter EQ 0) AND (unit EQ -1) then printf, -2, $
      format='(/,2(A5,A7,A11,A8,A8,A6,A5,A6,:,/))', $
      'ORBIT', 'DATE', 'START', 'END', 'DATA', 'SDEV', 'EDEV', 'GAPS', $
      '-----', '----', '-----', '---', '----', '----', '----', '----'
    printf, unit, $
      strtrim(orbit,2) + $
      ' ' + string(date, format='(A10)') + $
      ' ' + string(t0, format='(A8)') + $
      ' ' + string(t1, format='(A8)') + $
      ' ' + string('('+strtrim(datamin,2)+')', format='(A5)') + $
      ' ' + string(strtrim(sdiff,2), format='(A4)') + $
      ' ' + string(strtrim(ediff,2), format='(A4)') + $
      ' ' + string(strtrim(n_gp_nan,2), format='(I3)') + ',' + $
      strtrim(n_m1_nan,2) + ',' + $
      strtrim(n_m5_nan,2)
    
    ;; GOTO this point if no ATS info
    
    CDFERROR:
    catch, /cancel
    if err EQ 1 then printf, unit, strtrim(orbit,2)+'  CDF not found'
    if err EQ 2 then printf, unit, strtrim(orbit,2)+$
      '  Error checking ', filenames(0)
    
    ;; Flag troublesome CDF
    
    bad = 0
    if (err EQ 1) OR (err EQ 2) then bad=1 $
    else if (n_gp_nan GT 25) OR (n_m1_nan GT 0) OR $
      (n_m5_nan GT 1) OR (datamin LT 13) then bad=1 $
    else if (data_type(sdiff) NE 7) then $
      if (sdiff GT  2) OR (ediff LT -2) then bad=1
    bad_iters(iter) = bad
endfor

bad_indices = where(bad_iters EQ 1)
if bad_indices(0) NE -1 then trouble = check_orbits(bad_indices) $
  else trouble=0

if keyword_set(out) then close, unit

return
end


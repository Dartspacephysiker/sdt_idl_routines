;+
; PROCEDURE:  compare_cdf_db
;
; PURPOSE:    Compares timespans of CDf files to instrument turnons
;             and checks them for gaps.  Works on any given array of
;             orbits, or a specified range of orbits.
;
; KEYWORDS:
;
;   QTY       String: ees, ies, tms, acf, dcf.
;   VERSION   If set to a 2-char string, looks for a specific version
;             number in the CDF filename.  If that version is not found,
;             the CDF is deemed bad.  Default is '??'.
;   ONTIMES   (OPTIONAL) The name of the file containing the
;             instrument turnon times.
;             If not set, a timespan/gap characterization is done
;             for the CDFs, without the comparison to turnon times.
;   ORBARRAY  If set, the first argument is taken as an array of
;             orbits instead of the first orbit in a range. The
;             second argument is ignored. 
;   TROUBLE   Set this to a named variable which will be set to an
;             array of orbits for which CDFs were less than perfect.
;   OUT       If set, the name of the output file.
;   APPEND    Appends to the output file instead of overwriting it.
;
; ARGUMENTS:
;
;   FIRST     The first orbit in the range or an array of orbits.
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
pro compare_cdf_db, $
           qty = qty, $
           version = ver, $
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
    n_orbits = fix(last) - fix(first) + 1
    check_orbits = indgen(n_orbits) + fix(first)
endif else begin
    check_orbits = fix(first)
    n_orbits = n_elements(check_orbits)
endelse

; CDF file location

cdfhome = getenv('FAST_CDF_HOME')
if NOT keyword_set(cdfhome) then message, 'FAST_CDF_HOME not set.'
dir = cdfhome + '/' + qty       ; CDF file location
if NOT keyword_set(ver) then ver='??'

; Get comparison information from supplied file.

if keyword_set(file) then begin
    ontimes = findfile(file)
    if NOT keyword_set(ontimes) $
      then ontimes = (findfile(cdfhome + '/cdf_status/timespans/' + file))(0)
    if NOT keyword_set(ontimes) then message, 'File '+file+' nonexistent'
    ;; Create template for reading ascii file
    tpl = {ascii_template, $
                version:1.0, $
                datastart:0, $
                delimiter:byte(32), $
                missingvalue:0.0, $
                commentsymbol:'', $
                fieldcount:[5], $
                fieldtypes:[3,7,7,7,7], $
                fieldnames:['orbit', 'on1', 'off1', 'on2', 'off2'], $
                fieldlocations:[0,5,24,43,62], $
                fieldgroups:[0,1,2,3,4]}
    ats = read_ascii_nonx(ontimes(0), template=tpl, /verbose)
endif else begin
    ats = {orbit:0}       ; dummy structure
endelse

bad_iters = intarr(n_orbits)
for iter = 0, (n_orbits - 1) DO begin
    orbit = check_orbits(iter)
    ;; String form of orbit number must be 5 chars long, zero padded
    zeroes = ['','0','00','000','0000']
    sorb = strcompress(string(orbit),/remove_all)
    sorb = zeroes(5 - strlen(sorb)) + sorb
    filenames = findfile(dir+'/fa_k0_'+qty+'_'+sorb+'_v'+ver+'.cdf')
    
    err = 0
    catch, errstat
    if errstat NE 0 then begin
        err = 2
        goto, ERROR
    endif
    
    ;; Scheduled ON and OFF times for this orbit
    
    ind = (where(ats.orbit EQ orbit))(0)
    sched1 = 0 ; flags tell if we had one or two scheduled passes
    sched2 = 0
    if ind NE -1 then begin
        ;; Get instrument on and off times from ats info
        if ats.off1(ind) NE '' then begin
            sched1 = 1
            ton1 = str_to_time(ats.on1(ind))
            toff1 = str_to_time(ats.off1(ind))
        endif
        if ats.off2(ind) NE '' then begin
            sched2 = 1
            ton2 = str_to_time(ats.on2(ind))
            toff2 = str_to_time(ats.off2(ind))
        endif
    endif
    if NOT sched1 then begin
        ;; Create alternates for variables needed later
        ton1_diff = '?'
        toff1_diff = '?'
        ton2_diff = '?'
        toff2_diff = '?'
    endif
    
    if NOT keyword_set(filenames(0)) then begin
        err = 1
        goto, ERROR
    endif
    
    ;; Load the time array from the CDF
    
    loadcdf, filenames(0), 'TIME', time
    ntime = dimen1(time)
    totalmin = (time(ntime - 1) - time(0))/60d
    
    ;; NAN characterization
    
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
        ;; Total time minus gap time
        gaplens = (time(nan_en_ind) - time(nan_st_ind))/60d
        datamin = fix(totalmin - total(gaplens, /double))
    endif else begin
        n_gp_nan = n_nan
        n_m1_nan = 0
        n_m5_nan = 0
        datamin = fix(totalmin)
    endelse
    
    ;; ON and OFF times from CDF file (strings)
    
    if (!VERSION.RELEASE LE '5.4') then begin
        date = (str_sep(time_to_str(time(0)), '/'))(0)
    endif else begin
        date = (strsplit(time_to_str(time(0)), '/', /EXTRACT))(0)
    endelse
    if n_m5_nan EQ 1 then begin
        if (!VERSION.RELEASE LE '5.4') then begin
            t0 = (str_sep(time_to_str(time(0)), '/'))(1)
            t1 = (str_sep(time_to_str(time(nan_st_ind(m5_nan_ind(0)))), '/'))(1)
            t2 = (str_sep(time_to_str(time(nan_en_ind(m5_nan_ind(0)))), '/'))(1)
            t3 = (str_sep(time_to_str(time(ntime-1)), '/'))(1)
        endif else begin
            t0 = (strsplit(time_to_str(time(0)), '/', /EXTRACT))(1)
            t1 = (strsplit(time_to_str(time(nan_st_ind(m5_nan_ind(0)))), '/', /EXTRACT))(1)
            t2 = (strsplit(time_to_str(time(nan_en_ind(m5_nan_ind(0)))), '/', /EXTRACT))(1)
            t3 = (strsplit(time_to_str(time(ntime-1)), '/', /EXTRACT))(1)
        endelse
    endif else begin
        if (!VERSION.RELEASE LE '5.4') then begin
            t0 = (str_sep(time_to_str(time(0)), '/'))(1)
            t1 = (str_sep(time_to_str(time(ntime-1)), '/'))(1)
        endif else begin
            t0 = (strsplit(time_to_str(time(0)), '/', /EXTRACT))(1)
            t1 = (strsplit(time_to_str(time(ntime-1)), '/', /EXTRACT))(1)
        endelse
        t2 = '-'
        t3 = '-'
    endelse
    
    ;; Time deviations for instrument turn-ons and turn-offs
    
    if sched1 AND NOT sched2 then begin
        ;; Only one scheduled pass
        ton1_diff = fix((time(0) - ton1)/60d)
        toff1_diff = fix((time(ntime - 1) - toff1)/60d)
        ton2_diff = '-'
        toff2_diff = '-'
    endif else if sched2 then begin
        ;; Two scheduled passes
        if n_m5_nan EQ 1 then begin
            ton1_diff  = fix((time(0) - ton1)/60d)
            toff1_diff = fix((time(nan_st_ind(m5_nan_ind(0))) - toff1)/60d)
            ton2_diff  = fix((time(nan_en_ind(m5_nan_ind(0))) - ton2)/60d)
            toff2_diff = fix((time(ntime-1) - toff2)/60d)
        endif else begin
            err = 3
            goto, ERROR
        endelse
    endif
    
    ;; Print report line for this orbit
    ;; Print Header to SDTERR
    
    if (iter EQ 0) AND (unit EQ -1) then printf, -2, $
      format='(/,2(A5,A7,A11,A8,A10,A8,A8,A6,A6,A6,A6,A5,:,/))', $
      'ORBIT','DATE','START','END','START','END','DATA','S1DEV','E1DEV','S2DEV','E2DEV','GAPS', $
      '-----','----','-----','---','-----','---','----','-----','-----','-----','-----','----'
    printf, unit, $
      strtrim(orbit,2) + $
      ' ' + string(date, format='(A10)') + $
      ' ' + string(t0, format='(A8)') + $
      ' ' + string(t1, format='(A8)') + $
      ' ' + string(t2, format='(A8)') + $
      ' ' + string(t3, format='(A8)') + $
      ' ' + string('('+strtrim(datamin,2)+')', format='(A5)') + $
      ' ' + string(strtrim(ton1_diff,2), format='(A4)') + $
      ' ' + string(strtrim(toff1_diff,2), format='(A4)') + $
      ' ' + string(strtrim(ton2_diff,2), format='(A4)') + $
      ' ' + string(strtrim(toff2_diff,2), format='(A4)') + $
      ' ' + string(strtrim(n_gp_nan,2), format='(I3)') + ',' + $
      strtrim(n_m1_nan,2) + ',' + $
      strtrim(n_m5_nan,2)
    
    ;; GOTO this point if no ATS info or if bad or missing CDF
    
    ERROR:
    catch, /cancel
    if err EQ 1 then printf, unit, strtrim(orbit,2) + ' CDF not found'
    if err EQ 2 then printf, unit, strtrim(orbit,2) + $
      '  Error checking ', filenames(0)
    if err EQ 3 then printf, unit, strtrim(orbit,2) + $
      ' DB says two passes; CDF disagrees'
    
    ;; Flag troublesome CDF
    
    bad = 0
    if (err EQ 1 OR err EQ 2 OR err EQ 3) then bad=1 $
    else if ((n_gp_nan GT 25) OR (n_m1_nan GT 0) OR $
             (n_m5_nan GT  1) OR (datamin LT 12)) then bad=1 $
    else if (data_type(toff1_diff) NE 7) then $
      if (ton1_diff GT 4) OR (toff1_diff LT -5) then bad=1 $
    else if (data_type(toff2_diff) NE 7) then $
      if (ton2_diff GT 4) OR (toff2_diff LT -5) then bad=1
    ;; Number of passes in ACF is unreliable
    if bad AND err EQ 3 AND qty EQ 'acf' then bad=0
    bad_iters(iter) = bad
endfor

bad_indices = where(bad_iters EQ 1)
if bad_indices(0) NE -1 then trouble = check_orbits(bad_indices) $
  else trouble=0

if keyword_set(out) then close, unit

return
end


;+
; PROCEDURE: make_cdf_structs.pro
;
; USAGE: make_cdf_structs, namelist, datavary, datanovary, times=times
;
; PURPOSE:
;     from stored data, creates the structures that are needed to write to CDF.
;
; INPUTS:
;     namelist: array of tplot names or tplot numbers of the quantities desired
;
; OUTPUTS:
;     datavary:
;         an array of structures.  Each element of the array is a structure corresponding
;         to one value of time, containing time and a value for each of several quantities.
;         All elements of datavary will be written to the CDF as record-variant data.
;             
;     datanovary:
;         a structure, each tag of which is a time-invariant quantity that came from
;         either the data structure or the limit structure of the stored data.
;         All elements of datanovary will be written to the CDF as non-record-variant data.
;
; KEYWORDS:
;     times:
;         when stored data quantities have different time arrays, they must all be
;         interpolated to the same time array in order to write to CDF.  The default
;         action is to interpolate all time based quantities to the time array of the
;         first data quantity listed.  If it is desired to interpolate to a different
;         time array than this, set the keyword times to the array of desired times.
;     
; DETAILS:
;     for each tplot variable named, this routine expects to find a tag 'x' containing
;     time, which will be named 'time' in the created structures, a tag 'y', which will
;     be given the name of the tplot variable in the created structures, and a tag 'v',
;     which will be named 'name_v', where name is the name of the tplot variable.
;     This routine is meant to be used prior to using 'makecdf' to write a CDF.
;     When using 'makecdf', the above names will be the default names of the CDF
;     variables that are written to CDF, and one one can use keyword parameters to
;     change the names of the variables from the above to anything else. (see EXAMPLE).
;
; EXAMPLE:
;     To make a CDF file named 'foo.cdf' containing tplot variables 'el_0' and 'el_high',
;     give the following IDL commands:
;
;         > make_cdf_structs, ['el_0', 'el_high'], datavary, datanovary
;         > makecdf, file='foo', datavary, datanovary=datanovary, $
;               tagsvary=['time', 'el_0', 'el_high'], tagsnovary=['el_0_en', 'el_high_pa']
;
;     The resulting CDF file will contain an Epoch variable (computed from the time),
;     a time variable (taken by default from the 'x' component of the first named tplot
;     variable, but specifiable otherwise by the 'times' keyword to 'make_cdf_structs'),
;     and, for each tplot variable named in the argument list to 'make_cdf_structs', the
;     'y' component, with its name taken, in order, from 'tagsvary', and the 'v' component,
;     with its name taken, in order, from 'tagsnovary'.
;     Thus the CDF file from the above commands will contain the CDF variables
;         Epoch:
;             This is of type CDF_EPOCH, and is calculated from the time variable below
;         time:
;             by default, the 'x' tag from the tplot variable 'el_0'
;         el_0:
;             the 'y' tag from the tplot variable 'el_0'
;         el_high:
;             the 'y' tag from the tplot variable 'el_high'
;         el_0_en:
;             the 'v' tag from the tplot variable 'el_0'
;         el_high_pa:
;             the 'v' tag from the tplot variable 'el_high'
;
; SEE ALSO:
;     "strarr_to_arrstr.pro", "makecdf.pro"
;
; CREATED BY: Vince Saba
;
; LAST MODIFICATION: @(#)make_cdf_structs.pro	1.2 09/05/96
;-


pro make_cdf_structs, tp_namelist, datavary, datanovary, times=times
@tplot_com.pro

if (data_type(tp_namelist) ge 1) and (data_type(tp_namelist) le 3) then begin
    tp_namelist = [data_quants(tp_namelist).name]    
endif

n_names = n_elements(tp_namelist)

strvary = 0
datanovary = 0
for i = 0, n_names - 1 do begin
    name = tp_namelist(i)
    get_data, name, data=data, limit=limit
    if i eq 0 then begin
	if not keyword_set(times) then times = data.x
        add_str_element, strvary, 'time', times
    endif

    ; for each tplot name, add data.y to the strvary structure
    interpdata = data_cut(data, times)
    add_str_element, strvary, name, interpdata

    ; for each tplot name, add data.v to the datanovary structure
    add_str_element, datanovary, name + '_v', data.v
endfor

; convert this structure of time-based arrays into a time-based
; array of structures.
strarr_to_arrstr, strvary, datavary

return
end


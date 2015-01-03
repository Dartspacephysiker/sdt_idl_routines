;+
; FUNCTION: countcdfrvarrecs
;
; PURPOSE: count the number of records written to rvariables in one or more CDF files
;
; INPUTS:
;     filespec:
;         file specification of the files to be counted, in the form
;         used by findfile.pro.
;
; KEYWORDS:
;     count:
;         receives the number of CDFs that result from expanding the filespec.
;
; OUTPUTS:
;     return value:
;         returns an array of structures containing the names and number of elements
;         of each of the specified files.  The number of elements in the array of
;         structures is equal to 'count' described above.  Each structure has two
;         fields, 'name', which contains the filename of the CDF, and 'size', which
;         contains the number of rvariable records contained in the file.
;     
; EXAMPLE:
;     To generate a list of the names and sizes of all the EES orbit CDF files:
;         stats = countcdfrvarrecs('/disks/juneau/cdf1/ees/fa_k0_ees*.cdf', count=count)
;         for i = 0, count - 1 do begin
;             print, stats(i).name, stats(i).size
;         endfor
;             
; CREATED BY: Vince Saba, July, 1997.
;
; VERSION: @(#)countcdfrvarrecs.pro	1.2 07/18/97
;-


function countcdfrvarrecs, filespec, count=count

cdffilelist = findfile(filespec)
if cdffilelist(0) eq '' then begin
    count = 0
    return, 0
endif

count=n_elements(cdffilelist)
element = {name:'', size:0}
result = replicate(element,count)
for i = 0, count - 1 do begin
    cdffile = cdffilelist(i)
    id = cdf_open(cdffile)
    inq = cdf_inquire(id)
    result(i).name = cdffile
    result(i).size = inq.maxrec + 1
    cdf_close,id
endfor

return, result
end


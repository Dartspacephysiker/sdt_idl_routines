;+
;NAME:  cdf_info
;FUNCTION:   cdf_info(id)
;PURPOSE:
;  Returns a structure with useful information about a CDF file.
;  In particular the number of file records is returned in this structure.
;-

function cdf_info,id

inq = cdf_inquire(id)
q = !quiet
!quiet = 1
cdf_control,id,var='Epoch',get_var_info=info,get_filename=fn
!quiet = q
res = create_struct('filename',fn,inq,'num_recs',info.maxrec+1)

return,res

end

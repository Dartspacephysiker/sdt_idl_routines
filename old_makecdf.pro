 pro old_makecdf,data,filename=filename,tagnames=tagnames,overwrite=overwrite

if keyword_set(overwrite) then begin
  on_ioerror, create
  id = cdf_open(filename)
  cdf_delete,id
  create:
  on_ioerror,null
endif

id = cdf_create(filename,/single)
nr = n_elements(data)

if not keyword_set(tagnames) then tagnames = tag_names(data)

nt = n_elements(tagnames)

;print,nt,nr
;print,tagnames
for n=0,nt-1 do begin
  d0 = data(0)
  nd = ndimen(d0.(n))
  dim = dimen(d0.(n))
  type = data_type(d0.(n))
;print,tagnames(n),nd,dim
  dat = data.(n)
  if nd ne 0 then begin
    case data_type(dat) of
     1:  zid = cdf_varcreate(id,tagnames(n),dim ne 0,dim=dim,/cdf_uchar)
     2:  zid = cdf_varcreate(id,tagnames(n),dim ne 0,dim=dim,/cdf_int2)
     3:  zid = cdf_varcreate(id,tagnames(n),dim ne 0,dim=dim,/cdf_int4)
     4:  zid = cdf_varcreate(id,tagnames(n),dim ne 0,dim=dim,/cdf_float)
     5:  zid = cdf_varcreate(id,tagnames(n),dim ne 0,dim=dim,/cdf_double)
    endcase
  endif else begin
    case data_type(dat) of
     1:  zid = cdf_varcreate(id,tagnames(n),/zvar,/cdf_uchar)
     2:  zid = cdf_varcreate(id,tagnames(n),/zvar,/cdf_int2)
     3:  zid = cdf_varcreate(id,tagnames(n),/zvar,/cdf_int4)
     4:  zid = cdf_varcreate(id,tagnames(n),/zvar,/cdf_float)
     5:  zid = cdf_varcreate(id,tagnames(n),/zvar,/cdf_double)
    endcase
  endelse   
  cdf_varput,id,tagnames(n),dat
endfor

epoch0 = 719528.d * 24.* 3600. * 1000.  ;Jan 1, 1970
epoch = data.time  * 1000. + epoch0
zid = cdf_varcreate(id,'Epoch',/CDF_EPOCH)
cdf_varput,id,'Epoch',epoch

cdf_close,id

end

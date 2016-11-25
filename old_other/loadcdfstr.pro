;+
;PROCEDURE:	loadcdfstr
;PURPOSE:	
;  loads data from specified cdf file into a structure.
;INPUT:		
;	x:		A named variable to return the structure in
;
;KEYWORDS:
;       FILENAMES:  [array of] CDF filename[s].  (or file id's)
;       VARNAMES:   [array of] CDF variable name[s] to be loaded.
;       TAGNAMES:   optional array of structure tag names.
;       TIME:     If set, will create tag TIME using the Epoch variable.
;SEE ALSO:
;  "loadcdf", "loadallcdf", "print_cdf_info","make_cdf_index"
;
;CREATED BY:	Davin Larson 
;MODIFICATIONS:
;LAST MODIFICATION:	@(#)loadcdfstr.pro	1.9 07/02/12
;-

pro loadcdfstr,data0,novardata  $
   ,filenames=cdf_files $
   ,varnames=cdf_vars,tagnames=tagnames $
   ,novarnames=novarnames $
   ,append=append,time=time

if n_elements(cdf_files) eq 0 then cdf_files=dialog_pickfile(filter="*.cdf")

on_ioerror,skip

for num = 0,n_elements(cdf_files)-1 do begin

   cdf_file = cdf_files(num)
   id = 0
   if data_type(cdf_file) eq 7 then id = cdf_open(cdf_file) else id = cdf_file
   if not keyword_set(silent) then print,'Loading ',cdf_file
   
   inq = cdf_info(id)

   if not keyword_set(cdf_vars) then begin     ;get only variables that vary
      for n=0,inq.nvars-1 do begin
         vinq=cdf_varinq(id,n)
         if vinq.recvar eq 'VARY' then append_array,cdf_vars,vinq.name
      endfor
      for n=0,inq.nzvars-1 do begin
         vinq=cdf_varinq(id,n,/zvar)
         if vinq.recvar eq 'VARY' then append_array,cdf_vars,vinq.name
      endfor
   endif

   nvars = n_elements(cdf_vars)
   if not keyword_set(tagnames) then tagnames = cdf_vars
   tagnames = strcompress(tagnames,/remove_all)

   if not keyword_set(data0) then append=0
   if not keyword_set(append)  then begin      ;define the data structure:
;      if keyword_set(time) then dat = {TIME:0.d}
      for n=0,nvars-1 do begin
          vinq = cdf_varinq(id,cdf_vars(n))
          if vinq.is_zvar then dim = vinq.dim else dim = inq.dim*vinq.dimvar
          w = where(dim,ndim)
          if ndim gt 0 then dim=dim(w) else dim=0
;print,cdf_vars(n),ndim,dim
          case vinq.datatype of
            'CDF_REAL8' :   value = 0.d
            'CDF_DOUBLE':   value = 0.d
            'CDF_REAL4' :   value = 0.
            'CDF_FLOAT' :   value = 0.
            'CDF_INT4'  :   value = 0l
            'CDF_INT2'  :   value = 0
            'CDF_INT1'  :   value = 0b
            'CDF_CHAR'  :   value = 0b
            'CDF_UCHAR' :   value = 0b
            'CDF_EPOCH' :   value = 0.d
            else        :   message ,'Invalid type,  please fix source...'
          endcase
          if ndim gt 0 then val = make_array(value=value,dim=dim)   $
          else val=value
          add_str_element,dat,tagnames(n),val
      endfor
      if keyword_set(time) then begin
          w = where(tag_names(dat) eq 'TIME',c)
          if c eq 0 then add_str_element,dat,'TIME',0.d
      endif
   endif else dat = data0(0)

   nrecs = inq.num_recs
   data = replicate(dat,nrecs)

   del = 0
   if keyword_set(time) then begin
      loadcdf,id,'Epoch',x
      epoch0 = 719528.d * 24.* 3600. * 1000.  ;Jan 1, 1970
      data.time = (x - epoch0)/1000.
;      del = 1
   endif
;help,dat,/st
;print,cdf_vars
   for n=0,nvars-1 do begin
       loadcdf,id,cdf_vars(n),x,/no_shift
;print,n,'  ',cdf_vars(n)
;help,x
;help,data.(n+del)
       data.(n+del) = x
   endfor

   if num eq 0 and keyword_set(novarnames) then begin
      novardata = 0
      novartags = strcompress(novarnames,/remove_all)
      for i=0,n_elements(novarnames)-1 do begin
         loadcdf,id,novarnames(i),val
         add_str_element,novardata,novartags(i),val
      endfor
   endif

   if data_type(cdf_file) eq 7 then cdf_close,id

   if keyword_set(append) then data0=[data0,data] else data0 = data
   append = 1
skip: 
   if id eq 0 then print,'Unable to open file: ',cdf_file
endfor

end




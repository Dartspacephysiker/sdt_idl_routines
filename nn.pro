FUNCTION nn,data,time,silent=silent ;nearest neighbor function
;+
;NAME:                  nn
;PURPOSE:               Find the index of the data point(s) nearest to the specified time(s)
;                       
;CALLING SEQUENCE:      ind=nn(data,time)
;INPUTS:                data:  a data structure, a tplot variable name/index,
;                          or a time array
;                       time:  (double) seconds from 1970-01-01, scalar or array
;                              if not present, "ctime" is called to get time(s)
;OPTIONAL INPUTS:       none
;KEYWORD PARAMETERS:    silent:  passed to ctime if input time not specified
;OUTPUTS:               a long scalar index or long array of indicies
;                       on failure, returns: -2 if bad inputs, 
;                                            -1 if nearest neighbor not found
;EXAMPLE:               ctime,times,npoints=2
;                       inds=nn('Np',times)
;                       get_data,'Np',data=dens & get_data,'Tp',data=temp
;                       plot,dens.y(inds(0):inds(1)),temp(inds(0):inds(1))
;LAST MODIFICATION:     @(#)nn.pro	1.4 96/12/06
;CREATED BY:            Frank Marcoline
;-
  if not keyword_set(silent) then silent = 0

  nd = n_elements(data)         ;1 if a str, more if an array

  case data_type(data) of 
    0: begin 
      print,'Must supply input data'
      return,-2
    end 
    8: dat = data
    7: get_data,data,data=dat
    6: begin 
      print,'Can''t handle complex inputs'
      help,data
      return,-2
    endif 
    else: if nd gt 1 then dat = {x:data} else get_data,data(0),data=dat
  endcase 

  if data_type(time) eq 0 then ctime,time,silent=silent

  n = n_elements(time)
  if n eq 1 then inds = 0l else inds = lonarr(n)

  for i=0,n-1 do begin 
    a = abs(dat.x-time(i))
    b = min(a,c)                ;c contains the index to b
    inds(i) = c
  endfor 
  return,inds
end

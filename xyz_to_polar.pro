;+
;PROCEDURE:  xyz_to_polar,xyz
;PURPOSE: Calculates magnitude, theta and phi given a 3 vector 
;INPUT:   several options exist for xyz:
;    string:    data associated with the string is used.
;    structure: data.y is assumed to contain the xyz array
;    array(n,3)   n by (x,y,z components)
;    array(3)      vector:  [x,y,z]
;RETURN VALUES: through the keywords.  Same dimensions and type as the 
;    input value of x.
;KEYWORDS:    Named variables in which results are put
;   MAGNITUDE:
;   THETA:
;   PHI:   
;   MAX_VALUE:
;   MIN_VALUE:
;   MISSING:
;OPTION KEYWORDS:  These are used to set "cart_to_sphere" opts.
;   CO_LATITUDE:   If set theta will be in co-latitude. (0<=theta<=180)
;   PH_0_360:      If set positive, 0<=phi<=360, if zero, -180<=phi<=180.
;                  If set negative, will guess the best phi range.
;   PH_HIST:       A 2 element vector, a min and max histeresis value.
;EXAMPLES:
;
;     Passing arrays:
;x = findgen(100)
;y = 2*x
;z = x-20
;vecs = [[x],[y],[z]]
;xyz_to_polar,vecs,mag=mag      ;mag will be the magnitude of the array.
;
;     Passing a structure:
;dat = {ytitle:'Vector',x:findgen(100),y:vecs}
;xyz_to_polar,dat,mag=mag,theta=th,phi=ph
;mag,th and ph will be all be structures.
;
;     Passing a string:  (see store_data, get_data)
;xyz_to_polar,'Vp'   ; This assumes data has been created for this string.
;    This will compute new data quantities: 'Vp_mag','Vp_th','Vp_ph'
;-

pro xyz_to_polar,data, $
    magnitude = magnitude, $
    theta = theta, $
    phi = phi,  $
    max_value=max_value, $
    min_value=min_value, $
    missing = missing, $
    co_latitude=co_latitude,$
    ph_0_360=ph_0_360, $
    ph_hist=ph_hist

case data_type(data) of
   7: begin                                       ; strings
      get_data,data,data=struct    ;,limits=lim
      str_element,struct,'max_value',val=max_value
      str_element,struct,'min_value',val=min_value
      if data_type(struct) ne 8 then return       ; error
      xyz_to_polar,struct,mag=mag_struct,theta=th_struct,phi=ph_struct, $
          max_value=max_value,min_value=min_value,$
          co_latitude=co_latitude,ph_0_360=ph_0_360,ph_hist=ph_hist
      magnitude = data+'_mag'
      theta     = data+'_th'
      phi       = data+'_phi'
      store_data,magnitude,data=mag_struct
      store_data,theta    ,data=th_struct
      store_data,phi      ,data=ph_struct,dlim={ynozero:1}
      return
      end
   8: begin                                       ; structures
      xyz_to_polar,data.y,mag=mag_val,theta=theta_val,phi=phi_val,$
         max_value=max_value,min_value=min_value,missing=missing,$
          co_latitude=co_latitude,ph_0_360=ph_0_360,ph_hist=ph_hist
      yt = ''
      str_element,data,'ytitle',val=yt
      magnitude = {x:data.x, y:mag_val}
      theta     = {x:data.x, y:theta_val}
      phi       = {x:data.x, y:phi_val}
      if keyword_set(yt) then begin
         add_str_element,magnitude,'ytitle',yt+' (mag)'
         add_str_element,theta,'ytitle',yt+' (theta)'
         add_str_element,phi,'ytitle',yt+' (phi)'
      endif
      if keyword_set(min_value) then begin
         add_str_element,magnitude,'min_value',min_value
         add_str_element,theta,'min_value',min_value
         add_str_element,phi,'min_value',min_value
      endif
      if keyword_set(max_value) then begin
         add_str_element,magnitude,'max_value',max_value
         add_str_element,theta,'max_value',max_value
         add_str_element,phi,'max_value',max_value
      endif
      return
      end
   else: begin                                    ; normal arrays
      if ndimen(data) eq 2 then begin
         x = data(*,0)
         y = data(*,1)
         z = data(*,2)
      endif else begin
         x = data(0)
         y = data(1)
         z = data(2)
      endelse
      cart_to_sphere,x,y,z,magnitude,theta,phi,$
         co_latitude=co_latitude,ph_0_360=ph_0_360,ph_hist=ph_hist
      if keyword_set(max_value) then begin
         ind = where(x ge max_value,count)
         if count gt 0 then begin
            if n_elements(missing) eq 0 then missing = max(x)
            magnitude(ind)=missing
            theta(ind)=missing
            phi(ind)=missing
         endif
      endif
      if keyword_set(min_value) then begin
         ind = where(x le min_value,count)
         if count gt 0 then begin
            if n_elements(missing) eq 0 then missing = min(x)
            magnitude(ind)=missing
            theta(ind)=missing
            phi(ind)=missing
         endif
      endif
      return
      end
endcase

end




      
      
      
   

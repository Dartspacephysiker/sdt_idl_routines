;+
;PROCEDURE:	get_E_perp
;PURPOSE:	
;	Generates two E_perp component-time data structures for tplot, 
;       E_perp spin-axial component from ion distribution, E_perp spin-plane component from field measurement
;       in spacecraft velocity coordinates and transformed E_perp in north-east (perp to B) coordinates
;       
;KEYWORDS:
;	T1:		start time, seconds since 1970
;	T2:		end time, seconds since 1970		
;
;OUTPUT: 
;       eion:           E_perp spin-axial component
;       eavmean:        E_perp spin-plane component
;       Eeast:          E_perp component along the east unit vector
;       Enorth:         E_perp component along the north unit vector
;       '-v_iXb [mV/m]'    {x:time, y:eion}
;       'sm_eav'           {x:time, y:eavmean}
;       'Eeast'            {x:time, y:Eeast}
;       'Enorth'           {x;time, y:Enorth}
;
;CREATED BY:	Kyoung-joo Hwang, Kristina A. Lynch, Bill Peria
;VERSION:	1
;LAST MODIFICATION:  2004/08/10
;
;EXAMPLE)
;   If you run this code with FAST orbit 1750 with these parameters,
;   '1997-01-30/06:40:55','1997-01-30/06:41:27' 
;   you should get a plot that looks like 'getEperp750.ps'
;

pro get_E_perp, tt1, tt2, NO_PLOT = no_plot

device, decomposed = 0, retain = 2
loadct2,13

me = 9.11e-31         ;;; electron mass [kg]
mi = 16*1.67e-27      ;;; for Oxygen ion
;mi = 1.67e-27        ;;; for Hydrogen ion

;'1997-01-30/06:40:55','1997-01-30/06:41:27'    (1750)  => southward  down
;;;;;;; v_drift, ion by computing the 1st moment of ion distribution function

vdrift=fltarr(1)
tvd=dblarr(1)

ivdrift=0
time=gettime(tt1)

while time lt gettime(tt2) do begin
ies = get_fa_ies_c(time,/advance)
ies = conv_units(ies,'counts')
ies.data = ies.data > 1
if (min(ies.data) eq 1) then ies.data(where(ies.data eq 1)) = !values.f_nan
ies = conv_units(ies,'df')
iesvprp = ies.data*0.0
iesvpar = ies.data*0.0
iesvvv = sqrt(ies.energy*1.6e-19*2/mi)     
iesvprp = iesvvv*sin(ies.theta*!dtor)
iesvpar = iesvvv*cos(ies.theta*!dtor)

d3v = sqrt(ies.energy)*ies.denergy*abs(sin(ies.theta/57.3))*ies.dtheta
vdriftok = where(ies.data eq ies.data and ies.denergy ne 0)
newvdrift =                         $
        total(iesvprp(vdriftok)*ies.data(vdriftok)*d3v(vdriftok))/   $
        total(ies.data(vdriftok)*d3v(vdriftok)   )                     
newtvd = time

if (ivdrift eq 0) then begin
    vdrift = [newvdrift] 
    tvd = [newtvd]
endif else begin
    vdrift = [vdrift, [newvdrift]]
    tvd = [tvd, [newtvd]]
endelse

ivdrift = ivdrift+1
endwhile


;;;;;;; E_ion = -(v_drift+v_sc) X b, including subtraction of sc velocity contribution

;get_fa_orbit, tvd, n_elements(tvd), /time_array, /no_store, struc=orb, /all, /def
get_fa_orbit, tvd, n_elements(tvd), /time_array, /no_store, struc=orb, /all, orbit_file='/afs/northstar.dartmouth.edu/ugrad/river/almanac/orbit/definitive'
bbbalt = sqrt(total(orb.B_model^2,2))    ;;;;; in nT
v_sc = sqrt(total(orb.fa_vel^2,2))       ;;;;; in km/s

store_data,'-v_scXb',data={x:tvd,y:(-0.*vdrift-v_sc*1000.)*bbbalt*1.e-6}
options,'-v_scXb','color',100   ;;; blue

eion=-1.0*(vdrift+v_sc*1000.)*bbbalt*1.e-6     ;;;;; in mV/m
store_data,'-v_iXb [mV/m]',data={x:tvd,y:eion}    ;;;;; vec[v_i = v_measure + v_sc], v_sc~90deg
store_data,'zero',data={x:tvd,y:-0.0*eion}


;;;;;;; E_along_V, E_near_B to get smoothed E along V 

fa_fields_despin, t1=tt1, t2=tt2

get_data,'E_ALONG_V',data=ealongv
store_data,'eav',data={x:ealongv.x,y:ealongv.y}


;;;;;;; Averaging eav data corresponding to the time scale of eion 

binsize = (tvd[1:*]-tvd)[n_elements(tvd[1:*])/2]
;bmean, ealongv.x, ealongv.y, BINSIZE=binsize, /no_plot, xb=bins, bme=eavmean
bmean, ealongv.x, ealongv.y, BINSIZE=binsize, /no_plot, xbins=bins, bmean=eavmean
store_data, 'sm_eav', data={x:bins, y:eavmean}
store_data, 'smoothedeav', data={x:bins, y:eavmean}
options,'smoothedeav', 'color',4     ;;; green


;;;;;;; Coordinate transformation

unitB = normn3(orb.B_model)                                 ;;; z-axis
unitQ = normn3(crossn3(orb.fa_vel, orb.B_model))            ;;; y-axis 
unitv_fperp = normn3(crossn3(orb.B_model, unitQ))           ;;; x-axis


;;; v_drift = (v_drift dot unitQ)*unitQ + (v_drift dot unitv_fperp)*unitv_fperp
;;;                  (1)                           (2)
;;;         (1)  <== from ealongv/B, i.e., eavmean [mV/m]  
;;;         (2)  <== from v_drift from ion distribution fn.  therefore you already get these (1) and (2).
;;; v_drift = (East_comp)*unitE + (North_comp)*unitN
;;;
;;; E_ion = - v_drift X B = B*(v_drift dot unitQ)*(unitB X unitQ) + B*(v_drift dot unitv_fperp)*(unitB X unitv_fperp)
;;;                                               -------------- unitv_fperp                     ------------ - unitQ
;;; East_comp = unitE (dot) E_ion
;;;           = B*(v_drift dot unitQ)*(unitE dot unitv_fperp) - B*(v_drift dot unitv_fperp)*(unitE dot unitQ)
;;; North_comp = unitN (dot) E_ion
;;;            = B*(v_drift dot unitQ)*(unitN dot unitv_fperp) - B*(v_drift dot unitv_fperp)*(unitN dot unitQ)


unitR = normn3(orb.fa_pos)
z = [0.,0.,1.]
unitz = repvec(z,n_elements(tvd))                
unitE = normn3(crossn3(unitz, unitR))             ;;; East unit vector
unitN = normn3(crossn3(unitR, unitE))             ;;; North unit vector 

eavmean = congrid(eavmean, n_elements(tvd))
viondrift = vdrift+v_sc*1000.0

Enorth = eavmean*total(unitN*unitv_fperp,2) - bbbalt*viondrift*total(unitN*unitQ,2)*1.e-6     ;;; in mV/m
Eeast = eavmean*total(unitE*unitv_fperp,2) - bbbalt*viondrift*total(unitE*unitQ,2)*1.e-6      ;;; in mV/m

store_data, 'Eeast', data={x:tvd, y:Eeast}
store_data, 'Enorth', data={x:tvd, y:Enorth}
options,'Enorth', 'color',6      ;;; red
store_data, 'Eeast, Enorth(red)', data={x:tvd, y:Eeast}

if not keyword_set(no_plot) then begin
	ymin = min([Enorth, Eeast])
	ymax = max([Enorth, Eeast])

	tplot,['-v_iXb [mV/m]','eav','Eeast, Enorth(red)']

	tplot_panel,var='-v_iXb [mV/m]',oplot='zero' 
	tplot_panel,var='-v_iXb [mV/m]',oplot='-v_scXb'
	tplot_panel,var='eav',oplot='smoothedeav'
	tplot_panel,var='eav',oplot='zero'
	tplot_panel,var='Eeast, Enorth(red)',oplot='Enorth'
	tplot_panel,var='Eeast, Enorth(red)',oplot='zero'
	ylim,'Eeast, Enorth(red)',ymin,ymax,0	
endif

stop
;file1 = 'getEprp1750'
;popen,ctable=39,/port,file1

;pclose

return
end




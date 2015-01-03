;+
;PROCEDURE:	plot_fa_k0_orb.pro
;INPUT:	none
;
;PURPOSE:
;	Plots FAST Orbit Ephemeris and Attitude Data
;
;	Plot 1: Right Ascension of Spin Axis
;	Plot 2: Declination of Spin Axis
;	Plot 3: Spacecraft Altitude
;	Plot 4: Footprint Latitude
;	Plot 5: Footprint Longitude
;	Plot 6: Magnetic Local Time
;	Plot 7: Invariant Latitude
;
;KEYWORDS
;
;NOTES:	
;	Run load_fa_k0_orb.pro first to get the k0 data
;
;CREATED BY:	Tim Quinn 2009-09-21
;VERSION:	1
;LAST MODIFICATION:  
;MOD HISTORY:	
;-
pro plot_fa_k0_orb

	get_data,'orbit',data=tmp
	ntmp=n_elements(tmp.y)
	if ntmp gt 5 then begin
		orb=tmp.y(5)
		orbit_num=strcompress(string(orb),/remove_all)
		if ntmp gt 11 and orb ne tmp.y(ntmp-5) then begin
			orbit_num=orbit_num+'-'+strcompress(string(tmp.y(ntmp-5)),/remove_all)
		endif
	endif else begin
		orb=tmp.y(ntmp-1)
		orbit_num=strcompress(string(orb),/remove_all)
	endelse
	
	tplot,['fa_spin_ra','fa_spin_dec','alt','flat','flng','mlt','ilat'] $
	,title='FAST Ephemeris/Attitude Data for Orbit '+orbit_num

return
end

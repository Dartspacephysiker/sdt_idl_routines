;+
;PROCEDURE:   tplot  [,datanames]
;PURPOSE:     
;   Creates a time series plot of user defined quantities.
;INPUT:     
;   datanames:  Array of handles. (string names)   Each string should be a
;       handle associated with a data quantity.  (see the "STORE_DATA" and 
;       "GET_DATA" routines.)   Alternatively, datanames can be an array of
;       integers, run "TPLOT_NAMES" to show the current numbering.     
;
;KEYWORDS:
;   TITLE:    A string to be used for the title. (Remembered)
;   ADD_VAR:  Set this variable to add datanames to the previous plot.
;   LASTVAR:  Set this variable to plot the previous variables.
;   MIX:      An array of integers used to mix the order of plot panels.
;     ie. to reverse the order of a 3 panel plot, type:
;     tplot,mix=[2,1,0]
;   WINDOW:   Window to be used for all time plots.  If set to -1, then the
;             current window is used.
;   VAR_LABEL:  String [array]; Variable(s) used for putting labels along
;     the bottom. This allows quantities such as altitude to be labeled.
;   VER:      Must be 1,2 or 3 (2 is default)  Uses a different labeling scheme.
;   OVERPLOT: Will not erase the previous screen if set.
;
;RESTRICTIONS:
;   Some data must be loaded prior to trying to plot it.  Try running 
;   "_GET_EXAMPLE_DAT" for a test.
;
;EXAMPLES:  (assumes "_GET_EXAMPLE_DAT" has been run)
;   tplot,['amp','slp','flx2'] ;Plots the named quantities
;   tplot,'flx1',/ADD          ;Add the quantity 'flx1'.
;   tplot                      ;Re-plot the last variables.
;   tplot,var_label=['alt']   ;Put Distance labels at the bottom.
;       For a long list of examples see "_TPLOT_EXAMPLE"
;
;OTHER RELATED ROUTINES:
;   Examples of most usages of TPLOT and related routines are in 
;      the crib sheet: "_TPLOT_EXAMPLE"
;   Use "TPLOT_NAMES" to print a list of acceptable names to plot.
;   Use "TPLOT_OPTIONS" for setting various global options. 
;   Plot limits can be set with the "YLIM" procedure.
;   Spectrogram limits can be set with the "ZLIM" procedure.
;   Time limits can be set with the "TLIMIT" procedure.
;   The "OPTIONS" procedure can be used to set all IDL
;      plotting keyword parameters (i.e. psym, color, linestyle, etc) as well
;      as some keywords that are specific to tplot (i.e. panel_size, labels, 
;      etc.)  For example, to change the relative panel width for the quantity
;      'slp', run the following:
;            OPTIONS,'slp','panel_size',1.5
;   TPLOT calls the routine "SPECPLOT" to make spectrograms and 
;      calls "MPLOT" to make the line plots. See these routines to determine
;      what other options are available.
;   Use "GET_DATA" to retrieve the data structure (or
;      limit structure) associated with a TPLOT quantity.
;   Use "STORE_DATA" to create new TPLOT quantities to plot.
;   The routine "DATA_CUT" can be used to extract interpolated data.
;   The routine "TSAMPLE" can also be used to extract data.
;   Time stamping is performed with the routine "TIME_STAMP".
;   Use "CTIME" or "GETTIME" to obtain time values.
;   tplot variables can be stored in files using "TPLOT_FILE"
;
;CREATED BY:	Davin Larson  June 1995
;FILE:  tplot.pro
;VERSION:  1.59
;LAST MODIFICATION:  97/02/05
;-

pro tplot,datanames,      $
   WINDOW = wind,         $
   NOCOLOR = nocolor,     $
   VER = ver,             $
   OPLOT = oplot,         $
   OVERPLOT = overplot,   $
   TITLE = title,         $
   LASTVAR = lastvar,     $
   MIX = mix,             $
   ADD_VAR = add_var,     $
   REFDATE = refdate,     $
   VAR_LABEL = var_label, $
   OPTIONS = opts,        $
   T_OFFSET = t_offset,   $
   TRANGE = trng,         $
   NAMES = names,         $
   PICK = pick, $
   NEW = new          

@tplot_com.pro

if keyword_set(overplot) then oplot=overplot
if n_elements(trng) eq 2 then trange = time_double(trng)

tplot_options,ver=ver,title=title,var_label=var_label,refdate=refdate, $
   wind=wind, options = opts

chsize = !p.charsize
if chsize eq 0. then chsize=1.

def_opts= {ymargin:[4.,2.],xmargin:[12.,12.],position:fltarr(4), $
   title:'',ytitle:'',xtitle:'', $
   xrange:dblarr(2),xstyle:1,    $
   version:2, t_window:-1, wshow:0,  $
   charsize:chsize,noerase:0,overplot:0,spec:0}

extract_tags,def_opts,tplot_opts

if keyword_set(new) then tplot_var=0
if n_elements(tplot_var) eq 0 then tplot_var=0

if keyword_set(lastvar) then  datanames = tplot_lastvar   

if keyword_set(pick) then $
   ctime,prompt='Click on desired panels. (button 3 to quit)',panel=mix
if keyword_set(mix) then datanames = tplot_var(mix)  

dt = data_type(datanames)
if (dt ge 1) and (dt le 3) then  datanames=[data_quants(datanames).name]

if keyword_set(add_var) and n_elements(tplot_var) ne 0 then begin
   datanames = [datanames,tplot_var]
endif 

if keyword_set(new) or n_elements(tplot_var) eq 0 then return

nd = n_elements(datanames)
if nd gt 0 then begin
   tplot_lastvar = tplot_var
   tplot_var = datanames ;  array of names
endif

if !d.name eq 'X' then begin
   current_window= !d.window > 0
   if def_opts.t_window ge 0 then w = def_opts.t_window $
   else w = current_window
   wset,w
   if def_opts.wshow ne 0 then wshow,icon=0
endif

ind = array_union(tplot_var,data_quants.name)
sizes = data_quants(ind).panel_size

ns = n_elements(sizes)
 
nd = dimen1(tplot_var)
tplot_y = replicate(!y,nd)
tplot_clip = lonarr(6,nd)


str_element,def_opts,'ygap',value = ygap
str_element,def_opts,'charsize',value = chsize

if keyword_set(nocolor) then add_str_element,def_opts,'nocolor',nocolor

nvlabs = [0.,0.,0.,1.]
nvl = n_elements(tplot_var_label) + nvlabs(def_opts.version) 
def_opts.ymargin = def_opts.ymargin + [nvl,0.]


pos = plot_positions(ysizes=sizes,options=def_opts,ygap=ygap)


if trange(0) eq trange(1) then trg=minmax_range(reform(data_quants(ind).trange)) $
else  trg = trange

if def_opts.version eq 3 then begin
   str_element,def_opts,'num_lab_min',value=num_lab_min
   str_element,def_opts,'tickinterval',value=tickinterval
   str_element,def_opts,'xtitle',value=xtitle
   if not keyword_set(num_lab_min) then $
      num_lab_min= 2. > (.035*(pos(2,0)-pos(0,0))*!d.x_size/chsize/!d.x_ch_size)
   time_setup = time_ticks(trg,time_offset,num_lab_min=num_lab_min, $
      side=vtitle,xtitle=xtitle,tickinterval=tickinterval)
   time_scale = 1.
   if keyword_set(tplot_var_label) then begin
      time = time_setup.xtickv+time_offset
      for i=0,n_elements(tplot_var_label)-1 do begin
         vtit = strmid(tplot_var_label(i),0,3)
         get_data,tplot_var_label(i),data=data,alimits=limits
         if data_type(data) ne 8 then  print,tplot_var_label(i),' not valid!' $
         else begin
            def = {ytitle:vtit, format:'(F6.1)'}
            extract_tags,def,data,tags = ['ytitle','format']
            extract_tags,def,limits,tags = ['ytitle','format']
            v = data_cut(data,time)
            vlab = strcompress( string(v,format=def.format) ,/remove_all)
            vtitle = def.ytitle + '!C' +vtitle
            time_setup.xtickname = vlab +'!C'+time_setup.xtickname
            time_setup.xtitle = '!C'+time_setup.xtitle
         endelse
      endfor
   endif
   extract_tags,def_opts,time_setup
endif

if def_opts.version eq 2 then begin
   time_setup = timetick(trg(0),trg(1),0,time_offset,xtitle)
   time_scale = 1.
   if keyword_set(tplot_var_label) then begin
      time = time_setup.xtickv+time_offset
      vtitle = 'UT'
      for i=0,n_elements(tplot_var_label)-1 do begin
         vtit = strmid(tplot_var_label(i),0,3)
         get_data,tplot_var_label(i),data=data,alimits=limits
         if data_type(data) ne 8 then  print,tplot_var_label(i),' not valid!' $
         else begin
            def = {ytitle:vtit, format:'(F6.1)'}
            extract_tags,def,data,tags = ['ytitle','format']
            extract_tags,def,limits,tags = ['ytitle','format']
            v = data_cut(data,time)
            vlab = strcompress( string(v,format=def.format) ,/remove_all)
            vtitle = vtitle + '!C' +def.ytitle
            time_setup.xtickname = time_setup.xtickname +'!C'+vlab
            xtitle = '!C'+xtitle
         endelse
      endfor
      def_opts.xtitle = xtitle
   endif else def_opts.xtitle = 'Time (UT) '+xtitle
   extract_tags,def_opts,time_setup
endif 

if def_opts.version eq 1 then begin
   deltat = trg(1) - trg(0)
   case 1 of
      deltat lt 60. : begin & time_scale=1.    & tu='Seconds' & p=16 & end
      deltat lt 3600. : begin & time_scale=60.   & tu='Minutes' & p=13 & end
      deltat le 86400. : begin & time_scale=3600. & tu='Hours'   & p=10 & end
      deltat le 31557600. : begin & time_scale=86400. & tu='Days' & p=7 & end
      else            : begin & time_scale=31557600. & tu='Years' & p = 5 & end
   endcase
   ref = strmid(time_to_str(trg(0)),0,p)
   time_offset = str_to_time(ref)
;   print,ref+' '+tu,p,time_offset-trg(0)
   def_opts.xtitle = 'Time (UT)  '+tu+' after '+ref
   add_str_element,def_opts,'xtickname',replicate('',22)
endif

t_offset = time_offset

def_opts.xrange = (trg-time_offset)/time_scale

if keyword_set(oplot) then def_opts.noerase = 1

for i=0,nd-1 do begin
   name = tplot_var(i)
   def_opts.position = pos(*,i)         ;  get the correct plot position
   get_data,name,alimits=limits,data=data,index=index
   if index eq 0 then  print,'Unknown variable: ',name $
   else print,index,name,format='(i3," ",a)'
   if keyword_set(data) then  nd2 = n_elements(data) else nd2 = 1
   if data_type(data) eq 7 then datastr=data else datastr=0
   for d=0,nd2-1 do begin
     newlim = def_opts
     newlim.ytitle = name
     if keyword_set(datastr) then begin
        name = datastr(d)
        get_data,name,index=index,data=data  ,alimits=limits2
        if index eq 0 then  print,'Unknown variable: ',name $
        else print,index,name,format='(i3,"   ",a)'
     endif else limits2 = 0
     if data_type(data) eq 8 then data.x = (data.x - time_offset)/time_scale $
     else data={x:dindgen(2),y:findgen(2)}
     extract_tags,newlim,data,      except = ['x','y','dy','v']
     extract_tags,newlim,limits2
     extract_tags,newlim,limits
;     extract_tags,newlim,def_opts
     newlim.overplot = d ne 0
     if keyword_set(overplot) then newlim.overplot = 1   ;<- *** LINE ADDED **
     if i ne (nd-1) then newlim.xtitle=''
     if i ne (nd-1) then newlim.xtickname = ' '
     if newlim.spec ne 0 then routine='specplot' else routine='mplot'
     str_element,newlim,'tplot_routine',value=routine
     call_procedure,routine,data=data,limits=newlim
   endfor
   def_opts.noerase = 1
   def_opts.title  = ''
   tplot_y(i)=!y  
   tplot_clip(*,i) = !p.clip
endfor
tplot_d = !d
tplot_p = !p
tplot_x = !x
trange_cur = (!x.range * time_scale) + time_offset

if keyword_set(vtitle) then begin                 ; finish var_labels
  xspace = chsize * !d.x_ch_size / !d.x_size
  yspace = chsize * !d.y_ch_size / !d.y_size
  xpos = pos(0,nd-1) - (def_opts.xmargin(0)-1) * xspace 
  ypos = pos(1,nd-1) - 1.5 * yspace 
  xyouts,xpos,ypos,vtitle,/norm,charsize=chsize
endif


time_stamp,charsize = chsize*.5

if !d.name eq 'X' then begin
  tplot_window = !d.window
  if def_opts.t_window ge 0 then wset,current_window
endif
return
end


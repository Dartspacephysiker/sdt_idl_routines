;+
;PROCEDURE:  tplot_options [,string,value]
;NAME:
;  tplot_options
;PURPOSE:
;  Sets global options for the tplot routine.
;KEYWORDS:
;   HELP:      Display current options structure.
;   VAR_LABEL:   String [array], variable[s] to be used for plot labels.
;   FULL_TRANGE: 2 element double array specifying the full time range.
;   TRANGE:      2 element double array specifying the current time range.
;   REFDATE:    Reference date.  String with format: 'YYYY-MM-DD'.
;         This reference date is used with the gettime subroutine.
;   WINDOW:     Window to be used for all time plots. (-1 specifies current 
;       window.
;   VERSION:    plot label version. (1 or 2 or 3)
;EXAMPLES:
;   tplot_options,'ynozero',1          ; set all panels to YNOZERO=1
;   tplot_options,'title','My Data'    ; Set title
;   tplot_options,'xmargin',[10,10]    ; Set left/right margins to 10 characters
;   tplot_options,'ymargin',[4,2]      ; Set top/bottom margins to 4/2 lines
;   tplot_options,'position',[.25,.25,.75,.75]  ; Set plot position (normal coord)
;   tplot_options,'wshow',1             ; de-iconify window with each tplot
;   tplot_options,'version',3          ; Sets the best time ticks possible
;   tplot_options,'window',0           ; Makes tplot always use window 0
;   tplot_options,/help                ; Display current options
;   tplot_options,get_options=opt      ; get option structure in the variable opt.
;
;SEE ALSO:  "TPLOT", "OPTIONS", "TPLOT_COM"
;CREATED BY:  Davin Larson   95/08/29
;LAST MODIFICATION: 97/02/05
;VERSION: @(#)tplot_options.pro	1.12
;-
pro tplot_options,string,value  $
  ,var_label=var_label $
  ,version=version  $
  ,title = title  $
  ,refdate = refdate  $
  ,full_trange = tr_full   $
  ,trange = tr    $ 
  ,options = opts  $ 
  ,get_options = get_opts $
  ,help=help  $
  ,window = wind
@tplot_com

if n_elements(opts)      ne 0 then tplot_opts    = opts
if data_type(tplot_opts) ne 8 then tplot_opts=0
if data_type(string) eq 7 then options,tplot_opts,string,value

if n_elements(title)     ne 0 then options,tplot_opts,'title',title

if n_elements(var_label) ne 0 then tplot_var_label = var_label
if n_elements(version)   ne 0 then options,tplot_opts,'version',version
if n_elements(refdate)   ne 0 then $
   tplot_refdate = strmid(time_string(refdate),0,10)

if n_elements(tr)        ne 0 then trange = tr
if n_elements(tr_full)   ne 0 then trange_full = tr_full
if n_elements(wind)      ne 0 then options,tplot_opts,'t_window',wind

if n_elements(trange_full)   eq 0 then trange_full = double([0.,0.])
if n_elements(trange_old)    eq 0 then trange_old  = trange_full
if n_elements(trange)        eq 0 then trange = trange_old

if keyword_set(help) then begin
   help,/st,tplot_opts,tplot_var_label,tplot_var 
endif

get_opts = tplot_opts

end

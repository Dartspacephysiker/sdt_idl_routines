;+
;COMMON BLOCK:  tplot_com
;
;WARNING!  THIS COMMON BLOCK IS SUBJECT TO CHANGE!  DON'T BE TOO SURPRISED
;   IF VARIABLES ARE ADDED, CHANGED, OR DISAPPEAR!
;
;   data_quants:  structure array,  handle to location of ALL data.
;   tplot_var:     string array containing the names of data quantities
;      to be plotted.  There will be one panel for each element of the array.
;   time_offset:   double,  time offset for the x data points.
;   time_scale:    almost obsolete.
;   trange:        2 element double array:  time range for next plot.
;   trange_cur:    2 element double array:  Actual start/end times of last plot.
;   trange_old:    2 element double array:  Previous start/end times.
;   trange_full:   2 element double array:  Full start/end times.
;   tplot_refdate: string:  format: YYYY-MM-DD  Time reference for a
;      reference date.  Used for relative addressing in the gettime routine.
;   tplot_window:  integer.  window number used for last plot.
;   tplot_x:       copy of !x structure
;   tplot_y;       array of !y structures.
;   tplot_var_label:  variable name to be used in labeling.
;SEE ALSO:   "tplot_options" and "tplot"
;CREATED BY:	Davin Larson
;LAST MODIFICATION: 97/02/05
;VERSION: @(#)tplot_com.pro	1.19
;
;-
common tplot_com, data_quants, tplot_var, $
   tplot_lastvar,  $
   time_offset,time_scale,  $
   trange,trange_old,trange_full, $
   trange_cur,              $
   tplot_refdate,   $
   tplot_var_label, $
   tplot_window,    $
   tplot_x,         $
   tplot_y,         $
   tplot_d,         $
   tplot_p,         $
   tplot_clip,      $
   tplot_opts


;   trange_nxt:    2 element double array:  start/end times for next plot.

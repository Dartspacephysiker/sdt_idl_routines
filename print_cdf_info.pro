;+
;PROCEDURE: 	print_cdf_info
;PURPOSE:	prints information about a specified cdf file
;INPUT:
;	filename:	The name of the file for which info is desired.
;KEYWORDS:	
;	none
;
;CREATED BY:	unknown
;LAST MODIFICATION: 	@(#)print_cdf_info.pro	1.11 07/02/12
;-

pro print_cdf_info,filename
if keyword_set(filename) eq 0 then filename = dialog_pickfile()
print,'File: ',filename
id=cdf_open(filename)
;print,id
result=cdf_info(id)
help,result,/str
print,'dim=',result.dim
q= !quiet
print,'number or records=',result.num_recs
;help,info,/st

cdf_doc,id,v,r,c
;print,v,r,c
print,format='(" mrec ","rec"," Z","          VAR NAME","        TYPE"," ELEM", "   VARY"," DIMVAR")'
;help,cdf_varinq(id,0),/str
for itest =0,result.nvars-1  do begin
!quiet =1
   cdf_control,id,var=itest,get_var_info=info
!quiet = q
   vinq = cdf_varinq(id,itest)
   print,info.maxrec,format='(i5," ",$)'
   print,itest,vinq,format='(i3,i2,a18,a12,i5,a7,5z)'
endfor

for itest =0,result.nzvars-1  do begin
!quiet =1
   cdf_control,id,var=itest,get_var_info=info,/zvar
!quiet = q
   vinq = cdf_varinq(id,itest, /zvariable)
   print,info.maxrec,format='(i5," ",$)'
   print,itest,vinq,format='(i3,i2,a18,a12,i5, a7, i7,i7,i7,i7)'
endfor


cdf_close,id
end



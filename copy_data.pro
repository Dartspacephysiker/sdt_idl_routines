;+
;PROCEDURE:  	copy_data,  oldname, newname
;PURPOSE:	to copy a data structure
;INPUT:	
;	oldname:	name associated with old data structure
;	newname:	name associated with new data structure
;KEYWORDS:
;       LINK:   if set, then the data is not copied but is linked to the old
;                   name.
;
;SEE ALSO:	"get_data", 
;		"store_data"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION: copy_data.pro  1.9   95/11/22
;-
pro copy_data,oldname,newname,LINK=link
get_data,oldname,lim=lim,data=data
data.ytitle = newname
if keyword_set(link) then data = oldname
store_data,newname,lim=lim,data=data
return
end





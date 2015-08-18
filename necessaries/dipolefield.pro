function dipolefield,alt

Bo=5.40115e-5; T at surface
RE=6370.0e3
fromcentre=alt+RE
return, Bo*(RE/fromcentre)^3 
end
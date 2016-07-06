FUNCTION LOSS_CONE_WIDTH,altitude
;this pro given an altitude in m returns the half angle of the loss cone
;assuming a width of 90 deg at 100km
  ratio     = DIPOLEFIELD(100.0*1000.0)/DIPOLEFIELD(altitude)
  halfwidth = ATAN(SQRT(1/(ratio-1)))
  
  RETURN,halfwidth

END
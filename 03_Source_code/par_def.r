# Default parameters for WORMSIM
  par.def <- list(surveys = list(start = list(year = 2000, month = 0),
                                 stop = list(year = 2000, month = 1),
                                 interval = list(year = 0, month = 1)),
                  rbr = 0.34,
                  exposure.p1 = 3.5,
                  mda = list(nrounds = 20,
                             years = 2000:2019,
                             months = 0,
                             coverage = 0.7),
                  morbidity = list(threshold = 3000,
                                   suscept.shape = 1.5,
                                   regression = 0))
  
  
### END OF CODE ###
  
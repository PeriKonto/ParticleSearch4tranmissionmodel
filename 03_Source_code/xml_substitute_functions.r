# Functions to substitute parameter values in a parsed XML files. All functions
# follow the naming convention "set.[name]", where [name] refers to the
# parameter for which the value(s) is/are to be substituted. All functions take
# two arguments:
#   doc = object holding a parsed XML file, created with read.inputfile().
#   pars = named list of parameter value(s).


# Change parameter values for disease process
  set.morbidity <- function(doc = NULL, par = list(threshold = NULL,
                                                   suscept.shape = NULL,
                                                   regression = NULL)) {
    
    xpath.expr <- "/wormsim.inputfile/disease.processes/disease.process"
    parameters <- xpathApply(doc, xpath.expr)
    
    xmlAttrs(parameters[[1]])["susceptibility.shape.param"] <- paste(par$suscept.shape)
    xmlAttrs(parameters[[1]][[1]])["a"] <- paste(par$regression)
    xmlAttrs(parameters[[1]][[3]])["treshold"] <- paste(par$threshold[1])
    #xmlAttrs(parameters[[1]][[4]])["treshold"] <- paste(par$threshold[2])
    
    return(doc)
    
  }
  
  set.morbidity.threshold <- function(doc = NULL, par = NULL) {
    
    xpath.expr <- "/wormsim.inputfile/disease.processes/disease.process"
    parameters <- xpathApply(doc, xpath.expr)
    
    xmlAttrs(parameters[[1]][[3]])["treshold"] <- paste(par[1])
   # xmlAttrs(parameters[[1]][[4]])["treshold"] <- paste(par[2])
    
    return(doc)
    
  }

  set.morbidity.suscept.shape <- function(doc = NULL, par = NULL) {
    
    xpath.expr <- "/wormsim.inputfile/disease.processes/disease.process"
    parameters <- xpathApply(doc, xpath.expr)
    
    xmlAttrs(parameters[[1]])["susceptibility.shape.param"] <- paste(par)
    
    return(doc)
    
  }
  
  set.morbidity.regression <- function(doc = NULL, par = NULL) {
    
    xpath.expr <- "/wormsim.inputfile/disease.processes/disease.process"
    parameters <- xpathApply(doc, xpath.expr)
    
    xmlAttrs(parameters[[1]][[1]])["a"] <- paste(par)
    
    return(doc)
    
  }
  

# Change the history of MDA
# NOTE: if there are comments within the treatment element of the template
#       XML file, these will count towards the number of lines and will result
#       in treatments rounds being dropped at the bottom of the element!
  set.mda <- function(doc = NULL, par = list(nrounds = NULL, years = NULL,
                                             months = NULL, coverage = NULL)) {
    
    xpath.expr <- "/wormsim.inputfile/mass.treatment/treatment.rounds/treatment.round"
    treatments <- xpathApply(doc, xpath.expr)
    
    years <- sort(rep(par$years, length(par$months)))
    months <- rep(par$months, length(par$years))
    coverage <- rep(par$coverage, length(par$months)*length(par$years))
    
    for (i in 1:par$nrounds) { # set attributes to appropriate values
      
      xmlAttrs(treatments[[i]])["year"] <- paste(years[i])
      xmlAttrs(treatments[[i]])["month"] <- paste(months[i])
      xmlAttrs(treatments[[i]])["coverage"] <- paste(coverage[i])
      
    }
    
    a  <-  (xmlChildren(doc)$wormsim.inputfile)[["mass.treatment"]][["treatment.rounds"]]
    n  <-  length(xmlChildren(a))
    
    if (par$nrounds < n){
      removeChildren(a, kids = as.list((par$nrounds+1):n))
    }
    
    return(doc)
    
  }
  
  set.cov <- function(doc = NULL, par = NULL) {
    
    xpath.expr <- "/wormsim.inputfile/mass.treatments/mass.treatment/treatment.rounds/treatment.round"
    treatments <- xpathApply(doc, xpath.expr)
    
    a  <-  (xmlChildren(doc)$wormsim.inputfile)[["mass.treatments"]][["mass.treatment"]][["treatment.rounds"]]
    n  <-  length(xmlChildren(a))
    
    coverage <- par
    if(length(coverage) < n) coverage <- rep(coverage, n)
    
    for (i in 1:n) { # set attributes to appropriate values
      
      xmlAttrs(treatments[[i]])["coverage"] <- paste(coverage[i])
      
    }
    
    return(doc)
    
  }
  
  
# Change exposure heterogeneity (for both sexes)
  set.exposure.p1 <- function(doc, par = NULL) {
    
    xpath.expr <- "/wormsim.inputfile/exposure/male/exposure.index"
    dist <- xpathApply(doc, xpath.expr)
    xmlAttrs(dist[[1]])["p1"] <- paste(par)
    
    xpath.expr <- "/wormsim.inputfile/exposure/female/exposure.index"
    dist <- xpathApply(doc, xpath.expr)
    xmlAttrs(dist[[1]])["p1"] <- paste(par)
    
    return(doc)
    
  }
  
  
# Change relative biting rate
  set.rbr <- function(doc, par = NULL) {
    
    xpath.expr <- "/wormsim.inputfile/fly/monthly.biting.rates"
    env <- xpathApply(doc, xpath.expr)
    xmlAttrs(env[[1]])["relative.biting.rate"] <- paste(par)
    
    return(doc)
    
  }
  
  
# Change timing of periodic surveys
  set.surveys <- function(doc, par = list(start = list(year = NULL, month = NULL),
                                          stop = list(year = NULL, month = NULL),
                                          interval = list(year = NULL, month = NULL))) {
    
    xpath.expr <- "/wormsim.inputfile/simulation/surveillance/start"
    surv.start <- xpathApply(doc, xpath.expr)
    xmlAttrs(surv.start[[1]])["year"] <- paste(par$start$year)
    xmlAttrs(surv.start[[1]])["month"] <- paste(par$start$month)
    
    xpath.expr <- "/wormsim.inputfile/simulation/surveillance/stop"
    surv.stop <- xpathApply(doc, xpath.expr)
    xmlAttrs(surv.stop[[1]])["year"] <- paste(par$stop$year)
    xmlAttrs(surv.stop[[1]])["month"] <- paste(par$stop$month)
    
    xpath.expr <- "/wormsim.inputfile/simulation/surveillance/interval"
    surv.int <- xpathApply(doc, xpath.expr)
    xmlAttrs(surv.int[[1]])["years"] <- paste(par$interval$year)
    xmlAttrs(surv.int[[1]])["months"] <- paste(par$interval$month)
    
    return(doc)
  }


# Change value of zeta and exposure.p1
  set.rbr.expo.p1 <- function(doc = NULL, par = list(rbr = NULL,
                                                     exposure.p1 = NULL)) {
    
  # Set rbr
    xpath.expr <- "/wormsim.inputfile/fly/monthly.biting.rates"
    env <- xpathApply(doc, xpath.expr)
    xmlAttrs(env[[1]])["relative.biting.rate"] <- paste(par$rbr)
    
  # Set exposure.p1
    xpath.expr <- "/wormsim.inputfile/exposure/male/exposure.index"
    dist <- xpathApply(doc, xpath.expr)
    xmlAttrs(dist[[1]])["p1"] <- paste(par$exposure.p1)
    
    xpath.expr <- "/wormsim.inputfile/exposure/female/exposure.index"
    dist <- xpathApply(doc, xpath.expr)
    xmlAttrs(dist[[1]])["p1"] <- paste(par$exposure.p1)
    
    return(doc)
    
  }
  
  
  
### END OF CODE
  
  
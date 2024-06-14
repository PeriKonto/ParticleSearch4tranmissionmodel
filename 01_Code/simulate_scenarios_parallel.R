#####  Script for parallel simulation in WORMSIM v2.75#### 
# Original Author: Luc Coffeng (L.C) << Created: 10 November 2016 >>
# Modified by Peri Kontoroupis (P.K) 10 January 2017 to use its output by the Grid Search script

# This script uses Wormsim v2.75
#is used to find optimal parameter combinations that only fit the first threshold (i.e. any severity) 
# whereas the second threshold is fixed at a high value.

# v1. 1.2.17 P.K
#---------------------------------------------------------------------------
### START OF CODE ###
# Prep session
  rm(list = ls())

  library(data.table)
  library(foreach)
  library(doParallel)
  library(XML)
  library(ggplot2)

  base.dir    <- "V:/UserData/461049/Luc Parallel v2.75"
  code.dir    <- file.path(base.dir, "01_Code")
  output.dir  <- file.path(base.dir, "02_Output")
  source.dir  <- file.path(base.dir, "03_Source_code")
  wormsim.dir <- file.path(base.dir, "04_wormsim_v2.75")
    
  input.template <- file.path(source.dir, "template.xml")
  input.schema   <- file.path(wormsim.dir, "wormsim.xsd")

# Load functions
  setwd(source.dir)
  source("xml_substitute_functions.r")  # Functions to adjust an xml file
  source("create_xml_functions.r")      # Automated script to create xml file from a template
  source("basic_functions.r")           # Functions to run WORMSIM and process output
  source("par_grid_functions.r")        # Function to create a grid of parameter values
  source("par_def.R")                   # Default values for subset of parameters

  
# Default parameters (if different from those specified in "par_def.R)
  seed.start <- 0
  seed.end   <- 9 # use 10 seed numbers to random number generator - model output is the average 
  
  par.def <- within(par.def, {
    surveys <- list(start = list(year = 2000,
                                 month = 0),
                    stop = list(year = 2001,
                                month = 1),  # make sure that at least two surveys take place for code to work
                    interval = list(year = 1,
                                    month = 0))
    mda <- list(nrounds = 20,  # Cannot exceed the number of treatments in template
                years = 2000:2019,
                months = c(0, 6),
                coverage = 0.0)
    rbr <- 0.430 # hyper endemic case
    exposure.p1 <- 3.5
    morbidity <- list(threshold = 1,  # first element = stage-1 disease (note: in the xml file the stage 2 is set to 1e15)
                      #c(1, 3e3),     # example: first element = stage-1 disease,  second element = stage-2 disease
                      suscept.shape = 1.5,
                      regression = 0)
  })
  
  setwd(wormsim.dir)
  generate.inputfile(template = input.template, schema = input.schema,
                     xml.name = "input_default", pars = par.def)
  
  # example: 1st iteration range of parameters for the first iteration,  
   #par.alt <- list(rbr = c(0.305, 0.43),
   #                 morbidity.threshold = exp(seq(from = log(1e2), to = log(5e3), length.out = 5)),
   #                  morbidity.suscept.shape =  1 / seq(from = 1, to = 50, length.out = 5),
   #                 morbidity.regression    =  seq(from = 0.0, to = 0.25, length.out = 5))
  
  # example: 2nd iteration - deactive the 1st iteration and select range of parameters for the second iteration 
   par.alt <- list(rbr = c(0.305, 0.43),
                morbidity.threshold = exp(seq(from = log(1e1), to = log(5e2), length.out = 5)),
                morbidity.suscept.shape =  1 / seq(from = 10, to = 40, length.out = 5),
                morbidity.regression    =  seq(from = 0.0, to = 0.0125, length.out = 5))

  par.alt.combi.list <- create.par.list(par.alt)

# quick plot to see how the pameter grid looks like
  threshold          <- lapply(par.alt.combi.list, function(x) {x[2]})       
  suscept.shape      <- lapply(par.alt.combi.list, function(x) {x[3]})  
  regression         <- lapply(par.alt.combi.list, function(x) {x[4]}) 
  parOld<-par(mfrow=c(1,2))  
  plot(unlist(threshold), unlist(suscept.shape))
  plot(unlist(threshold), unlist(regression))
# user should manually close the window 

  start.time <- Sys.time()
# Run simulations and save in a list object ("output") with each element of the
# representing a parameter set
  cluster <- makeCluster(parallel::detectCores())
  
  registerDoParallel(cluster)
  
  output <- foreach(i = 1:length(par.alt.combi.list),
                    .inorder = TRUE,
                    .errorhandling = "remove",
                    .packages = c("XML", "data.table")) %dopar% {
                      
                    # Set paths and load functions (re-execute for parallel sessions)
                      setwd(source.dir)
                      source("xml_substitute_functions.r")
                      source("create_xml_functions.r")
                      source("basic_functions.r")
                      source("par_grid_functions.r")
                      
                    # Create folder to work in
                      setwd(wormsim.dir)
                      input.file.name <- paste("par_set_", i, sep = "")
                      dir.create(file.path(wormsim.dir, input.file.name),
                                 showWarnings = FALSE)
                      file.copy(dir(), file.path(wormsim.dir, input.file.name),
                                overwrite = TRUE)
                      setwd(file.path(wormsim.dir, input.file.name))
                      
                      # Run model
                      generate.inputfile(template = "input_default.xml",
                                         schema = input.schema,
                                         xml.name = input.file.name,
                                         pars = par.alt.combi.list[[i]])
                      run.proc.sim(
                        input.file = input.file.name,
                        seed.start = seed.start,
                        seed.end = seed.end,
                        delete.txt = FALSE
                      )
                      
                    # # Read summary files
                    #   summ <- data.table(read.output(input.file.name, type = ""))
                    #   age <- data.table(read.output(input.file.name, type = "X"))
                    #   intensity <- data.table(read.output(input.file.name, type = "Y"))
                      
                    # Read individual simulation files and remove failed simulations
                      summ <- read.output.ind(input.file.name,
                                              seed.start = seed.start,
                                              seed.end = seed.end,
                                              type = "")
                      age <- read.output.ind(input.file.name,
                                             seed.start = seed.start,
                                             seed.end = seed.end,
                                             type = "X")
                      # intensity <- read.output.ind(input.file.name,
                      #                              seed.start = seed.start,
                      #                              seed.end = seed.end,
                      #                              type = "Y")

                      fail <- summ[1,4,] == 0
                      summ <- data.table(apply(summ[,, !fail], 1:2, mean))
                      age <- data.table(apply(age[,, !fail], 1:2, mean))
                      # intensity <- data.table(apply(intensity[,, !fail], 1:2, mean))
                      
                    # Save zip file and clean up
                       zip.file <- dir(pattern = "zip")
                       file.copy(
                         from = zip.file,
                         to = file.path(output.dir, zip.file)
                       )
                      
                    # Clean up
                      setwd(wormsim.dir)
                      unlink(input.file.name, recursive = TRUE)
                      
                    # Return result
                      with(par.alt.combi.list[[i]],
                           list(par_set = i,
                                n_sim = sum(!fail),
                                summ = summ,
                                age = age))
                    } 
  
  stopCluster(cluster)
  
# Clean up WORMSIM folder
  unlink(file.path(wormsim.dir, "input_default.xml"))
  
# Save output
  setwd(output.dir)
  save.image(file = file.path(output.dir, "scen_results.RData"))
  
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  time.taken
  
### END OF CODE ###
  
#### Grid parameter search #####
# This script searches in a 3-d parameter grid, credible parameter combination that fit model predictions of skin disease per age class to observations 

# The inputs to the script are : 
# a. the output from the parallel script  (scen_results.RData)
# b. the mesoendemic mf observations  (outputhyper_SD.csv)
# c. the hyperendemic mf observations (outputmeso_SD.csv)

# The outputs are saved as pdf under \02_Output folder
# 1.Pdf of the 3-d parameter grid and the associated Sum of square error metric (distance function)  
# 2.Diagnostic plots in pdf of the parameter combinations and their associated fit to observations (meso and hyper cases)   

# Author: Peri Kontoroupis (PK) Erasmus MC
# v1. 16.1.17 P.K
# v2. 25.1.17 Amended by Luc Coffeng
# v3. 01.2.17 P.K.

# known issues 
# Warning message: "Removed 125 rows containing missing values (geom_point)"
# this is warning message is generated from the NaNs in the observations

# Future version: 
# User can choose to select a different stage - 1, symptoms including:
# Hanging groin (hg)
# skin atrophy (atr)
# Troublesome itch (itchprev)

#---------------------------------------------------------------------------
#[1] Nomeclature for outputhyper_SD.csv and outputmeso_SD.csv
# Column headings :
# agegr VillageID   N nod skin itch itchsl atr dpmi dpmc dpm hg 
# nodprev  skinprev   itchprev itchslprev   atrprev   dpmiprev    dpmcprev  
# dpmprev     hgprev       nod_lo     nod_hi     skin_lo   skin_hi    itch_lo
# itchsl_hi atr_lo    atr_hi      dpm_lo     dpm_hi      hg_lo     hg_hi

#[2] Nomeclature for scen_results.RData
# lists : par.alt.combi.list, output, par.alt.combi.table 
#---------------------------------------------------------------------------
### START OF CODE ###

rm(list = ls())

# load libraries
library(data.table)
library(ggplot2)
library(plyr)

# set directories
base.dir   <- "V:/UserData/461049/Luc Parallel v2.75"

sim.dir    <- file.path(base.dir, "02_Output") 
output.dir <- file.path(base.dir, "01_Code")   
data.dir   <- file.path(base.dir, "05_Data")

# load observation data
setwd(data.dir)
#---------------------------------------------------------------------------
load("hyper endemic.RData")  
obs.data <- copy(all_pop); 
setkey(obs.data, VillageID, agegr)  # sort by aggregate name and village id
# remove all unnessary names
obs.data=obs.data[, agegr := factor(x = agegr,
                                    levels = levels(agegr),
                                    labels = gsub(pattern = " years",  
                                                  replacement = "",
                                                  x = levels(agegr)),
                                    ordered = TRUE)]

### this can be changed by user to any health outcome
obs.data[, morb.data := (skin/N) * 100]  # mf prevalence (%) for skin atrophy (irreversible)

load("meso endemic.RData") 
obs2.data <- copy(all_pop); 
setkey(obs2.data, VillageID, agegr)  # sort by aggregate name and village id
# remove all unnessary names
obs2.data=obs2.data[, agegr := factor(x = agegr,
                                    levels = levels(agegr),
                                    labels = gsub(pattern = " years",  
                                                  replacement = "",
                                                  x = levels(agegr)),
                                    ordered = TRUE)]

### this can be changed by user to any health outcome
obs2.data[, morb.data := (skin/N) * 100]  # mf prevalence (%) for skin atrophy (irreversible)
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# load simulation output from parallel script 
setwd(sim.dir)
load("scen_results.RData") 

### LUC ### 25.1.17
par.alt.combi.table <- rbindlist(par.alt.combi.list)  # produces a data.table that is easier to work with and keep track of
###########

plot.points <- function(y)
{
  y$par_set  
}
id=sapply(output, plot.points)
par.alt.combi.table[, id:= id]  # generares a unique key, required to link the model predictions to the observations
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Define function to calculate distance function: combine meso and hyper endemic
calc.distance <- function(y, data1, data2) {
  
  rbr.input <- par.alt.combi.table[y$par_set, rbr]  
  y <- y$age[year == min(year)]
  # select model parameters that are grouped per age and
  y[, MmorbAny := M * ((MmorbStage1 + MmorbStage2) / 100)]
  y[, FmorbAny := F * ((FmorbStage1 + FmorbStage2) / 100)]
  y[, MorbAny := (MmorbAny + FmorbAny) / (M + F) * 100]   
  
  if (rbr.input == 0.305) { # meso endemic
    data <- copy(data1)
  } else {                # hyper endemic
    data <- copy(data2)
  } 
  
  y[, agegr := factor(x = age,
                    levels  = c(5, 10, 20, 30, 50,  70, 90),
                    labels = data[, levels(agegr)])]
  
  data <- merge(x = data, y = y[, list(agegr, MorbAny)], by = "agegr", all = TRUE) 

  # Distance function (SSE) of the model realizations to the model output
  data[, sum((morb.data - MorbAny)^2, na.rm = TRUE)] 
    
 }

par.alt.combi.table[, SSE := sapply(output, calc.distance, data1 = obs.data, data2 = obs2.data)]

grid.fit <- par.alt.combi.table[, list(SSE = sum(SSE)), by = .(morbidity.threshold, morbidity.suscept.shape, morbidity.regression)]

# Plot utility: save the parameter grid in a pdf 
pd <- position_dodge(0.5)
pdf("Grid search outcome.pdf", width = 15, height = 13)
ggplot(data = grid.fit,
       mapping = aes(x = morbidity.threshold,
                     y = morbidity.suscept.shape,
                     size = SSE)) +
  geom_point() +
  facet_wrap(~ morbidity.regression, labeller = "label_both")
dev.off()
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# Diagnostic plots 
#1. Extract the relevant model predictions from the list object output, 
plot.points <- function(y, data1, data2) {
  x <- y$par_set
  rbr.input <- par.alt.combi.table[y$par_set, rbr]
  y <- y$age[year == min(year)]
  # select model parameters that are grouped per age and
  y[, MmorbAny := M * ((MmorbStage1 + MmorbStage2) / 100)]
  y[, FmorbAny := F * ((FmorbStage1 + FmorbStage2) / 100)]
  y[, MorbAny := (MmorbAny + FmorbAny) / (M + F) * 100]    
  if (rbr.input == 0.305) { # meso endemic
    data <- copy(data1)
  } else {                # hyper endemic
    data <- copy(data2)
  }   
  y[, agegr := factor(x = age,
                      levels  = c(5, 10, 20, 30, 50,  70, 90),
                      labels = data[, levels(agegr)])]
  data <- merge(x = data, y = y[, list(agegr, MorbAny)], by = "agegr", incomparables = NA) # merge observations to model realizations
 zz <- dim(data)
 data[, id:=  rep.int(x,  zz[1] ) ]
 data.table(data)[, .(agegr, VillageID, morb.data, MorbAny, id)]
}

list.ofdata=lapply(output, plot.points, data1 = obs.data, data2 = obs2.data)

#Rbindlist the result to get a nice data.table with columns for age group, prevalence of Morb, and parameter set identifier.
list.ofdata <- rbindlist(list.ofdata)  
  
#Merge the paramater values onto the result from step 1, using the parameter set identifying number.
data2list <- merge(x = list.ofdata, y = par.alt.combi.table, by = "id", incomparables = NA) 

#In the data.table resulting create an additional column for endemicity (given the rbr)
data2list[, endem := ifelse(data2list$rbr==0.430, "Hyperendemic", "Mesoendemic")]

#4.  Plot the model predictions vs the observations per endemic scenario
pd <- position_dodge(0.5)

select.var =  "skin atrophy" ### this can be changed by user to any health outcome

pdf("Diagnostic plots per endemic scenario.pdf", width = 15, height = 13)

for(select.endem in c("Mesoendemic", "Hyperendemic")) {
  print(
ggplot(data = data2list[endem == select.endem]) +
  geom_line(mapping = aes(x = agegr,
                          y = MorbAny,
                          col = morbidity.suscept.shape,
                          group = id)) +
  geom_point(data = data2list[endem == select.endem],
             aes_string(x = "agegr",
                        y = "morb.data",
                        group = "VillageID"),
             colour = "black",
             position = pd,
             size = .75) +
  facet_grid(morbidity.threshold ~ morbidity.regression, labeller = label_both) +
  scale_y_continuous(name = "Morbidity (%)\n",
                     limits = c(0, 100),
                     breaks = 0:5 * 20) +
  scale_x_discrete(name = "\nAge category (years)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle(paste0("Variable: ", select.var,
                 "\nSetting: ", select.endem,
                 "\n")) 
)
}
dev.off()

#---------------------------------------------------------------------------
### END OF CODE ###
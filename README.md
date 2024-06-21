 This script searches in a 3-d parameter grid, credible parameter combination that fit model predictions of skin disease per age class to observations 

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

Wormsim-2 v2.75 (Nov 2, 2016)
1. Fixed bug that caused symptoms not to be removed after regression of damage (note that the disease process itself worked correctly).

Wormsim-2 v2.74 (Oct 19, 2016)
1. Prevented negative values of damage due to a disease process (which caused an exception when regression rate was > 0)

Wormsim-2 v2.73 (Oct 05, 2016)
1. Fixed annoying error in mixup of true/false for v58 treatment.

Wormsim-2 v2.72 (Oct 30, 2014)
1. Fixed bug in v58 treatment and mf production (female worms were knockout during entire recoveryperiod)

Wormsim-2 v2.71 (Oct 10, 2014)
1. Fixed bug in cumulative treatment effect.

Wormsim-2 v2.70 (Oct 10, 2014)
1. Included options for mass treatment with different drugs for v58 treatment

Wormsim-2 v2.69 (Oct 2, 2014)
1. Added options for mass treatment with different drugs

Wormsim-2 v2.68 (Sep 7, 2014)
1. Added individual output
   Set attribute individual-output of surveillance element "false" to suppress individual output

Wormsim-2 v2.67 (July 28, 2014)
1. Refactored treatment

Wormsim-2 v2.66 (July 21, 2014)
1. Fixed bug in v58 treatment

Wormsim-2 v2.65 (July 11, 2014)
1. Split the OV16 output in mf- and mf+

Wormsim-2 v2.64 (June 19, 2014)
1. Added option to use the v58 treatment effects. The attribute v58 in <mass.treatment v58="true"> 
   is used to choose between v58 and the new (v62) treatment effects. See input-wormsim-v264.xml.

Wormsim-2 v2.63 (May 6, 2014)
1. Added OV16 flags

Wormsim-2 v2.62 (Apr 1, 2014)
1. Merged v2.58F and v2.61 (where v2.58F is a merge of 2.58Ap3 and 2.58E)

Wormsim-2 v2.61 (Apr 23, 2012)
1. fout gecorrigeeerd in vector control / initialisatie per run

Wormsim-2 v2.60 (Apr 20, 2012)
1. prepatente wormen worden niet langer door ivermectine behandeling gedood

Wormsim-2 v2.59 (Apr 11, 2012)
A. Effecten ivermectine behandeling

1. Sterfte M en F wormen 
	Voor elke behandeling en voor elke persoon wordt een random getal r uit [0,1) getrokken.
	Op basis van r wordt voor M en F wormen de stertekans bepaald (via de inverse vd CDF van een beta verdeling die apart voor M en F wormen
	in de intputfile wordt gespecificeerd).
	Per worm bepaalt de sterftekans voor M/F wormen of de betreffende worm de behandeling overleeft.
    Herhaalde behandeling: idem, alles random, dus geen consistentie van vatbaarheid voor behandeling oid
2. Mf productie en inseminatie F wormen
    mf productie = 0, gedurende bepaalde periode x (waarbij x wordt getrokken uit een verdeling, bijv een Weibull)
    inseminatie F wormen onmogelijk gedurende deze periode x
    herhaalde behandeling: alleen effect als mf productie > 0 
    geen consistentie van effect behandeling (per worm of behandelingsronde)
PLANNED FOR v2.60
B. Individuele output

    voor alle survey momenten:
    YEAR;ID;GENDER;BIRTHDATE;AVG(SKINSNIPCOUNT);#PAST IVM TREATMENTS

wormsim-2 v2.58 (Jan 7, 2012)
* added a new section to the inputfile to allow defining age classes for survey output 
  different from those used to specify the standard population
  see rbr75-exp677c13.xml and rbr75-exp677c14.xml and of course the XML schema wormsim.xsd
wormsim-2 v2.57 (Jan 5, 2012)
* modified implementation of ivermectin treatment effect to be compliant with Onchosim
  an ivermectin treatment can never lead to a recovery of a worm sooner than 
  the recovery from a previous treatment (this could happen due to heterogeneity in treatment effect and
  small interval between ivermectin treatments)
* corrected an error in the averaging procedure that caused error in zipping and deleting 
  output of individual runs when a range of runs did not start with 0

wormsim-2 v2.56 (Jan 4, 2012)
* corrected an error in the sequence of events triggered by the monthly event
  until now, L1uptake was based on mf load of the previous month
  in Onchosim, as now in Wormsim, the order is as follows:
  1. reproduction (i.e. insemination of female worms)
  2. mf production update
  3. calculcate FOI from L1uptake (or use clamped FOI during warmup period)
  4. distribute new worms

wormsim-2 v2.55 (Jan 3, 2012)
* corrected an error in the implementation of the delay of the monthly event
* inputfile rbr75-exp677c6.xml has the correct delays:
  reaper   		-4
  newborns 		-3   
  survey  		-2
  ivermectine 	-1
  monthly event +1
  
wormsim-2 v2.54 (Jan 2, 2012)
* included prepatent worms (both M and F) in ivermectin treatment ; this
  will cause F worms to have a lower mf production when becoming patent and inseminated 
  the first time


wormsim-2 v2.53 (Jan 2, 2012)
* modified defaults for optional delays; omitting the delays mentioned below will result in the default values specified below.

* modified default for optional delay attribute to survey start 		(default = -5 hours)
see:	<surveillance nr.skin-snips="2">
            <start year="2000" delay="-5"/>
            <stop year="2020"/>
            <interval years="5"/>
        </surveillance>

* modified default for optional delay attribute to treatment rounds		(default = -4 hours)
see:	<mass.treatment>
              <treatment.rounds>
                     <treatment.round year="2000" month="2" coverage="0.6" delay="-4"/>
                     <treatment.round year="2001" month="2" coverage="0.6" delay="-4"/>
                     <treatment.round year="2002" month="2" coverage="0.6" delay="-4"/>

* modified default for optional delay attribute to fertility table 		(default = -3 hours)
see:	<fertility.table delay="-3">

* modified default for optional delay attribute to the reaper   		(default = -2 hours)
see: 	<the.reaper max.population.size="440" reap="0.1" delay="-2"/>

* added optional monthly.event.delay attribute to worm					(default = -1 hour)
  this affects the monthly worm distribution
see		<worm mf-lifespan="9" monthly.event.delay="-1">

The allowed range for these attributes is +/- 12 (hours)

wormsim-2 v2.52 (Nov  30, 2011)
* included the Onchosim erroneous calculation Cw' = Cw + fc (instead of - as specified in the manual Cw' = Cw/(1-fc)) in the -o option
* added optional delay attribute to survey start 	(default = +0 hour)
* added optional delay attribute to the reaper   	(default = +1 hour)
* added optional delay attribute to fertility table (default = +2 hours)
* added optional delay attribute to treatment rounds(default = +3 hours)
  the allowed range for these attributes is +/- 12 (hours)
* allowed monthnr = 0 which is also the default for surveys ; yearnr=2000 and monthnr=0 is the same as yearnr=1999 monthnr=12


wormsim-2 v2.51 (Nov  9, 2011)
* added command-line option (-o) to reproduce Onchosim errors in births and exposure of newborns:
  with the -o option, newborns will be generated at the end of each year and added to the population in the past year (after the yearly survey)
  
wormsim-2 v2.50 (Oct 12, 2011)
* corrected error in getProduction() for Onchosim. The error was that recentlyInseminated() was NOT checked. 


wormsim-2 v0.01 (May 3, 2011)
* created a common code base for onchosim and schistosim
* checked events package: current version of event package will be common base
* see diff-oncho-schisto.txt file in package directory


Wormsim v0.96
1. Cosmetic change in Host.java: added method getSexRatio().
2. Modified FemaleWorm.recentlyInseminated() which did not produce the same result when 
   handling ReproductionEvent and MfProductionUpdateEvent. This may explain observed differences
   between Onchosim-97 and Wormsim-0.94 reported by Luc Coffeng.  

Wormsim v0.95
1. De random number generator wordt nu ook gebruikt voor poisson en neg binomiale verdelingen. 
   Dat betekent dat een run met dezelfde seed en inputfile altijd hetzelfde resultaat oplevert.
2. De malabsorptie factor is toegevoegd voor ivermectine behandelingen (random, niet consistent).
3. De leeftijdsafhankelijke mf productie moet nu in hetzelfde format als bij Onchosim worden opgegeven 
  (ipv de leeftijd vd worm moet nu het aantal jaar sinds patent worden gekoppeld aan een mf productie factor)
4. Een simulatierun duurt nu 4 sec ipv 20 sec (bij een maximale populatiegrootte van 440 op een enkele jaren oude laptop). 
 
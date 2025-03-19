/*====================================================================
project:       Experiment - Master Do File
Authors:       Julie Bousquet/Mark Marvin Kadigo/Anna Gasten 
----------------------------------------------------------------------
Creation Date:    03-10-2022
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/


** INITIAL COMMANDS
	cap log close 
	clear all
	set more off
	set mem 800m

set seed 85632485


/*====================================================================
                        1: Packages
====================================================================*/

*ssc install ietoolkit
*ssc install swindex 
*net install swindex.pkg
*h swindex 

*ssc install mdesc
*ssc install egenmore 
*ssc install distinct
*ssc install estout
*ssc install coefplot

/*====================================================================
                        2: Master Set Up
====================================================================*/


 clear all

	*Data path 

   *USERNAME @JULIE BOUSQUET
if inlist(c(username), "u0131185", "julie") == 1 {
   	global masterfolder	`"/users/`c(username)'/ownCloud - julie.bousquet@kuleuven.be@owncloud.gwdg.de/ETH_UGA Experiment/04. Experimental Approach FAFO/09. Replication Package JDE/"'
   }

   *USERNAME @ANNA GASTEN
 if inlist(c(username), "gasten") == 1 {
   	global masterfolder	`"/users/`c(username)'/ownCloud/ETH_UGA Experiment/04. Experimental Approach FAFO/09. Replication Package JDE/"'
   }
   
   *USERNAME @MARK MARVIN KADIGO
 if inlist(c(username), "MKadigo") == 1 {
   	global masterfolder	`"/users/`c(username)'/ownCloud - markmarvin.kadigo@uantwerpen.be@owncloud.gwdg.de/ETH_UGA Experiment/04. Experimental Approach FAFO/09. Replication Package JDE/"'
   }
   

   *USERNAME @usernam [Please, add your username and enter your path]
/* 
  if inlist(c(username), "") == 1 {
   	global masterfolder	`"/users/`c(username)'/"'
   }
 */  

 /*====================================================================
                        4: Folder Structure
====================================================================*/

	****************** 
	**    DATA      **
	******************

		global data	"$masterfolder/01. Datasets/"
			global data_base  "$data/01. Base/"
			global data_temp  "$data/02. Temp/"
			global data_final "$data/03. Final/"
			global data_lsms 	"$data/04. LSMS/"
		global out	"$masterfolder/02. Output/"
			global out_fig	"$masterfolder/02. Output/Figures/"
			global out_tab	"$masterfolder/02. Output/Tables/"
		global do	"$masterfolder/03. Codefiles/"
	

/*====================================================================
                        5: RoadMap
====================================================================*/

	******************************
	**     RUN THE DO FILES     **
	******************************

* /!\ Instructions: to run the dofiles, erase the "/*" below.

/*

*************
*PREPARATION*
*************

*CLEANING DO FILE
	qui do "$do/01_EXP_MergeClean.do"

*Note: Creates the final dataset "$data_final/04_UGA_ETH_Prepared.dta"

**************
*DESCRIPTIVES*
**************

	qui do "$do/02_EXP_Descriptive.do" 

/*
This do file generates
			- Balance tables: Table A7: TA7_Balance_Tables
				The generated tables TA7_Balance_Tables_All; TA7_Balance_Tables_Hosts; 
				TA7_Balance_Tables_Refugees are manually aggregated into table TA7_Balance_Tables
			- Summary Statistics
					- Table A8: TA8_SummStat_Uganda
					- Table A9: TA9_SummStat_Ethiopia
*/

***************
*MAIN ANALYSIS*
***************

	qui do "$do/03_EXP_Analysis.do"

/*
This do file generates
			- Main analysis: Table A11: 	TA11_Analysis_PrejudiceIndex
			- Main analysis: Figure 4: 	FIG4_CFP_Analysis
			- By localities: Table A16:	TA16_Analysis_byLocality
			- By localities: Figure 5: 	FIG5_CFP_Analysis_byLocalities

*Note: the followind dofiles uses the dofile to correct 
*for MHT "$do/2a.fdr_qvalues.do"
*/

***************
*HETEROGENEITY*
***************

	qui do "$do/04_EXP_Heterogeneity.do"

/*
This do file generates
			- By gender and education: Table A18: TA18_Analysis_Gender_Education
      - By Over-work: Table A19: TA19_Analysis_OverWork
      - By Occupation Pressure: Table A20: TA20_Analysis_OccupationPressure
      - By network/contact: Table A21: TA21_Analysis_Contact
      - By language shared with in group: Table A22: TA22_Analysis_LanguageShare
      - By language fractionalization: Table A23: TA23_Analysis_LanguageFraction
      - Table 1: TAB1_Analysis_HeterogMutli
           Aggregates for hosts of tables
             - By Over-work: Table A19
             - By Occupation Pressure: Table A20
             - By network/contact: Table A21
             - By language shared with in group: Table A22
*/

************
*ROBUSTNESS*
************

	qui do "$do/05_EXP_Robustness.do" 

/*
This do file generates
			- Comparison summary statistics with LSMS: Table A4: TA4_Summary_Statistics_LSMS
			- By components of the index: Table A12: TA12_Analysis_byIndex
			- Labor Market competition: Table A10: TA10_Analysis_LMCompetitionIndex 
			- Dummy Variable: Table A13: TA13_Analysis_DummyIndex
			- Without clustered SEs: Table A14: TA14_Analysis_ClusteredSEs
      - By a set of employment variable: Table A15: TA15_Analysis_EmploymentDef
			- Regression Coefficient Comparisons Across Locations (diff-in-mean): TA17_Analysis_PValues 
	
*/

*********************
* POWER CALCULATION *
*********************

/*
This Rfile 06_EXP_Power calculations.rmd 
generates Table A24: TA24_Retrospective_PC.tex
*/



*/



exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><


/*====================================================================
project:       Experiment - Cleaning DoFile
Authors:       Julie Bousquet/Mark Marvin Kadigo/Anna Gasten 
Description:

Creates the final dataset "$data_final/04_UGA_ETH_Prepared.dta"

----------------------------------------------------------------------
Creation Date:    03-10-2022
====================================================================*/




/*====================================================================
                        0: Set up
====================================================================*/


*The datasets
/*
		*ETH
*HH
use "$data_base/ETH-HH_Main_User_Weights.dta", clear
*HH Roster
use "$data_base/ETH-Roster_User_Weights.dta", clear
*RSI 
use "$data_base/ETH-RSI_Main_User_Weights.dta", clear

		*UG
*HH
use "$data_base/UGA-HH_Main_User_Weights.dta", clear
*HH Roster
use "$data_base/UGA-Roster_User_Weights.dta", clear
*RSI
use "$data_base/UGA-RSI_Main_User_Weights.dta", clear
*/

/*====================================================================
                       1: ETHIOPIA
====================================================================*/

				****************************
				***   HOUSEHOLD DATA    ****
				****************************


use "$data_base/ETH-HH_Main_User_Weights.dta", clear

	*HOUSEHOLD IDs
	gen hhid = string(qhcluster) + string(qhid) 
	codebook hhid
	destring hhid, replace
	isid hhid
	lab var hhid "Household ID using qhcluster and qhid"
	
	*WEIGHTS
	*Pull together the different weights in ETH
	gen 	  w_hh = HHrelweigh_ADA if  Region == 1 //ADDIS ABADA
	replace w_hh = HHrelweigh_PPS if  Region == 2 //FAFAN
	mdesc w_hh
	lab var w_hh "HH Weight"

	*REFUGEE
	codebook qhtype
	tab HHstatus 

	*GEOGRAPHICS
	codebook qhcountry
	tab QHGEONAME1 
	tab QHGEOCODE1
	tab Region 
	* All three variables capture the same information

	*CAMPS / URBAN
	codebook qhcluscamp  
	codebook qhclusurban 

	*ID THE DATASET 
	gen dataset_type_hh = "HH"
	lab var dataset_type_hh "HH DATASET"

	*CLUSTER
	mdesc PSU_PPS
	gen 	  cluster_psu_hh = PSU_PPS 		if  Region == 2 //FAFAN
	replace cluster_psu_hh = ClusterID_ADA 	if  Region == 1 //ADDIS ABADA
	lab var cluster_psu_hh "Cluster Variable PSU Primary Sampling Unit"
	mdesc cluster_psu_hh

save "$data_temp/ETH_HHSurvey_Prep.dta", replace



				******************************
				***   HOUSEHOLD ROSTER    ****
				******************************

use "$data_base/ETH-Roster_User_Weights.dta", clear

	*HOUSEHOLD IDs
	*This is not unqiue since household roster
	gen hhid = string(qhcluster) + string(qhid)
	codebook hhid
	destring hhid, replace
	lab var hhid "Household ID using qhcluster and qhid"
	
	*INDIVIDUAL IDs with RSI Select
	gen rsi_flag = qiidv if qiidv == HR100
	gen rsiiid = string(qhcluster) + string(qhid) + string(qiidv) if !mi(rsi_flag)
	codebook rsiiid
	destring rsiiid, replace
	*isid child
	lab var rsiiid "Individual ID of RSI using qhcluster, qhid, qiidv"
	drop rsi_flag
		
	*INDIVIDUAL IDs
	*This is the individuals ID 
	gen iid = string(qhcluster) + string(qhid) + string(HR100) 
	codebook iid
	destring iid, replace
	isid iid
	lab var iid "HH ROSTER: Individual ID"

	preserve
	*If we keep only the RSIs, then it is an id
	drop if mi(rsiiid)
	isid rsiiid
	restore 

	*WEIGHTS
	gen 	  w_hh = HHrelweigh_ADA if  Region == 1 //ADDIS ABADA
	replace w_hh = HHrelweigh_PPS if  Region == 2 //FAFAN
	mdesc w_hh
	lab var w_hh "HH Weight"

	*ID THE DATASET 
	gen dataset_type_hhroster = "HH ROSTER"
	lab var dataset_type_hhroster "HH ROSTER DATASET"

	*CLUSTER
	mdesc PSU_PPS
	gen 	  cluster_psu_hh = PSU_PPS 		if  Region == 2 //FAFAN
	replace cluster_psu_hh = ClusterID_ADA 	if  Region == 1 //ADDIS ABADA
	lab var cluster_psu_hh "Cluster Variable PSU Primary Sampling Unit"
	mdesc cluster_psu_hh

save "$data_temp/ETH_HHRosterSurvey_Prep.dta", replace



				****************************
				***   INDIVIDUAL RSI    ****
				****************************


use "$data_base/ETH-RSI_Main_User_Weights.dta", clear

	*HOUSEHOLD IDs
	gen hhid = string(qicluster) + string(qihid)
	codebook hhid
	destring hhid, replace
	isid hhid 
	lab var hhid "Household ID using qhcluster and qhid"

	*INDIVIDUAL IDs 
	gen rsiiid = string(qicluster) + string(qihid) + string(qiidv) 
	codebook rsiiid
	destring rsiiid, replace
	isid rsiiid
	lab var rsiiid "Individual ID using qhcluster and qhid and qiidv"
	
	*WEIGHTS
	tab Region
	codebook Region
	gen 	w = RSIrelweigh_ADA if  Region == 1 //ADDIS ABADA
	replace w = RSIrelweigh_PPS if  Region == 2 //FAFAN

	 tab qirefugee [aw=w]
	 tab qirefugee 

	su w RSIrelweigh_ADA RSIrelweigh_PPS, d 

	mdesc w
	lab var w "Weight"
	
	*ID THE DATASET 
	gen dataset_type_rsi = "RSI"
	lab var dataset_type_rsi "RSI DATASET"

	*CLUSTER
	mdesc PSU_PPS
	gen 	  cluster_psu = PSU_PPS 	if  Region == 2 //FAFAN
	replace cluster_psu = ClusterID_ADA if  Region == 1 //ADDIS ABADA
	lab var cluster_psu "Cluster Variable PSU Primary Sampling Unit"
	mdesc cluster_psu

	* CLEAN REGIONS IN UGANDA TO CREATE WEIGHTS 
	tab QIGEONAME1
	tab qicluscamp
	codebook qicluscamp
	gen 	  region = "Addis Ababa" if QIGEONAME1 == "Addis Ababa" 
	replace region = "Jigjiga" if QIGEONAME1 == "Fafan" & qicluscamp == 2 //Non Camp
	replace region = "Kebribeyah" if QIGEONAME1 == "Fafan" & qicluscamp == 1 //Camp
	*replace region = "Fafan" if QIGEONAME1 == "Fafan" 
	tab region 
	lab var region "QI Region"

	gen 	country_HH_pop = 952215 if region == "Addis Ababa" 
	replace country_HH_pop = 29127  if region == "Jigjiga" 
	replace country_HH_pop = 2975   if region == "Kebribeyah" 
	lab var country_HH_pop "Country HH Population for Weights"
	tab country_HH_pop
	
save "$data_temp/ETH_RSISurvey_Prep.dta", replace




/*====================================================================
                       2: UGANDA
====================================================================*/

				****************************
				***   HOUSEHOLD DATA    ****
				****************************

use "$data_base/UGA-HH_Main_User_Weights.dta", clear

tab 	QHGEONAME1
drop if QHGEONAME1 == "KAMPALA"

append using "$data_base/UGA-HH_Main_User_Adaptive W.dta" 

tab 		ClusType_ADA
codebook 	ClusType_ADA

	*HOUSEHOLD IDs
	gen hhid = string(qhcluster) + string(qhid) 
	codebook hhid
	destring hhid, replace
	isid hhid
	lab var hhid "Household ID using qhcluster and qhid"

	*RSI INDIVIDUAL ID
	*QHRSI and QIIDV are the same. They refer to the household member who 
	*did the RSI survey. (and not the surveyd household member necessarily)
	*br qhcluster qhid qiidv qhrsi 
	*gen flag=  1 if qhrsi != qiidv
	*tab flag

	*WEIGHTS
	*Pull together the different weights in UGA
	gen 	w_hh = HHrelweigh  //Normal Weights
	replace w_hh = HHrelweigh_ADA if Region == 1 //KAMPALA
	mdesc w_hh
	lab var w_hh "HH Weight"

	*REFUGEE
	codebook qhtype

	*GEOGRAPHICS
	codebook qhcountry
	tab QHGEONAME1 
	tab QHGEOCODE1

	*CAMPS / URBAN
	codebook qhcluscamp  
	codebook qhclusurban 

	*ID THE DATASET 
	gen 	  dataset_type_hh = "HH"
	lab var dataset_type_hh "HH DATASET"

	*CLUSTER
	gen 	  cluster_psu_hh = psu
	replace cluster_psu_hh = ClusterID_ADA  if Region == 1 //KAMPALA //ADA SAMPLE
	lab var cluster_psu_hh "Cluster Variable PSU Primary Sampling Unit"
	mdesc cluster_psu_hh

save "$data_temp/UGA_HHSurvey_Prep.dta", replace


				******************************
				***   HOUSEHOLD ROSTER    ****
				******************************

use "$data_base/UGA-Roster_User_Weights.dta", clear

tab 	QHGEONAME1
drop if QHGEONAME1 == "KAMPALA"

append using "$data_base/UGA-Roster_User_Adaptive W.dta" 

tab 		ClusType_ADA
codebook 	ClusType_ADA
*keep if 	ClusType_ADA == 2 


	*HOUSEHOLD IDs
	*This is not unqiue since household roster
	gen hhid = string(qhcluster) + string(qhid)
	codebook hhid
	destring hhid, replace
	lab var hhid "Household ID using qhcluster and qhid"

	*INDIVIDUAL IDs with RSI Select
	gen rsi_flag = qiidv if qiidv == HR100
	gen rsiiid = string(qhcluster) + string(qhid) + string(qiidv) if !mi(rsi_flag)
	codebook rsiiid
	destring rsiiid, replace
	*isid chiid
	lab var rsiiid "Individual ID of RSI, using qhcluster, qhid and qiidv"
	drop rsi_flag
	
	
	*INDIVIDUAL IDs
	*This is the individuals ID 
	gen iid = string(qhcluster) + string(qhid) + string(HR100) 
	codebook iid
	destring iid, replace
	isid iid
	lab var iid "HH ROSTER: Individual ID"

	preserve
	drop if mi(rsiiid)
	isid rsiiid
	restore 
	
	*WEIGHTS
	gen 	w_hh = HHrelweigh
	replace w_hh = HHrelweigh_ADA if Region == 1 //KAMPALA
	mdesc w_hh
	lab var w_hh "HH Weight"
	
	*ID THE DATASET 
	gen 	  dataset_type_hhroster = "HH ROSTER"
	lab var dataset_type_hhroster "HH ROSTER DATASET"

	*CLUSTER
	gen 	  cluster_psu_hh = psu
	replace cluster_psu_hh = ClusterID_ADA  if Region == 1 //KAMPALA //ADA SAMPLE
	lab var cluster_psu_hh "Cluster Variable PSU Primary Sampling Unit"

save "$data_temp/UGA_HHRosterSurvey_Prep.dta", replace


				****************************
				***   INDIVIDUAL RSI    ****
				****************************

use "$data_base/UGA-RSI_Main_User_Weights.dta", clear

tab 	QIGEONAME1
drop if QIGEONAME1 == "KAMPALA"


append using "$data_base/UGA-RSI_Main_User_Adaptive W.dta" 

tab 		ClusType_ADA
codebook 	ClusType_ADA

	*HOUSEHOLD IDs
	gen hhid = string(qicluster) + string(qihid)
	codebook hhid
	destring hhid, replace
	isid hhid 
	lab var hhid "Household ID using qhcluster and qhid"

	*INDIVIDUAL IDs 
	gen rsiiid = string(qicluster) + string(qihid) + string(qiidv) 
	codebook rsiiid
	destring rsiiid, replace
	isid rsiiid
	lab var rsiiid "Individual ID using qhcluster and qhid and qiidv"

	*WEIGHTS
	gen 	w = RSIrelweigh
	replace w = RSIrelweigh_ADA if  Region == 1 //KAMPALA //ADA SAMPLE
	mdesc w
	lab var w "Weight"

	*ID THE DATASET 
	gen dataset_type_rsi = "RSI"
	lab var dataset_type_rsi "RSI DATASET"

	*CLUSTER
	gen cluster_psu = psu
	replace cluster_psu = ClusterID_ADA if Region == 1 //KAMPALA //ADA SAMPLE
	lab var cluster_psu "Cluster Variable PSU Primary Sampling Unit"

	* CLEAN REGIONS IN UGANDA TO CREATE WEIGHTS 
	tab QIGEONAME1
	gen 	  region = "Isingiro" if  QIGEONAME1 == "ISINGIRO" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2001)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2002)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2004)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2005)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2006)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2007)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2009)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2010)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2011)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2012)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2013)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2015)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2016)" 
	replace region = "Isingiro" if  QIGEONAME1 == "ISINGIRO (2017)" 
	replace region = "Kampala"  if  QIGEONAME1 == "KAMPALA" 
	replace region = "Nakivale" if  QIGEONAME1 == "NAKIVALE" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3001)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3002)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3003)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3004)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3005)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3032)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3033)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3034)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3035)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3036)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3037)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3038)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3039)" 
	replace region = "Nakivale" if  QIGEONAME1 == "Nakivale (3040)" 
	tab region 
	lab var region "QI Region"

	gen 	  country_HH_pop = 88578 if region == "Isingiro" 
	replace country_HH_pop = 406556 if region == "Kampala" 
	replace country_HH_pop = 18262 if region == "Nakivale" 
	lab var country_HH_pop "Country HH Population for Weights"
	tab country_HH_pop

save "$data_temp/UGA_RSISurvey_Prep.dta", replace







/*====================================================================
                       3: MERGE ETHIOPIA
====================================================================*/

use "$data_temp/ETH_HHSurvey_Prep.dta" , clear 

	merge 1:m hhid using "$data_temp/ETH_HHRosterSurvey_Prep.dta"

	drop _merge

	merge m:1 rsiiid using "$data_temp/ETH_RSISurvey_Prep.dta", gen(merge_rsi)
	count if rsiiid==. & merge_rsi!=1
	*The non merge are the household members who did not do the RSI survey
	*which is normal

	gen country = 1
	lab def country 1 "Ethiopia" 2 "Uganda", modify
	lab val country country 
	lab var country "IDF the country"

	gen ciid = string(qicluster) + string(qihid) + string(qiidv) + string(country)
	lab var ciid "Individual ID with Country ID from cluster, hid, idv, country"
	

save "$data_final/01_ETH_MergeAll_Prep.dta", replace

*Obsolete dataset
erase "$data_temp/ETH_HHSurvey_Prep.dta" 
erase "$data_temp/ETH_HHRosterSurvey_Prep.dta"
erase "$data_temp/ETH_RSISurvey_Prep.dta"

/*====================================================================
                       4: MERGE UGANDA
====================================================================*/

	
use "$data_temp/UGA_HHSurvey_Prep.dta" , clear 

	merge 1:m hhid using "$data_temp/UGA_HHRosterSurvey_Prep.dta"

	drop _merge

	merge m:1 rsiiid using "$data_temp/UGA_RSISurvey_Prep.dta", gen(merge_rsi)
	count if rsiiid==. & merge_rsi!=1

	gen country = 2
	lab def country 1 "Ethiopia" 2 "Uganda", modify
	lab val country country 
	lab var country "IDF the country"

	gen ciid = string(qicluster) + string(qihid) + string(qiidv) + string(country)
	lab var ciid "Individual ID with Country ID from cluster, hid, idv, country"


save "$data_final/01_UGA_MergeAll_Prep.dta", replace


*Obsolete dataset
erase "$data_temp/UGA_HHSurvey_Prep.dta" 
erase "$data_temp/UGA_HHRosterSurvey_Prep.dta"
erase "$data_temp/UGA_RSISurvey_Prep.dta"



/*====================================================================
                       5: MERGE ETHIOPIA AND UGANDA
                             FULL SAMPLE
====================================================================*/


use "$data_final/01_ETH_MergeAll_Prep.dta", clear 

append using "$data_final/01_UGA_MergeAll_Prep.dta"

	tab merge_rsi 

save "$data_final/02_UGA_ETH_MergeAll_Prep.dta", replace


/*====================================================================
                       6: MERGE ETHIOPIA AND UGANDA
                             RSI SAMPLE
====================================================================*/


use "$data_final/02_UGA_ETH_MergeAll_Prep.dta", clear

	keep if merge_rsi == 3 //Keep only the households member who did hte RSI surveys 
	*to have their demo info if necessary.

	*LOCATE ALL THE VARIABLES FROM THE HOUSEHOLD SURVEY
	foreach x of var QHGEOCODE1-HHemployed_grp { 
		rename `x' HH_`x' 
	} 

	*LOCATE ALL THE VARIABLES FROM THE ROSTER SURVEY
	foreach x of var qhmember - LFpart { 
		rename `x' HHRost_`x' 
	} 
	
	*PUT THEM AT THE END 
	order PSU_PPS - dataset_type_hhroster, last

	*PUT THE IDS AND AGGREGATE WEIGHT AT THE BEGINNING
	order ciid hhid rsiiid w 

	*CIID is the individual ID
	isid ciid 

	*RSIID is the ID that duplicates in THE MERGE but unique in own country
	preserve
	keep if country == 1
	isid rsiiid 
	restore

	preserve
	keep if country == 2
	isid rsiiid 
	restore
	
save "$data_final/03_UGA_ETH_MergeAll_SSRSI_Prep.dta", replace

erase "$data_final/02_UGA_ETH_MergeAll_Prep.dta"
 



/*====================================================================
                       7: CLEAN ETHIOPIA AND UGANDA
                             RSI SAMPLE
====================================================================*/


use "$data_final/03_UGA_ETH_MergeAll_SSRSI_Prep.dta", clear


*************
* REFUGEES **
*************

tab HH_HHstatus //Household Head Refugees Status from HH survey
tab HH_qhtype //Refugees status from HH survey

tab EX900A1 //Refugee status from Experiment
*2869 H and 1633 R

tab qirefugee //Refugee status from the survey household answered
*4068 H and 3190 Refugee
bys country: tab qirefugee
bys country: tab qirefugee [aw=w]
sort hhid
*browse hhid ciid HH_HHstatus HH_qhtype EX900A1 qirefugee BK504

tab EX900A1 qirefugee
*98 Not refugee are put in the refugee sample of the experiment


		*-------------------------*
		*Examining the discrepency 
		codebook EX900A1 qirefugee 
		gen flag = 1 if EX900A1 == 2 & qirefugee == 0
		tab flag 

		tab BK504 if flag == 1 
		*87 are permanent resident 
		bys country: tab BK503 if flag == 1 
		*66 in ETH said they were ETH 
		*15 in UGA said they were UGA

		drop flag
		*-------------------------*

codebook qirefugee
gen refugee = qirefugee 
lab def refugee 0 "Host" 1 "Refugee", modify
lab val refugee refugee
lab var refugee "Refugee"
tab refugee 

tab EX900A1, m //SPLIT: National/Refugee 
codebook EX900A1

gen 	exp_refugee = 1 if EX900A1 == 2
replace exp_refugee = 0 if EX900A1 == 1
lab def exp_refugee 1 "Refugee" 0 "Host", modify 
lab val exp_refugee exp_refugee 
lab var exp_refugee "EXP: Refugee"

tab exp_refugee refugee

**********
* URBAN **
**********

tab HH_qhclusurban //Household Level Urban: 
tab qiclusurban //Individual Level Urban
tab HH_qhclusurban  qiclusurban
* Fully overlapping variables

codebook qiclusurban
gen 	urban = 0 if qiclusurban == 2 
replace urban = 1 if qiclusurban == 1
lab def urban 0 "Rural" 1 "Urban", modify
lab val urban urban
lab var urban "Urban"
tab 	urban

**********
* GENDER *
**********

tab BK502 //From the RSI survey
tab qisex //From the RSI survey
tab EX900C1 //From the experiment
tab qisex BK502

tab HH_qhrsisex //HH Member RSI Gender in HH Survey
tab HH_HHsex //HHhead gender 
tab HHRost_HR103 //HH Roster Gender 

tab HHRost_HR103 HH_qhrsisex // Fully overlapping variables
tab HHRost_HR103 qisex // Fully overlapping variables
tab HHRost_HR103 EX900C1
tab BK502 EX900C1

*RSI Survey
codebook BK502 
gen 	male = 0 if BK502 == 2 
replace male = 1 if BK502 == 1
lab def male 0 "Female" 1 "Male", modify
lab val male male
lab var male "Male"
tab 	male
tab BK502

*Experiment
codebook EX900C1
tab EX900C1, m 
gen 	exp_male_self = 0 if EX900C1 == "Female" | EX900C1 == "ሴት" | EX900C1 == "ጓል ኣንስተይቲ"
replace exp_male_self = 1 if   EX900C1 == "Male" | EX900C1 == "ወንድ" | EX900C1 == "ወዲ ተባዕታይ"
lab def exp_male_self 0 "Female" 1 "Male", modify
lab val exp_male_self exp_male_self
lab var exp_male_self "EXP: Gender" 
tab exp_male_self, m 

tab male exp_male_self //100% respected !! Women receive women text

     ****************
     **** HH HEAD ***
     ****************

tab HHRost_HR102
mdesc HHRost_HR102 

codebook HHRost_HR102
lab list HR102
gen hhead = 1 if HHRost_HR102 == 0
replace hhead = 0 if HHRost_HR102 != 0 
lab def hhead 0 "Not HH head" 1 "HH Head", modify
lab val hhead hhead
lab var hhead "Household Head"
tab hhead

***************
* NATIONALITY *
***************

*Experiment 
tab 	EX900C2, m
gen 	exp_nationality_self = EX900C2 
replace exp_nationality_self = "Somalia" if EX900C2 == "ሶማሊያ"
replace exp_nationality_self = "Ethiopia" if EX900C2 == "ኢትዮጵያ"
replace exp_nationality_self = "Eritrea" if EX900C2 == "ኤርትራ"
tab 	exp_nationality_self, m
lab var exp_nationality_self "EXP: Nationality"

*We need to investigate a bit 
bys country: tab exp_nationality_self refugee 

***********
* COUNTRY *
***********

codebook country

gen ethiopia = 1 if country == 1 
replace ethiopia = 0 if country == 2 
lab def ethiopia 0 "Uganda" 1 "Ethiopia", modify 
lab val ethiopia ethiopia 
lab var ethiopia "Country is Ethiopia"
bys ethiopia: tab qirefugee

*******
* AGE *
*******

su BK501 //18-65  
su qiage 
su HHRost_HR104 

count if BK501 != qiage 
count if BK501 != HHRost_HR104
count if qiage != HHRost_HR104

gen age = BK501 
lab var age "Age of the respondent"

*WAP
su HHRost_HR104

*********
* CAMPS *
*********

tab qicluscamp
codebook qicluscamp

gen 	camp = 0 if qicluscamp == 2 
replace camp = 1 if qicluscamp == 1
lab def camp 0 "Non Camp" 1 "Camp", modify
lab val camp camp
lab var camp "Camp"
tab camp 
tab camp refugee [aw=w]  if ethiopia==1
tab camp refugee [aw=w] if ethiopia==0

******************
* LENGTH OF STAY
******************

// Here: exclusively based on year of arrival, since no need for highly fine-grained variable

tab BK508Y
codebook BK508Y
codebook BK510Y

gen stay_ctry = 2022 - BK508Y
codebook stay_ctry if refugee==1 // 412 missings
label variable stay_ctry "REF: Years in ETH/UGA"

gen stay_rsd = BK510Y
codebook stay_rsd if refugee==1 // 0 missings
label variable stay_rsd "REF: Years in current residence"

replace stay_ctry=stay_rsd if stay_ctry==. //assumption to replace missings

summarize stay_ctry if EX901!=., detail // only for those participating in the experiment
local median = r(p50)
gen long_stay = (stay_ctry > `median') if refugee==1 & EX901!=.
lab var long_stay "Duration of stay in host country above median"
egen quant_stay = xtile(stay_ctry), n(4)
label variable quant_stay "Duration of stay quartiles: <4 ; 4-6 ; 7-14 ; >14"


******************
* MARITAL STATUS *
******************

tab HHRost_HR105
codebook HHRost_HR105

gen married = 1 if HHRost_HR105 == 2 
replace married = 0 if HHRost_HR105 != 2 & !mi(HHRost_HR105)
lab var married "Married"
lab def married 0 "Else" 1 "Married", modify 
lab val married married
tab married
*13 missing


******************
* HOUSEHOLD SIZE *
******************

ren HHRost_qhmember hhsize
su hhsize 
lab var hhsize "Household Size"
* Average household size: 4.6 individuals

************
* LITERATE *
************

tab BK517 
gen literate = 1 if BK517 == 1 
replace literate = 0 if BK517 == 2 
lab var literate "Literate"
lab def literate 1 "Literate" 0 "Not Literate", modify
lab val literate literate

tab literate

*************
* EDUCATION *
*************

tab Edu 
tab BK515 
tab BK516
codebook BK516 

gen 	  educ_primary = 0 if 	BK516 == 1 | ///No formal education
				 	BK516 == 2  //Less than Primary
replace educ_primary = 1 if 	BK516 == 3 | ///Completed Primary
					BK516 == 4 | ///Completed O-Level/Secondary
					BK516 == 5 | ///Completed A-Level
					BK516 == 6 //Completed University
lab var educ_primary "Received at least Primary Education Level"
lab def educ_primary 0 "Less than Primary" 1 "At least Primary", modify 
lab val educ_primary educ_primary 
tab educ_primary, m 

*There are 325 OTHERs that we need to classify
tab literate if mi(educ_primary)
*122 are not literate
replace educ_primary = 0 if literate == 0 //If not literate, probably not educ 

*Currently enrolled
tab BK515 if mi(educ_primary), m
codebook BK515
*Currently enrolled can qualify as "at least"
replace educ_primary = 0 if BK515 == 1 & mi(educ_primary) //Primary 
replace educ_primary = 1 if BK515 == 2 & mi(educ_primary) //Secondary 
replace educ_primary = 1 if BK515 == 4 & mi(educ_primary) //College 
replace educ_primary = 1 if BK515 == 5 & mi(educ_primary) //Universiyt 
replace educ_primary = 1 if BK515 == 6 & mi(educ_primary) //Vocational 

tab educ_primary, m 

tab BK514 if  mi(educ_primary) 
tab BK526 if  mi(educ_primary), m
tab BK528 if  mi(educ_primary) 

*NOT SURE HOW TO CLEAN THE 154 @ANNA
tab literate if mi(educ_primary) & !mi(EX900D), m
tab BK526 if mi(educ_primary) & !mi(EX900D), m

replace educ_primary = 1 if mi(educ_primary) & BK526!=27 & BK526!=28 & literate ==1
replace educ_primary = 1 if mi(educ_primary) & EX900B3 ==1 & literate ==1

**********
* REGION *
**********

tab region
encode region, gen(region_cat) 
lab var region_cat "Region labeled"

tab region_cat country 
gen region_short = 1 if region_cat == 1 //ADDIS
replace region_short = 2 if region_cat == 3 | region_cat == 5 //JIJ
replace region_short = 3 if region_cat == 4 //KAM
replace region_short = 4 if region_cat == 2 | region_cat == 6
lab def region_short 1 "Addis" 2 "Jijiga" 3 "Kampala" 4 "Isingiro", modify 
lab val region_short region_short 
lab var region_short "Region"
tab region_short


*****************************************
* LANGUAGE BY REGION AND REFUGEE STATUS *
*****************************************

tab BK521
// majority language= at least twice as much as all other languages

tab BK521 [aw=w] if region_short==1 & refugee==0
* AMHARIC = Main language among hosts in Addis
gen maj_lang_ig = 1 if BK521==7 & region_short==1 & refugee==0
replace maj_lang_ig = 0 if (BK521!=7 & BK521!=.) & region_short==1 & refugee==0

tab BK521 [aw=w] if region_short==1 & refugee==1
* TIGRIGNA = Main language among refugees in Addis
replace maj_lang_ig = 1 if BK521==6 & region_short==1 & refugee==1
replace maj_lang_ig = 0 if (BK521!=6 & BK521!=.) & region_short==1 & refugee==1

tab BK521 [aw=w] if region_short==2 & refugee==0
* SOMALI = Main language among hosts in Jijiga
replace maj_lang_ig = 1 if BK521==5 & region_short==2 & refugee==0
replace maj_lang_ig = 0 if (BK521!=5 & BK521!=.) & region_short==2 & refugee==0

tab BK521 [aw=w] if region_short==2 & refugee==1
* SOMALI = Main language among refugees in Jijiga
replace maj_lang_ig = 1 if BK521==5 & region_short==2 & refugee==1
replace maj_lang_ig = 0 if (BK521!=5 & BK521!=.) & region_short==2 & refugee==1

tab BK521 [aw=w] if region_short==3 & refugee==0
* LUGANDA = Main language among hosts in Kampala
replace maj_lang_ig = 1 if BK521==1 & region_short==3 & refugee==0
replace maj_lang_ig = 0 if (BK521!=1 & BK521!=.) & region_short==3 & refugee==0

tab BK521 [aw=w] if region_short==3 & refugee==1
* SOMALI, TIGRIGNA, SWAHILI = Main language among refugees in Kampala
replace maj_lang_ig = 1 if (BK521==3 | BK521==5 | BK521==6) & region_short==3 & refugee==1
replace maj_lang_ig = 0 if (BK521!=3 & BK521!=5 & BK521!=6 & BK521!=.) & region_short==3 & refugee==1

tab BK521 [aw=w] if region_short==4 & refugee==0
* RUNYANKORE = Main language among hosts in Isingiro
replace maj_lang_ig = 1 if BK521==2 & region_short==4 & refugee==0
replace maj_lang_ig = 0 if (BK521!=2 & BK521!=.) & region_short==4 & refugee==0

tab BK521 [aw=w] if region_short==4 & refugee==1
* KINYARWANDA, Swahili = Main language among refugees in Isingiro
replace maj_lang_ig = 1 if (BK521==3 | BK521==4) & region_short==4 & refugee==1
replace maj_lang_ig = 0 if (BK521!=3 & BK521!=4 & BK521!=.) & region_short==4 & refugee==1

tab maj_lang_ig region_short [aw=w] if refugee==0, cell nofreq
tab maj_lang_ig region_short [aw=w] if refugee==1, cell nofreq
label variable maj_lang_ig "Linguistic majority group (by in-group, region)"

// BASED ON TABULATES ABOVE: GENERATE OUT-GROUP MAJORITY LANGUAGES

* TIGRIGNA = Main language among refugees in Addis
gen maj_lang_og = 1 if BK521==6 & region_short==1 & refugee==0
replace maj_lang_og = 0 if (BK521!=6 & BK521!=.) & region_short==1 & refugee==0

* AMHARIC = Main language among hosts in Addis
replace maj_lang_og = 1 if BK521==7 & region_short==1 & refugee==1
replace maj_lang_og = 0 if (BK521!=7 & BK521!=.) & region_short==1 & refugee==1

* SOMALI = Main language among refugees in Jijiga
replace maj_lang_og = 1 if BK521==5 & region_short==2 & refugee==0
replace maj_lang_og = 0 if (BK521!=5 & BK521!=.) & region_short==2 & refugee==0

* SOMALI = Main language among hosts in Jijiga
replace maj_lang_og = 1 if BK521==5 & region_short==2 & refugee==1
replace maj_lang_og = 0 if (BK521!=5 & BK521!=.) & region_short==2 & refugee==1

* SOMALI, TIGRIGNA, SWAHILI = Main language among refugees in Kampala
replace maj_lang_og = 1 if (BK521==3 | BK521==5 | BK521==6) & region_short==3 & refugee==0
replace maj_lang_og = 0 if (BK521!=3 & BK521!=5 & BK521!=6 & BK521!=.) & region_short==3 & refugee==0

* LUGANDA = Main language among hosts in Kampala
replace maj_lang_og = 1 if BK521==1 & region_short==3 & refugee==1
replace maj_lang_og = 0 if (BK521!=1 & BK521!=.) & region_short==3 & refugee==1

* KINYARWANDA, SWAHILI = Main language among refugees in Isingiro
replace maj_lang_og = 1 if (BK521==3 | BK521==4) & region_short==4 & refugee==0
replace maj_lang_og = 0 if (BK521!=3 & BK521!=4 & BK521!=.) & region_short==4 & refugee==0

* RUNYANKORE = Main language among hosts in Isingiro
replace maj_lang_og = 1 if BK521==2 & region_short==4 & refugee==1
replace maj_lang_og = 0 if (BK521!=2 & BK521!=.) & region_short==4 & refugee==1

tab maj_lang_og region_short [aw=w] if refugee==0, cell nofreq
tab maj_lang_og region_short [aw=w] if refugee==1, cell nofreq
label variable maj_lang_og "Sharing main language of the out-group, by region"

save "$data_temp/01_Language_descr.dta", replace

***********************************
* LABOR FORCE PARTICIPATION (LFP) *
***********************************

* * * LFP as defined in the roster * * *

tab HHRost_employed

tab HHRost_employed EX900D, m

codebook HHRost_LF201 HHRost_LF202 HHRost_LF203 HHRost_LF204 HHRost_LF205
tab HHRost_LF201, nol m
tab HHRost_LF202, m
tab HHRost_LF203, m
tab HHRost_LF204, m 
tab HHRost_LF205, m

replace HHRost_LF201 = 2 if HHRost_LF201 == 8 | HHRost_LF201 == 9 
replace HHRost_LF202 = 2 if HHRost_LF202 == 8 
replace HHRost_LF203 = 2 if HHRost_LF203 == 8 
replace HHRost_LF204 = 2 if HHRost_LF204 == 8 
replace HHRost_LF205 = 2 if HHRost_LF205 == 8 
replace HHRost_LF206 = 2 if HHRost_LF206 == 8
replace HHRost_LF207 = 2 if HHRost_LF207 == 8
replace HHRost_LF208 = 2 if HHRost_LF208 == 8


*Employed
gen 	  LFP_rost = 1 if HHRost_LF201 == 1 | ///Any wage work
				HHRost_LF202 == 1 | ///Any IGA
				HHRost_LF203 == 1 | ///Any unpaid work
				HHRost_LF204 == 1 | ///Any agri work
				HHRost_LF205 == 1  //Not work but have a job to get back to

*Unemployed
replace LFP_rost = 2 if HHRost_LF201 == 2 & ///None of the above
				HHRost_LF202 == 2 & ///
				HHRost_LF203 == 2 & ///
				HHRost_LF204 == 2 & ///
				HHRost_LF205 == 2 & ///
				(HHRost_LF206 == 1 & ///Would have worked if job availl
				HHRost_LF207 == 1 & ///Wanted to work
				HHRost_LF208 == 1) //Looked for a job in last month
*Out of the Labor Force (OLF)
replace LFP_rost = 3 if HHRost_LF201 == 2 & ///None of the above
				HHRost_LF202 == 2 & ///
				HHRost_LF203 == 2 & ///
				HHRost_LF204 == 2 & ///
				HHRost_LF205 == 2 & ///
				(HHRost_LF206 == 2 | HHRost_LF207 == 2 | HHRost_LF208 == 2) //Did not look for any job in last month

lab def LFP_rost 1 "Employed" 2 "Unemployed" 3 "OLF", modify 
lab val LFP_rost LFP_rost 
lab var LFP_rost "LFP Roster should match HHRost_employed,  Employed 1 Unemployed 2 OLF 3"
tab LFP_rost 

tab LFP_rost HHRost_employed, m


* * * LFP as defined in the RSI * * *

codebook LM601 LM602 LM603 LM604 LM605  LM607 LM608 LM609 LM615 LM616
*br HHRost_LF201 HHRost_LF202 HHRost_LF203 HHRost_LF204 HHRost_LF205 ///
*	HHRost_LF206 HHRost_LF207 HHRost_LF208 ///
*	LM601 LM602 LM603 LM604 LM605 LM606 LM607 LM608 LM609  LM615 LM616 LFP_rost LFP
*sort LFP_rost 

*BASED ON TEWORDOS EXPLANATION
gen 	LFP = 1 if  LM626 == 1 |  LM626 == 2 |  LM626 == 3 
replace LFP = 2 if  LM609 == 1 & LM615 == 1 & (LM616 == 1 | LM617 == 1)
replace LFP = 3 if mi(LFP)

lab def LFP 1 "Employed" 2 "Unemployed" 3 "OLF", modify 
lab val LFP LFP 
lab var LFP "In the last 14d, Employed 1 Unemployed 2 OLF 3"

tab LFP 
tab LFP_rost 

*Comparing LFP Roster and RSI: very different 
*Becuase in Roster was defined by the household head
tab LFP_rost LFP 

*The var EX900D determined who has done the experiment. If empty,
*the individual did not do the exerpiement
tab EX900D LFP, m 
//The missing are the out of the labor force 


************
* EMPLOYED *
************

codebook LM601 LM602 LM603 LM604 LM605 
gen 	  employed = 1 if LFP == 1 
replace employed = 0 if LFP == 2
lab def employed 1 "Employed" 0 "Unemployed", modify 
lab val employed employed 
lab var employed "In the last 14d, Employed 1 Unemployed 0. OLF missing"
tab employed 
 
****************
* TYPE OF WORK *
****************

tab LM626
tab LM626 employed, m
gen tow = 1 if LM626 == 1 
replace tow = 2 if LM626 == 2 
replace tow = 3 if LM626 == 3 

lab def tow 1 "Wage Work" 2 "Self-Employed" 3 "Work in Agri", modify 
lab val tow tow 
lab var tow "Type of Work 14d"

replace tow = 1 if tow==. & LM626==. & employed == 1 & HHRost_LF201==1
replace tow = 2 if tow==. & LM626==. & employed == 1 & HHRost_LF202==1 | HHRost_LF203==1
replace tow = 3 if tow==. & LM626==. & employed == 1 & HHRost_LF204==1

tab tow, m
tab tow if employed==1 , m // 36 observations are still missing

gen 	  tow_ww = 1 if tow == 1 
replace tow_ww = 0 if tow == 2 | tow == 3 
lab def tow_ww 1 "Wage Work" 0 "Else", modify 
lab val tow_ww tow_ww 
lab var tow_ww "TOW: Work as Wage Worker"

gen 	  tow_se = 1 if tow == 2 
replace tow_se = 0 if tow == 1 | tow == 3 
lab def tow_se 1 "Self-Employed" 0 "Else", modify 
lab val tow_se tow_se 
lab var tow_se "TOW: Work as Self Employed"

gen 	  tow_ag = 1 if tow == 3 
replace tow_ag = 0 if tow == 1 | tow == 2
lab def tow_ag 1 "Agri Work" 0 "Else", modify 
lab val tow_ag tow_ag 
lab var tow_ag "TOW: Work in Agriculture"

save "$data_temp/Merge_clean_LM.dta", replace 




					**************************
					***** 8: EXPERIMENT ******
					**************************


use "$data_temp/Merge_clean_LM.dta", clear  

*****************************************
** SAMPLE SELECTION FOR THE EXPERIMENT **
*****************************************

*Drop those who did not take part in the experiemnt bc OLF 
tab EX900D LFP, m //The missing are the out of the labor force BUT also some Empl and Unempl (42 observations)
tab EX900D LFP if LFP==1 | LFP==2, m
tab EX900D LFP if LFP==3, m

*browse LM626 if EX900D==. & (LFP==1 | LFP==2)

*In the questionnaire, whether people do the experiment should be 
*based on LM626 but this is not the case as you can see here
*At least, It does not include the Unemployed 
tab LM626
tab EX900D LM626, m 
tab LFP  if mi(LM626) &  EX900D == 1 , m 

bys ethiopia: tab refugee [aw=w]

*/!!!!!!\
*/!!!!!!\
drop if mi(EX900D) & LFP == 3 // /!!!!!!\ DROP THE OLFs
*/!!!!!!\
*/!!!!!!\

bys ethiopia: tab refugee [aw=w]

tab LM626 if LFP==1 , m
tab LM626 if LFP==2 , m

*browse LM626 LFP EX900D

***********************
***** EXPERIMENT ******
***********************

************************
* IN GROUP / OUT GROUP *
************************

* IN GROUP *
tab EX900A2, m 
bys country: tab EX900A2 male //Seems balance across gender
codebook EX900A2 //1 in group 2 outgroup
gen 	exp_ingroup = 1 if EX900A2 == 1 
replace exp_ingroup = 0 if EX900A2 == 2 
lab def exp_ingroup 0 "Out Group" 1 "In Group", modify
lab val exp_ingroup exp_ingroup 
lab var exp_ingroup "EXP: In Group"
tab 	exp_ingroup 

* OUT GROUP *
tab EX900A2, m 
bys country: tab EX900A2 male //Seems balance across gender
codebook EX900A2 //1 in group 2 outgroup
gen 	exp_outgroup = 0 if EX900A2 == 1 
replace exp_outgroup = 1 if EX900A2 == 2 
lab def exp_outgroup 1 "Out Group" 0 "In Group", modify
lab val exp_outgroup exp_outgroup 
lab var exp_outgroup "EXP: Out Group"
tab 	exp_outgroup 

tab exp_outgroup exp_ingroup, m // correct: opposing categories
tab exp_refugee exp_ingroup

********************************
* SAME OCCUP / DIFFERENT OCCUP *
********************************

*SAME OCCUPATION *
tab EX900A3, m 
codebook EX900A3
gen exp_same_occup = 1 if EX900A3 == 1 
replace exp_same_occup = 0 if EX900A3 == 2
lab def exp_same_occup 1 "Same Occupation" 0 "Different Occupation"
lab val exp_same_occup exp_same_occup 
lab var exp_same_occup "EXP: Same Occupation"

*DIFFERENT OCCUPATION *
gen exp_diff_occup = 0 if EX900A3 == 1 
replace exp_diff_occup = 1 if EX900A3 == 2
lab def exp_diff_occup 1 "Different Occupation" 0 "Same Occupation"
lab val exp_diff_occup exp_diff_occup 
lab var exp_diff_occup "EXP: Different Occupation"

tab exp_diff_occup exp_same_occup, m // correct: opposing categories

bys country: tab exp_same_occup exp_male [aw=w] //Seems NOT balance across gender but across occup (within each gender group)
bys country: tab exp_same_occup exp_refugee  [aw=w] //Seems NOT balance across refugee status but across occup (within the group of refugees and hosts)

****************
** OCCUPATION **
****************

*-----------------------------*
* INVESTIGATION IN OCCUPATION *

	*EX900B1 ANSWERD ONLY BY GROUP WITH SAME OCCUPATION OR exp_same_occup == 1
	codebook EX900B1 //Occupation of the respondent
	tab exp_same_occup
	tab EX900B1 if exp_same_occup == 1 //Should be 2239 and it is correct

	*NOT SUPPOSED TO BE ANSWERED BY GROUP WITH DIFFERENT OCCUPATION OR exp_same_occup == 0
	// BUT UNEMPLOYED INDIVIDUALS STILL ANSWERED EX900B1 (preferred occupation), even if assigned to the "different occupation" treatment in the experiment
	tab EX900B1 if exp_same_occup == 0 //Should be 0 BUT WE have 482 obs
	tab EX900B2  if !mi(EX900B1) & exp_same_occup == 0 //out of these 482, we have 462 who were still assigned a "different" occupation from the pre-defined list of 10 occupations

	
	tab LFP if EX900B1!="" & exp_same_occup == 0 // The unemployed were the ones who also answered 900B1, despite being assigned to "different occ" treatment (random draw from list of 10 occupations)

	*EX900B2 ANSWERD ONLY BY GROUP WITH DIFFERENT OCCUPATION OR exp_same_occup == 0
	tab EX900B2  if exp_same_occup == 1 //should be missing and it is 

	tab EX900B2  if exp_same_occup == 0 // 2216 ANSWERs out of 2263
	/* ANNA: Could this be the 42 missings? */
	tab EX900B1  if mi(EX900B2) & exp_same_occup == 0 // 14 additional observations 
	*to get back from EX900B1 ? 

	tab LM621
	tab LM621 if mi(EX900B2) & exp_same_occup == 0
	*br LM621 EX900B1 if !mi(EX900B1)
	tab LM621 if !mi(EX900B1)
	tab LM621 if !mi(EX900B1) & LFP == 1 
	tab LM621 if mi(EX900B1) & LFP == 2 

* END INVESTIGATION IN OCCUPATION *	
*-----------------------------*

***********************************
**** EXPERIMENTAL OCCUPATIONS ****
**********************************
	   
tab EX900B1 if employed==1 // about 1800 employed (in same-occupation treatment)
tab EX900B1 if employed==0 // about 900 unemployed (in same-occupation and different-occupation treatment)


*************************************
*OWN OCCUPATION: TITLE FOR EMPLOYED *
*************************************

//Idea: Use 19 main categories that are the basis for LM621 and LM623
tab LFP
codebook LFP
*1 employed 

*Please select the category of the main economic activity based on the response
tab LM621 
*Please select the specific economic activity the person is engaged in
tab LM623

// Most likely 1-10 are head categories and the enumerator sometimes went into the "lower level" categories, 
// but sometimes indicated just the head category
// Cleanest way is to work exclusively with head categories
lab list LM621
tab LM623 if LM621==1 
tab LM623 if LM621==2
// Concern: These two variables are sometimes quite different (most likely because "farmer" can also be "trading" his products etc.)

codebook LM621 if LFP==1 // information available for all 3730 employed individuals
codebook LM623 if LFP==1 // information missing for 297 individuals -> in these cases rely on LM621 or LM622

lab def occup_lab 1 "Farming/animal husbandry" /// 
					2 "Trade" ///
					3 "Food-related business" ///
					4 "Beauty care" ///
					5 "Entertainment" ///
					6 "Clothing" ///
					7 "Manual works" ///
					8 "Manual technical services" ///
					9 "Communications/ IT/ Computer" ///
					10 "Finance" ///
					12 "Transportation" ///
					13 "Accommodation" ///
					14 "Education Sector" ///
					15 "Health Sector" ///
					16 "High-skilled office work" ///
					17 "Public Sector" ///
					18 "Religious services" ///
					19 "Other" ///
					100 "Unemployed", ///
					modify

*Note: Omitting category 11 here, since "specialized services/ products are difficult to code and often fall under another category as well."
lab list LM623
lab list LM621 

gen own_occupation=.
label var own_occupation "Title of own occupation"

***** 1- FARMING *****

tab LM623 if own_occupation==. & LM621==1, nolabel

replace own_occupation = 1 if 	LM621==1 

*STRING*
tab LM622 if LM623==1 & LM621==1 

tab LM622 if LM623 == 11 & LM621==1 
replace own_occupation = 15 if LM623==11 & LM621==1 & (LM622=="public health")

tab LM622 if LM623==12 & LM621==1 
replace own_occupation = 7 if  LM623==12 & LM621==1 & (LM622=="guard")

tab LM622 if LM623==13 & LM621==1 

tab LM622 if LM623==14 & LM621==1 

tab LM622 if LM623==15 & LM621==1 

tab LM622 if LM623==2 & LM621==1 // people in the intersection of farming and trade - all seem to work in farming

tab LM622 if LM623==3 & LM621==1 // people in the intersection of farming and food-related business - all seem on farming/cultivation side (not on processing side)

tab LM622 if LM623==4 & LM621==1 // all in farming

tab LM622 if LM623==5 & LM621==1 // need to chose right occupation for some
replace own_occupation = 2 if LM623==5 & LM621==1 & (LM622=="fish seller" | LM622=="selling fish and tomatoes" | LM622=="sells fish")


***** 2- TRADE *****
tab LM623 if own_occupation==. & LM621==2, nolab

replace own_occupation = 2 if LM621==2 & inlist(LM623, 2, 21, 22, 23, 24, 25, 26, 27)

tab LM622 if LM623==2 & LM621==2 
replace own_occupation = 3 if LM623==2 & LM621==2 & (LM622=="Chapati making")

tab LM622 if LM623==21 & LM621==2 
replace own_occupation = 3 if LM623==21 & LM621==2 & (LM622=="cooking and hawking around"| LM622=="hawking eats")

tab LM622 if LM623==22 & LM621==2 
replace own_occupation = 12 if LM623==22 & LM621==2 & (LM622=="Dirver")
replace own_occupation = 3 if LM623==22 & LM621==2 & (LM622=="roasting meat")

tab LM622 if LM623==23 & LM621==2 
replace own_occupation = 10 if LM623==23 & LM621==2 & (LM622=="Mobile Money")
replace own_occupation = 3 if LM623==23 & LM621==2 & (LM622=="bar owner" | LM622=="coffee house" | LM622=="dairy attendant" | LM622=="fast food delivering service")
replace own_occupation = 9 if LM623==23 & LM621==2 & (LM622=="mobil charging")
replace own_occupation = 6 if LM623==23 & LM621==2 & (LM622=="tailor")

tab LM622 if LM623==24 & LM621==2 
replace own_occupation = 7 if LM623==24 & LM621==2 & (LM622=="Cleaning Shop" | LM622=="Cleaning services" | LM622=="cleaner")
replace own_occupation = 16 if LM623==24 & LM621==2 & (LM622=="balancing accounts" | LM622=="balancing books" | LM622=="interior designing" | LM622=="marketing")
replace own_occupation = 3 if LM623==24 & LM621==2 & (LM622=="bar attendant" | LM622=="bar services" | LM622=="cleaning  rice ,nuts and ther food staffs")
replace own_occupation = 12 if LM623==24 & LM621==2 & (LM622=="driver" | LM622=="bar services")

tab LM622 if LM623==25 & LM621==2 

tab LM622 if LM623==26 & LM621==2 

tab LM622 if LM623==27 & LM621==2 

tab LM622 if LM623==1 & LM621==2 // people in the intersection of farming and trade - most in trade, some exceptions
replace own_occupation = 7 if LM623==1 & LM621==2 & (LM622=="Craft maker")
replace own_occupation = 2 if LM623==1 & LM621==2 & (LM622!="Craft maker")

tab LM622 if LM623==3 & LM621==2 // 
replace own_occupation = 3 if LM623==3 & LM621==2 & (LM622=="Bar attendant" | LM622=="bar attendant" | ///
	LM622=="bar attendant, servimg customers" | LM622=="small bar owner" | LM622=="soft and hard drinks, bar attendant" | ///
	LM622=="a) bartender b) selling alcoholic drinks")
replace own_occupation = 2 if LM623==3 & LM621==2 & (LM622!="Bar attendant" & LM622!="bar attendant" & ///
	LM622!="bar attendant, servimg customers" & LM622!="small bar owner" & LM622!="soft and hard drinks, bar attendant" & ///
	LM622!="a) bartender b) selling alcoholic drinks")

tab LM622 if LM623==4 & LM621==2 // 
replace own_occupation = 3 if LM623==4 & LM621==2 & (LM622=="bar attendant")
replace own_occupation = 8 if LM623==4 & LM621==2 & (LM622=="electrician")
replace own_occupation = 10 if LM623==4 & LM621==2 & (LM622=="money transfers")
replace own_occupation = 2 if LM623==4 & LM621==2 & (LM622!="bar attendant" & LM622!="electrician" & LM622!="money transfers")

tab LM622 if LM623==5 & LM621==2 // 
replace own_occupation = 2 if LM623==5 & LM621==2

tab LM622 if LM623==6 & LM621==2 // 
replace own_occupation = 7 if LM623==6 & LM621==2 & (LM622=="Charcoal burning" | LM622=="charcoal maker(orikosya amakara")
replace own_occupation = 2 if LM623==6 & LM621==2 & (LM622!="Charcoal burning" & LM622!="charcoal maker(orikosya amakara")
tab LM622 if LM623==6 & LM621==2 & own_occupation==.


***** 3 - FOOD-RELATED BUSINESS *****

tab LM623 if own_occupation==. & LM621==3, nolab

replace own_occupation = 3 if LM621==3 & inlist(LM623, 3, 31, 32, 33, 34, 35, 36, 37, 38, 39)

tab LM622 if LM623==3 & LM621==3 
replace own_occupation = 2 if LM623==3 & LM621==3 & (LM622=="shopkeeper" | LM622=="selling Vegetables" ///
	| LM622=="selling foods like rice ,posho at someone's shop" | LM622=="selling foods like rice, posho, salt" | LM622=="selling tomatoes" ///
	| LM622=="selling tomatoes and matooke" | LM622=="selling tomatoes,onions, groundnuts")
replace own_occupation = 12 if LM623==3 & LM621==3 & (LM622=="shopping and delivering to customers")

tab LM622 if LM623==31 & LM621==3 
replace own_occupation = 7 if LM623==31 & LM621==3 & (LM622=="cleaning")
replace own_occupation = 13 if LM623==31 & LM621==3 & (LM622=="hotel" | LM622=="hotel manager")

tab LM622 if LM623==32 & LM621==3 

tab LM622 if LM623==33 & LM621==3 
replace own_occupation = 16 if LM623==33 & LM621==3 & (LM622=="balancing books, shopping and managing" | LM622=="marketing manager")
replace own_occupation = 2 if LM623==33 & LM621==3 & (LM622=="Market Vendor" | LM622=="Shop" | LM622 == "Shop Owner" | LM622=="avocado and irish sales" ///
	| LM622=="hawker" | LM622=="hawker- yellow bananas" | LM622=="sales agent" | LM622=="sales manager" | LM622=="sales person" | LM622=="seller" ///
	| LM622=="selling Cassava" | LM622=="selling clothes" | LM622=="selling foods like rice posho" | LM622=="selling fruits.the business owner" ///
	| LM622=="selling matooke, onoins, tomatoes" | LM622=="selling sugar, rice and posho" | LM622=="selling to customers" | LM622=="selling tomatoes" ///
	| LM622=="selling tomatoes to customer" | LM622=="selling tomatoes, bananas, oranges" | LM622=="small vegetable stall" | LM622=="to take care of the shop" ///
	| LM622=="vegetable stole seller" | LM622=="vegetables sell")
replace own_occupation = 4 if LM623==33 & LM621==3 & (LM622=="Hair business" | LM622=="hair business")
replace own_occupation = 6 if LM623==33 & LM621==3 & (LM622=="tailoring, i have lost a lot of clothes")

tab LM622 if LM623==34 & LM621==3 

tab LM622 if LM623==35 & LM621==3 
replace own_occupation = 7 if LM623==35 & LM621==3 & (LM622=="cleaning")
replace own_occupation = 2 if LM623==35 & LM621==3 & (LM622=="sales")

tab LM622 if LM623==36 & LM621==3 
replace own_occupation = 2 if LM623==36 & LM621==3 & (LM622=="shop keeper")

tab LM622 if LM623==37 & LM621==3 
replace own_occupation = 1 if LM623==37 & LM621==3 & (LM622=="fisherman")

tab LM622 if LM623==38 & LM621==3 
replace own_occupation = 2 if LM623==38 & LM621==3 & (LM622=="trade")
            
tab LM622 if LM623==39 & LM621==3 
replace own_occupation = 19 if LM623==39 & LM621==3 & (LM622=="stock taking.the business owner")
replace own_occupation = 2 if LM623==39 & LM621==3 & (LM622=="trade")

tab LM622 if LM623==1 & LM621==3 //
replace own_occupation = 13 if LM623==1 & LM621==3 & (LM622=="hotel" | LM622=="hotel manager")
replace own_occupation = 3 if LM623==1 & LM621==3 & (LM622!="hotel" & LM622!="hotel manager")

tab LM622 if LM623==2 & LM621==3 //
replace own_occupation = 3 if LM623==2 & LM621==3

tab LM622 if LM623==4 & LM621==3 //
replace own_occupation = 3 if LM623==4 & LM621==3

tab LM622 if LM623==6 & LM621==3 //
replace own_occupation = 3 if LM623==6 & LM621==3

tab LM622 if LM623==7 & LM621==3 //
replace own_occupation = 1 if LM623==7 & LM621==3 & (LM622=="fisher man")

tab LM622 if LM623==8 & LM621==3 //
replace own_occupation = 3 if LM623==8 & LM621==3

tab LM622 if LM623==9 & LM621==3 //
replace own_occupation = 19 if LM623==9 & LM621==3 & (LM622=="Barker")
replace own_occupation = 3 if LM623==9 & LM621==3 & (LM622!="Barker")

tab LM622 if LM623==310 & LM621==3
replace own_occupation = 19 if LM623==310 & LM621==3 & (LM622=="wofecho")

***** 4 - BEAUTY CARE *****

tab LM623 if own_occupation==. & LM621==4, nolab
replace own_occupation = 4 if LM621==4 & inlist(LM623, 41, 42, 43)

tab LM622 if LM623==41 & LM621==4 //
replace own_occupation = 7 if LM623==41 & LM621==4 & (LM622=="cleaner")

tab LM622 if LM623==42 & LM621==4 //

tab LM622 if LM623==43 & LM621==4 //

tab LM622 if LM623==1 & LM621==4 //
replace own_occupation = 4 if LM623==1 & LM621==4

tab LM622 if LM623==2 & LM621==4 //
replace own_occupation = 4 if LM623==2 & LM621==4

***** 5 - ENTERTAINMENT *****

tab LM623 if own_occupation==. & LM621==5, nolab
replace own_occupation = 5 if LM621==5 & inlist(LM623, 51, 52, 54, 55)

tab LM622 if LM623==51 & LM621==5 //

tab LM622 if LM623==52 & LM621==5 //

tab LM622 if LM623==54 & LM621==5 //

tab LM622 if LM623==55 & LM621==5 //
replace own_occupation=12 if LM623==55 & LM621==5 & (LM622=="driver")

tab LM622 if LM623==1 & LM621==5 //
replace own_occupation = 3 if LM623==1 & LM621==5 & (LM622=="serving beer serving food")

tab LM622 if LM623==2 & LM621==5 //
replace own_occupation = 5 if LM623==2 & LM621==5 

tab LM622 if LM623==4 & LM621==5 //
replace own_occupation = 5 if LM623==4 & LM621==5 

***** 6 - CLOTHING *****

replace own_occupation = 6 if LM621==6 & inlist(LM623, 61, 62)
tab LM623 if own_occupation==. & LM621==6, nolab

tab LM622 if LM623==61 & LM621==6 //
replace own_occupation=12 if LM623==61 & LM621==6 & (LM622=="delivery")
replace own_occupation=7 if LM623==61 & LM621==6 & (LM622=="wash cloth")

tab LM622 if LM623==62 & LM621==6 //
replace own_occupation=6 if LM623==62 & LM621==6 & (LM622=="tailoring")
replace own_occupation=2 if LM623==62 & LM621==6 & (LM622!="tailoring") // cloth selling rather in "trade" than "clothes"

tab LM622 if LM623==1 & LM621==6 //
replace own_occupation = 6 if LM623==1 & LM621==6

tab LM622 if LM623==2 & LM621==6 //
replace own_occupation = 6 if LM623==2 & LM621==6

// One could also merge the "cloth production" sector (tailor) with the "manual works" sector 7 ?

***** 7 - MANUAL WORKS *****

tab LM623 if own_occupation==. & LM621==7, nolab
replace own_occupation = 7 if LM621==7 & inlist(LM623, 71, 72, 73, 74, 75, 76, 77, 78, 710)

tab LM622 if LM623==71 & LM621==7 //
replace own_occupation=16 if LM623==71 & LM621==7 & (LM622=="design houses")
replace own_occupation=8 if LM623==71 & LM621==7 & (LM622=="Carpenter" | LM622=="carpenter")

tab LM622 if LM623==72 & LM621==7 //

tab LM622 if LM623==73 & LM621==7 //

tab LM622 if LM623==74 & LM621==7 //

tab LM622 if LM623==75 & LM621==7 //
replace own_occupation=3 if LM623==75 & LM621==7 & (LM622=="cook")
replace own_occupation=12 if LM623==75 & LM621==7 & (LM622=="driving people")

tab LM622 if LM623==76 & LM621==7 //
replace own_occupation=12 if LM623==76 & LM621==7 & (LM622=="delivery")
replace own_occupation=2 if LM623==76 & LM621==7 & (LM622=="house broker")
replace own_occupation=8 if LM623==76 & LM621==7 & (LM622=="carpenter" | LM622=="phone mechanic")

tab LM622 if LM623==77 & LM621==7 //

tab LM622 if LM623==78 & LM621==7 //
replace own_occupation=2 if LM623==78 & LM621==7 & (LM622=="selling spares")
replace own_occupation=8 if LM623==78 & LM621==7 & (LM622=="Carpenter" | LM622=="WELDING" | LM622=="furniture work" | LM622=="making furniture")

tab LM622 if LM623==710 & LM621==7 //

tab LM622 if LM623==1 & LM621==7 //
replace own_occupation = 7 if LM623==1 & LM621==7

tab LM622 if LM623==2 & LM621==7 //
replace own_occupation = 7 if LM623==2 & LM621==7

tab LM622 if LM623==4 & LM621==7 //
replace own_occupation = 7 if LM623==4 & LM621==7

tab LM622 if LM623==5 & LM621==7 //
replace own_occupation = 7 if LM623==5 & LM621==7

tab LM622 if LM623==6 & LM621==7 //
replace own_occupation = 7 if LM623==6 & LM621==7
replace own_occupation = 2 if LM623==6 & LM621==7 & (LM622=="Broker")
replace own_occupation = 19 if LM623==6 & LM621==7 & (LM622=="Dobhi")
replace own_occupation = 1 if LM623==6 & LM621==7 & (LM622=="Peasant" | LM622=="Rearing Animal" | LM622=="casual labourer , weeding, digging,etc" | LM622=="cultivating beans and maize" | LM622=="cultivating daily labourer" | LM622=="digging" | LM622=="digging and all jobs" | LM622=="digging beans, maize" | LM622=="digging for other people" | LM622=="weeding beans" | LM622=="digging for others and planting of crops like beans maize")

tab LM622 if LM623==7 & LM621==7 //
replace own_occupation = 7 if LM623==7 & LM621==7

tab LM622 if LM623==8 & LM621==7 //
replace own_occupation = 7 if LM623==8 & LM621==7

tab LM622 if LM623==9 & LM621==7 //
replace own_occupation = 7 if LM623==9 & LM621==7

tab LM622 if LM623==10 & LM621==7 //
replace own_occupation = 10 if LM623==10 & LM621==7


***** 8 - MANUAL TECHNICAL SERVICES *****

tab LM623 if own_occupation==. & LM621==8, nolab
replace own_occupation = 8 if LM621==8 & inlist(LM623, 81, 82, 83, 84, 85, 86, 87, 88)

tab LM622 if LM623==81 & LM621==8 //

tab LM622 if LM623==82 & LM621==8 //

tab LM622 if LM623==83 & LM621==8 //

tab LM622 if LM623==84 & LM621==8 //
replace own_occupation = 2 if LM623==84 & LM621==8 & (LM622=="Daily sales")
replace own_occupation = 16 if LM623==84 & LM621==8 & (LM622=="secretary")

tab LM622 if LM623==85 & LM621==8 //

tab LM622 if LM623==86 & LM621==8 //
replace own_occupation = 7 if LM623==86 & LM621==8 & (LM622=="manual work")
replace own_occupation = 2 if LM623==86 & LM621==8 & (LM622=="selling spares")
replace own_occupation = 16 if LM623==84 & LM621==8 & (LM622=="working with internet")

tab LM622 if own_occupation==. & LM621==8
replace own_occupation = 8 if own_occupation==. & LM621==8
replace own_occupation = 7 if LM621==8 & (LM622=="builder")

***** 9 - COMMUNICATIONS/ IT/ COMPUTER/ MOBILE *****

tab LM622 if own_occupation==. & LM621==9
replace own_occupation = 9 if own_occupation==. & LM621==9
replace own_occupation = 16 if LM621==9 & (LM622=="English interpreter" | LM622=="Marketing through advert sales" | LM622=="Marking Managers" | LM622=="interpreter" | LM622=="secretary")
replace own_occupation= 17 if LM621==9 & (LM622=="police")
replace own_occupation= 7 if LM621==9 & (LM622=="security gard")

tab LM622 if own_occupation==. & LM621==11
replace own_occupation = 16 if own_occupation==. & LM621==11
replace own_occupation= 7 if LM621==11 & (LM622=="cleaning and washing clothes" | LM622=="Security guard" | LM622=="security officer")
replace own_occupation= 2 if LM621==11 & (LM622=="selling perfumes" | LM622=="selling stuf in bulky" | LM622=="make sales and supervise work" | LM622=="Attending to clients")
replace own_occupation = 10 if LM621==11 & (LM622=="Accountant")
replace own_occupation = 9 if LM621==11 & (LM622=="Software Enginner, Developing software features" | LM622=="data processor")
                  
tab LM622 if own_occupation==. & LM621==16
replace own_occupation = 16 if LM621==16
replace own_occupation = 10 if LM621==16 & (LM622=="Auditing" | LM622=="Book keeper" | LM622=="an auditor. audting" | LM622=="balancing the finance books and budgeting")
replace own_occupation= 2 if LM621==16 & (LM622=="Cashery")
replace own_occupation = 9 if LM621==16 & (LM622=="ICT Officer" | LM622=="ICT manager" ///
	| LM622=="Software developer" | LM622=="computing and programing" | LM622=="data base" ///
	| LM622=="entering data" | LM622=="he runs the communication section system")
replace own_occupation= 7 if LM621==16 & (LM622=="manual labourer b) mixing sand and cement" | LM622=="almunim works")

***** 10 - FINANCE *****

tab LM622 if own_occupation==. & LM621==10
replace own_occupation = 10 if own_occupation==. & LM621==10
replace own_occupation= 16 if LM621==10 & (LM622=="Marketing manager" | LM622=="manager" | LM622=="marketing")
replace own_occupation = 2 if LM621==10 & (LM622=="sales")
replace own_occupation = 7 if LM621==10 & (LM622=="Security Services")
                           	  
***** 12 - TRANSPORTATION *****

tab LM622 if own_occupation==. & LM621==12
replace own_occupation = 12 if own_occupation==. & LM621==12
replace own_occupation= 16 if LM621==12 & (LM622=="Administration" | LM622=="Board member" | LM622=="Services")
replace own_occupation = 8 if LM621==12 & (LM622=="Mechanic" | LM622=="auto mechanic")
replace own_occupation = 7 if LM621==12 & (LM622=="Pump attendant" | LM622=="loading and off load taxes and bas")
replace own_occupation = 10 if LM621==12 & (LM622=="accountant")
replace own_occupation = 2 if LM621==12 & (LM622=="selling fuel")
 				
***** 13 - ACCOMODATION *****

tab LM622 if own_occupation==. & LM621==13
replace own_occupation = 13 if own_occupation==. & LM621==13
replace own_occupation = 3 if LM621==13 & (LM622=="Catering")
replace own_occupation = 16 if LM621==13 & (LM622=="Personnel Management")
replace own_occupation = 7 if LM621==13 & (LM622=="Security guard" | LM622=="construction" | LM622=="guarding")
         
***** 14 - EDUCATION *****

tab LM622 if own_occupation==. & LM621==14
replace own_occupation = 14 if own_occupation==. & LM621==14
replace own_occupation= 7 if LM621==14 & (LM622=="clean")
replace own_occupation= 15 if LM621==14 & (LM622=="Nurse, first aid service for kids")
replace own_occupation = 9 if LM621==14 & (LM622=="IT")
replace own_occupation = 16 if LM621==14 & (LM622=="Laboratory" | LM622=="Laboratory Technician" | LM622=="coordinator"| LM622=="management")
replace own_occupation = 10 if LM621==14 & (LM622=="bursar")
 				  
***** 15 - HEALTH *****

tab LM622 if own_occupation==. & LM621==15
replace own_occupation = 15 if own_occupation==. & LM621==15
replace own_occupation= 7 if LM621==15 & (LM622=="cleaner")

***** 17 - PUBLIC SECTOR *****
// NOTE: Whenever possible, code these occupations by industry. Keep only "obvious" public service occupations in group 17.

tab LM622 if own_occupation==. & LM621==17
replace own_occupation = 19 if own_occupation==. & LM621==17
replace own_occupation = 17 if LM621==17 & (LM622=="Diffence force" | ///
	LM622=="community mobilizer" | LM622=="keeping law and order" | ///
	LM622=="national id registration" | LM622=="police" | LM622=="police hizeb tabaki nw" | ///
	LM622=="provide service to the community peace" | LM622=="social worker" | ///
	LM622=="subcounty chief, subcounty management" | LM622=="youth development officer/ yewetat srawoch yastebabiral")
replace own_occupation = 16 if LM621==17 & (LM622=="AId supplier officer" | ///
	LM622=="Administration" | LM622=="Development"| LM622=="Field supervisor" | ///
	LM622=="HRM officer" | LM622=="Human resource manager" | LM622=="Land Administration, surveying" | ///
	LM622=="NGO shufar" | LM622=="Office mangement" | LM622=="artificial estimations" | ///
	LM622=="record keeping" | LM622=="research" | LM622=="public relation")
replace own_occupation = 10 if LM621==17 & (LM622=="Accountant" | ///
	LM622=="Controlling budget flow of school")
replace own_occupation= 7 if LM621==17 & (LM622=="Cleaner" | LM622=="Cleaning" | ///
	LM622=="Cleaning Supervisor" | LM622=="LDU security services" | ///
	LM622=="Security service for the community" | LM622=="cleaner" | ///
	LM622=="cleaning" | LM622=="road cleaner" | LM622=="security" | ///
	LM622=="security Services"| LM622=="security guard" | LM622=="sweeping the road" | ///
	LM622=="tebeka" | LM622=="tebeka (security)")
replace own_occupation= 14 if LM621==17 & (LM622=="Consult, train and Evaluation")
replace own_occupation= 13 if LM621==17 & (LM622=="Hotel management")                            
replace own_occupation= 9 if LM621==17 & (LM622=="ICT expert" | LM622=="IT Officer" | ///
	LM622=="Ict Officers" | LM622=="it director")
replace own_occupation= 2 if LM621==17 & (LM622=="Purchasing" | LM622=="casher")
replace own_occupation = 12 if LM621==17 & (LM622=="drive" | LM622=="driver")
replace own_occupation = 15 if LM621==17 & (LM622=="farmaciste" | ///
	LM622=="medical doctor for reproductive health")
			  
***** 18 - RELIGION *****

tab LM622 if own_occupation==. & LM621==18
replace own_occupation = 18 if own_occupation==. & LM621==18

***** 19 - OTHER *****

tab LM622 if own_occupation==. & LM621==19

replace own_occupation = 19 if own_occupation==. & LM621==19
replace own_occupation= 2 if LM621==19 & (LM622=="Broker" | LM622=="Cashir" | ///
	LM622=="Selling and transporting matooke to Kampala" | ///
	LM622=="a) attendant b) petrol service" | LM622=="broker" | LM622=="cashir" | ///
	LM622=="charcoal seller" | LM622=="display the games list, being cashier, setting time basing on the money paid" | ///
	LM622=="making brooms and hawking" | LM622=="managing workers and goods sold" | LM622=="merchandise" | ///
	LM622=="selling charcoal" | LM622=="selling goods" | LM622=="selling old metallic things" | ///
	LM622=="selling vegetables" | LM622=="selling water" | LM622=="sells charcoal" | LM622=="shop owner" | ///
	LM622=="shopping" | LM622=="store keeper store mekotatariya")
replace own_occupation= 7 if LM621==19 & (LM622=="Builder" | LM622=="Housemaid" | ///
	LM622=="Security Guard" | LM622=="Stone quarry" | LM622=="a) house worker b) ensuring that the house is in order" | ///
	LM622=="a) houseworker b) cleaning and ordering the house" | LM622=="a) houseworker b) cleaning services" | ///
	LM622=="a) house worker b) providing cleaning services" | ///
	LM622=="a) security officer b) protecting people and property" | LM622=="baby seating and keeping the home" | ///
	LM622=="care taker" | LM622=="cargo parkaging" | LM622=="cleaner" | LM622=="cleaner - cleaning clothes" | ///
	LM622=="cleaner, cleaning kampala streets" | LM622=="cleaner, for customers clothes home" | ///
	LM622=="cleaner.washes clothes" | LM622=="cleaning" | LM622=="cleaning and washing clothes" | ///
	LM622=="cleaning, carrying garbage, fetching water" | LM622=="cleaning the offices and cooking for the staff" | ///
	LM622=="cleaning, sorting and packing foods to export" | LM622=="cooking and cleaninig,carining child" | ///
	LM622=="cooking,cleqning and wshing clothes" | LM622=="fetching water" | LM622=="he only does security duties day and night" | ///
	LM622=="house maintenance" | LM622=="house wife" | LM622=="loading and unloading of goods" |  ///
	LM622=="maid" | LM622=="maid/helper" | LM622=="protecting clients and their property" | ///
	LM622=="providing security" | LM622=="security" | LM622=="security officer" | LM622=="sanitary" | ///
	LM622=="sending cement to the builders" | LM622=="shoe making" | LM622=="socking and washing," | ///
	LM622=="sweeping" | LM622=="washing clothes" | LM622=="wood work")
replace own_occupation= 8 if LM621==19 & (LM622=="Craft making" | LM622=="Lighting decorator" | ///
	LM622=="Printing assistant" | LM622=="a) crafts maker b) making and selling crafts" | LM622=="a) welder b) welding" | ///
	LM622=="a) worker b) phone repair" | LM622=="building and carpenter" | LM622=="carpenter" | LM622=="carpenter(building house)" | ///
	LM622=="construction" | LM622=="crafting" | LM622=="electric instslation" | LM622=="electric mesmere zrgata" | ///
	LM622=="furnitur" | LM622=="look after the tap water source" | LM622=="machine operator" | LM622=="photocopy")
replace own_occupation= 12 if LM621==19 & (LM622=="Driving" | LM622=="driver" | LM622=="driving bajaj" | LM622=="sewoch transport" | ///
	LM622=="trsnsport, transport service for individuals")
replace own_occupation= 16 if LM621==19 & (LM622=="Chemist" | LM622=="Conducting research on bacteria" | ///
	LM622=="General Manager" | LM622=="Sells Super visor at total oil company" | LM622=="Custodian" | ///
	LM622=="adjudication" | LM622=="administrator" | LM622=="artchitecture" | LM622=="camera man" | ///
	LM622=="civil engineering" | LM622=="collect money from residents for the purpose of security" | ///
	LM622=="customer relations" | LM622=="customer service manager" | LM622=="engineer" | ///
	LM622=="graphics designing," | LM622=="interpretation of language" | LM622=="interpretor/ interpreting for" | ///
	LM622=="manager" | LM622=="marketer" | LM622=="principal" | LM622=="translating")
replace own_occupation = 9 if LM621==19 & (LM622=="IT programer" | LM622=="Internet based" | ///
	LM622=="Network Zrgata" | LM622=="Network services" | LM622=="computer maintenance" | ///
	LM622=="it officer" | LM622=="printing operator" | LM622=="software developer") 
replace own_occupation = 17 if LM621==19 & (LM622=="Police hono wenjel mekelakel be wana sajin maereg yagelegilal" | ///
	LM622=="a) army b) protecting and securing the country" | LM622=="commandant")
replace own_occupation = 13 if LM621==19 & (LM622=="a) caretaker b) looking after the house" | LM622=="guarding a rental houses" | ///
	LM622=="landlady" | LM622=="landlord- renting houses" | LM622=="managing all the tenants" | LM622=="looking after someone's home")
replace own_occupation = 10 if LM621==19 & (LM622=="accountant" | LM622=="accounts" | ///
	LM622=="banker" | LM622=="finance")
replace own_occupation = 3 if LM621==19 & (LM622=="bar" | LM622=="selling beer" | LM622=="selling in the bar,") 
replace own_occupation = 6 if LM621==19 & (LM622=="beading and tayloring" | LM622=="making bags" | LM622=="making jewelry and bags" | ///
	LM622=="washing clothes and tailoring") 
replace own_occupation = 1 if LM621==19 & (LM622=="coffee making- collection of coffee")
replace own_occupation = 15 if LM621==19 & (LM622=="doctor" | LM622=="herbalist" | LM622=="midwife" | ///
	LM622=="supply soya to mothers, talk to mothers on how to breastfeed and family planing with MTI NGO" | ///
	LM622=="translation, health education and also distribute items")    
replace own_occupation = 5 if LM621==19 & (LM622=="music and library")
replace own_occupation = 4 if LM621==19 & (LM622=="plaiting" | LM622=="shaves people's hair")                               

label values own_occupation occup_lab 

tab own_occupation, missing
count if own_occupation ==. & employed==0 // missing only for the unemployed
count if own_occupation ==. & employed==1

tab employed 

tab LM622 if employed==1 & own_occupation==.


***** Missing: Cleaning of occupations in Somali language ********

replace own_occupation=12 if LM622=="shufrna" // Driver


*************************************
*ASPIRED OCCUPATION: TITLE FOR UNEMPLOYED *
*************************************

tab LM610 
tab LM610 
tab LM622
tab EX900B1 
tab EX900B2

bys employed: tab EX900B1 if exp_diff_occup == 1 & !mi(EX900B1)
 
codebook EX900B1
codebook EX900B1 if employed==1 // answered for 50% of sample (those who are in diff_occup treatment)
codebook EX900B1 if employed==0 // answered for all unemployed

codebook exp_diff_occup //

*1) Coding occupations of the unemployed who were assigned to "Different occupation vignette"
* Relevant for descriptives about aspired occupations 
 
gen 	unmployed_title = "Business" if EX900B1 == "business" & exp_diff_occup == 1
replace unmployed_title = "Security" if EX900B1 == "A security guard" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "BUSINESS woman" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "Business Man" & exp_diff_occup == 1
replace unmployed_title = "Mechanic" if EX900B1 == "Car mechanic" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "BODA BODA RIDER" & exp_diff_occup == 1
replace unmployed_title = "Cleaner" if EX900B1 == "Cleaning" & exp_diff_occup == 1
replace unmployed_title = "Cook" if EX900B1 == "Cooking" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "Driving" & exp_diff_occup == 1
replace unmployed_title = "Electrician" if EX900B1 == "Electricashan" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "Get a capital and start a business" & exp_diff_occup == 1
replace unmployed_title = "Stylist" if EX900B1 == "Hawker for gents clothws" & exp_diff_occup == 1
replace unmployed_title = "ICT" if EX900B1 == "ICT works" & exp_diff_occup == 1
replace unmployed_title = "ICT" if EX900B1 == "IT business" & exp_diff_occup == 1
replace unmployed_title = "ICT" if EX900B1 == "IT technician" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "Internet Cafe owner" & exp_diff_occup == 1
replace unmployed_title = "Manager" if EX900B1 == "Management" & exp_diff_occup == 1
replace unmployed_title = "Mechanic" if EX900B1 == "Mekanic" & exp_diff_occup == 1
replace unmployed_title = "Doctor" if EX900B1 == "Mekupist" & exp_diff_occup == 1
replace unmployed_title = "Cook" if EX900B1 == "Migbi zgjet" & exp_diff_occup == 1
replace unmployed_title = "Trade" if EX900B1 == "Nigede" & exp_diff_occup == 1
replace unmployed_title = "Nurse" if EX900B1 == "Nursing" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "Own a shop" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "Owning a Dairy shop" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "Retail shop" & exp_diff_occup == 1
replace unmployed_title = "Shopkeeper" if EX900B1 == "Shop attendant" & exp_diff_occup == 1
replace unmployed_title = "Tailor" if EX900B1 == "TAILORING" & exp_diff_occup == 1
replace unmployed_title = "Tailor" if EX900B1 == "Tailoring" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "Daily Labourer" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "Daily Labourers" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "Daily labores" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "Daily labourer" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "Enemployment" & exp_diff_occup == 1
replace unmployed_title = "Trade" if EX900B1 == "Trading" & exp_diff_occup == 1
replace unmployed_title = "Translation" if EX900B1 == "Transilation Job" & exp_diff_occup == 1
replace unmployed_title = "Accountant" if EX900B1 == "accountant" & exp_diff_occup == 1
replace unmployed_title = "Accountant" if EX900B1 == "accountante" & exp_diff_occup == 1
replace unmployed_title = "Accountant" if EX900B1 == "accunting" & exp_diff_occup == 1
replace unmployed_title = "Accountant" if EX900B1 == "acountant" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "any" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "any Job that gives him money" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "any good job" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "any goood job" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "any job" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "any manual work" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "any work" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "applying henna, makeup" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "basic commodity shop" & exp_diff_occup == 1
replace unmployed_title = "Health" if EX900B1 == "be health officer lemeketer yifelgalu" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "beauty" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "beauty care" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "beauty make up" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "beauty salon owner" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "beauty salon(tsigure bete)" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "buetique owner" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "buetuque owner" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "business" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "business like a shop" & exp_diff_occup == 1
replace unmployed_title = "Manager" if EX900B1 == "business management or human resource" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "business owned without agriculture" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "bussiness Astadadaer" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "cafeteria owner and management" & exp_diff_occup == 1
replace unmployed_title = "Cook" if EX900B1 == "cake and dabo" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "capital- start up own business" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "car driving" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "casual laborer" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "casual labourer" & exp_diff_occup == 1
replace unmployed_title = "Catering" if EX900B1 == "cetering service's" & exp_diff_occup == 1
replace unmployed_title = "Catering" if EX900B1 == "catering" & exp_diff_occup == 1
replace unmployed_title = "ICT" if EX900B1 == "computer since" & exp_diff_occup == 1
replace unmployed_title = "ICT" if EX900B1 == "computering" & exp_diff_occup == 1
replace unmployed_title = "Construction" if EX900B1 == "constrictio" & exp_diff_occup == 1
replace unmployed_title = "Construction" if EX900B1 == "construction" & exp_diff_occup == 1
replace unmployed_title = "Construction" if EX900B1 == "construction trkuarsch" & exp_diff_occup == 1
replace unmployed_title = "Construction" if EX900B1 == "construction worker" & exp_diff_occup == 1
replace unmployed_title = "Cook" if EX900B1 == "cook" & exp_diff_occup == 1
replace unmployed_title = "Cook" if EX900B1 == "cooking" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "cosmetics" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "daily casual labor" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "daily causal labourer" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "daily laborer" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "daily laborers" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "daily labourer" & exp_diff_occup == 1
replace unmployed_title = "Education" if EX900B1 == "day care for children" & exp_diff_occup == 1
replace unmployed_title = "Minning" if EX900B1 == "digging for money" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "doing business" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "drive" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "driver" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "drivers" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "driving" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "driving and mechanics" & exp_diff_occup == 1
replace unmployed_title = "Electrician" if EX900B1 == "electician" & exp_diff_occup == 1
replace unmployed_title = "Electrician" if EX900B1 == "electrician" & exp_diff_occup == 1
replace unmployed_title = "Farming" if EX900B1 == "farming(cattle keeping)" & exp_diff_occup == 1
replace unmployed_title = "Farming" if EX900B1 == "farmer" & exp_diff_occup == 1
replace unmployed_title = "Food" if EX900B1 == "food preparation" & exp_diff_occup == 1
replace unmployed_title = "Service Station" if EX900B1 == "fuel pump attendant" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "general labourer" & exp_diff_occup == 1
replace unmployed_title = "Mechanic" if EX900B1 == "garaj" & exp_diff_occup == 1
replace unmployed_title = "Mechanic" if EX900B1 == "general mechanics" & exp_diff_occup == 1
replace unmployed_title = "Farming" if EX900B1 == "goat agrigator" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "hair cutting" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "hair dresser" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "hair dressing" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "hena" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "hina beaty solan" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "hotel manager" & exp_diff_occup == 1
replace unmployed_title = "Construction" if EX900B1 == "house building" & exp_diff_occup == 1
replace unmployed_title = "ICT" if EX900B1 == "ict manager" & exp_diff_occup == 1
replace unmployed_title = "ICT" if EX900B1 == "ict work" & exp_diff_occup == 1
replace unmployed_title = "Manager" if EX900B1 == "import and export manager" & exp_diff_occup == 1
replace unmployed_title = "Engineer" if EX900B1 == "industrial engineering sra" & exp_diff_occup == 1
replace unmployed_title = "Translation" if EX900B1 == "interpretation work" & exp_diff_occup == 1
replace unmployed_title = "Livestock" if EX900B1 == "live stock" & exp_diff_occup == 1
replace unmployed_title = "Livestock" if EX900B1 == "live stocks" & exp_diff_occup == 1
replace unmployed_title = "Livestock" if EX900B1 == "livestock broker" & exp_diff_occup == 1
replace unmployed_title = "Logistics" if EX900B1 == "logistics or custom clearance" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "make up" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "make up artist" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "making cookies, beaty salooon" & exp_diff_occup == 1
replace unmployed_title = "Manager" if EX900B1 == "mamaker" & exp_diff_occup == 1
replace unmployed_title = "Manager" if EX900B1 == "management" & exp_diff_occup == 1
replace unmployed_title = "Manager" if EX900B1 == "manager" & exp_diff_occup == 1
replace unmployed_title = "Manager" if EX900B1 == "mangegemet" & exp_diff_occup == 1
replace unmployed_title = "Mechanic" if EX900B1 == "mekanic" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "no occupation" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "not currently" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "not employed" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "not given" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "not job" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "operating agrocery shop" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "own business" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "owner of business outside Agricultural" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "perfume making" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "person al hair dressing salon" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "personal business" & exp_diff_occup == 1
replace unmployed_title = "Food" if EX900B1 == "restaurant" & exp_diff_occup == 1
replace unmployed_title = "Food" if EX900B1 == "restaurant cheff" & exp_diff_occup == 1
replace unmployed_title = "Food" if EX900B1 == "restaurant owner" & exp_diff_occup == 1
replace unmployed_title = "Food" if EX900B1 == "restuarant work" & exp_diff_occup == 1
replace unmployed_title = "Retail" if EX900B1 == "retail business" & exp_diff_occup == 1
replace unmployed_title = "Retail" if EX900B1 == "retail shop" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "run a shop of her own" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "running a business" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "salaried employee" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "sales" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "sales person" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "saloon , applying henna" & exp_diff_occup == 1
replace unmployed_title = "Secretary" if EX900B1 == "secretarial" & exp_diff_occup == 1
replace unmployed_title = "Secretary" if EX900B1 == "secretay" & exp_diff_occup == 1
replace unmployed_title = "Security" if EX900B1 == "security services" & exp_diff_occup == 1
replace unmployed_title = "Shopkeeper" if EX900B1 == "seeking for shop attendant job" & exp_diff_occup == 1
replace unmployed_title = "Self Employment" if EX900B1 == "self employed" & exp_diff_occup == 1
replace unmployed_title = "Self Employment" if EX900B1 == "self employment" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "selling charcoal" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "selling clothes and shoes" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "selling clothes" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "selling coffee" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "selling female cosmetics" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "selling soft drinks" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "sells" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "setting up a restaurant" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "shaving" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "she wants a spare shop" & exp_diff_occup == 1
replace unmployed_title = "Cleaner" if EX900B1 == "she wants to work as a cleaner" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "shiyach /sale's" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "shop" & exp_diff_occup == 1
replace unmployed_title = "Shopkeeper" if EX900B1 == "shop attendant" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "shop owner" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "shopping owner" & exp_diff_occup == 1
replace unmployed_title = "Social Worker" if EX900B1 == "social worker or any adminstration work" & exp_diff_occup == 1
replace unmployed_title = "Beauty" if EX900B1 == "starting up acosmetics shop and makeup booth" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "stationary work" & exp_diff_occup == 1
replace unmployed_title = "Shopkeeper" if EX900B1 == "super market attendant" & exp_diff_occup == 1
replace unmployed_title = "Supervisor" if EX900B1 == "supervisor" & exp_diff_occup == 1
replace unmployed_title = "Tailor" if EX900B1 == "tailoring" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "tax driver" & exp_diff_occup == 1
replace unmployed_title = "Teacher" if EX900B1 == "teaching At primary school" & exp_diff_occup == 1
replace unmployed_title = "Teacher" if EX900B1 == "technically mechine vahicle" & exp_diff_occup == 1
replace unmployed_title = "Housewife" if EX900B1 == "the house wife" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "to open any kind of business" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "to start his own nyama choma business" & exp_diff_occup == 1
replace unmployed_title = "Trade" if EX900B1 == "trade" & exp_diff_occup == 1
replace unmployed_title = "Translation" if EX900B1 == "translator" & exp_diff_occup == 1
replace unmployed_title = "Transportion" if EX900B1 == "transportation business" & exp_diff_occup == 1
replace unmployed_title = "Secretary" if EX900B1 == "tsehafi/ Secretary" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "unemployed" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "unemployed but looking for a job" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "wage employment on salaried work" & exp_diff_occup == 1
replace unmployed_title = "Waiter" if EX900B1 == "waiter" & exp_diff_occup == 1
replace unmployed_title = "Waiter" if EX900B1 == "waitress" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "wants to be employed and they pay him per month" & exp_diff_occup == 1
replace unmployed_title = "Security" if EX900B1 == "watchman" & exp_diff_occup == 1
replace unmployed_title = "Wholesale" if EX900B1 == "wholesaler" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "wishes to startup abotique" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "work daily laborers" & exp_diff_occup == 1
replace unmployed_title = "Construction" if EX900B1 == "work on a construction site" & exp_diff_occup == 1
replace unmployed_title = "Service Station" if EX900B1 == "working at petro station" & exp_diff_occup == 1
replace unmployed_title = "Oil Company" if EX900B1 == "working in company of oil" & exp_diff_occup == 1
replace unmployed_title = "Hardware" if EX900B1 == "working in hard ware as attendant" & exp_diff_occup == 1
replace unmployed_title = "Service Station" if EX900B1 == "working on a petro station" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "business" & exp_diff_occup == 1
replace unmployed_title = "ICT" if EX900B1 == "IT" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "business" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "Any job" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "Anything" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "Causal Labourer" & exp_diff_occup == 1
replace unmployed_title = "Cook" if EX900B1 == "Cooking food" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "Hair dressing" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "bueique owner" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "buetique" & exp_diff_occup == 1
replace unmployed_title = "Carpenter" if EX900B1 == "carpenter" & exp_diff_occup == 1
replace unmployed_title = "Cashier" if EX900B1 == "cashier" & exp_diff_occup == 1
replace unmployed_title = "Cleaner" if EX900B1 == "cleaner" & exp_diff_occup == 1
replace unmployed_title = "Cleaner" if EX900B1 == "cleaning" & exp_diff_occup == 1
replace unmployed_title = "Electronic Shop" if EX900B1 == "electronic shop" & exp_diff_occup == 1
replace unmployed_title = "Engineer" if EX900B1 == "engineer" & exp_diff_occup == 1
replace unmployed_title = "Furniture" if EX900B1 == "furniture" & exp_diff_occup == 1
replace unmployed_title = "Waiter" if EX900B1 == "Tea Girl" & exp_diff_occup == 1

*Translating difficult ones
replace unmployed_title = "Shopkeeper" if EX900B1 == "bakhaar raashin" & exp_diff_occup == 1
replace unmployed_title = "Student" if EX900B1 == "shaqo la,aan laakiin wax ban bartaa" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "shaqo la,aan" & exp_diff_occup == 1
replace unmployed_title = "Welding" if EX900B1 == "Sufare" & exp_diff_occup == 1
replace unmployed_title = "Blacksmith" if EX900B1 == "Waxaan ka shaqeeya Tumalnimo" & exp_diff_occup == 1
replace unmployed_title = "Animal Trade" if EX900B1 == "ganacsiga xoolaha" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "neged" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "hada ma shaqeeyo laakiin ganacsiga aqaanaa ayay itri" & exp_diff_occup == 1
replace unmployed_title = "Student" if EX900B1 == "arday ban ahay mashaqeyo" & exp_diff_occup == 1
replace unmployed_title = "Student" if EX900B1 == "ganacsi baanraadinhayaa" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "bakhaar raashin" & exp_diff_occup == 1
replace unmployed_title = "Agricultural Work" if EX900B1 == "shaqada beeraha" & exp_diff_occup == 1
replace unmployed_title = "Construction" if EX900B1 == "bakhaar dhisme" & exp_diff_occup == 1
replace unmployed_title = "Clothing Store" if EX900B1 == "dukaamada dharka dumarka lagu iibiyo" & exp_diff_occup == 1
replace unmployed_title = "Civil Servant" if EX900B1 == "shaqale dowladed" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "shaqo abuur" & exp_diff_occup == 1
replace unmployed_title = "Animal Trade" if EX900B1 == "ganacsiga xoolaha" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "dhanka xoolaha ayan labshaqeyn laha" & exp_diff_occup == 1
replace unmployed_title = "Tailor" if EX900B1 == "dawaarle ama dhartole" & exp_diff_occup == 1
replace unmployed_title = "Shopkeeper" if EX900B1 == "dukaan" & exp_diff_occup == 1
replace unmployed_title = "Student" if EX900B1 == "studen at quran" & exp_diff_occup == 1
replace unmployed_title = "Clothing Store" if EX900B1 == "meherad dharka lagugado" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "Shay buna" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "Negde" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "Neged sera" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "Shay buna" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "Nigede" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "yeshiyach sira (sales" & exp_diff_occup == 1
replace unmployed_title = "Care" if EX900B1 == "operating asaloon, makeup, applying henna, treating the hair" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "tsegur bet" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "samuna mecher cher" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "ye Nigede sera" & exp_diff_occup == 1
replace unmployed_title = "Student" if EX900B1 == "temare nache" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "yeshama nigid" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "niged" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "niged" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "mangnawm sera" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "negede" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "Yaqeter wayem yagel sera" & exp_diff_occup == 1
replace unmployed_title = "Teacher" if EX900B1 == "memhr" & exp_diff_occup == 1
replace unmployed_title = "Cleaner" if EX900B1 == "ye tsidat sera" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "ya negde sera" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "nigid" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "Yetsegur sira" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "sera yalawem" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "Yegl sira" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "negde" & exp_diff_occup == 1
replace unmployed_title = "Barber" if EX900B1 == "barbary" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "yaqen sera" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "yegil bussies" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "yemetedaderut beketeta degaf sefetnet erdata and bezemed erdata new" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "tsigure bete" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "Ye wore Ktre" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "manegnawm sera" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "shiyach" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "yegel negde srea" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "shufrina" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "bodaboda cyclist" & exp_diff_occup == 1
replace unmployed_title = "Cleaner" if EX900B1 == "xaaqe" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "shaqo la,aaan" & exp_diff_occup == 1
replace unmployed_title = "Cleaner" if EX900B1 == "xaadhe" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "yegel Nigede" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "yatagagwen yaqeter sera" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "sera falage naw menem sera yalawem" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "waa qofdanyar aha" & exp_diff_occup == 1
replace unmployed_title = "Selling Clothes" if EX900B1 == "libs meshet" & exp_diff_occup == 1
replace unmployed_title = "Local public office" if EX900B1 == "bet tsihefet" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "manegnawm sera" & exp_diff_occup == 1
replace unmployed_title = "Messenger in an office" if EX900B1 == "office west Telalaki" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "yegil mangawim sira" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "yetegegnewn" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "Ye Tsegur Sra" & exp_diff_occup == 1
replace unmployed_title = "Printing work" if EX900B1 == "yahetmat sera" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "yenged sra" & exp_diff_occup == 1
replace unmployed_title = "Care" if EX900B1 == "Wet bet/Tsaguri bet" & exp_diff_occup == 1
replace unmployed_title = "Restaurant" if EX900B1 == "mehrad ama restaurant" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "shufar makina mendat" & exp_diff_occup == 1
replace unmployed_title = "Tailor" if EX900B1 == "dhartole" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "sera ate" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "yeken sera" & exp_diff_occup == 1
replace unmployed_title = "Plumber" if EX900B1 == "ye buwanbuwa sera ena tigena" & exp_diff_occup == 1
replace unmployed_title = "Any Job" if EX900B1 == "Teketro Mesrat" & exp_diff_occup == 1
replace unmployed_title = "Selling Clothes" if EX900B1 == "yerase nigde libese" & exp_diff_occup == 1
replace unmployed_title = "Sales" if EX900B1 == "shiach weym sells lay" & exp_diff_occup == 1
replace unmployed_title = "Cook" if EX900B1 == "megeb mabsel" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "beshufirna" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "mnm aynet sera yelewm" & exp_diff_occup == 1
replace unmployed_title = "Butcher" if EX900B1 == "Tsegr beat" & exp_diff_occup == 1
replace unmployed_title = "Garage worker" if EX900B1 == "yegarsj sira" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "yegel megebe bet mekifete" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == "internet bete meserat eflegalhu" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "negide" & exp_diff_occup == 1
replace unmployed_title = "Driver" if EX900B1 == "shiferena" & exp_diff_occup == 1
replace unmployed_title = "Unemployed" if EX900B1 == "menem sera yaltem gana bamflge laye nache" & exp_diff_occup == 1
replace unmployed_title = "Business" if EX900B1 == " business" & exp_diff_occup == 1
replace unmployed_title = "Daily Worker" if EX900B1 == "Daily laborer" & exp_diff_occup == 1
replace unmployed_title = "Hair Dresser" if EX900B1 == "Hair dresser" & exp_diff_occup == 1
replace unmployed_title = "Trading" if EX900B1 == "Trade" & exp_diff_occup == 1
replace unmployed_title = "Agricultural Work" if EX900B1 == "agriculture officer" & exp_diff_occup == 1
replace unmployed_title = "Nurse" if EX900B1 == "nurse" & exp_diff_occup == 1
replace unmployed_title = "Secretary" if EX900B1 == "office attendant" & exp_diff_occup == 1
replace unmployed_title = "Typist" if EX900B1 == "typist" & exp_diff_occup == 1
replace unmployed_title = "Humanitarian" if EX900B1 == "humanitarian" & exp_diff_occup == 1

tab EX900B1 if exp_diff_occup == 1, m 
tab EX900B1 if mi(unmployed_title) & exp_diff_occup == 1, m 
 
*2) Export list of unemployed in different-occupation-treatment (ask Tewodros for translations)
replace unmployed_title = EX900B1 if exp_diff_occup == 1 & mi(unmployed_title)
*66 statmeents untraslated 

*3) Coding occupations of the unemployed who were assigned to "same-occupation" treatment
* Note: Only the unemployed (employed also answered EX900B1 if SO treatment, but we rely on 622 for them.)

tab own_occupation LFP
tab unmployed_title LFP, m 

tab LM610  

*Occupation of the respondent:
codebook EX900B1 
*Text of different occupatio
codebook EX900B2
bys employed: tab EX900B2 

bys employed: tab EX900B1 if exp_diff_occup == 1 & !mi(EX900B1)
tab EX900B1 if exp_diff_occup == 0 & employed == 0 , m 
tab unmployed_title if employed == 0 , m  
*504 unemployed occupation missing 
bys employed: tab own_occupation, m 
bys employed: tab EX900B2 exp_diff_occup, m 

replace	unmployed_title = "Business" if EX900B1 == "business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "Nigede" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "Shop attendant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Tailor" if EX900B1 == "Tailoring" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "Daily Labourer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "Daily labourer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Accountant" if EX900B1 == "accountant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Accountant" if EX900B1 == "acountant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "any" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "any good job" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "any job" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Beauty" if EX900B1 == "beauty care" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "buetique owner" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Catering" if EX900B1 == "catering" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Construction" if EX900B1 == "construction" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Construction" if EX900B1 == "construction worker" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cook" if EX900B1 == "cook" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cook" if EX900B1 == "cooking" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "daily laborer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "daily laborers" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "daily labourer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "doing business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "driver" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "drivers" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "driving" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Farming" if EX900B1 == "farmer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Service Station" if EX900B1 == "fuel pump attendant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "general labourer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Farming" if EX900B1 == "goat agrigator" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "hair cutting" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "hair dresser" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "hair dressing" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Manager" if EX900B1 == "manager" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Food" if EX900B1 == "restaurant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Food" if EX900B1 == "restaurant cheff" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Retail" if EX900B1 == "retail shop" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "sales" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Self Employment" if EX900B1 == "self employed" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "selling clothes" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "shop" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "shop attendant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "shop owner" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Tailor" if EX900B1 == "tailoring" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "tax driver" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trade" if EX900B1 == "trade" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Translation" if EX900B1 == "translator" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "waiter" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "waitress" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Wholesale" if EX900B1 == "wholesaler" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cook" if EX900B1 == "Cooking food" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "Hair dressing" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Carpenter" if EX900B1 == "carpenter" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cleaner" if EX900B1 == "cleaner" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cleaner" if EX900B1 == "cleaning" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Engineer" if EX900B1 == "engineer" & exp_diff_occup == 0 & employed == 0 

*Translating difficult ones
replace unmployed_title = "Shopkeeper" if EX900B1 == "bakhaar raashin" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "shaqo la,aan" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "bakhaar raashin" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "Nigede" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "niged" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "negede" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "nigid" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "negde" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily laborer" if EX900B1 == "yaqen sera" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "tsigure bete" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "manegnawm sera" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "Hair dresser" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Nurse" if EX900B1 == "nurse" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "negida" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "Niged" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "Ye nigede sera" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "yegel neged" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "ye gel negede" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "Nigid" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "nigid gomen chrcharo" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "bakhaar raadhin" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Finance" if EX900B1 == "finance balemuya" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Construction" if EX900B1 == "fiber glass sra" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "ICT" if EX900B1 == "becomputer moya" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "dhaqo la,aan" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "shaqa la,aan laakiin waxan ka shaqaynlahaa kuuliga" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "shaqo la,aan laakiin waa xoogsi kuuliya" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "working as a restaurant attendant or waitress" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Craft Making" if EX900B1 == "shaqo mahayo laakiin waxan ku fiicanahay farsamada gacanta (creft making)" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "wants to start a business in hair dressing" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "get employed in  an organisation as adriver" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Beauty" if EX900B1 == "to start small business loans like cosmotics shop" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Selling Clothes" if EX900B1 == "Selling clothes like Bitengi in a boutique" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "ICT" if EX900B1 == "things to deal with information technology" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "shuferna(driver)" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cook" if EX900B1 == " a cook" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "ICT" if EX900B1 == " be ICT muya" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Construction" if EX900B1 == " house painter" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == " office Manager" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == " own shop attendant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Accountant" if EX900B1 == "Accountant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Accountant" if EX900B1 == "Accounting" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "Any Jobs" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Electrician" if EX900B1 == "Audiovisual technician" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Mechanic" if EX900B1 == "Automatic" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Care" if EX900B1 == "Beauty care" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Care" if EX900B1 == "Beauty salons" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Business (chapati stall)" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Business Lady" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Business girl" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Business man" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Businesses" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "Casual work" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cleaner" if EX900B1 == "Cleaner" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cleaner" if EX900B1 == "Cleaning informal jobs" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Social Worker" if EX900B1 == "Community facilitator" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Construction" if EX900B1 == "Constraction" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cook" if EX900B1 == "Cook" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cleaner" if EX900B1 == "Domestic worker" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "Driver" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "Driving" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "Driving heavy vehicles" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Engineer" if EX900B1 == "Engineer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Engineer" if EX900B1 == "Enginer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Agricultural Work" if EX900B1 == "Farming" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sports" if EX900B1 == "Footballer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Furniture" if EX900B1 == "Furnicher" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Furniture" if EX900B1 == "Furniture" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Mechanic" if EX900B1 == "General Mechanic" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Get a capital and start my own business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Garage" if EX900B1 == "Guarge" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "ICT" if EX900B1 == "Information Technology" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "ICT" if EX900B1 == "Internet User" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "ICT" if EX900B1 == "It & computer training" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "Job Siker" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Care" if EX900B1 == "Makeup artist" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Manager" if EX900B1 == "Manager" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "Marketing and salesperson" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Mechanic" if EX900B1 == "Mechanic" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Welder" if EX900B1 == "Metal Wood" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "Not Currently employed" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Nurse" if EX900B1 == "Nurse" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Own business in clothing" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Photography" if EX900B1 == "Photography" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Private business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Secretary" if EX900B1 == "Receptionist" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Restaurant owner" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Retail" if EX900B1 == "Retailer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Retail" if EX900B1 == "Salaried employee" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "Sales" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "Sales Personnel" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "Sales person" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Secretary" if EX900B1 == "Secretarial" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Secretary" if EX900B1 == "Secretarial services" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "Selling" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Selling Clothes" if EX900B1 == "Selling clothes" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "Shop keeper" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Tailor" if EX900B1 == "Tailor" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Teacher" if EX900B1 == "Teacher" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Teacher" if EX900B1 == "Teaching" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "Waiter" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Accountant" if EX900B1 == "accounting" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Accountant" if EX900B1 == "acunatant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "any as long as it gives her money" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "any available job" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "anything" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "anything related to IT" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Mechanic" if EX900B1 == "auto mechanic" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Baker" if EX900B1 == "baking and confectionary" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Barber" if EX900B1 == "barbing saloon" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "bazaar clothe owner" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Beauty" if EX900B1 == "beautiful salon owner" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Beauty" if EX900B1 == "beauty salon" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Construction" if EX900B1 == "build and construction" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "business manager" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "business specifically boutique" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "business woman" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "casaul labourer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "casual labor" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "casual laborer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cook" if EX900B1 == "chef" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Education" if EX900B1 == "child care" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Construction" if EX900B1 == "ciramic production" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Engineer" if EX900B1 == "civil engineer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Engineer" if EX900B1 == "civil enginering" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cleaner" if EX900B1 == "cleaner and care children" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cleaner" if EX900B1 == "cleaners" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cleaner" if EX900B1 == "cleaninig" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "ICT" if EX900B1 == "computer skills" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cook" if EX900B1 == "cook for companies" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Care" if EX900B1 == "cosmetic shop" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Counsellor" if EX900B1 == "counselling postion" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Counsellor" if EX900B1 == "counsellor" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "daily Laborers" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "ICT" if EX900B1 == "database/ network administrator" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Design" if EX900B1 == "decorations" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Design" if EX900B1 == "designer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "electronic shop attendant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Engineer" if EX900B1 == "engineering" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Agricultural Work" if EX900B1 == "farming" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Agricultural Work" if EX900B1 == "farming on land" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Design" if EX900B1 == "fashion and design" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Finance" if EX900B1 == "finance assistant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Service Station" if EX900B1 == "fuel pump attending" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Secretary" if EX900B1 == "guard" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "hair dressing business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Tourism" if EX900B1 == "hotel received" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "HR" if EX900B1 == "human resource management" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Translation " if EX900B1 == "interpreter / translator" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Jewelery" if EX900B1 == "jewelry business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Jewelery" if EX900B1 == "jewelry shop" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Laundry" if EX900B1 == "laundry lady" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Logistics" if EX900B1 == "logistics" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Fashion" if EX900B1 == "make up and fashion" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "making and selling chips" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "making and selling snacks" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Manual Labor" if EX900B1 == "manual labour" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Mechanic" if EX900B1 == "mechanic" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Mechanic" if EX900B1 == "mekanicale" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Welder" if EX900B1 == "metal work" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "no currently employed" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "no job" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "none" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "own business outside agriculture" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "own business outside of agriculture" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "own bussiness cosmetics" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "own private studing religion" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "owner business outsid of agriculture" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "owning retail shop" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Agricultural Work" if EX900B1 == "peasant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Pharmacy" if EX900B1 == "pharmacist" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Photography" if EX900B1 == "photography" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Plumber" if EX900B1 == "plumber" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Food" if EX900B1 == "private milk industry" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Secretary" if EX900B1 == "receptionist" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "restaurant business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cook" if EX900B1 == "restaurant cook" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "restaurant worker" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Any Job" if EX900B1 == "salary type" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "sales and marketing" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "salesperson" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "saloon" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Security" if EX900B1 == "security Guard" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Security" if EX900B1 == "security guards" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Security" if EX900B1 == "security,tibeka" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "seeking office work" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Pet Shop" if EX900B1 == "sell animal" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "seller/shiach lay mesrat" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "selling" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Pet Sho" if EX900B1 == "selling chat" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "selling clothes, and shoes" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "selling containers" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Sales" if EX900B1 == "selling for charcoal" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Student" if EX900B1 == "she's a student" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "shop attending" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "shop keeper" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "shopkeeper" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Social Work" if EX900B1 == "social worker" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "ICT" if EX900B1 == "software development" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Engineer" if EX900B1 == "sound engineer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "starting a hair dressing business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "starting a restaurant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "stop attendant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Student" if EX900B1 == "student" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "supermarket attendant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Tailor" if EX900B1 == "tailor" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Teacher" if EX900B1 == "teacher" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trade" if EX900B1 == "trading" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "un employed at home chaild care" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Agricultural Work" if EX900B1 == "vegetable house" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Agricultural Work" if EX900B1 == "vegetables selling" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Veterinary" if EX900B1 == "veternary" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "waitressing in a restuarant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "want to start glossary retail business" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Tailor" if EX900B1 == "wants to go for tailoring" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Wholesale" if EX900B1 == "whole sale foods" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Wholesale" if EX900B1 == "wholesale distributors" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Manual Labor" if EX900B1 == "work at petro station" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Carpenter" if EX900B1 == "working as acapenter" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "working as awaiter in a restaurant" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Baker" if EX900B1 == "working in bakery" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Waiter" if EX900B1 == "working in saloon" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Service" if EX900B1 == "any thing to do with tailoring, waitressing etc" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Student" if EX900B1 == "arday" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Construction" if EX900B1 == "dhismaha guryaha ayuuraadinhayay" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Barber" if EX900B1 == "tsegur qorach/ barberry" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Midwife" if EX900B1 == "midwifery" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Shopkeeper" if EX900B1 == "nigid supermarket" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "driving tuk tuk and delivery van" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "Ye tsegur sra" & exp_diff_occup == 0 & employed == 0
replace unmployed_title = "Restaurant" if EX900B1 == "mehrad" & exp_diff_occup == 0 & employed == 0
replace unmployed_title = "Restaurant" if EX900B1 == " mehrad" & exp_diff_occup == 0 & employed == 0
replace unmployed_title = "Cleaner" if EX900B1 == "ye tsidat sira begegn lemesrat yichilalu" & exp_diff_occup ==  0 & employed == 0
replace unmployed_title = "Cleaner" if EX900B1 == "Ye tsedat Serategna" & exp_diff_occup ==  0 & employed == 0
replace unmployed_title = "Unemployed" if EX900B1 == "shaqa mahaysto laakin waxan ku fiicnaan lahaa ganacsiga" & exp_diff_occup ==  0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "ye ken sira" & exp_diff_occup ==  0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "shufar" & exp_diff_occup ==  0 & employed == 0 
replace unmployed_title = "Cleaner" if EX900B1 == "sedat sera" & exp_diff_occup ==  0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "yeshufer redat" & exp_diff_occup ==  0 & employed == 0 
replace unmployed_title = "Daily Worker" if EX900B1 == "yeken sera electric tegena" & exp_diff_occup ==  0 & employed == 0 
replace unmployed_title = "Engineer" if EX900B1 == "enjera megager" & exp_diff_occup ==  0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "shufer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "shufrena" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Unemployed" if EX900B1 == "shaqo la,aan guri joogto" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "yegil bussines" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "shofer" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Trading" if EX900B1 == "ye gel negede" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Driver" if EX900B1 == "Shufurna" & exp_diff_occup == 0 & employed == 0
replace unmployed_title = "Driver" if EX900B1 == "shufar" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Butcher" if EX900B1 == "Ye wondoch Tsegri Beat" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Selling Clothes" if EX900B1 == "Libs mateb" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Selling Clothes" if EX900B1 == "sew bet libs mateb" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "yetsegur sira" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Restaurant" if EX900B1 == "mehrad ama dukan" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Hair Dresser" if EX900B1 == "ye tsegir sra" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Cook" if EX900B1 == "Ye megibe zegijet" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "dukaan raashin" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "megibe mabesel" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Ye megibe zegijet" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "bakhaar rasshin" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Business" if EX900B1 == "Migebe mabesel sera" & exp_diff_occup == 0 & employed == 0 
replace unmployed_title = "Counseling" if unmployed_title == "Counsellor"  & employed == 0 
replace unmployed_title = "Daily Worker" if unmployed_title == "Daily laborer"   & employed == 0 
replace unmployed_title = "Business" if unmployed_title == "Electronic Shop"  & employed == 0 
replace unmployed_title = "Agricultural Work" if unmployed_title == "Farming"   & employed == 0 
replace unmployed_title = "Garage" if unmployed_title == "Garage worker"  & employed == 0 
replace unmployed_title = "Pet Shop" if unmployed_title == "Pet Sho"   & employed == 0 
replace unmployed_title = "Services broadly" if unmployed_title == "Service" & employed == 0 
replace unmployed_title = "Social Work" if unmployed_title == "Social Worker" & employed == 0 
replace unmployed_title = "Translation" if unmployed_title == "Translation " & employed == 0 

*sort EX900B1
tab EX900B1 if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 , m 
*49 missing - in a language i can't translate ! 
*br * if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 
*br MB706 if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 

tab MB703 if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 , m 
tab MB704 if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 , m 
tab MB705 if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 , m 
tab MB706 if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 , m 

lab list MB706
*Small shop
replace unmployed_title = "Business" if MB706 == 23 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
*Bicycle mechanic
replace unmployed_title = "Mechanic" if MB706 == 85 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
*Teacher/School (elementary, secondary school, religious)
replace unmployed_title = "Teacher" if MB706 == 141 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)

lab list BK526 
tab BK526 employed , m
tab BK526 if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 , m 

replace unmployed_title = "Business" if BK526 == 1 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Cook" if BK526 == 2 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Beauty" if BK526 == 3 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Driver" if BK526 == 4 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Tailor" if BK526 == 5 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Construction" if BK526 == 6 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Cleaner" if BK526 == 7 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Carpenter" if BK526 == 12 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Mechanic" if BK526 == 13 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Photography" if BK526 == 24 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Agricultural Work" if BK526 == 25 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)
replace unmployed_title = "Unemployed" if BK526 == 28 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)

tab BK526O if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 , m 
tab LM610 if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 , m 
lab list LM610

replace unmployed_title = "Daily Worker" if LM610 == 2 & exp_diff_occup == 0 & employed == 0 & mi(unmployed_title)

tab EX900B1 if mi(unmployed_title) & exp_diff_occup == 0 & employed == 0 , m 
*2 missing 


*4) Flag unrealistic occupations for SO-vignette

/* 
 [She/He] has been working as a [OCCUPATION O: Same occupation as 
 respondent/ different occupation] for a long time so [she/he] has 
 a lot of experience in [her/ his] occupation. 
*/

gen 	flag_unemp_wrong = 1 if EX900B1 == "Any job" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "Anything" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "Causal Labourer" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "Daily Labourer" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "Daily Labourers" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "Daily labores" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "Daily labourer" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "Counseling" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "Enemployment" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "Get a capital and start a business" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "any Job that gives him money" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "any" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "any good job" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "any goood job" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "any job" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "any manual work" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "any work" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "business like a shop" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "capital- start up own business" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "casual laborer" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "casual labourer" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "daily casual labor" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "daily causal labourer" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "daily laborer" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "daily laborers" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "daily labourer" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "digging for money" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "she wants a spare shop" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "she wants to work as a cleaner" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "no occupation" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "not currently" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "not employed" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "not given" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "not job" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "the house wife" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "to open any kind of business" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "to start his own nyama choma business" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "unemployed" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "unemployed but looking for a job" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "wage employment on salaried work" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "wants to be employed and they pay him per month" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "wishes to startup abotique" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "work daily laborers" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "general labourer" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "salaried employee" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "seeking for shop attendant job" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if unmployed_title == "Student" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if unmployed_title == "Unemployed" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if unmployed_title == "Any Job" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "internet bete meserat eflegalhu" & exp_diff_occup == 1
replace flag_unemp_wrong = 1 if EX900B1 == "yegel megebe bet mekifete" & exp_diff_occup == 1

tab flag_unemp_wrong
distinct EX900B1 if exp_diff_occup == 1
*336 statements
*130 clearly wrong 
*30%
lab var flag_unemp_wrong "Flag Unemployed Jobs: Sensless"
lab var unmployed_title "Unemployment Title Cleaned"


*5) Generate groups for unmployed_title

generate unmployed_industry = "Farming/animal husbandry" if ///
    unmployed_title == "Agricultural Work" | ///
    unmployed_title == "Agriculture" | ///
    unmployed_title == "Animal Trade" | ///
	unmployed_title == "Livestock"

replace unmployed_industry = "Trade" if ///
    unmployed_title == "Retail" | ///
    unmployed_title == "Sales" | ///
    unmployed_title == "Shopkeeper" | ///
    unmployed_title == "Trading" | ///
    unmployed_title == "Wholesale" | ///
	unmployed_title == "Cashier" | ///
	unmployed_title == "Jewelery" | /// * shop
	unmployed_title == "Logistics" | ///
	unmployed_title == "Pet Shop" | ///
    unmployed_title == "Clothing Store" | ///
    unmployed_title == "Selling Clothes" | ///
	unmployed_title == "Trade"

replace unmployed_industry = "Food-related business" if ///
    unmployed_title == "Butcher" | ///
    unmployed_title == "Cook" | ///
    unmployed_title == "Cooking/catering" | ///
    unmployed_title == "Waiter" | ///
	unmployed_title == "Baker" | ///
	unmployed_title == "Catering" | ///
	unmployed_title == "Food" | ///
	unmployed_title == "Restaurant"

replace unmployed_industry = "Beauty care" if ///
    unmployed_title == "Barber" | ///
    unmployed_title == "Beauty" | ///
    unmployed_title == "Beauty/Hair services" | ///
    unmployed_title == "Care" | ///
    unmployed_title == "Fashion" | ///
    unmployed_title == "Hair Dresser" | ///
	unmployed_title == "Stylist"

replace unmployed_industry = "Entertainment" if ///
    unmployed_title == "Film/Photography" | ///
    unmployed_title == "Videography" | ///
	unmployed_title == "Photography" | ///
	unmployed_title == "Sports" | ///
	unmployed_title == "Kiter"

replace unmployed_industry = "Clothing" if ///
    unmployed_title == "Tailor" | ///
    unmployed_title == "Tailoring"
 
replace unmployed_industry = "Manual works" if ///
    unmployed_title == "Construction" | ///
    unmployed_title == "Construction work" | ///
	unmployed_title == "Security" | ///
    unmployed_title == "Security services" | ///
	unmployed_title == "Laundry" | ///
	unmployed_title == "Manual" | ///
	unmployed_title == "Manual Labor" | ///
	unmployed_title == "Cleaner" | ///
    unmployed_title == "Cleaning" | ///
    unmployed_title == "Minning" | ///
    unmployed_title == "Shoe-shining /repairing" 
   
replace unmployed_industry = "Manual technical services" if ///
    unmployed_title == "Bicycle mechanic" | ///
    unmployed_title == "Carpenter" | ///
    unmployed_title == "Craft-making" | ///
    unmployed_title == "Electrician" | ///
    unmployed_title == "Engineer" | ///
    unmployed_title == "Furniture" | ///
    unmployed_title == "Garage" | ///
    unmployed_title == "General mechanic" | ///
    unmployed_title == "Machine Operator" | ///
    unmployed_title == "Oil Company" | ///
    unmployed_title == "Service Station" | ///
	unmployed_title == "Blacksmith" | ///
	unmployed_title == "Craft Making" | ///
	unmployed_title == "Mechanic" | ///
    unmployed_title == "Motorcycle mechanic" | ///
    unmployed_title == "Plumber" | ///
    unmployed_title == "Printing work" | ///
	unmployed_title == "Auto mechanic" | ///
	unmployed_title == "Welder"  | ///
	unmployed_title == "Welding"

replace unmployed_industry = "Communications/ IT/ Computer" if ///
    unmployed_title == "ICT" | ///
    unmployed_title == "IT and computer training (MS Office, programming, etc)" | ///
	unmployed_title == "Graphic design" | ///
	unmployed_title == "Hardware" | ///
	unmployed_title == "Photoshop editor"

replace unmployed_industry = "Finance" if ///
    unmployed_title == "Accountant" | ///
	unmployed_title == "Banker" | ///
	unmployed_title == "Finance"

replace unmployed_industry = "Transportation" if ///
    unmployed_title == "Driver" | ///
    unmployed_title == "Driving" | ///
	unmployed_title == "Transportion"

replace unmployed_industry = "Accommodation" if ///
    unmployed_title == "Travel agency" | ///
	unmployed_title == "Tourism"

replace unmployed_industry = "Education Sector" if ///
    unmployed_title == "Education Sector" | ///
    unmployed_title == "Education/teaching" | ///
    unmployed_title == "Teacher" | ///
	unmployed_title == "Education"

replace unmployed_industry = "Health Sector" if ///
    unmployed_title == "Midwife" | ///
    unmployed_title == "Nurse" | ///
    unmployed_title == "Nurse/Social assistance/First-Aid" | ///
    unmployed_title == "Pharmacy" | ///
	unmployed_title == "Doctor" | ///
	unmployed_title == "Health" | ///
	unmployed_title == "Veterinary"

replace unmployed_industry = "High-skilled office work" if ///
    unmployed_title == "Business" | ///
    unmployed_title == "Business/ management/ entrepreneurship" | ///
    unmployed_title == "Counselling & Peace-building" | ///
    unmployed_title == "HR" | ///
    unmployed_title == "Language (e.g. English, Kiswahili, French, Luganda, etc)" | ///
    unmployed_title == "Manager" | ///
    unmployed_title == "Secretary" | ///
    unmployed_title == "Supervisor" | ///
    unmployed_title == "Translation" | ///
	unmployed_title == "Counseling" | ///
	unmployed_title == "Design" | ///
	unmployed_title == "Typist" | ///
	unmployed_title == "Messenger in an office"

replace unmployed_industry = "Public Sector" if ///
    unmployed_title == "Community jobs" | ///
    unmployed_title == "Local public office" | ///
	unmployed_title == "Social Work" | ///
	unmployed_title == "Civil Servant" | ///
	unmployed_title == "Humanitarian"

replace unmployed_industry = "Other" if ///
    unmployed_title == "Any Job" | ///
    unmployed_title == "Daily Worker" | ///
    unmployed_title == "Housewife" | ///
    unmployed_title == "Self Employment" | ///
    unmployed_title == "Student" | ///
    unmployed_title == "Unemployed" | ///
	unmployed_title == "Services broadly"

replace unmployed_industry = "1" if unmployed_industry == "Farming/animal husbandry"
replace unmployed_industry = "2" if unmployed_industry == "Trade"
replace unmployed_industry = "3" if unmployed_industry == "Food-related business"
replace unmployed_industry = "4" if unmployed_industry == "Beauty care"
replace unmployed_industry = "5" if unmployed_industry == "Entertainment"
replace unmployed_industry = "6" if unmployed_industry == "Clothing"
replace unmployed_industry = "7" if unmployed_industry == "Manual works"
replace unmployed_industry = "8" if unmployed_industry == "Manual technical services" 
replace unmployed_industry = "9" if unmployed_industry == "Communications/ IT/ Computer"
replace unmployed_industry = "10" if unmployed_industry == "Finance"
replace unmployed_industry = "12" if unmployed_industry == "Transportation"
replace unmployed_industry = "13" if unmployed_industry == "Accommodation" 
replace unmployed_industry = "14" if unmployed_industry == "Education Sector"
replace unmployed_industry = "15" if unmployed_industry == "Health Sector"
replace unmployed_industry = "16" if unmployed_industry == "High-skilled office work"
replace unmployed_industry = "17" if unmployed_industry == "Public Sector" 
replace unmployed_industry = "18" if unmployed_industry == "Religious services" 
replace unmployed_industry = "19" if unmployed_industry == "Other" 

tab unmployed_industry
label variable unmployed_industry "Preferred industry, based on EX900B1 (unemployed)"

*6) Alternative: Rely on skills of unemployed, and use "preferred occupation" as second choice

tab BK526
decode BK526, gen(BK526_string) maxlength(20)

tab BK526_string

gen unmployed_skills = "1" if employed==0 & BK526_string=="Agriculture"
replace unmployed_skills = "3" if employed==0 & BK526_string=="Cooking/catering"
replace unmployed_skills = "4" if employed==0 & BK526_string=="Beauty/Hair services"
replace unmployed_skills = "5" if employed==0 & BK526_string=="Film/Photography"
replace unmployed_skills = "6" if employed==0 & BK526_string=="Tailoring"
replace unmployed_skills = "7" if employed==0 & (BK526_string=="Cleaning" ///
												| BK526_string=="Construction work" ///
												| BK526_string=="Security services" ///
												| BK526_string=="Shoe-shining /repair")
replace unmployed_skills = "8" if employed==0 & (BK526_string=="Auto mechanic" ///
												| BK526_string=="Bicycle mechanic" ///
												| BK526_string=="Carpenter" ///
												| BK526_string=="Craft-making" ///
												| BK526_string=="Electrician" ///
												| BK526_string=="General mechanic" ///
												| BK526_string=="Motorcycle mechanic" ///
												| BK526_string=="Plumber")
replace unmployed_skills = "9" if employed==0 & BK526_string=="IT and computer trai"
replace unmployed_skills = "12" if employed==0 & BK526_string=="Driving"
replace unmployed_skills = "13" if employed==0 & BK526_string=="Travel agency"
replace unmployed_skills = "14" if employed==0 & BK526_string=="Education/teaching"
replace unmployed_skills = "15" if employed==0 & (BK526_string=="Nurse/Social assista" ///
												| BK526_string=="Pharmacy")
replace unmployed_skills = "16" if employed==0 & BK526_string=="Counselling & Peace-"
replace unmployed_skills = "19" if employed==0 & BK526_string=="Other"
replace unmployed_skills = unmployed_industry if employed==0 & unmployed_industry!="" & ///
												(BK526_string=="Business/ management" ///
												| BK526_string=="Language (e.g. Engli" ///
												| BK526_string=="None" ///
												| BK526_string=="Other") 
*Category too broad -> rely on unmployed_industry to have a feeling of the type of business the individual dreams of

label variable unmployed_skills "Actual skills, based on 526 & EX900B1 if unclear (unemployed)"
tab unmployed_skills
tab unmployed_industry


*************
**** MERGE OWN OCCUPATION AND UNEMPLOYED OCCUPATION IN ONE SINGLE VARIABLE 
*************

bys employed: tab unmployed_title , m // raw title
bys employed: tab unmployed_industry , m // preferred industry (experiment)
bys employed: tab unmployed_title , m // skills for industry

bys employed: tab own_occupation , m

*decode own_occupation, gen (own_occupation_str)
destring unmployed_skills, replace
destring unmployed_industry, replace

label values unmployed_industry occup_lab
label values unmployed_skills occup_lab

***
* DATA GENERATION BASED ON PREFERRED OCCUP OR SKILLS?
***

gen cleaned_occupations = own_occupation if employed==1
replace cleaned_occupations = unmployed_skills if employed==0
*replace cleaned_occupations = unmployed_industry if employed==0

tab cleaned_occupations
lab var cleaned_occupations "Occupation title cleaned"

 
*****************************
*DIFFERENT OCCUPATION: TITLE*
*****************************

** CLEAN OCCUPATION FOR THE GROUP OF DIFFERENT OCCUPATIONS 

tab EX900B2, m //Text of different occupation
tab EX900B2 if exp_diff_occup == 1 & !mi(unmployed_title), m //Text of different occupation

codebook EX900B2
gen 	exp_occup_DO = "Architect" if EX900B2 == "Architect"
replace exp_occup_DO = "Banker" if EX900B2 == "Banker"
replace exp_occup_DO = "Cleaner" if EX900B2 == "Cleaner"
replace exp_occup_DO = "Doctor" if EX900B2 == "Doctor"
replace exp_occup_DO = "Farmer" if EX900B2 == "Farmer"
replace exp_occup_DO = "Lawyer" if EX900B2 == "Lawyer"
replace exp_occup_DO = "Security officer" if EX900B2 == "Security officer"
replace exp_occup_DO = "Shopkeeper" if EX900B2 == "Shopkeeper"
replace exp_occup_DO = "Teacher" if EX900B2 == "Teacher"
replace exp_occup_DO = "Waiter" if EX900B2 == "Waiter"
replace exp_occup_DO = "Security officer" if EX900B2 == "ሓላፊ ጸጥታ"
replace exp_occup_DO = "Farmer" if EX900B2 == "ሓረስታይ"
replace exp_occup_DO = "Teacher" if EX900B2 == "መምህር"
replace exp_occup_DO = "Banker" if EX900B2 == "ሰራሕተኛ ባንክ"
replace exp_occup_DO = "Security officer" if EX900B2 == "ሱቅ ጠባቂ"
replace exp_occup_DO = "Architect" if EX900B2 == "ነዳፊ"
replace exp_occup_DO = "Cleaner" if EX900B2 == "ናይ ጽርየት ስራህ"
replace exp_occup_DO = "Architect" if EX900B2 == "አርክቴክት"
replace exp_occup_DO = "Caretaker" if EX900B2 == "አስተናጋጅ"
replace exp_occup_DO = "Waiter" if EX900B2 == "ኣሳላፊ"
replace exp_occup_DO = "Shopkeeper" if EX900B2 == "ወናኒ ድኳን"
replace exp_occup_DO = "Banker" if EX900B2 == "የባንክ ሰራተኛ"
replace exp_occup_DO = "Security officer" if EX900B2 == "የጥበቃ ሰራተኛ"
replace exp_occup_DO = "Cleaner" if EX900B2 == "የጽዳት ሰራተኛ"
replace exp_occup_DO = "Doctor" if EX900B2 == "ዶክተር"
replace exp_occup_DO = "Doctor" if EX900B2 == "ዶክተር/ሃኪም"
replace exp_occup_DO = "Farmer" if EX900B2 == "ገበሬ"
replace exp_occup_DO = "Lawyer" if EX900B2 == "ጠበቃ"
replace exp_occup_DO = "Lawyer" if EX900B2 == "ጠበቓ"
lab var exp_occup_DO "EXP: Different Occupation Job Title"
mdesc exp_occup_DO


tab EX900B1 if mi(exp_occup_DO) 

bys employed: tab exp_occup_DO if exp_same_occup == 0 & EX900D, m   

* * * GROUPS WITH SAME OCCUPATIONS SHOULD NOT HAVE ANSWERED THIS Q * * *

tab exp_occup_DO if exp_same_occup == 1, m 
*This is the case so we are good

********
*SKILLS*
********

*Education degree required?
tab EX900B3 if exp_same_occup == 0
tab EX900B3 if exp_same_occup == 1

gen 	  exp_HS_DO = 1 if EX900B3 == 1 
replace exp_HS_DO = 0 if EX900B3 == 2
lab var exp_HS_DO "Given different occupation group, is the profession HIGH SKILL"
lab def exp_HS_DO 0 "DO: Low Skill" 1 "DO: High Skill", modify 
lab val exp_HS_DO exp_HS_DO 
tab exp_HS_DO
tab exp_occup_DO exp_HS_DO

****************************
**** CONTACT HYPOTHESIS ****
****************************

*In the past 30 days, how many times did you use a mobile phone to contact someone…
lab list NW811A
*0 No Calls
*98 Don t know 
*99 Refusal
*…from the [Ugandan/Ethiopian] community?
tab NW811A if refugee == 1, m //Refugees made calls to hosts
*…from a refugee community in [Uganda/Ethiopia]?
tab NW811B if refugee == 0, m //Host made calls to refugees

gen 	phone_contact =  NW811A if refugee == 1 
replace phone_contact =  NW811B if refugee == 0 & mi(phone_contact)
tab phone_contact  
lab var phone_contact "Phone call to outgroup member"
bys refugee: tab phone_contact [aw=w]

gen 	bi_phone_contact = 0 if phone_contact == 0 
lab def bi_phone_contact 0 "Zero Contact" 1 "At least one", modify
lab val bi_phone_contact bi_phone_contact 
lab var bi_phone_contact "At least one contact with outgroup"
tab bi_phone_contact, m 

bys refugee: tab bi_phone_contact, m 

** WAGE WORKER 
*What is the nationality of your employers (the business owners or the households)?
*628
bys refugee country:  tab LM628 
codebook country // 1 Ethiopia 2 Uganda
lab list LM628 //Employer Nationality
*1 Ugandan
*7 Ethiopian

//Country Uganda(1)/Ethiopia(2): Refugee's (1) Employer is Ugandan(1)/Ethiopian(7) host 
tab LM628 if refugee == 1 & (country == 2 | country == 1)
gen 	employer_outgroup = 1 if LM628 == 1 & refugee == 1 & country == 2 
replace employer_outgroup = 1 if LM628 == 7 & refugee == 1 & country == 1 & mi(employer_outgroup)
//Country Uganda (2): Host's (0) Employer is Refugee (1)
tab LM628 if LM628 != 1 & refugee == 0 & country == 2 
replace employer_outgroup = 1 if LM628 != 1  & !mi(LM628) & refugee == 0 & country == 2  & mi(employer_outgroup)
//Country Ethiopia (1): Host's (0) Employer is Refugee (1)
tab LM628 if LM628 != 7 & refugee == 0 & country == 1   
replace employer_outgroup = 1 if LM628 != 7 & !mi(LM628) & refugee == 0 & country == 1  & mi(employer_outgroup)
tab employer_outgroup
lab var employer_outgroup "Employer is Outgroup"
bys refugee: tab employer_outgroup [aw=w]

*631
*Approximately, what is the composition of nationalities at your work place?	All [Ugandan/Ethiopian] nationals
*Mostly [Ugandan/Ethiopian] nationals, some refugees
*Mostly refugees, some nationals
*All refugees
*Other nationalities
bys refugee: tab LM631 [aw=w]

** SELF EMPLOYED
*644
*What nationality does the co-owner(s) of the business have?	Ugandan
bys refugee country: tab LM644 [aw=w]
lab list LM644
tab LM644 if refugee == 1 & (country == 2 | country == 1)
gen 	coowner_outgroup = 1 if LM644 == 1 & refugee == 1 & country == 2 
replace coowner_outgroup = 1 if LM644 == 7 & refugee == 1 & country == 1 & mi(coowner_outgroup)
replace coowner_outgroup = 1 if LM644 != 1 & !mi(LM644) & refugee == 0 & country == 2  & mi(coowner_outgroup)
replace coowner_outgroup = 1 if LM644 != 7 & !mi(LM644) & refugee == 0 & country == 1  & mi(coowner_outgroup)
tab coowner_outgroup
lab var coowner_outgroup "Co-Owner Business Outgroup"
bys refugee: tab coowner_outgroup [aw=w]

*667
*Does the business hire employees besides your household members?	Yes
*No	1
*2

*668
*How many workers does the business employ besides your household members?	|___|___|___|in Number	1-997

*669
tab LM669B //Ugandan
tab LM669F //Ethiopian
bys refugee country: tab LM669B [aw=w]
bys refugee country: tab LM669F [aw=w]
gen 	colleague_outgroup = 1 if LM669B > 0 & !mi(LM669B) & refugee == 1 
replace colleague_outgroup = 1 if LM669F > 0 & !mi(LM669F) & refugee == 1 & mi(colleague_outgroup)
replace colleague_outgroup = 1 if LM669C > 0 & !mi(LM669C) & refugee == 0 & mi(colleague_outgroup) 
replace colleague_outgroup = 1 if LM669C > 0 & !mi(LM669D) & refugee == 0 & mi(colleague_outgroup) 
replace colleague_outgroup = 1 if LM669C > 0 & !mi(LM669E) & refugee == 0 & mi(colleague_outgroup) 
replace colleague_outgroup = 1 if LM669C > 0 & !mi(LM669G) & refugee == 0 & mi(colleague_outgroup) 
replace colleague_outgroup = 1 if LM669C > 0 & !mi(LM669H) & refugee == 0 & mi(colleague_outgroup) 
replace colleague_outgroup = 1 if LM669C > 0 & !mi(LM669I) & refugee == 0 & mi(colleague_outgroup) 
lab var colleague_outgroup "Employed in Business Outgroup"
bys refugee: tab colleague_outgroup

*AGRICULTURAL ACTIVITIES
*688
*Does the farm currently hire workers on a longer-term basis? That is to say workers with tasks carried out with longer term engagement on the farm.	Yes
*No
*689
*How many workers do you currently employ on a longer-term basis?	|___|___| in Number
*690
tab LM690B //Ugandan
tab LM690F //Ethiopian
bys refugee country: tab LM690B [aw=w]
bys refugee country: tab LM690F [aw=w]
gen 	farm_outgroup = 1 if LM690B > 0 & !mi(LM690B) & refugee == 1 
replace farm_outgroup = 1 if LM690F > 0 & !mi(LM690F) & refugee == 1 & mi(farm_outgroup)
replace farm_outgroup = 1 if LM690C > 0 & !mi(LM690C) & refugee == 0 & mi(farm_outgroup) 
replace farm_outgroup = 1 if LM690C > 0 & !mi(LM690D) & refugee == 0 & mi(farm_outgroup) 
replace farm_outgroup = 1 if LM690C > 0 & !mi(LM690E) & refugee == 0 & mi(farm_outgroup) 
replace farm_outgroup = 1 if LM690C > 0 & !mi(LM690G) & refugee == 0 & mi(farm_outgroup) 
replace farm_outgroup = 1 if LM690C > 0 & !mi(LM690H) & refugee == 0 & mi(farm_outgroup) 
replace farm_outgroup = 1 if LM690C > 0 & !mi(LM690I) & refugee == 0 & mi(farm_outgroup) 
lab var farm_outgroup "Hire Worker Farm Outgroup"
bys refugee: tab farm_outgroup


*********************
**** INTEGRQTION ****
*********************

*1007
*I will now read out to you a few general sentences. 
*Please tell me whether you agree or disagree with the statement 
*and the extent of your agreement or disagreement.  
*A	Over the course of my life, I have had many friends who 
*are [Ugandan/Ethiopian] nationals.
tab IN1007A

*B	Over the course of my life, I have had many friends who are refugees.	Yes
tab IN1007B 

gen 	network_outgroup_neg = IN1007B if refugee == 0 
replace network_outgroup_neg = IN1007A  if refugee == 1
recode network_outgroup_neg (5=1) (4=2) (3=3) (2=4) (1=5), gen(network_outgroup)
lab var network_outgroup "Friends with Outgroup"
lab def network_outgroup 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" ///
	5 "Strongly Agree", modify
lab val network_outgroup network_outgroup
lab var network_outgroup_neg "Have had no outgroup friends"
bys refugee: tab network_outgroup [aw=w]

gen bi_network_outgroup = 1 if network_outgroup == 4 | network_outgroup == 5 
replace bi_network_outgroup = 0 if network_outgroup == 1 | ///
									network_outgroup == 2 | ///
									network_outgroup == 3 
lab def bi_network_outgroup 0 "No Outgroup Friend" 1 "Some Outgroup Friends", ///
		modify 
lab val bi_network_outgroup bi_network_outgroup 
lab var bi_network_outgroup "Have had Outgroup Friends"
bys refugee: tab bi_network_outgroup


********************************************************
*** EXTRA WEIGHTS
********************************************************

* Scale weights, so that their mean is comparable across regions
	
bys region_short qirefugee: egen sum_w_region_r = sum(w)
bys region_short qirefugee: egen mean_w_region_r = mean(w)
lab var sum_w_region_r "Sum of weights by region"
lab var mean_w_region_r "Mean of weights by region"

tab region_short mean_w_region_r if qirefugee==0
tab region_short mean_w_region_r if qirefugee==1

gen w_scaled = w/mean_w_region_r
label variable w_scaled "RSI weights, scaled to mean=1 by region and group"

bys region_short qirefugee: sum w_scaled

*Rename the sampling weights initially untransforme by SURVYE
ren w w_orig
lab var w_orig "Original Survey SAMPLING weights (untransformed)"
codebook  w_orig
*Rename the rescaled sampling weights transformed by the research tean
ren w_scaled w
codebook w 


****************
** THE GROUPS **
****************

tab exp_same_occup 
tab exp_diff_occup
tab exp_ingroup
tab exp_outgroup


/*	
          Same occupation	Different occupation
In-group	     T1	               T2
Out-group	     T3	               T4

               Same occupation	Different occupation
In/Out-group	     T1&T3	               T2&T4

               Same/Different occupation
In-group	           T1&T2	              
Out-group              T3&T4
*/


***********************
** OUTCOME VARIABLES **
***********************

/*
           1 Strongly Agree
           2 Agree
           3 Neither agree nor disagree
           4 Disagree
           5 Strongly disagree

           */

* HIGHER IS THAT THEY DO DISAGREE: SO THE LARGER THE MORE DISAGREEING
** code variables in a way that higher values mean higher prejudice/ discrimination

codebook EX901 EX902 

*[Ugandan/Ethiopian] employer should hire [Aida/Robert] as an employee
tab EX901, m 

*An employer who is a refugee should hire [Aida/Robert] as an employee
tab EX902, m 

codebook EX903 	EX903_1 EX903_2 EX903_3 EX903_4 EX903_5 EX903_6 EX903_7 ///
				EX903_8 EX903_9 EX903_10 EX903_11 EX903_12 

*What do you recommend her/him to do
codebook EX903 

*Aida/Robert should not work
tab EX903_1, m 
lab var EX903_1 "OUT: Recommend: Should not work"
*Apply to employers directly
tab EX903_2, m 
lab var EX903_2 "OUT: Recommend: Apply to employers directly"
*Place or answer job advertisements
tab EX903_3, m 
lab var EX903_3 "OUT: Recommend: Place or answer job advertisements"
*Post resume on professional/social networking sites
tab EX903_4, m 
lab var EX903_4 "OUT: Recommend: Post resume on professional/social networking sites"
*Seek help from friends and relatives
tab EX903_5, m 
lab var EX903_5 "OUT: Recommend: Seek help from friends and relatives"
*Check at factories, work sites
tab EX903_6, m 
lab var EX903_6 "OUT: Recommend: Check at factories, work sites"
*Wait on the street to be recruited
tab EX903_7, m 
lab var EX903_7 "OUT: Recommend: Wait on the street to be recruited"
*Seek financial help to start a business
tab EX903_8, m 
lab var EX903_8 "OUT: Recommend: Seek financial help to start a business"
*Contact refugee support organizations
tab EX903_9, m 
lab var EX903_9 "OUT: Recommend: Contact refugee support organizations"
*Contact refugee settlement officials
tab EX903_10, m 
lab var EX903_10 "OUT: Recommend: Contact refugee settlement officials"
*Ask for help from family or friends
tab EX903_11, m 
lab var EX903_11 "OUT: Recommend: Ask for help from family or friends"
*Other
tab EX903_12, m 
lab var EX903_12 "OUT: Recommend: Other"

codebook EX904A EX904B EX904C EX904D EX904E EX904F EX904G EX904H EX905

*I would feel comfortable when interacting with [NAME]
tab EX904A, m 
lab var EX904A "OUT: Statement: I would feel comfortable when interacting with [NAME]"
*I would get along with [NAME]
tab EX904B, m
lab var EX904B "OUT: Statement: I would get along with [NAME]"
* Someone like [AIDA/ROBERT] lives close to me
tab EX904C, m 
lab var EX904C "OUT: Statement: Someone like [NAME] lives close to me"
*Someone like [AIDA/ROBERT] can marry a family member
tab EX904D, m 
lab var EX904D "OUT: Statement: Someone like [NAME] can marry a family member"
*Someone like [AIDA/ROBERT] can work with me 
tab EX904E, m 
lab var EX904E "OUT: Statement: Someone like [NAME] can work with me "
*Someone like [AIDA/ROBERT] can becaume my supervisor
tab EX904F, m 
lab var EX904F "OUT: Statement: Someone like [NAME] can becaume my supervisor"
*I  don’t feel in competition with people like [NAME] if i would have to search for a job
tab EX904G, m 
lab var EX904G "OUT: Statement: I don’t feel in competition with people like [NAME] "
*Ultimately, I fear people like [NAME] takes away my job
tab EX904H, m
/* ANNA: I changed the label here, since agreeing means higher prejudice */

lab def agree 1 "Strongly Disagree" 2 "Disagree" 3 "Neither agree nor disagree" ///
				4 "Agree" 5 "Strongly Agree" , modify 
recode EX904H (5=1) (4=2) (3=3) (2=4) (1=5)
lab val EX904H agree
tab EX904H, m
lab var EX904H "OUT: Statement: Ultimately, I fear people like [NAME] takes away my job"

*Perception interviewer
tab EX905, m



				**********************************
				********** 9. INDEXES ************
				**********************************

** ANDERSON 2008 INDEX 

** /!\ First install the pacakge /!\ 
*ssc install swindex 
*net install swindex.pkg
*h swindex 


************************************************************
*(1) Prejudice directed towards a precise out-group member *
************************************************************

*Prejudice index concerning social interactions with Aida/ Robert
tab EX904A
tab EX904B
egen pmind_social = rmean(EX904A EX904B)
lab var pmind_social "OUT: Mean Index Prejudice on Social Interaction A/R"
tab pmind_social 

gen  	pdind_social = 0 if pmind_social <= 2 & !mi(pmind_social)
replace pdind_social = 1 if pmind_social > 2 & !mi(pmind_social)
lab def pdind_social 0 "Not Prejudicial" 1 "Prejudicial", modify
lab val pdind_social pdind_social 
lab var pdind_social "OUT: Dummy Mean Index Prejudice on Social Interaction A/R"
tab pdind_social 

swindex EX904A EX904B, generate(paind_social) 
lab var paind_social "OUT: Anderson Index Prejudice on Social Interaction A/R"


*Prejudice index concerning private interactions with Aida/ Robert
tab EX904C
tab EX904D
egen pmind_priv = rmean(EX904C EX904D)
lab var pmind_priv "OUT: Mean Index Prejucide on Private Interaction A/R"

gen 	pdind_priv = 0 if pmind_priv <= 2 & !mi(pmind_priv)
replace pdind_priv = 1 if pmind_priv > 2 & !mi(pmind_priv)
lab def pdind_priv 0 "Not Prejudicial" 1 "Prejudicial", modify
lab val pdind_priv pdind_priv 
lab var pdind_priv "OUT: Dummy Mean Index Prejudice on Private Interaction A/R"
tab pdind_priv 

swindex EX904C EX904D, generate(paind_priv) 
lab var paind_priv "OUT: Anderson Index Prejucide on Private Interaction A/R"


*Prejudice index concerning work interactions with Aida/ Robert
tab EX904E
tab EX904F
egen pmind_work = rmean(EX904E EX904F)
lab var pmind_work "OUT: Mean Index Prejudince on Work Interaction A/R"

gen 	pdind_work = 0 if pmind_work <= 2 & !mi(pmind_work)
replace pdind_work = 1 if pmind_work > 2 & !mi(pmind_work)
lab def pdind_work 0 "Not Prejudicial" 1 "Prejudicial", modify
lab val pdind_work pdind_work 
lab var pdind_work "OUT: Dummy Mean Index Prejudice on Work Interaction A/R"
tab pdind_work 

swindex EX904E EX904F, generate(paind_work) 
lab var paind_work "OUT: Anderson Index Prejudince on Work Interaction A/R"


*Labor market competition index
tab EX904G
tab EX904H
egen lab_comp_mind = rmean(EX904G EX904H)
lab var lab_comp_mind "OUT: Mean Index LM Competition A/R"

gen 	lab_comp_dind = 0 if lab_comp_mind <= 2 & !mi(lab_comp_mind)
replace lab_comp_dind = 1 if lab_comp_mind > 2 & !mi(lab_comp_mind)
lab def lab_comp_dind 0 "Not Prejudicial" 1 "Prejudicial", modify
lab val lab_comp_dind lab_comp_dind 
lab var lab_comp_dind "OUT: Dummy Mean Index LM Competition A/R"
tab lab_comp_dind 

swindex EX904G EX904H, generate(lab_comp_aind) 
lab var lab_comp_aind "OUT: Anderson Index LM Competition A/R"


***************************
* GENERAL PREJUDICE INDEX *
***************************
* over all the dimensions *
***************************

*Mean
egen 	prej_mind = rmean(EX904A EX904B EX904C EX904D EX904E EX904F)
lab var prej_mind "OUT: Mean Index Prejudice, Soc. and Priv. and Work"
su 		prej_mind, d

gen 	prej_dind = 0 if prej_mind <= 2 & !mi(prej_mind)
replace prej_dind = 1 if prej_mind > 2 & !mi(prej_mind)
lab def prej_dind 0 "Not Prejudicial" 1 "Prejudicial", modify
lab val prej_dind prej_dind 
lab var prej_dind "OUT: Dummy Mean Index Prejudice, Soc. and Priv. and Work"
tab prej_dind 

*Anderson
swindex EX904A EX904B EX904C EX904D EX904E EX904F, generate(prej_aind) 
lab var prej_aind "OUT: Anderson Index Prejudice, Soc. and Priv. and Work"


su pmind_social pmind_priv pmind_work lab_comp_mind ///
   prej_mind ///
   paind_social paind_priv paind_work lab_comp_aind ///
   prej_aind



******************************************************
*(2) Prejudice directed towards the entire out-group *
******************************************************

*Prejudice index concerning private interactions with the entire out-group
tab IN1010A 
tab IN1010C 
egen prej_mind_priv_og_r = rmean(IN1010A IN1010C) if refugee == 1
lab var prej_mind_priv_og_r "OUT: Mean Index Prejudice on Private Interaction OUT GROUP - REF"

swindex IN1010A IN1010C if refugee == 1, generate(prej_aind_priv_og_r) 
lab var prej_aind_priv_og_r "OUT: Anderson Index Prejudice on Private Interaction OUT GROUP - REF"


tab IN1010B 
tab IN1010D 
egen prej_mind_priv_og_h = rmean(IN1010B IN1010D) if refugee == 0
lab var prej_mind_priv_og_h "OUT: Mean Index Prejudice on Private Interaction OUT GROUP - HOST"

swindex IN1010B IN1010D if refugee == 0, generate(prej_aind_priv_og_h) 
lab var prej_aind_priv_og_h "OUT: Anderson Index Prejudice on Private Interaction OUT GROUP - HOST"


gen 	pmind_priv_og = prej_mind_priv_og_r 
replace pmind_priv_og = prej_mind_priv_og_h if mi(pmind_priv_og)
lab var pmind_priv_og "OUT: Mean Index Prejudice on Private Interaction OUT GROUP"


gen 	paind_priv_og = prej_aind_priv_og_r 
replace paind_priv_og = prej_aind_priv_og_h if mi(paind_priv_og)
lab var paind_priv_og "OUT: Anderson Prejudice on Private Interaction OUT GROUP"


*Prejudice index concerning work interactions with the entire out-group
tab IN1010E  
tab IN1010G  
egen prej_mind_work_og_r = rmean(IN1010E IN1010G) if refugee == 1
lab var prej_mind_work_og_r "OUT: Mean Index Prejudice on work Interaction OUT GROUP - REF"

swindex IN1010E IN1010G if refugee == 1, generate(prej_aind_work_og_r) 
lab var prej_aind_work_og_r "OUT: Anderson Index Prejudice on work Interaction OUT GROUP - REF"


tab IN1010F 
tab IN1010H  
egen prej_mind_work_og_h = rmean(IN1010F IN1010H) if refugee == 0
lab var prej_mind_work_og_h "OUT: Mean Index Prejudice on work Interaction OUT GROUP - HOST"

swindex IN1010F IN1010H if refugee == 0, generate(prej_aind_work_og_h) 
lab var prej_aind_work_og_h "OUT: Anderson Index Prejudice on work Interaction OUT GROUP - HOST"

gen 	pmind_work_og = prej_mind_work_og_r 
replace pmind_work_og = prej_mind_work_og_h if mi(pmind_work_og)
lab var pmind_work_og "OUT: Mean Index Prejudice on work Interaction OUT GROUP"

gen 	paind_work_og = prej_aind_work_og_r 
replace paind_work_og = prej_aind_work_og_h if mi(paind_work_og)
lab var paind_work_og "OUT: Anderson Prejudice on work Interaction OUT GROUP"

egen prej_mind_og_r = rmean(IN1010A IN1010C IN1010E IN1010G) if refugee == 1
lab var prej_mind_og_r "OUT: Mean Index Prejudice on Interaction OUT GROUP - REF"

swindex IN1010A IN1010C IN1010E IN1010G if refugee == 1, generate(prej_aind_og_r) 
lab var prej_aind_og_r "OUT: Anderson Index Prejudice on Interaction OUT GROUP - REF"

egen prej_mind_og_h = rmean(IN1010B IN1010D IN1010F IN1010H) if refugee == 0
lab var prej_mind_og_h "OUT: Mean Index Prejudice on Interaction OUT GROUP - HOST"

swindex IN1010B IN1010D IN1010F IN1010H if refugee == 0, generate(prej_aind_og_h) 
lab var prej_aind_og_h "OUT: Anderson Index Prejudice on Interaction OUT GROUP - HOST"

gen 	pmind_og = prej_mind_og_r 
replace pmind_og = prej_mind_og_h if mi(pmind_og)
lab var pmind_og "OUT: Mean Pooled Index Prejudice on Interaction OUT GROUP"

gen 	paind_og = prej_aind_og_r 
replace paind_og = prej_aind_og_h if mi(paind_og)
lab var paind_og "OUT: Anderson Pooled Index Prejudice on Interaction OUT GROUP"


*********************************
********* EXTRA INDICES *********
*********************************
 

/*===============================================================
			Generating the index considering refugees 
			separate from hosts in the pooled sample
=================================================================*/
*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0, generate(prej_host_pooled) 
lab var prej_host_pooled "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hosts"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1, generate(prej_refugee_pooled) 
lab var prej_refugee_pooled "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugees"

gen 	prej_aind_byR=.
replace prej_aind_byR = prej_host_pooled if refugee==0
replace prej_aind_byR = prej_refugee_pooled if refugee==1
lab var prej_aind_byR "OUT: Anderson Index Prejudice by Refugee group, Soc. and Priv. and Work "


** INDIVIDUAL OUTCOMES 

**************
*** SOCIAL ***
**************

*hosts
swindex EX904A EX904B if refugee==0, generate(prej_social_host_pooled) 
lab var prej_social_host_pooled "OUT: Anderson Index Prejudice, Social"

*refugees
swindex EX904A EX904B if refugee==1, generate(prej_social_refugee_pooled) 
lab var prej_social_refugee_pooled "OUT: Anderson Index Prejudice, Social"

gen 	paind_social_byR=.
replace paind_social_byR = prej_social_host_pooled if refugee==0
replace paind_social_byR = prej_social_refugee_pooled if refugee==1
lab var paind_social_byR "OUT: Anderson Index Prejudice by Refugee group, Social"

***************
*** PRIVATE ***
***************

*hosts
swindex EX904C EX904D if refugee==0, generate(prej_private_host_pooled) 
lab var prej_private_host_pooled "OUT: Anderson Index Prejudice, Social"

*refugees
swindex EX904C EX904D if refugee==1, generate(prej_private_refugee_pooled) 
lab var prej_private_refugee_pooled "OUT: Anderson Index Prejudice, Social"

gen 	paind_private_byR=.
replace paind_private_byR = prej_private_host_pooled if refugee==0
replace paind_private_byR = prej_private_refugee_pooled if refugee==1
lab var paind_private_byR "OUT: Anderson Index Prejudice by Refugee group, Private"

************
*** WORK ***
************

*hosts
swindex EX904E EX904F if refugee==0, generate(prej_work_host_pooled) 
lab var prej_work_host_pooled "OUT: Anderson Index Prejudice, Social"

*refugees
swindex EX904E EX904F if refugee==1, generate(prej_work_refugee_pooled) 
lab var prej_work_refugee_pooled "OUT: Anderson Index Prejudice, Social"

gen 	paind_work_byR=.
replace paind_work_byR = prej_work_host_pooled if refugee==0
replace paind_work_byR = prej_work_refugee_pooled if refugee==1
lab var paind_work_byR "OUT: Anderson Index Prejudice by Refugee group, Work"


** LABOR MARKET COMPETITION
*hosts
swindex EX904G EX904H if refugee==0, generate(prej_lmcomp_host_pooled) 
lab var prej_lmcomp_host_pooled "OUT: Anderson Index Prejudice, Social"

*refugees
swindex EX904G EX904H if refugee==1, generate(prej_lmcomp_refugee_pooled) 
lab var prej_lmcomp_refugee_pooled "OUT: Anderson Index Prejudice, Social"

gen 	paind_lmcomp_byR=.
replace paind_lmcomp_byR = prej_lmcomp_host_pooled if refugee==0
replace paind_lmcomp_byR = prej_lmcomp_refugee_pooled if refugee==1
lab var paind_lmcomp_byR "OUT: Anderson Index Labor Market Competition by Refugee group"



/*===============================================================
			Generating the index considering refugees 
			separate from hosts for the different countries 
			and different localities: BY LOCALITY
=================================================================*/

*hosts in Uganda-Kampala
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==0 & refugee==0 & region_short==3, generate(prejhostUgK) 
lab var prejhostUgK "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsUgK'la"

*hosts in Uganda-Isingiro
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==0 & refugee==0 & region_short==4, generate(prejhostUgI) 
lab var prejhostUgI "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsUgIs'giro"

*refugees in Uganda-Kampala
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==0 & refugee==1 & region_short==3, generate(prejrefugeeUgK) 
lab var prejrefugeeUgK "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesUgK'la"

*refugees in Uganda-Isingiro
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==0 & refugee==1 & region_short==4, generate(prejrefugeeUgI) 
lab var prejrefugeeUgI "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesUgIs'giro"

*hosts in Ethiopia-Addis
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==1 & refugee==0 & region_short==1, generate(prejhostETA) 
lab var prejhostETA "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsETAddis"

*hosts in Ethiopia-Jijiga
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==1 & refugee==0 & region_short==2, generate(prejhostETJ) 
lab var prejhostETJ "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsETJijiga"

*refugees in Ethiopia-Addis
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==1 & refugee==1 & region_short==1, generate(prejrefugeeETA) 
lab var prejrefugeeETA "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesETAddis"

*refugees in Ethiopia-Jijiga
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==1 & refugee==1 & region_short==2, generate(prejrefugeeETJ) 
lab var prejrefugeeETJ "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesETJijiga"

gen 	prej_aind_byL =.
replace prej_aind_byL =prejhostUgK if ethiopia==0 & refugee==0 & region_short==3
replace prej_aind_byL =prejhostUgI if ethiopia==0 & refugee==0 & region_short==4
replace prej_aind_byL =prejrefugeeUgK if ethiopia==0 & refugee==1 & region_short==3
replace prej_aind_byL =prejrefugeeUgI if ethiopia==0 & refugee==1 & region_short==4
replace prej_aind_byL =prejhostETA if ethiopia==1 & refugee==0 & region_short==1
replace prej_aind_byL =prejhostETJ if ethiopia==1 & refugee==0 & region_short==2
replace prej_aind_byL =prejrefugeeETA if ethiopia==1 & refugee==1 & region_short==1
replace prej_aind_byL =prejrefugeeETJ if ethiopia==1 & refugee==1 & region_short==2
lab var prej_aind_byL  "OUT: Anderson Index Prejudice by Locality, Soc. and Priv. and Work"


***********************************************
**** FOR LABOR MARKET COMPETITION VARIABLE ****
***********************************************

*hosts in Uganda-Kampala
swindex EX904G EX904H if ethiopia==0 & refugee==0 & region_short==3, generate(plmhostUgK) 
lab var plmhostUgK "OUT: Anderson Index Labor Market Competition _hostsUgK'la"

*hosts in Uganda-Isingiro
swindex EX904G EX904H if ethiopia==0 & refugee==0 & region_short==4, generate(plmhostUgI) 
lab var plmhostUgI "OUT: Anderson Index Labor Market Competition _hostsUgIs'giro"

*refugees in Uganda-Kampala
swindex EX904G EX904H if ethiopia==0 & refugee==1 & region_short==3, generate(plmrefugeeUgK) 
lab var plmrefugeeUgK "OUT: Anderson Index Labor Market Competition _refugeesUgK'la"

*refugees in Uganda-Isingiro
swindex EX904G EX904H if ethiopia==0 & refugee==1 & region_short==4, generate(plmrefugeeUgI) 
lab var plmrefugeeUgI "OUT: Anderson Index Labor Market Competition _refugeesUgIs'giro"

*hosts in Ethiopia-Addis
swindex EX904G EX904H if ethiopia==1 & refugee==0 & region_short==1, generate(plmhostETA) 
lab var plmhostETA "OUT: Anderson Index Labor Market Competition _hostsETAddis"

*hosts in Ethiopia-Jijiga
swindex EX904G EX904H if ethiopia==1 & refugee==0 & region_short==2, generate(plmhostETJ) 
lab var plmhostETJ "OUT: Anderson Index Labor Market Competition ETJijiga"

*refugees in Ethiopia-Addis
swindex EX904G EX904H if ethiopia==1 & refugee==1 & region_short==1, generate(plmrefugeeETA) 
lab var plmrefugeeETA "OUT: Anderson Index Labor Market Competition ETAddis"

*refugees in Ethiopia-Jijiga
swindex EX904G EX904H if ethiopia==1 & refugee==1 & region_short==2, generate(plmrefugeeETJ) 
lab var plmrefugeeETJ "OUT: Anderson Index Labor Market Competition ETJijiga"

gen 	paind_lmcomp_byL =.
replace paind_lmcomp_byL =plmhostUgK if ethiopia==0 & refugee==0 & region_short==3
replace paind_lmcomp_byL =plmhostUgI if ethiopia==0 & refugee==0 & region_short==4
replace paind_lmcomp_byL =plmrefugeeUgK if ethiopia==0 & refugee==1 & region_short==3
replace paind_lmcomp_byL =plmrefugeeUgI if ethiopia==0 & refugee==1 & region_short==4
replace paind_lmcomp_byL =plmhostETA if ethiopia==1 & refugee==0 & region_short==1
replace paind_lmcomp_byL =plmhostETJ if ethiopia==1 & refugee==0 & region_short==2
replace paind_lmcomp_byL =plmrefugeeETA if ethiopia==1 & refugee==1 & region_short==1
replace paind_lmcomp_byL =plmrefugeeETJ if ethiopia==1 & refugee==1 & region_short==2
lab var paind_lmcomp_byL  "OUT: Anderson Index Labor Market Competition by Locality"


/*===============================================================
		Generating the index considering gender of the respondents 
			separate from hosts and refugees: BY GENDER
=================================================================*/

*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & male == 0, generate(prej_hostfemale) 
lab var prej_hostfemale "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsfemale"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & male == 1, generate(prej_hostmale) 
lab var prej_hostmale "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsmale"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & male == 0, generate(prej_refugeefemale) 
lab var prej_refugeefemale "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesfemale"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & male == 1, generate(prej_refugeemale) 
lab var prej_refugeemale "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesmale"

gen 	prej_aind_byG =.
replace prej_aind_byG =prej_hostfemale if refugee==0 & male == 0
replace prej_aind_byG =prej_hostmale if refugee==0 & male == 1
replace prej_aind_byG =prej_refugeefemale if refugee==1 & male == 0
replace prej_aind_byG =prej_refugeemale if refugee==1 & male == 1
lab var prej_aind_byG  "OUT: Anderson Index Prejudice by Gender, Soc. and Priv. and Work"

/*===============================================================
		Generating the index considering gender of the respondents 
			separate from hosts and refugees: BY HOUSEHOLD HEAD
=================================================================*/

*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & hhead == 0, generate(prej_hostNHHH) 
lab var prej_hostNHHH "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsNHHH"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & hhead == 1, generate(prej_hostHHH) 
lab var prej_hostHHH "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsHHH"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & hhead == 0, generate(prej_refugeeNHHH) 
lab var prej_refugeeNHHH "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesNHHH"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & hhead == 1, generate(prej_refugeeHHH) 
lab var prej_refugeeHHH "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesHHH"

gen 	prej_aind_byHH =.
replace prej_aind_byHH =prej_hostNHHH if refugee==0 & hhead == 0
replace prej_aind_byHH =prej_hostHHH if refugee==0 & hhead == 1
replace prej_aind_byHH =prej_refugeeNHHH if refugee==1 & hhead == 0
replace prej_aind_byHH =prej_refugeeHHH if refugee==1 & hhead == 1
lab var prej_aind_byHH  "OUT: Anderson Index Prejudice by Household Head, Soc. and Priv. and Work"




/*===============================================================
		Generating the index considering educ of the respondents 
			separate from hosts and refugees: BY EDUCATION
=================================================================*/
*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & educ_primary == 0, generate(prej_hostnoprim) 
lab var prej_hostnoprim "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsnoprimary"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & educ_primary == 1, generate(prej_hostprim) 
lab var prej_hostprim "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsprimary"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & educ_primary == 0, generate(prej_refugeenoprim) 
lab var prej_refugeenoprim "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesnoprimary"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & educ_primary == 1, generate(prej_refugeeprim) 
lab var prej_refugeeprim "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesprimary"

gen prej_aind_byE =.
replace prej_aind_byE =prej_hostnoprim if refugee==0 & educ_primary == 0
replace prej_aind_byE =prej_hostprim if refugee==0 & educ_primary == 1
replace prej_aind_byE =prej_refugeenoprim if refugee==1 & educ_primary == 0
replace prej_aind_byE =prej_refugeeprim if refugee==1 & educ_primary == 1
lab var prej_aind_byE  "OUT: Anderson Index Prejudice by Education, Soc. and Priv. and Work"



/*===============================================================
		Generating the index considering network of the respondents 
			separate from hosts and refugees: BY NETWORK
=================================================================*/
*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & bi_network_outgroup == 0, generate(prej_hostnocon) 
lab var prej_hostnocon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsnocontact"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & bi_network_outgroup == 1, generate(prej_hostcon) 
lab var prej_hostcon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostscontact"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & bi_network_outgroup == 0, generate(prej_refugeenocon) 
lab var prej_refugeenocon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesnocontact"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & bi_network_outgroup == 1, generate(prej_refugeecon) 
lab var prej_refugeecon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeescontact"

gen prej_aind_byN =.
replace prej_aind_byN =prej_hostnocon if refugee==0 & bi_network_outgroup == 0
replace prej_aind_byN =prej_hostcon if refugee==0 & bi_network_outgroup == 1
replace prej_aind_byN =prej_refugeenocon if refugee==1 & bi_network_outgroup == 0
replace prej_aind_byN =prej_refugeecon if refugee==1 & bi_network_outgroup == 1
lab var prej_aind_byN  "OUT: Anderson Index Prejudice by Network, Soc. and Priv. and Work"


**# Bookmark #1
/*===============================================================
		Generating the index considering length of stay of the respondents 
			only for refugees: BY LENGTH OF STAY
=================================================================*/

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & long_stay == 0, generate(prej_refugeeshortst) 
lab var prej_refugeeshortst "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesshortstay"


swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & long_stay == 1, generate(prej_refugeelongst) 
lab var prej_refugeelongst "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeeslongstay"

gen prej_aind_byS =.
replace prej_aind_byS =prej_refugeeshortst if refugee==1 & long_stay == 0
replace prej_aind_byS =prej_refugeelongst if refugee==1 & long_stay == 1
lab var prej_aind_byS  "OUT: Anderson Index Prejudice by Length of stay, Soc. and Priv. and Work"

**# Bookmark #8

/*===============================================================
		Generating the index considering language of the respondents 
			separate from hosts and refugees: BY IN-GROUP LANGUAGE
=================================================================*/
*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & maj_lang_ig==0, generate(prej_hostnolig) 
lab var prej_hostnocon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsnolig"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & maj_lang_ig == 1, generate(prej_hostlig) 
lab var prej_hostcon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostslig"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & maj_lang_ig == 0, generate(prej_refugeenolig) 
lab var prej_refugeenocon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesnolig"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & maj_lang_ig == 1, generate(prej_refugeelig) 
lab var prej_refugeecon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeescontact"

gen prej_aind_byLIG =.
replace prej_aind_byLIG =prej_hostnolig if refugee==0 & maj_lang_ig == 0
replace prej_aind_byLIG =prej_hostlig if refugee==0 & maj_lang_ig == 1
replace prej_aind_byLIG =prej_refugeenolig if refugee==1 & maj_lang_ig == 0
replace prej_aind_byLIG =prej_refugeelig if refugee==1 & maj_lang_ig == 1
lab var prej_aind_byLIG  "OUT: Anderson Index Prejudice by In-group language, Soc. and Priv. and Work"

drop prej_hostnolig prej_hostlig prej_refugeenolig prej_refugeelig
**# Bookmark #9

/*===============================================================
		Generating the index considering language of the respondents 
			separate from hosts and refugees: BY OUT-GROUP LANGUAGE
=================================================================*/
*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & maj_lang_og==0, generate(prej_hostnolog) 
lab var prej_hostnocon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsnolog"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & maj_lang_og == 1, generate(prej_hostlog) 
lab var prej_hostcon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostslog"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & maj_lang_og == 0, generate(prej_refugeenolog) 
lab var prej_refugeenocon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesnolog"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & maj_lang_og == 1, generate(prej_refugeelog) 
lab var prej_refugeecon "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeescontact"

gen prej_aind_byLOG =.
replace prej_aind_byLOG =prej_hostnolog if refugee==0 & maj_lang_og == 0
replace prej_aind_byLOG =prej_hostlog if refugee==0 & maj_lang_og == 1
replace prej_aind_byLOG =prej_refugeenolog if refugee==1 & maj_lang_og == 0
replace prej_aind_byLOG =prej_refugeelog if refugee==1 & maj_lang_og == 1
lab var prej_aind_byLOG  "OUT: Anderson Index Prejudice by Out-group language, Soc. and Priv. and Work"

sum prej_aind_byLOG

drop prej_hostnolog prej_hostlog prej_refugeenolog prej_refugeelog

/*===============================================================
			Generating the index considering refugees 
			separate from hosts for the different countries
=================================================================*/

*hosts in Uganda
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==0 & refugee==0, generate(prejhostUg) 
lab var prejhostUg "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsUg"

*refugees in Uganda
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==0 & refugee==1, generate(prejrefugeeUg) 
lab var prejrefugeeUg "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesUg"

*hosts in Ethiopia
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==1 & refugee==0, generate(prejhostET) 
lab var prejhostET "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsET"

*refugees in Ethiopia
swindex EX904A EX904B EX904C EX904D EX904E EX904F if ethiopia==1 & refugee==1, generate(prejrefugeeET) 
lab var prejrefugeeET "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesET"

gen 	prej_aind_byC = .
replace prej_aind_byC=prejhostUg if ethiopia==0 & refugee==0
replace prej_aind_byC=prejrefugeeUg if ethiopia==0 & refugee==1
replace prej_aind_byC=prejhostET if ethiopia==1 & refugee==0
replace prej_aind_byC=prejrefugeeET if ethiopia==1 & refugee==1
lab var prej_aind_byC "OUT: Anderson Index Prejudice by Country, Soc. and Priv. and Work"




/*===============================================================
		Generating the index considering gender of the respondents 
			separate from hosts and refugees: BY URBAN
=================================================================*/

*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & urban == 0, generate(prej_hostrural) 
lab var prej_hostrural "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsrural"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & urban == 1, generate(prej_hosturban) 
lab var prej_hosturban "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostsurban"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & urban == 0, generate(prej_refugeerural) 
lab var prej_refugeerural "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesrural"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & urban == 1, generate(prej_refugeeurban) 
lab var prej_refugeeurban "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeesurban"

gen 	prej_aind_byU =.
replace prej_aind_byU =prej_hostrural if refugee==0 & urban == 0
replace prej_aind_byU =prej_hosturban if refugee==0 & urban == 1
replace prej_aind_byU =prej_refugeerural if refugee==1 & urban == 0
replace prej_aind_byU =prej_refugeeurban if refugee==1 & urban == 1
lab var prej_aind_byU  "OUT: Anderson Index Prejudice by Urban, Soc. and Priv. and Work"



*************************
** INDIVIDUAL OUTCOMES **
*************************

**************
*** SOCIAL ***
**************

*hosts in Uganda
swindex EX904A EX904B if  ethiopia==0 & refugee==0, generate(prej_social_host_byCUG) 
lab var prej_social_host_byCUG "OUT: Anderson Index Prejudice, Social"

*refugees in Uganda
swindex EX904A EX904B if ethiopia==0 &  refugee==1, generate(prej_social_refugee_byCUG) 
lab var prej_social_refugee_byCUG "OUT: Anderson Index Prejudice, Social"

*hosts in Ethiopia
swindex EX904A EX904B if  ethiopia==1 & refugee==0, generate(prej_social_host_byCET) 
lab var prej_social_host_byCET "OUT: Anderson Index Prejudice, Social"

*refugees in Ethiopia
swindex EX904A EX904B if ethiopia==1 &  refugee==1, generate(prej_social_refugee_byCET) 
lab var prej_social_refugee_byCET "OUT: Anderson Index Prejudice, Social"

gen 	paind_social_byR_byC=.
replace paind_social_byR_byC = prej_social_host_byCUG if ethiopia==0 &  refugee==0
replace paind_social_byR_byC = prej_social_refugee_byCUG if ethiopia==0 &  refugee==1
replace paind_social_byR_byC = prej_social_host_byCET if ethiopia==1 &  refugee==0
replace paind_social_byR_byC = prej_social_refugee_byCET if ethiopia==1 &  refugee==1
lab var paind_social_byR_byC "OUT: Anderson Index Prejudice by Refugee group and Country, Social"

***************
*** PRIVATE ***
***************

*hosts in Uganda
swindex EX904C EX904D if ethiopia==0 &  refugee==0, generate(prej_private_host_byCUG) 
lab var prej_private_host_byCUG "OUT: Anderson Index Prejudice, Social"

*refugees in Uganda
swindex EX904C EX904D if ethiopia==0 &  refugee==1, generate(prej_private_refugee_byCUG) 
lab var prej_private_refugee_byCUG "OUT: Anderson Index Prejudice, Social"

*hosts in Ethiopia
swindex EX904C EX904D if ethiopia==1 &  refugee==0, generate(prej_private_host_byCET) 
lab var prej_private_host_byCET "OUT: Anderson Index Prejudice, Social"

*refugees in Ethiopia
swindex EX904C EX904D if ethiopia==1 &  refugee==1, generate(prej_private_refugee_byCET) 
lab var prej_private_refugee_byCET "OUT: Anderson Index Prejudice, Social"

gen 	paind_private_byR_byC=.
replace paind_private_byR_byC = prej_private_host_byCUG if ethiopia==0 &  refugee==0
replace paind_private_byR_byC = prej_private_refugee_byCUG if ethiopia==0 &  refugee==1
replace paind_private_byR_byC = prej_private_host_byCET if  ethiopia==1 & refugee==0
replace paind_private_byR_byC = prej_private_refugee_byCET if  ethiopia==1 & refugee==1
lab var paind_private_byR_byC "OUT: Anderson Index Prejudice by Refugee group and Country, Private"

************
*** WORK ***
************

*hosts in Uganda
swindex EX904E EX904F if ethiopia==0 &  refugee==0, generate(prej_work_host_byCUG) 
lab var prej_work_host_byCUG "OUT: Anderson Index Prejudice, Social"

*refugees in Uganda
swindex EX904E EX904F if ethiopia==0 &  refugee==1, generate(prej_work_refugee_byCUG) 
lab var prej_work_refugee_byCUG "OUT: Anderson Index Prejudice, Social"

*hosts in Ethiopia
swindex EX904E EX904F if ethiopia==1 &  refugee==0, generate(prej_work_host_byCET) 
lab var prej_work_host_byCET "OUT: Anderson Index Prejudice, Social"

*refugees in Ethiopia
swindex EX904E EX904F if ethiopia==1 &  refugee==1, generate(prej_work_refugee_byCET) 
lab var prej_work_refugee_byCET "OUT: Anderson Index Prejudice, Social"

gen 	paind_work_byR_byC=.
replace paind_work_byR_byC = prej_work_host_byCUG if  ethiopia==0 & refugee==0
replace paind_work_byR_byC = prej_work_refugee_byCUG if ethiopia==0 &  refugee==1
replace paind_work_byR_byC = prej_work_host_byCET if  ethiopia==1 & refugee==0
replace paind_work_byR_byC = prej_work_refugee_byCET if ethiopia==1 &  refugee==1
lab var paind_work_byR_byC "OUT: Anderson Index Prejudice by Refugee group and Country, Work"


******************************
** LABOR MARKET COMPETITION **
******************************

*hosts in Uganda
swindex EX904G EX904H if  ethiopia==0 & refugee==0, generate(prej_lmcomp_host_byCUG) 
lab var prej_lmcomp_host_byCUG "OUT: Anderson Index Prejudice, Social"

*refugees in Uganda
swindex EX904G EX904H if  ethiopia==0 & refugee==1, generate(prej_lmcomp_refugee_byCUG) 
lab var prej_lmcomp_refugee_byCUG "OUT: Anderson Index Prejudice, Social"

*hosts in Ethiopia
swindex EX904G EX904H if  ethiopia==1 & refugee==0, generate(prej_lmcomp_host_byCET) 
lab var prej_lmcomp_host_byCET "OUT: Anderson Index Prejudice, Social"

*refugees in Ethiopia
swindex EX904G EX904H if  ethiopia==1 & refugee==1, generate(prej_lmcomp_refugee_byCET) 
lab var prej_lmcomp_refugee_byCET  "OUT: Anderson Index Prejudice, Social"

gen 	paind_lmcomp_byR_byC=.
replace paind_lmcomp_byR_byC = prej_lmcomp_host_byCUG if  ethiopia==0 & refugee==0
replace paind_lmcomp_byR_byC = prej_lmcomp_refugee_byCUG if ethiopia==0 &  refugee==1
replace paind_lmcomp_byR_byC = prej_lmcomp_host_byCET if  ethiopia==1 & refugee==0
replace paind_lmcomp_byR_byC = prej_lmcomp_refugee_byCET if ethiopia==1 &  refugee==1
lab var paind_lmcomp_byR_byC "OUT: Anderson Index Prejudice by Refugee group and Country, Labor Market Competition"




*************
** MISSING **
*************

mdesc  ethiopia urban male age hhsize educ_primary married refugee employed

/*
    Variable    |     Missing          Total     Percent Missing
----------------+-----------------------------------------------
       ethiopia |           0          4,716           0.00
          urban |           0          4,716           0.00
           male |           0          4,716           0.00
            age |           0          4,716           0.00
         hhsize |           0          4,716           0.00
   educ_primary |          18          4,716           0.38
        married |          11          4,716           0.23
        refugee |           0          4,716           0.00
       employed |           0          4,716           0.00
----------------+-----------------------------------------------
*/

tab educ_primary
codebook educ_primary
mdesc educ_primary

tab LM621 if mi(educ_primary)
label list LM621
replace educ_primary = 1 if LM621 == 16 & mi(educ_primary) //Skilled office Work
tab LM622 if mi(educ_primary)
*br LM622 if mi(educ_primary)

codebook LM622
replace educ_primary = 0 if LM622 == "Casual labourer" & mi(educ_primary) 
replace educ_primary = 0 if LM622 == "cleaner" & mi(educ_primary) 
replace educ_primary = 0 if LM622 == "daily labor" & mi(educ_primary) 
replace educ_primary = 0 if LM622 == "playing guitar and music" & mi(educ_primary) 
replace educ_primary = 0 if LM622 == "selling clothes" & mi(educ_primary) 
replace educ_primary = 0 if LM622 == "selling coffee" & mi(educ_primary) 
replace educ_primary = 0 if LM622 == "washing and cleaning houses for the somalis" & mi(educ_primary) 

tab EX900B1 if mi(educ_primary)
codebook EX900B1
replace educ_primary = 0 if EX900B1 == "day care for children" & mi(educ_primary) 
replace educ_primary = 0 if EX900B1 == "selling coffee" & mi(educ_primary) 

tab exp_occup_DO if mi(educ_primary)
codebook exp_occup_DO
replace educ_primary = 0 if exp_occup_DO == "Cleaner" & mi(educ_primary) 
replace educ_primary = 0 if exp_occup_DO == "Farmer" & mi(educ_primary) 
replace educ_primary = 0 if exp_occup_DO == "Waiter" & mi(educ_primary) 
replace educ_primary = 1 if exp_occup_DO == "Shopkeeper" & mi(educ_primary) 

tab LM610 if mi(educ_primary)
codebook LM610
replace educ_primary = 1 if LM610 == 4 & mi(educ_primary) //Own Business out of agri

tab LM623 employed if mi(educ_primary)
codebook LM623
lab list LM623
replace educ_primary = 1 if LM623 == 101 & mi(educ_primary) //Money transfer

tab employed if mi(educ_primary)
replace educ_primary = 1 if mi(educ_primary) //Employed

mdesc educ_primary






				***********************************
				** 10: LABOR MARKET COMPETITION ***
				***********************************


/*====================================================================
          A: OVER-REPRESENTATION OF REFUGEES/ HOSTS
====================================================================*/


 **** INSPECT OCCUPATION ***
 
tab cleaned_occupations if refugee==1 [aw=w], missing
tab cleaned_occupations if refugee==0 [aw=w], missing

replace cleaned_occupations=100 if cleaned_occupations==.


preserve

collapse (sum) w, by(cleaned_occupations refugee)

bysort refugee: egen total_ind = total(w)

gen occup_share = w/total_ind

label values occup_share occup_lab 

/*
graph hbar (mean) occup_share, ///
    over(refugee) over(cleaned_occupations) asyvars  ///
    title("Industries") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal))
*/
reshape wide w total_ind occup_share, i(cleaned_occupations) j(refugee)

label variable w0 "Hosts"
label variable w1 "Refugees"

gen host_share= total_ind0 / (total_ind0 + total_ind1)
tab host_share

/*
graph hbar (asis) w0 w1, ///
    over(cleaned_occupations) stack percentage  ///
    title("Industries") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal)) ///
	yline(62.9)
*/
restore 



 **** INSPECT OCCUPATION BY REGION ***
 
tab cleaned_occupations if refugee==1 & region_short==1 [aw=w], missing
tab cleaned_occupations if refugee==0 & region_short==1 [aw=w], missing

tab cleaned_occupations if refugee==1 & region_short==2 [aw=w], missing
tab cleaned_occupations if refugee==0 & region_short==2 [aw=w], missing

tab cleaned_occupations if refugee==1 & region_short==3 [aw=w], missing
tab cleaned_occupations if refugee==0 & region_short==3 [aw=w], missing

tab cleaned_occupations if refugee==1 & region_short==4 [aw=w], missing
tab cleaned_occupations if refugee==0 & region_short==4 [aw=w], missing

replace cleaned_occupations=100 if cleaned_occupations==.


** ADDIS

preserve

keep if region_short==1

collapse (sum) w (mean) region_short, by(cleaned_occupations refugee)

bysort refugee: egen total_ind = total(w)

gen occup_share = w/total_ind

label values occup_share occup_lab 

/*
graph hbar (mean) occup_share, ///
    over(refugee) over(cleaned_occupations) asyvars  ///
    title("Occupation shares per group, Addis") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal))
	
graph export "$out_fig\Addis_occupshare_per_group.png", replace
*/

reshape wide w total_ind occup_share, i(cleaned_occupations) j(refugee)
replace w1=0 if w1==.
egen filler=mean(total_ind1)
replace total_ind1=filler if total_ind1==.
drop filler

label variable w0 "Hosts"
label variable w1 "Refugees"

gen host_share= total_ind0 / (total_ind0 + total_ind1)
tab host_share

gen occup_host_share = w0 / (w0 + w1)

/*
graph hbar (asis) w0 w1, ///
    over(cleaned_occupations) stack percentage  ///
    title("Group shares per occupation, Addis") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal)) ///
	yline(81.1)

graph export "$out_fig\Addis_groupshare_per_occup.png", replace
*/

* overrepresentation of refugees:
tab cleaned_occupations if occup_host_share < host_share

* save occup_share of hosts
keep region_short cleaned_occupations occup_host_share 
egen occup_host_share_std = std(occup_host_share)
save "$data_temp/temp_occup_reg1.dta", replace

restore


** JIJIGA

preserve

keep if region_short==2

collapse (sum) w (mean) region_short, by(cleaned_occupations refugee)

bysort refugee: egen total_ind = total(w)

gen occup_share = w/total_ind

label values occup_share occup_lab 

/*
graph hbar (mean) occup_share, ///
    over(refugee) over(cleaned_occupations) asyvars  ///
    title("Occupation shares per group, Jijiga") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal))
	
graph export "$out_fig\Jijiga_occupshare_per_group.png", replace
*/

reshape wide w total_ind occup_share, i(cleaned_occupations) j(refugee)
replace w1=0 if w1==.
egen filler=mean(total_ind1)
replace total_ind1=filler if total_ind1==.
drop filler

label variable w0 "Hosts"
label variable w1 "Refugees"

gen host_share= total_ind0 / (total_ind0 + total_ind1)
tab host_share

gen occup_host_share = w0 / (w0 + w1)


/*
graph hbar (asis) w0 w1, ///
    over(cleaned_occupations) stack percentage  ///
    title("Group shares per occupation, Jijiga") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal)) ///
	yline(65.4),

graph export "$out_fig\Jijiga_groupshare_per_occup.png", replace
*/

* overrepresentation of refugees:
tab cleaned_occupations if occup_host_share < host_share

* save occup_share of hosts
keep region_short cleaned_occupations occup_host_share 
egen occup_host_share_std = std(occup_host_share)
save "$data_temp/temp_occup_reg2.dta", replace

restore


** KAMPALA

preserve

keep if region_short==3

collapse (sum) w (mean) region_short, by(cleaned_occupations refugee)

bysort refugee: egen total_ind = total(w)

gen occup_share = w/total_ind

label values occup_share occup_lab 

/*
graph hbar (mean) occup_share, ///
    over(refugee) over(cleaned_occupations) asyvars  ///
    title("Occupation shares per group, Kampala") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal))
	
graph export "$out_fig\Kampala_occupshare_per_group.png", replace
*/

reshape wide w total_ind occup_share, i(cleaned_occupations) j(refugee)
replace w1=0 if w1==.
egen filler=mean(total_ind1)
replace total_ind1=filler if total_ind1==.
drop filler

label variable w0 "Hosts"
label variable w1 "Refugees"

gen host_share= total_ind0 / (total_ind0 + total_ind1)
tab host_share

gen occup_host_share = w0 / (w0 + w1)

/*
graph hbar (asis) w0 w1, ///
    over(cleaned_occupations) stack percentage  ///
    title("Group shares per occupation, Kampala") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal)) ///
	yline(55.9)

graph export "$out_fig\Kampala_groupshare_per_occup.png" , replace
*/

* overrepresentation of refugees:
tab cleaned_occupations if occup_host_share < host_share

* save occup_share of hosts
keep region_short cleaned_occupations occup_host_share 
egen occup_host_share_std = std(occup_host_share)
save "$data_temp/temp_occup_reg3.dta", replace

restore


** ISINGIRO

preserve

keep if region_short==4

collapse (sum) w (mean) region_short, by(cleaned_occupations refugee)

bysort refugee: egen total_ind = total(w)

gen occup_share = w/total_ind

label values occup_share occup_lab 

/*
graph hbar (mean) occup_share, ///
    over(refugee) over(cleaned_occupations) asyvars  ///
    title("Occupation shares per group, Isingiro") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal))
	
graph export "$out_fig\Isingiro_occupshare_per_group.png", replace
*/

reshape wide w total_ind occup_share, i(cleaned_occupations) j(refugee)
replace w1=0 if w1==.
egen filler=mean(total_ind1)
replace total_ind1=filler if total_ind1==.
drop filler

label variable w0 "Hosts"
label variable w1 "Refugees"

gen host_share= total_ind0 / (total_ind0 + total_ind1)
tab host_share

gen occup_host_share = w0 / (w0 + w1)

/*
graph hbar (asis) w0 w1, ///
    over(cleaned_occupations) stack percentage  ///
    title("Group shares per occupation, Isingiro") ///
    ytitle("Percent") ///
    bar(1, color(eltblue)) bar(2, color(teal)) ///
	yline(54.9)

graph export "$out_fig\Isingiro_groupshare_per_occup.png", replace
*/
* overrepresentation of refugees:
tab cleaned_occupations if occup_host_share < host_share

* save occup_share of hosts
keep region_short cleaned_occupations occup_host_share 
egen occup_host_share_std = std(occup_host_share)
save "$data_temp/temp_occup_reg4.dta", replace

restore



************************************************
* OVERREPRESENTATION OF REFUGEES PER INDUSTRY
************************************************

* BASED ON PREVIOUS GRAPHS: 

* Addis: Overrepresented in Beauty Care, Entertainment
* Jijiga: Overrepresented in Trade, Clothing, Manual works
* Kampala: Overrepresented in Clothing, Religious services
* Isingiro: Overrepresented in Beauty care, entertainment, clothing, manual works, Finance, High-skilled office work

/*
lab def occup_lab 1 "Farming/animal husbandry" /// 
					2 "Trade" ///
					3 "Food-related business" ///
					4 "Beauty care" ///
					5 "Entertainment" ///
					6 "Clothing" ///
					7 "Manual works" ///
					8 "Manual technical services" ///
					9 "Communications/ IT/ Computer" ///
					10 "Finance" ///
					12 "Transportation" ///
					13 "Accommodation" ///
					14 "Education Sector" ///
					15 "Health Sector" ///
					16 "High-skilled office work" ///
					17 "Public Sector" ///
					18 "Religious services" ///
					19 "Other" ///
					100 "Unemployed", ///
					modify
*/
					
gen ref_overrep = 1 if region_short==1 & (own_occupation == 4 | own_occupation == 5 | ///
						own_occupation == 8 | own_occupation == 12 | own_occupation == 14 | ///
						own_occupation == 16)
replace ref_overrep = 0 if region_short==1 & own_occupation != 4 & own_occupation != 5 & ///
						own_occupation != 8 & own_occupation != 12 & own_occupation != 14 & ///
						own_occupation != 16 & own_occupation != 19
replace ref_overrep = 1 if region_short==2 & (own_occupation == 2 | own_occupation == 6 | ///
						own_occupation == 7 | own_occupation == 16)
replace ref_overrep = 0 if region_short==2 & own_occupation != 2 & own_occupation != 6 & ///
						own_occupation != 7 & own_occupation != 16  & own_occupation != 19
replace ref_overrep = 1 if region_short==3 & (own_occupation == 2 | own_occupation == 4 | ///
						own_occupation == 6 | own_occupation == 9 | own_occupation == 12 | ///
						own_occupation == 16 | own_occupation == 18)
replace ref_overrep = 0 if region_short==3 & own_occupation != 2 & own_occupation != 4 & ///
						own_occupation != 6 & own_occupation != 9 & own_occupation != 12 & ///
						own_occupation != 16 & own_occupation != 18 & own_occupation != 19
replace ref_overrep = 1 if region_short==4 & (own_occupation == 4 | own_occupation == 6 | ///
						own_occupation==7 | own_occupation==10 | own_occupation==16)
replace ref_overrep = 0 if region_short==4 & own_occupation != 4 & own_occupation != 6 & ///
						own_occupation != 7 & own_occupation != 10 & own_occupation != 16 & ///
						own_occupation != 19

label var ref_overrep "=1 if refugees overrepresented; =0 if hosts overrepresented; by location"


/*===============================================================
		Generating the index considering over-representation of refugees per industry& place
			separate refugees and hosts: BY REFUGEE PRESSURE
=================================================================*/
*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & ref_overrep==0, generate(prej_hostnoref) 
lab var prej_hostnoref "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostnoref"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & ref_overrep == 1, generate(prej_hostmanyref) 
lab var prej_hostmanyref "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostmanyref"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & ref_overrep == 0, generate(prej_refugeemanyhost) 
lab var prej_refugeemanyhost "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeemanyhost"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & ref_overrep == 1, generate(prej_refugeenohost) 
lab var prej_refugeenohost "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeenohost"

gen prej_aind_byPOG =.
replace prej_aind_byPOG =prej_hostnoref if refugee==0 & ref_overrep == 0
replace prej_aind_byPOG =prej_hostmanyref if refugee==0 & ref_overrep == 1
replace prej_aind_byPOG =prej_refugeemanyhost if refugee==1 & ref_overrep == 0
replace prej_aind_byPOG =prej_refugeenohost if refugee==1 & ref_overrep == 1
lab var prej_aind_byPOG  "OUT: Anderson Index Prejudice by Out-group pressure, Soc. and Priv. and Work"

sum prej_aind_byPOG

/*====================================================================
          B: WORKING HOURS
====================================================================*/


tab LM624
tab LM625

gen mnth_wrk_hrs = (LM624) * (LM625/4.35) // 4.35 weeks per month (on average)
*hist mnth_wrk_hrs
codebook mnth_wrk_hrs // drop 0 working hours and unemployed

preserve 

* Analyze working hours in the different sectors
drop if mnth_wrk_hrs==0
drop if mnth_wrk_hrs==. // unemployed

gen part_time = 1 if mnth_wrk_hrs < 152 // threshold for part-time work: 35 hrs/week = 152 hours per month (US standard definition)
replace part_time = 0 if mnth_wrk_hrs >= 152

gen over_work = 1 if mnth_wrk_hrs >= 209 // 48 hours/ week defined as legal threshold for over-work
replace over_work = 0 if mnth_wrk_hrs < 209
codebook over_work

collapse (mean) LM624 mnth_wrk_hrs part_time ref_overrep over_work [aw=w], by(cleaned_occupations region_short)

gen occup_host_share_loc = .
gen occup_host_share_loc_std = .
forvalues i = 1(1)4 { 
merge 1:1 region_short cleaned_occupations using "$data_temp/temp_occup_reg`i'.dta"
drop _merge
rename occup_host_share occup_host_share`i'
rename occup_host_share_std occup_host_share_std`i'
replace occup_host_share_loc = occup_host_share`i' if region_short==`i'
replace occup_host_share_loc_std = occup_host_share_std`i' if region_short==`i'
drop occup_host_share`i' occup_host_share_std`i'
}

corr(over_work ref_overrep) // industries with overrepresentation of refugees - more likely to work over-time (=more competition?) - or driven by refugees themselves?
corr(part_time ref_overrep) // less likely to work part-time - (less competition?)
corr(mnth_wrk_hrs ref_overrep) // lower working hours ()

egen median_over_work = median(over_work)
tab median_over_work
gen over_work_m = 1 if over_work >= median_over_work & over_work!=.
replace over_work_m = 0 if over_work < median_over_work
drop median_over_work

egen median_part_time = median(part_time)
gen part_time_m = 1 if part_time >= median_part_time &  part_time!=.
replace part_time_m = 0 if part_time < median_part_time
drop median_part_time

egen median_mnth_wrk_hrs = median(mnth_wrk_hrs)
gen mnth_wrk_hrs_m = 1 if mnth_wrk_hrs >= median_mnth_wrk_hrs & mnth_wrk_hrs!=.
replace mnth_wrk_hrs_m = 0 if mnth_wrk_hrs < median_mnth_wrk_hrs
drop median_mnth_wrk_hrs

keep region_short cleaned_occupations over_work_m part_time_m mnth_wrk_hrs_m

lab var over_work_m "Over Work"
lab var part_time_m "Part Time"
lab var mnth_wrk_hrs_m "Mean monthly work hours"

save "$data_temp/temp_wrk_hrs.dta", replace

restore 

merge m:1 region_short cleaned_occupations using "$data_temp/temp_wrk_hrs.dta"

drop _merge

lab var mnth_wrk_hrs "Monthly work hours"

/*===============================================================
		Generating the index considering sectors where many (more than median) individuals work over legal threshold
			separate from hosts and refugees: BY OVER-WORK (per industry)
=================================================================*/
*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & over_work_m==0, generate(prej_hostunderwrk) 
lab var prej_hostnoref "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostnoref"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & over_work_m == 1, generate(prej_hostoverwrk) 
lab var prej_hostmanyref "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostmanyref"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & over_work_m == 0, generate(prej_refugeeunderwrk) 
lab var prej_refugeemanyhost "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeemanyhost"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & over_work_m == 1, generate(prej_refugeeoverwrk) 
lab var prej_refugeenohost "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeenohost"

gen prej_aind_byOWK =.
replace prej_aind_byOWK =prej_hostunderwrk if refugee==0 & over_work_m == 0
replace prej_aind_byOWK =prej_hostoverwrk if refugee==0 & over_work_m == 1
replace prej_aind_byOWK =prej_refugeeunderwrk if refugee==1 & over_work_m == 0
replace prej_aind_byOWK =prej_refugeeoverwrk if refugee==1 & over_work_m == 1
lab var prej_aind_byOWK  "OUT: Anderson Index Prejudice by over-work, Soc. and Priv. and Work"

sum prej_aind_byOWK

drop prej_hostunderwrk prej_hostoverwrk prej_refugeeunderwrk prej_refugeeoverwrk

/*===============================================================
		Generating the index considering sectors where many (more than median) individuals work part-time
			separate from hosts and refugees: BY PART-TIME WORK (per industry)
=================================================================*/
*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & part_time_m==0, generate(prej_hostft) 
lab var prej_hostnoref "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostnoref"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & part_time_m == 1, generate(prej_hostpt) 
lab var prej_hostmanyref "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostmanyref"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & part_time_m == 0, generate(prej_refugeeft) 
lab var prej_refugeemanyhost "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeemanyhost"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & part_time_m == 1, generate(prej_refugeept) 
lab var prej_refugeenohost "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeenohost"

gen prej_aind_byPT =.
replace prej_aind_byPT =prej_hostft if refugee==0 & part_time_m == 0
replace prej_aind_byPT =prej_hostpt if refugee==0 & part_time_m == 1
replace prej_aind_byPT =prej_refugeeft if refugee==1 & part_time_m == 0
replace prej_aind_byPT =prej_refugeept if refugee==1 & part_time_m == 1
lab var prej_aind_byPT  "OUT: Anderson Index Prejudice by part-time, Soc. and Priv. and Work"

sum prej_aind_byPT

drop prej_hostft prej_hostpt prej_refugeeft prej_refugeept

/*===============================================================
		Generating the index considering sectors where average working hours are beyond median of the industries
			separate from hosts and refugees: BY WORKING HOURS (per industry)
=================================================================*/
*hosts
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & mnth_wrk_hrs_m==0, generate(prej_hostlowhrs) 
lab var prej_hostnoref "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostnoref"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==0 & mnth_wrk_hrs_m == 1, generate(prej_hosthighhrs) 
lab var prej_hostmanyref "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_hostmanyref"

*refugees
swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & mnth_wrk_hrs_m == 0, generate(prej_refugeelowhrs) 
lab var prej_refugeemanyhost "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeemanyhost"

swindex EX904A EX904B EX904C EX904D EX904E EX904F if refugee==1 & mnth_wrk_hrs_m == 1, generate(prej_refugeehighhrs) 
lab var prej_refugeenohost "OUT: Anderson Index Prejudice, Soc. and Priv. and Work_refugeenohost"

gen prej_aind_byHRS =.
replace prej_aind_byHRS =prej_hostlowhrs if refugee==0 & mnth_wrk_hrs_m == 0
replace prej_aind_byHRS =prej_hosthighhrs if refugee==0 & mnth_wrk_hrs_m == 1
replace prej_aind_byHRS =prej_refugeelowhrs if refugee==1 & mnth_wrk_hrs_m == 0
replace prej_aind_byHRS =prej_refugeehighhrs if refugee==1 & mnth_wrk_hrs_m == 1
lab var prej_aind_byHRS  "OUT: Anderson Index Prejudice by working hrs, Soc. and Priv. and Work"

sum prej_aind_byHRS

drop prej_hostlowhrs prej_hosthighhrs prej_refugeelowhrs prej_refugeehighhrs

				*******************************************
				*** 11. SUMMARY STATISTICS WITH WEIGHTS ***
				*******************************************

su 	prej_aind_byR /// REFUGEE
	prej_aind_byL /// LOCATION
	paind_lmcomp_byL /// LOCATION
	prej_aind_byG /// GENDER
	prej_aind_byHH /// HOUSEHOLD HEAD
	prej_aind_byE /// EDUCATION
	prej_aind_byN /// NETWORK
	prej_aind_byC /// COUNTRY
	prej_aind_byS /// LENGTH OF STAY (REFUGEES ONLY)
	prej_aind_byLIG /// MAIN IN-GROUP LANGUAGE
	prej_aind_byLOG /// MAIN OUT-GROUP LANGUAGE
	paind_social_byR /// SOCIAL
	paind_private_byR /// PRIVATE
	paind_work_byR /// WORK
	paind_lmcomp_byR /// LM COMPETITION
	paind_social_byR_byC /// SOCIAL
	paind_private_byR_byC /// PRIVATE
	paind_work_byR_byC /// WORK
	paind_lmcomp_byR_byC /// LM COMPETITION
	[aw=w]

mdesc 	prej_aind_byR /// REFUGEE
	prej_aind_byL /// LOCATION
	paind_lmcomp_byL /// LOCATION
	prej_aind_byG /// GENDER
	prej_aind_byHH /// HOUSEHOLD HEAD 
	prej_aind_byE /// EDUCATION
	prej_aind_byN /// NETWORK
	prej_aind_byC /// COUNTRY
	prej_aind_byS /// LENGTH OF STAY (REFUGEES ONLY)
	prej_aind_byLIG /// MAIN IN-GROUP LANGUAGE
	prej_aind_byLOG /// MAIN OUT-GROUP LANGUAGE
	paind_social_byR /// SOCIAL
	paind_private_byR /// PRIVATE
	paind_work_byR /// WORK
	paind_lmcomp_byR /// LM COMPETITION
	paind_social_byR_byC /// SOCIAL
	paind_private_byR_byC /// PRIVATE
	paind_work_byR_byC /// WORK
	paind_lmcomp_byR_byC // LM COMPETITION

save "$data_final/04_UGA_ETH_Prepared.dta", replace



*Erase obsolete datasets
erase "$data_final/01_ETH_MergeAll_Prep.dta" 
erase "$data_final/01_UGA_MergeAll_Prep.dta" 
*erase "$data_final/02_UGA_ETH_MergeAll_Prep.dta" 
erase "$data_final/03_UGA_ETH_MergeAll_SSRSI_Prep.dta" 

erase "$data_temp/Merge_clean_LM.dta"

erase "$data_temp/temp_occup_reg1.dta"
erase "$data_temp/temp_occup_reg2.dta"
erase "$data_temp/temp_occup_reg3.dta"
erase "$data_temp/temp_occup_reg4.dta"

erase "$data_temp/temp_wrk_hrs.dta"
erase "$data_temp/01_Language_descr.dta"

/*
erase "$out_fig\Addis_occupshare_per_group.png"
erase "$out_fig\Addis_groupshare_per_occup.png"
erase "$out_fig\Jijiga_occupshare_per_group.png"
erase "$out_fig\Jijiga_groupshare_per_occup.png"
erase "$out_fig\Kampala_occupshare_per_group.png"
erase "$out_fig\Kampala_groupshare_per_occup.png"
erase "$out_fig\Isingiro_occupshare_per_group.png"
erase "$out_fig\Isingiro_groupshare_per_occup.png"
*/

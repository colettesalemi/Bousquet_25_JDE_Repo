
/*====================================================================
project:       Experiment - Balance tests and Summary Statistics Do File
Authors:       Julie Bousquet/Mark Marvin Kadigo/Anna Gasten 
Description:    

This do file generates
            - Section 1: Balance tables: Table A7: TA7_Balance_Tables
                The generates tables TA7_Balance_Tables_All; TA7_Balance_Tables_Hosts; 
                TA7_Balance_Tables_Refugees are manually aggregated into table TA7_Balance_Tables
            - Section 2: Summary Statistics
                    - Table A8: TA8_SummStat_Uganda
                    - Table A9: TA9_SummStat_Ethiopia

----------------------------------------------------------------------
Creation Date:    24-10-2022
====================================================================*/





/*====================================================================
Section 1:     Experiment - Balance tests 
----------------------------------------------------------------------
====================================================================*/



/*====================================================================
                        0: Set up
====================================================================*/

global controls         ethiopia urban male age hhsize educ_primary ///
                        employed  
global outcomes         prej_aind paind_social paind_priv paind_work 
global demographics     ethiopia urban age male educ_primary ///
                        hhsize employed


/*====================================================================
                        1: Analysis
====================================================================*/

                ************************************
                        ** EQUALITY OF MEANS WITH WEIGHTS **
                ************************************

use "$data_final/04_UGA_ETH_Prepared.dta", clear

*Generating T1, T2, T3 & T4
gen     T1 = 1 if exp_ingroup == 1 & exp_same_occup == 1
replace T1 = 0 if T1 == . & exp_ingroup != . & exp_same_occup != .
                
gen     T2 = 1 if exp_ingroup == 1 & exp_same_occup == 0
replace T2 = 0 if T2 == . & exp_ingroup != . & exp_same_occup != .
                
gen     T3 = 1 if exp_ingroup == 0 & exp_same_occup == 1
replace T3 = 0 if T3 ==. & exp_ingroup != . & exp_same_occup != .

gen     T4 = 1 if exp_ingroup == 0 & exp_same_occup == 0
replace T4 = 0 if T4 == . & exp_ingroup != . & exp_same_occup != .

*Generating in-group_same occupation
gen     ingroupsame = 1 if T1 == 1
replace ingroupsame = 0 if T3 == 1 & ingroupsame == . 
lab def ingroupsame 0 "T3 Out Group, SO" 1 "T1 In Group, SO", modify 
lab val ingroupsame ingroupsame 
lab var ingroupsame "In Group vs Out Group, within the same occupation"

*Generating in-group_different occupation
gen     ingroupdiff = 1 if T2 == 1
replace ingroupdiff = 0 if T4 == 1 & ingroupdiff == . 
lab def ingroupdiff 0 "T4 Out Group, DO" 1 "T2 In Group, DO", modify 
lab val ingroupdiff ingroupdiff 
lab var ingroupdiff "In Group vs Out Group, within the different occupation"


gen treat_var = 1 if T1 == 1 
replace treat_var = 2 if T2 == 1
replace treat_var = 3 if T3 == 1 
replace treat_var = 4 if T4 == 1 
lab def treat_var 1 "T1" 2 "T2" ///
                3 "T3" 4 "T4", ///
                modify 

lab val treat_var treat_var 
lab var treat_var "Treatment Variable" 
tab treat_var

** BALANCE TABLES WITH RESPECTS TO THE DEMOGRAPHICS **

lab var employed "Employed"
lab var tow "Type of Work (14d)"
*ethiopia urban  male
lab var age "Age" 
lab var educ_primary "At least primary" 
*employed  
lab var tow_ww "Wage Worker"
lab var tow_se "Self Employed" 
lab var tow_ag "Agricultural" 
* hhsize



                        ******************
                        **** BALANCE *****
                        ******************

*POOLED
iebaltab $demographics [aw=w], grpvar(treat_var)  vce(cluster cluster_psu) ///
    savetex("$out_tab/TA7_Balance_Tables_All.tex") replace rowvarlabels ///
     tblnonote format(%9.2fc) stats("pair(diff)") starlevels(0.1 0.05 0.01)

*HOSTS
iebaltab $demographics [aw=w] if exp_refugee==0, grpvar(treat_var)  vce(cluster cluster_psu) ///
    savetex("$out_tab/TA7_Balance_Tables_Hosts.tex") replace rowvarlabels ///
     tblnonote format(%9.2fc) stats("pair(diff)") starlevels(0.1 0.05 0.01)

*REFUGEES
iebaltab $demographics [aw=w] if exp_refugee==1, grpvar(treat_var)  vce(cluster cluster_psu) ///
    savetex("$out_tab/TA7_Balance_Tables_Refugees.tex") replace rowvarlabels ///
     tblnonote format(%9.2fc) stats("pair(diff)") starlevels(0.1 0.05 0.01)



/*====================================================================
Section 2:       Experiment - Summary Statistics
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/

global outcomes_byR ethiopia urban male age hhsize educ_primary   ///
  		prej_aind_byR /// REFUGEE
                paind_social_byR /// SOCIAL
                paind_private_byR /// PRIVATE
                paind_work_byR /// WORK
                paind_lmcomp_byR /// LM COMPETITION
                exp_same_occup exp_outgroup


global outcomes_byC ethiopia urban male age hhsize educ_primary   ///
                prej_aind_byC /// REFUGEE
                paind_social_byR_byC /// SOCIAL
                paind_private_byR_byC /// PRIVATE
                paind_work_byR_byC /// WORK
                paind_lmcomp_byR_byC /// LM COMPETITION
                exp_same_occup exp_outgroup

/*====================================================================
                        1: Analysis
====================================================================*/

use "$data_final/04_UGA_ETH_Prepared.dta", clear

lab var educ_primary "Received at least primary education Level"
lab var prej_aind_byR "Anderson Index: Prejudice by country; Social, private and work" 
lab var paind_social_byR "Anderson Index: Prejudice by refugee group and country; Social" 
lab var paind_private_byR "Anderson Index: Prejudice by refugee group and country; Private" 
lab var paind_work_byR "Anderson Index: Prejudice by refugee group and country; Work" 
lab var paind_lmcomp_byR "Anderson Index: Prejudice by refugee group and country; Labor market competition"
lab var exp_same_occup "Treatment group assignment: Same occupation" 
lab var exp_outgroup "Treatment group assignment: Out-group"

eststo sumstat_R:   qui estpost su $outcomes_byR      [w=w] if refugee == 1 
eststo sumstat_H:   qui estpost su $outcomes_byR      [w=w] if refugee == 0 

lab var prej_aind_byC "Anderson Index: Prejudice by country; Social, private and work" 
lab var paind_social_byR_byC "Anderson Index: Prejudice by refugee group and country; Social " 
lab var paind_private_byR_byC "Anderson Index: Prejudice by refugee group and country; Private" 
lab var paind_work_byR_byC "Anderson Index: Prejudice by refugee group and country; Work" 
lab var paind_lmcomp_byR_byC "Anderson Index: Prejudice by refugee group and country; Labor market competition"
lab var exp_same_occup "Treatment group assignment: Same occupation" 
lab var exp_outgroup "Treatment group assignment: Out-group"


**UGANDA

preserve
keep if ethiopia == 0
lab var ethiopia "Country is Ethiopia"

eststo sumstat_R:   qui estpost su $outcomes_byC      [w=w] if refugee == 1 
eststo sumstat_H:   qui estpost su $outcomes_byC      [w=w] if refugee == 0 

esttab  sumstat_H sumstat_R   ///
        using "$out_tab/TA8_SummStat_Uganda.tex", ///
        cells("mean(pattern(1 1 1) fmt(2) label(Mean)) sd(pattern(1 1 1) label(SD)) count(pattern(1 1 1) fmt(0))") ///
        label nonumber booktabs replace gaps star(* 0.10 ** 0.05 *** 0.01) noobs ///
        mtitles("\textbf{HOSTS}" "\textbf{REFUGEES}") ///
        collabels(\multicolumn{1}{c}{{Mean}} \multicolumn{1}{c}{{SD}} \multicolumn{1}{l}{{Obs}}) 
restore                  


**ETHIOPIA

preserve 
keep if ethiopia == 1
lab var ethiopia "Country is Ethiopia"

eststo sumstat_R:   qui estpost su $outcomes_byC      [w=w] if refugee == 1 
eststo sumstat_H:   qui estpost su $outcomes_byC      [w=w] if refugee == 0 

esttab  sumstat_H sumstat_R   ///
        using "$out_tab/TA9_SummStat_Ethiopia.tex", ///
        cells("mean(pattern(1 1 1) fmt(2) label(Mean)) sd(pattern(1 1 1) label(SD)) count(pattern(1 1 1) fmt(0))") ///
        label nonumber booktabs replace gaps star(* 0.10 ** 0.05 *** 0.01) noobs ///
        mtitles("\textbf{HOSTS}" "\textbf{REFUGEES}") ///
        collabels(\multicolumn{1}{c}{{Mean}} \multicolumn{1}{c}{{SD}} \multicolumn{1}{l}{{Obs}}) 
restore                  








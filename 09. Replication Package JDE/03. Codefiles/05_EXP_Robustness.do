

/*====================================================================
Project:       Experiment - Robustness
Authors:       Julie Bousquet/Mark Marvin Kadigo/Anna Gasten 
Description: 

This do file generates
            - Section 1 - Comparison summary statistics with LSMS: Table A4: TA4_Summary_Statistics_LSMS
            - Section 2 - By components of the index: Table A12: TA12_Analysis_byIndex
            - Section 3 - Labor Market competition: Table A10: TA10_Analysis_LMCompetitionIndex 
            - Section 4 - Dummy Variable: Table A13: TA13_Analysis_DummyIndex
            - Section 5 - Without clustered SEs: Table A14: TA14_Analysis_ClusteredSEs
            - Section 6 - By a set of employment variable: Table A15: TA15_Analysis_EmploymentDef
            - Section 7 - Regression Coefficient Comparisons Across Locations (diff-in-mean): TA17_Analysis_PValues 

----------------------------------------------------------------------
Creation Date:    22-01-2025
====================================================================*/







/*====================================================================
Section 1:       Experiment - Summary Stats - LSMS Comparison
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/

global outcomes_ind male age educ_primary
global outcomes_hh hhsize


/*====================================================================
                        1: Analysis
====================================================================*/


                ****************************
                ** ETHIOPIA - ESPS (LSMS) **
                ****************************


*********************
** Individual Data **
*********************

use "$data_lsms/ETH_2021_ESPS-W5_v01_M_Stata/sect1_hh_w5.dta", clear 
keep household_id individual_id saq01 s1q02 s1q03a pw_w5


* Gender
tab s1q02
rename s1q02 male
replace male = 0 if male == 2
label define gender_label 0 "Female" 1 "Male"
label values male gender_label
tab male 

* Age
tab s1q03a
rename s1q03a age

* Household size
bysort household_id: gen hhsize = _N

	tempfile eth_temp1
	save `eth_temp1', replace

use "$data_lsms/ETH_2021_ESPS-W5_v01_M_Stata/sect2_hh_w5.dta", clear

* Primary School completed
tab s2q06

gen educ_primary = .
replace educ_primary = 0 if s2q00 == 2 // Younger than 4 years
replace educ_primary = 0 if s2q04 == 2 // Never attended school
replace educ_primary = 0 if s2q06 <=7 | s2q06 == 34 | s2q06 == 35 // Primary school (7 years) not completed
replace educ_primary = 1 if (s2q06 >= 6 & s2q06 <=35) // Primary school (>= 8 years) completed

merge 1:1 household_id individual_id using `eth_temp1'

sum educ_primary


keep if saq01 == 5 | saq01 == 14
keep if age >= 18 & age <=65



**********************************
** Descriptives Individual Data **
**********************************

eststo sumstat_esps_eth_ind:  estpost su $outcomes_ind    [w=pw_w5] 

	
*********************************
** Descriptives Household Data **
*********************************

collapse (mean) pw_w5 hhsize, by(household_id)
eststo sumstat_esps_eth_hh:   estpost su $outcomes_hh    [w=pw_w5] 



                ******************************************
                *** ETHIOPIA - HARM REF-HOST (HHR LMS) ***
                ******************************************


use "$data_final/04_UGA_ETH_Prepared.dta", clear

keep if ethiopia == 1
keep if refugee == 0

lab var educ_primary "Received at least primary education Level"


eststo sumstat_hhr_eth:  estpost su $outcomes_ind  $outcomes_hh  [w=w] 

eststo sumstat_hhr_eth_ind:  estpost su $outcomes_ind    [w=w] 
eststo sumstat_hhr_eth_hh:   estpost su $outcomes_hh    [w=w] 



                ****************************
                *** UGANDA - UNPS (LSMS) ***
                ****************************


********************
** Household Data **
********************


use "$data_lsms/UGA_2019_UNPS_v03_M_STATA14/HH/gsec1.dta", clear
gen hhid_str = substr(hhid, 1, 32)

keep hhid_str subreg district wgt

	tempfile uga_temp1
	save `uga_temp1', replace

	
*********************
** Individual Data **
*********************

use "$data_lsms/UGA_2019_UNPS_v03_M_STATA14/HH/gsec2.dta", clear
gen hhid_str = substr(hhid, 1, 32)
	
keep hhid_str pid h2q3 h2q8

* Gender
tab h2q3
rename h2q3 male
replace male = 0 if male == 2
label define gender_label 0 "Female" 1 "Male"
label values male gender_label
tab male 

* Age
tab h2q8
rename h2q8 age

* Household size
bysort hhid: gen hhsize = _N

	tempfile uga_temp2
	save `uga_temp2', replace


use "$data_lsms/UGA_2019_UNPS_v03_M_STATA14/HH/gsec4.dta", clear	
gen hhid_str = substr(hhid, 1, 32)

* Primary School completed
tab s4q05
tab s4q05, nol

tab s4q07
tab s4q07, nol

tab s4q09
tab s4q09, nol


gen educ_primary = .
replace educ_primary = 0 if s4q05 ==1 // Never attended school
replace educ_primary = 0 if s4q05 == 2 & s4q07 < 17 // Attended in the past, but low level
replace educ_primary = 1 if s4q05 == 2 & s4q07 >= 17 & s4q07 !=. & s4q07 != 98 // Attended school in the past, and high level
replace educ_primary = 0 if s4q05 == 3 & s4q09 < 16 // Currently attending school, but low level
replace educ_primary = 1 if s4q05 == 3 & s4q09 >= 16 & s4q09 !=. & s4q09 != 98 // Currently attending school, and high level
replace educ_primary = 0 if s4q05 == 3 & s4q10 < 30 // Currently attending school, but low level
replace educ_primary = 1 if s4q05 == 3 & s4q10 >= 30 & s4q10 !=. & s4q10 != 98 // Currently attending school, and high level

merge 1:1 hhid_str pid using `uga_temp2'
// Many non-merged observations as individuals are still young.
replace educ_primary = 0 if age <= 7 
drop _merge

merge m:1 hhid_str using `uga_temp1'
drop _merge

keep male age educ_primary hhsize subreg district wgt hhid_str pid

keep if subreg == 1 | subreg == 14
keep if age >=18 & age <=65


**********************************
** Descriptives Individual Data **
**********************************

eststo sumstat_lsms_uga_ind:   estpost su $outcomes_ind    [w=wgt] 


*********************************
** Descriptives Household Data **
*********************************

collapse (mean) wgt hhsize, by(hhid)
eststo sumstat_lsms_uga_hh:   estpost su $outcomes_hh    [w=wgt] 



                **************************************
                ** UGANDA - HARM REF-HOST (HHR LMS) **
                **************************************


use "$data_final/04_UGA_ETH_Prepared.dta", clear

keep if ethiopia == 0
keep if refugee == 0

lab var educ_primary "Received at least primary education Level"


eststo sumstat_hhr_uga_ind:  estpost su $outcomes_ind  [w=w] 
eststo sumstat_hhr_uga_hh:   estpost su $outcomes_hh    [w=w] 

eststo sumstat_hhr_uga:  estpost su $outcomes_ind $outcomes_hh    [w=w] 






                ****************************
                **         TABLES         **
                ****************************



* First table: Individual-level statistics (No bottom rule)
esttab sumstat_hhr_eth_ind sumstat_esps_eth_ind ///
    using "$out_tab/summary_statistics_lsms_eth.tex", ///
    cells("mean(fmt(2) label(Mean)) sd(label(SD)) count(fmt(0) label(Obs))") ///
    label nonumber booktabs replace gaps noobs ///
    collabels(none) ///  <-- No column headers in the second table
	nomtitles nonumber ///
    varlabels( ///
        male "Male" ///
        age "Age of the respondent" ///
        educ_primary "Received at least primary education" ///
    ) ///
    prehead("\begin{tabular}{lcccccc} \toprule" ///
            "\textbf{Panel A: Ethiopia} & \multicolumn{3}{c}{\textbf{HHR-LMS}} & \multicolumn{3}{c}{\textbf{LSMS}} \\" ///
            "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" ///
            "& \textbf{Mean} & \textbf{SD} & \textbf{Obs} & \textbf{Mean} & \textbf{SD} & \textbf{Obs} \\ \midrule") ///
    postfoot("")  // <-- Removes \bottomrule to keep the table open

* Second table: Household statistics (No headers)
esttab sumstat_hhr_eth_hh sumstat_esps_eth_hh ///
    using "$out_tab/summary_statistics_lsms_eth_hhsize_1.tex", ///
    cells("mean(fmt(2) label(Mean)) sd(label(SD)) count(fmt(0) label(Obs))") ///
    label nonumber booktabs replace gaps noobs ///
    collabels(none) ///  <-- No column headers in the second table
    nomtitles nonumber prehead("") ///
    varlabels( ///
        hhsize "Household Size" ///
    ) ///
     postfoot("\bottomrule  \end{tabular}  ")

filefilter "$out_tab/summary_statistics_lsms_eth_hhsize_1.tex" ///
           "$out_tab/summary_statistics_lsms_eth_hhsize.tex", ///
           replace from("\BSmidrule") to("")

erase "$out_tab/summary_statistics_lsms_eth_hhsize_1.tex"

* First table: Individual-level statistics (No bottom rule)
esttab sumstat_hhr_uga_ind sumstat_lsms_uga_ind ///
    using "$out_tab/summary_statistics_lsms_uga_1.tex", ///
    cells("mean(fmt(2) label(Mean)) sd(label(SD)) count(fmt(0) label(Obs))") ///
    label nonumber booktabs replace gaps noobs ///
    collabels(none) ///  <-- No column headers in the second table
    nomtitles nonumber ///
    varlabels( ///
        male "Male" ///
        age "Age of the respondent" ///
        educ_primary "Received at least primary education" ///
    ) ///
    prehead("\begin{tabular}{lcccccc} " ///
            "\textbf{Panel B: Uganda} & \multicolumn{3}{c}{\textbf{HHR-LMS}} & \multicolumn{3}{c}{\textbf{LSMS}} \\" ///
            "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" ) ///
    postfoot("")  // <-- Removes \bottomrule to keep the table open

* Second table: Household statistics (No headers)
esttab sumstat_hhr_uga_hh sumstat_lsms_uga_hh ///
    using "$out_tab/summary_statistics_lsms_uga_hhsize_1.tex", ///
    cells("mean(fmt(2) label(Mean)) sd(label(SD)) count(fmt(0) label(Obs))") ///
    label nonumber booktabs replace gaps noobs ///
    collabels(none) ///  <-- No column headers in the second table
    nomtitles nonumber prehead("") ///
    varlabels( ///
        hhsize "Household Size" ///
    ) ///
     postfoot("\bottomrule  \end{tabular}  ")

filefilter "$out_tab/summary_statistics_lsms_uga_hhsize_1.tex" ///
           "$out_tab/summary_statistics_lsms_uga_hhsize.tex", ///
           replace from("\BSmidrule") to("")

erase "$out_tab/summary_statistics_lsms_uga_hhsize_1.tex"

filefilter "$out_tab/summary_statistics_lsms_uga_1.tex" ///
           "$out_tab/summary_statistics_lsms_uga.tex", ///
           replace from("\BSmidrule") to("")

erase "$out_tab/summary_statistics_lsms_uga_1.tex"



*** COMBINE THE TABLE **

* Define output merged file
local final_tex "$out_tab/TA4_Summary_Statistics_LSMS.tex"

* Open the final output file
file open final using "`final_tex'", write replace


* Append first file (Ethiopia - Individual)
file open f1 using "$out_tab/summary_statistics_lsms_eth.tex", read
file read f1 line
while r(eof) == 0 {
    file write final "`line'" _n
    file read f1 line
}
file close f1

* Append second file (Ethiopia - Household)
file open f2 using "$out_tab/summary_statistics_lsms_eth_hhsize.tex", read
file read f2 line
while r(eof) == 0 {
    file write final "`line'" _n
    file read f2 line
}
file close f2

* Append third file (Uganda - Individual)
file open f3 using "$out_tab/summary_statistics_lsms_uga.tex", read
file read f3 line
while r(eof) == 0 {
    file write final "`line'" _n
    file read f3 line
}
file close f3

* Append fourth file (Uganda - Household)
file open f4 using "$out_tab/summary_statistics_lsms_uga_hhsize.tex", read
file read f4 line
while r(eof) == 0 {
    file write final "`line'" _n
    file read f4 line
}
file close f4

* Close final file
file close final

erase "$out_tab/summary_statistics_lsms_eth.tex"
erase "$out_tab/summary_statistics_lsms_eth_hhsize.tex"
erase "$out_tab/summary_statistics_lsms_uga.tex"
erase "$out_tab/summary_statistics_lsms_uga_hhsize.tex"






/*====================================================================
Section 2:    Experiment - Robustness by index
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/


*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    paind_social_byR /// SOCIAL
                    paind_private_byR /// PRIVATE
                    paind_work_byR /// WORK



/*====================================================================
                        1: Analysis
====================================================================*/

                        ***************************
                        **** ANALYSIS BY INDEX ****
                        ***************************

use "$data_final/04_UGA_ETH_Prepared.dta", clear


foreach outcome of global outcome_1 {


    **************** 
    ***  HOSTS   ***
    ****************

preserve

    eststo MEAN_`outcome' :  estpost su `outcome'

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
     * estimates store OLS_0_`outcome', title(Model `outcome')

** EXTRACTION Q VALUES 
*BEGIN
*preserve
    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG0  =`OUTG'
    mat list OUTG0

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC0  =`SAMEOCC'
    mat list  SAMEOCC0

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT0  =`SAMEOUT'
    mat list  SAMEOUT0

        qui gen     smpl_0 = 0
        qui replace smpl_0 = 1 if e(sample)==1

     eststo MEAN_0_`outcome':  estpost su `outcome'  if smpl_0 == 1 [aw=$weight]

     drop smpl_0 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_0_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG0  =`MAROUTG'
    mat list MAROUTG0

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_0_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC0  =`MARSAMEOCC'
    mat list  MARSAMEOCC0

    svmat OUTG0
    svmat SAMEOCC0
    svmat SAMEOUT0
    svmat MAROUTG0
    svmat MARSAMEOCC0

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG01)
    keep OUTG01 SAMEOCC01 SAMEOUT01 MAROUTG01 MARSAMEOCC01
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t0_`outcome' = mat_pval'
    matrix list     mat_pval_t0_`outcome'
    mat colnames    mat_pval_t0_`outcome' = "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup" 
    estadd matrix   mat_pval_t0_`outcome'

 restore 

 preserve

    **************** 
    *** REFUGEES ***
    ****************

    reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      *estimates store OLS_1_`outcome', title(Model `outcome')

    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG1  =`OUTG'
    mat list OUTG1

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC1  =`SAMEOCC'
    mat list  SAMEOCC1

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT1  =`SAMEOUT'
    mat list  SAMEOUT1
 
        qui gen     smpl_1 = 0
        qui replace smpl_1 = 1 if e(sample)==1

     eststo MEAN_1_`outcome':  estpost su `outcome'  if smpl_1 == 1 [aw=$weight]

     drop smpl_1

    ** MARGINS ** REFUGEES **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
               ,  cluster($cluster) 
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_1_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG1  =`MAROUTG'
    mat list MAROUTG1

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_1_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC1  =`MARSAMEOCC'
    mat list  MARSAMEOCC1

    svmat OUTG1
    svmat SAMEOCC1
    svmat SAMEOUT1 
    svmat MAROUTG1
    svmat MARSAMEOCC1

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG11)
    keep OUTG11 SAMEOCC11 SAMEOUT11 MAROUTG11 MARSAMEOCC11
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t1_`outcome' =mat_pval'
    matrix list     mat_pval_t1_`outcome'
    mat colnames    mat_pval_t1_`outcome' =   "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup"  
    estadd matrix   mat_pval_t1_`outcome'

restore



reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0_`outcome'[1,1],mat_pval_t0_`outcome'[1,2],mat_pval_t0_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_0_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_0_`outcome'  

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_0_`outcome'


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1_`outcome'[1,1],mat_pval_t1_`outcome'[1,2],mat_pval_t1_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_1_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_1_`outcome'

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_1_`outcome' 

}


* CREATE EMPTY MODEOL TO FILLE EMPTY COLLUMNS IN THE TABLE
preserve
    clear  
    set obs 2
    gen x = 0 
    gen y = 0 
    reg y x 
    lab var x "Nbr Refugees (ln)"
    ereturn list 
    return list
    estadd scalar N = . , replace
    eststo OLS
    estimates store M_EMPTY
    drop x y
restore






                        **********************************
                                *** TABLES ***
                        **********************************

**************
*** SOCIAL ***
**************

esttab  OLS_0_paind_social_byR OLS_1_paind_social_byR /// 
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\  \multicolumn{5}{c}{\textit{PANEL A: Prejudice Index on Social Interactions - OLS and Margins}} \\  \midrule   ") ///
        compress replace label fragment noobs wide collabels(none)  ///
        keep(1.exp_outgroup 1.exp_same_occup 1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation" ///
                 1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_social_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        mtitles(" "  " ") ///
        prefoot(" ") //
 

esttab  MAROG_0_paind_social_byR MAROG_1_paind_social_byR   /// 
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        compress fragment append label wide noline  collabels(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_social_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MARSO_0_paind_social_byR MARSO_1_paind_social_byR   /// 
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        compress fragment append label wide noline  collabels(none) ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_social_byR) star) se(par fmt(2))") ///
        stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MEAN_0_paind_social_byR M_EMPTY MEAN_1_paind_social_byR M_EMPTY ///
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") 

***************
*** PRIVATE ***
***************

esttab  OLS_0_paind_private_byR OLS_1_paind_private_byR /// 
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        posthead("\\[-0.6cm] \\  \multicolumn{5}{c}{\textit{PANEL B: Prejudice Index on Private Interactions - OLS and Margins}} \\  \midrule    ") ///
        compress fragment append label noobs nonumbers nomtitles wide collabels(none)  ///
        keep(1.exp_outgroup 1.exp_same_occup 1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation" ///
                 1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_private_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MAROG_0_paind_private_byR MAROG_1_paind_private_byR   /// 
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        compress fragment append label wide noline  collabels(none) ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_private_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MARSO_0_paind_private_byR MARSO_1_paind_private_byR   /// 
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        compress fragment append label wide noline collabels(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_private_byR) star) se(par fmt(2))") ///
        stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MEAN_0_paind_private_byR M_EMPTY MEAN_1_paind_private_byR M_EMPTY ///
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") 

************
*** WORK ***
************

esttab  OLS_0_paind_work_byR OLS_1_paind_work_byR /// 
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        posthead("\\[-0.6cm] \\  \multicolumn{5}{c}{\textit{PANEL C: Prejudice Index on Work Interactions - OLS and Margins}} \\  \midrule   ") ///
        compress fragment append label noobs nonumbers nomtitles wide  collabels(none) ///
        keep(1.exp_outgroup 1.exp_same_occup 1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation" ///
                 1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_work_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MAROG_0_paind_work_byR MAROG_1_paind_work_byR   /// 
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        compress fragment append label wide noline collabels(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_work_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MARSO_0_paind_work_byR MARSO_1_paind_work_byR  /// 
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        compress fragment append label wide noline collabels(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_work_byR) star) se(par fmt(2))") ///
        stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MEAN_0_paind_work_byR M_EMPTY MEAN_1_paind_work_byR M_EMPTY ///
        using "$out_tab/TA12_Analysis_byIndex.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")









/*====================================================================
Section 3:       Experiment - Labor Market Competition
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster 	cluster_psu 
global weight 	w 

global outcome_1    paind_lmcomp_byR // LM COMPETITION


/*====================================================================
                       1: ANALYSIS
====================================================================*/


use "$data_final/04_UGA_ETH_Prepared.dta", clear

foreach outcome of global outcome_1 {

    *************************
    * **** REGRESSIONS **** *
    *************************

    **************** 
    ***  HOSTS   ***
    ****************

preserve

    eststo MEAN_`outcome' :  estpost su `outcome'

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 

** EXTRACTION Q VALUES 
*BEGIN
*preserve
    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG0  =`OUTG'
    mat list OUTG0

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC0  =`SAMEOCC'
    mat list  SAMEOCC0

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT0  =`SAMEOUT'
    mat list  SAMEOUT0

        qui gen     smpl_0 = 0
        qui replace smpl_0 = 1 if e(sample)==1

     eststo MEAN_0_`outcome':  estpost su `outcome'  if smpl_0 == 1 [aw=$weight]

     drop smpl_0 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_0_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG0  =`MAROUTG'
    mat list MAROUTG0

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_0_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC0  =`MARSAMEOCC'
    mat list  MARSAMEOCC0

    svmat OUTG0
    svmat SAMEOCC0
    svmat SAMEOUT0
    svmat MAROUTG0
    svmat MARSAMEOCC0

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG01)
    keep OUTG01 SAMEOCC01 SAMEOUT01 MAROUTG01 MARSAMEOCC01
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t0_`outcome' = mat_pval'
    matrix list     mat_pval_t0_`outcome'
    mat colnames    mat_pval_t0_`outcome' = "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup" 
    estadd matrix   mat_pval_t0_`outcome'

 restore 

 preserve

    **************** 
    *** REFUGEES ***
    ****************

    reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      *estimates store OLS_1_`outcome', title(Model `outcome')

    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG1  =`OUTG'
    mat list OUTG1

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC1  =`SAMEOCC'
    mat list  SAMEOCC1

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT1  =`SAMEOUT'
    mat list  SAMEOUT1
 
        qui gen     smpl_1 = 0
        qui replace smpl_1 = 1 if e(sample)==1

     eststo MEAN_1_`outcome':  estpost su `outcome'  if smpl_1 == 1 [aw=$weight]

     drop smpl_1

    ** MARGINS ** REFUGEES **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
               ,  cluster($cluster) 
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_1_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG1  =`MAROUTG'
    mat list MAROUTG1

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_1_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC1  =`MARSAMEOCC'
    mat list  MARSAMEOCC1

    svmat OUTG1
    svmat SAMEOCC1
    svmat SAMEOUT1 
    svmat MAROUTG1
    svmat MARSAMEOCC1

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG11)
    keep OUTG11 SAMEOCC11 SAMEOUT11 MAROUTG11 MARSAMEOCC11
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t1_`outcome' =mat_pval'
    matrix list     mat_pval_t1_`outcome'
    mat colnames    mat_pval_t1_`outcome' =   "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup"  
    estadd matrix   mat_pval_t1_`outcome'

restore




reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0_`outcome'[1,1],mat_pval_t0_`outcome'[1,2],mat_pval_t0_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_0_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_0_`outcome'  

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_0_`outcome'


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1_`outcome'[1,1],mat_pval_t1_`outcome'[1,2],mat_pval_t1_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_1_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_1_`outcome'

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_1_`outcome' 

}


* CREATE EMPTY MODEL TO FILL EMPTY COLLUMNS IN THE TABLE
preserve
    clear  
    set obs 2
    gen x = 0 
    gen y = 0 
    reg y x 
    lab var x "Nbr Refugees (ln)"
    ereturn list 
    return list
    estadd scalar N = . , replace
    eststo OLS
    estimates store M_EMPTY
    drop x y
restore


                        **********************************
                                *** TABLES ***
                        **********************************



*****************************************************
************* LABOR MARKET COMPETITION **************
*****************************************************

esttab  OLS_0_paind_lmcomp_byR OLS_1_paind_lmcomp_byR /// 
        using "$out_tab/TA10_Analysis_LMCompetitionIndex.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\  \multicolumn{5}{c}{\textit{PANEL A: Index of Labor Market Competition}} \\  \midrule  ") ///
        compress replace label fragment noobs wide collab(none) ///
        keep(1.exp_outgroup 1.exp_same_occup 1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation" ///
                 1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_lmcomp_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  MAROG_0_paind_lmcomp_byR MAROG_1_paind_lmcomp_byR   /// 
        using "$out_tab/TA10_Analysis_LMCompetitionIndex.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_lmcomp_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MARSO_0_paind_lmcomp_byR  MARSO_1_paind_lmcomp_byR   /// 
        using "$out_tab/TA10_Analysis_LMCompetitionIndex.tex",  ///
        compress fragment append label wide noline collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_paind_lmcomp_byR) star) se(par fmt(2))") ///
        stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") 

esttab  MEAN_0_paind_lmcomp_byR M_EMPTY MEAN_1_paind_lmcomp_byR M_EMPTY ///
        using "$out_tab/TA10_Analysis_LMCompetitionIndex.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")







/*====================================================================
Section 4:       Experiment - Dummy Variable
----------------------------------------------------------------------
====================================================================*/



/*====================================================================
                        0: Set up
====================================================================*/

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_dind  // dummy


/*====================================================================
                       1: ANALYSIS
====================================================================*/


use "$data_final/04_UGA_ETH_Prepared.dta", clear

foreach outcome of global outcome_1 {

    *************************
    * **** REGRESSIONS **** *
    *************************

    **************** 
    ***  HOSTS   ***
    ****************

preserve

    eststo MEAN_`outcome' :  estpost su `outcome'

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 

** EXTRACTION Q VALUES 
*BEGIN
*preserve
    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG0  =`OUTG'
    mat list OUTG0

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC0  =`SAMEOCC'
    mat list  SAMEOCC0

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT0  =`SAMEOUT'
    mat list  SAMEOUT0

        qui gen     smpl_0 = 0
        qui replace smpl_0 = 1 if e(sample)==1

     eststo MEAN_0_`outcome':  estpost su `outcome'  if smpl_0 == 1 [aw=$weight]

     drop smpl_0 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_0_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG0  =`MAROUTG'
    mat list MAROUTG0

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_0_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC0  =`MARSAMEOCC'
    mat list  MARSAMEOCC0

    svmat OUTG0
    svmat SAMEOCC0
    svmat SAMEOUT0
    svmat MAROUTG0
    svmat MARSAMEOCC0

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG01)
    keep OUTG01 SAMEOCC01 SAMEOUT01 MAROUTG01 MARSAMEOCC01
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t0_`outcome' = mat_pval'
    matrix list     mat_pval_t0_`outcome'
    mat colnames    mat_pval_t0_`outcome' = "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup" 
    estadd matrix   mat_pval_t0_`outcome'

 restore 

 preserve

    **************** 
    *** REFUGEES ***
    ****************

    reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      *estimates store OLS_1_`outcome', title(Model `outcome')

    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG1  =`OUTG'
    mat list OUTG1

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC1  =`SAMEOCC'
    mat list  SAMEOCC1

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT1  =`SAMEOUT'
    mat list  SAMEOUT1
 
        qui gen     smpl_1 = 0
        qui replace smpl_1 = 1 if e(sample)==1

     eststo MEAN_1_`outcome':  estpost su `outcome'  if smpl_1 == 1 [aw=$weight]

     drop smpl_1

    ** MARGINS ** REFUGEES **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
               ,  cluster($cluster) 
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_1_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG1  =`MAROUTG'
    mat list MAROUTG1

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_1_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC1  =`MARSAMEOCC'
    mat list  MARSAMEOCC1

    svmat OUTG1
    svmat SAMEOCC1
    svmat SAMEOUT1 
    svmat MAROUTG1
    svmat MARSAMEOCC1

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG11)
    keep OUTG11 SAMEOCC11 SAMEOUT11 MAROUTG11 MARSAMEOCC11
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t1_`outcome' =mat_pval'
    matrix list     mat_pval_t1_`outcome'
    mat colnames    mat_pval_t1_`outcome' =   "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup"  
    estadd matrix   mat_pval_t1_`outcome'

restore




reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0_`outcome'[1,1],mat_pval_t0_`outcome'[1,2],mat_pval_t0_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_0_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_0_`outcome'  

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_0_`outcome'


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1_`outcome'[1,1],mat_pval_t1_`outcome'[1,2],mat_pval_t1_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_1_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_1_`outcome'

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_1_`outcome' 

}


* CREATE EMPTY MODEL TO FILL EMPTY COLLUMNS IN THE TABLE
preserve
    clear  
    set obs 2
    gen x = 0 
    gen y = 0 
    reg y x 
    lab var x "Nbr Refugees (ln)"
    ereturn list 
    return list
    estadd scalar N = . , replace
    eststo OLS
    estimates store M_EMPTY
    drop x y
restore


                        **********************************
                                *** TABLES ***
                        **********************************



**************************************************
************* DUMMY PREJUDICE INDEX **************
**************************************************

esttab  OLS_0_prej_dind OLS_1_prej_dind /// 
        using "$out_tab/TA13_Analysis_DummyIndex.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\  \multicolumn{5}{c}{\textit{PANEL A: Prejudice Indicator (Dummy)}} \\  \midrule  ") ///
        compress replace label fragment noobs wide collab(none) ///
        keep(1.exp_outgroup 1.exp_same_occup 1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation" ///
                 1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_dind) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  MAROG_0_prej_dind MAROG_1_prej_dind   /// 
        using "$out_tab/TA13_Analysis_DummyIndex.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_dind) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MARSO_0_prej_dind  MARSO_1_prej_dind   /// 
        using "$out_tab/TA13_Analysis_DummyIndex.tex",  ///
        compress fragment append label wide noline collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_dind) star) se(par fmt(2))") ///
        stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") 

esttab  MEAN_0_prej_dind M_EMPTY MEAN_1_prej_dind M_EMPTY ///
        using "$out_tab/TA13_Analysis_DummyIndex.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")





/*====================================================================
Section 5:       Experiment - Clustered Standard Errors
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                       0: Set Up
====================================================================*/

estimates drop _all 
set more off 

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster 	cluster_psu 
global weight 	w 

global outcome_1    prej_aind_byR 
 

/*====================================================================
                       1: Analysis
====================================================================*/


use "$data_final/04_UGA_ETH_Prepared.dta", clear


                *****************************
                ****   CLUSTERED SEs   ******
                *****************************

foreach outcome of global outcome_1 {

*estimates drop _all 



    **************** 
    ***  HOSTS   ***
    ****************

preserve

    eststo MEAN_`outcome' :  estpost su `outcome'

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
     * estimates store OLS_0_`outcome', title(Model `outcome')

** EXTRACTION Q VALUES 
*BEGIN
*preserve
    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG0  =`OUTG'
    mat list OUTG0

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC0  =`SAMEOCC'
    mat list  SAMEOCC0

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT0  =`SAMEOUT'
    mat list  SAMEOUT0

        qui gen     smpl_0 = 0
        qui replace smpl_0 = 1 if e(sample)==1

     eststo MEAN_0_`outcome':  estpost su `outcome'  if smpl_0 == 1 [aw=$weight]

     drop smpl_0 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_0_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG0  =`MAROUTG'
    mat list MAROUTG0

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_0_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC0  =`MARSAMEOCC'
    mat list  MARSAMEOCC0

    svmat OUTG0
    svmat SAMEOCC0
    svmat SAMEOUT0
    svmat MAROUTG0
    svmat MARSAMEOCC0

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG01)
    keep OUTG01 SAMEOCC01 SAMEOUT01 MAROUTG01 MARSAMEOCC01
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t0_`outcome' = mat_pval'
    matrix list     mat_pval_t0_`outcome'
    mat colnames    mat_pval_t0_`outcome' = "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup" 
    estadd matrix   mat_pval_t0_`outcome'

 restore 

 preserve

    **************** 
    *** REFUGEES ***
    ****************

    reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      *estimates store OLS_1_`outcome', title(Model `outcome')

    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG1  =`OUTG'
    mat list OUTG1

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC1  =`SAMEOCC'
    mat list  SAMEOCC1

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT1  =`SAMEOUT'
    mat list  SAMEOUT1
 
        qui gen     smpl_1 = 0
        qui replace smpl_1 = 1 if e(sample)==1

     eststo MEAN_1_`outcome':  estpost su `outcome'  if smpl_1 == 1 [aw=$weight]

     drop smpl_1

    ** MARGINS ** REFUGEES **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
               ,  cluster($cluster) 
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_1_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG1  =`MAROUTG'
    mat list MAROUTG1

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_1_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC1  =`MARSAMEOCC'
    mat list  MARSAMEOCC1

    svmat OUTG1
    svmat SAMEOCC1
    svmat SAMEOUT1 
    svmat MAROUTG1
    svmat MARSAMEOCC1

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG11)
    keep OUTG11 SAMEOCC11 SAMEOUT11 MAROUTG11 MARSAMEOCC11
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t1_`outcome' =mat_pval'
    matrix list     mat_pval_t1_`outcome'
    mat colnames    mat_pval_t1_`outcome' =   "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup"  
    estadd matrix   mat_pval_t1_`outcome'

restore






reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0_`outcome'[1,1],mat_pval_t0_`outcome'[1,2],mat_pval_t0_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_0_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_0_`outcome'  

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_0_`outcome'


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1_`outcome'[1,1],mat_pval_t1_`outcome'[1,2],mat_pval_t1_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_1_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_1_`outcome'

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_1_`outcome' 

}


                  *****************************
                  **** NON CLUSTERED SEs ******
                  *****************************


foreach outcome of global outcome_1 {



    **************** 
    ***  HOSTS   ***
    ****************

preserve

    eststo MEAN_`outcome' :  estpost su `outcome'

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
     * estimates store OLS_0_`outcome', title(Model `outcome')

** EXTRACTION Q VALUES 
*BEGIN
*preserve
    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG0  =`OUTG'
    mat list OUTG0

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC0  =`SAMEOCC'
    mat list  SAMEOCC0

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT0  =`SAMEOUT'
    mat list  SAMEOUT0

        qui gen     smpl_0 = 0
        qui replace smpl_0 = 1 if e(sample)==1

     eststo MEAN_0_`outcome':  estpost su `outcome'  if smpl_0 == 1 [aw=$weight]

     drop smpl_0 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_0_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG0  =`MAROUTG'
    mat list MAROUTG0

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_0_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC0  =`MARSAMEOCC'
    mat list  MARSAMEOCC0

    svmat OUTG0
    svmat SAMEOCC0
    svmat SAMEOUT0
    svmat MAROUTG0
    svmat MARSAMEOCC0

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG01)
    keep OUTG01 SAMEOCC01 SAMEOUT01 MAROUTG01 MARSAMEOCC01
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t0_`outcome' = mat_pval'
    matrix list     mat_pval_t0_`outcome'
    mat colnames    mat_pval_t0_`outcome' = "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup" 
    estadd matrix   mat_pval_t0_`outcome'

 restore 

 preserve

    **************** 
    *** REFUGEES ***
    ****************

    reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      *estimates store OLS_1_`outcome', title(Model `outcome')

    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG1  =`OUTG'
    mat list OUTG1

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC1  =`SAMEOCC'
    mat list  SAMEOCC1

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT1  =`SAMEOUT'
    mat list  SAMEOUT1
 
        qui gen     smpl_1 = 0
        qui replace smpl_1 = 1 if e(sample)==1

     eststo MEAN_1_`outcome':  estpost su `outcome'  if smpl_1 == 1 [aw=$weight]

     drop smpl_1

    ** MARGINS ** REFUGEES **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_1_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG1  =`MAROUTG'
    mat list MAROUTG1

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_1_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC1  =`MARSAMEOCC'
    mat list  MARSAMEOCC1

    svmat OUTG1
    svmat SAMEOCC1
    svmat SAMEOUT1 
    svmat MAROUTG1
    svmat MARSAMEOCC1

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG11)
    keep OUTG11 SAMEOCC11 SAMEOUT11 MAROUTG11 MARSAMEOCC11
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t1_`outcome' =mat_pval'
    matrix list     mat_pval_t1_`outcome'
    mat colnames    mat_pval_t1_`outcome' =   "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup"  
    estadd matrix   mat_pval_t1_`outcome'

restore






reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 
mat pval_`outcome' = mat_pval_t0_`outcome'[1,1],mat_pval_t0_`outcome'[1,2],mat_pval_t0_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store SEOLS_0_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store SEMAROG_0_`outcome'  

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store SEMARSO_0_`outcome'


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1
mat pval_`outcome' = mat_pval_t1_`outcome'[1,1],mat_pval_t1_`outcome'[1,2],mat_pval_t1_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store SEOLS_1_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store SEMAROG_1_`outcome'

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store SEMARSO_1_`outcome' 

}




* CREATE EMPTY MODEOL TO FILLE EMPTY COLLUMNS IN THE TABLE
preserve
    clear  
    set obs 2
    gen x = 0 
    gen y = 0 
    reg y x 
    lab var x "Nbr Refugees (ln)"
    ereturn list 
    return list
    estadd scalar N = . , replace
    eststo OLS
    estimates store M_EMPTY
    drop x y
restore



                        **********************************
                                *** TABLES ***
                        **********************************



esttab  OLS_0_prej_aind_byR OLS_1_prej_aind_byR  /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\  \multicolumn{5}{c}{\textit{PANEL A: Prejudice Index}} \\  \midrule  ") ///
        compress replace label fragment noobs wide collab(none) ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_aind_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  M_EMPTY SEOLS_0_prej_aind_byR M_EMPTY SEOLS_1_prej_aind_byR    /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
         keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup " ") ///
        cells("se(par([ ]) fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //


esttab  OLS_0_prej_aind_byR OLS_1_prej_aind_byR    /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation" ) ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_aind_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  M_EMPTY SEOLS_0_prej_aind_byR M_EMPTY SEOLS_1_prej_aind_byR    /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup " " ) ///
        cells("se(par([ ]) fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  OLS_0_prej_aind_byR OLS_1_prej_aind_byR    /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_aind_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  M_EMPTY SEOLS_0_prej_aind_byR M_EMPTY SEOLS_1_prej_aind_byR    /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup " " ) ///
        cells("se(par([ ]) fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MAROG_0_prej_aind_byR MAROG_1_prej_aind_byR   /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_aind_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  M_EMPTY SEMAROG_0_prej_aind_byR M_EMPTY SEMAROG_1_prej_aind_byR   /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup " ") ///
        cells("se(par([ ]) fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MARSO_0_prej_aind_byR  MARSO_1_prej_aind_byR   /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label wide noline collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_aind_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") 

esttab  M_EMPTY SEMARSO_0_prej_aind_byR M_EMPTY SEMARSO_1_prej_aind_byR   /// 
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label wide noline collab(none)  ///
        nonumbers noobs nomtitles   ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup " ") ///
        cells("se(par([ ]) fmt(2))") ///
        stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") 

esttab  MEAN_0_prej_aind_byR M_EMPTY MEAN_1_prej_aind_byR M_EMPTY ///
        using "$out_tab/TA14_Analysis_ClusteredSEs.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")








                



/*====================================================================
Section 6:      Experiment - Robustness by Employmnet
                Full sample, Removing wrong unemployed occupations 
                Removing all the unemployed
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/


*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byR
                  


/*====================================================================
                        1: Analysis
====================================================================*/


use "$data_final/04_UGA_ETH_Prepared.dta", clear

*replace w = 1 
*replace cluster_psu = 1 

bys ethiopia: tab qirefugee
tab region


            *********************************************
            ******* FIRST HETEROGENOUS ANALYSIS *********
            *********************************************
            ****          FULL SAMPLE               *****
            *********************************************

foreach outcome of global outcome_1 {

estimates drop _all 


    **************** 
    ***  HOSTS   ***
    ****************

preserve

    eststo MEAN_`outcome' :  estpost su `outcome'

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
     * estimates store OLS_0_`outcome', title(Model `outcome')

** EXTRACTION Q VALUES 
*BEGIN
*preserve
    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG0  =`OUTG'
    mat list OUTG0

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC0  =`SAMEOCC'
    mat list  SAMEOCC0

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT0  =`SAMEOUT'
    mat list  SAMEOUT0

        qui gen     smpl_0 = 0
        qui replace smpl_0 = 1 if e(sample)==1

     eststo MEAN_0_`outcome':  estpost su `outcome'  if smpl_0 == 1 [aw=$weight]

     drop smpl_0 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_0_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG0  =`MAROUTG'
    mat list MAROUTG0

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_0_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC0  =`MARSAMEOCC'
    mat list  MARSAMEOCC0

    svmat OUTG0
    svmat SAMEOCC0
    svmat SAMEOUT0
    svmat MAROUTG0
    svmat MARSAMEOCC0

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG01)
    keep OUTG01 SAMEOCC01 SAMEOUT01 MAROUTG01 MARSAMEOCC01
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t0_`outcome' = mat_pval'
    matrix list     mat_pval_t0_`outcome'
    mat colnames    mat_pval_t0_`outcome' = "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup" 
    estadd matrix   mat_pval_t0_`outcome'

 restore 

 preserve

    **************** 
    *** REFUGEES ***
    ****************

    reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      *estimates store OLS_1_`outcome', title(Model `outcome')

    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG1  =`OUTG'
    mat list OUTG1

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC1  =`SAMEOCC'
    mat list  SAMEOCC1

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT1  =`SAMEOUT'
    mat list  SAMEOUT1
 
        qui gen     smpl_1 = 0
        qui replace smpl_1 = 1 if e(sample)==1

     eststo MEAN_1_`outcome':  estpost su `outcome'  if smpl_1 == 1 [aw=$weight]

     drop smpl_1

    ** MARGINS ** REFUGEES **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
               ,  cluster($cluster) 
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_1_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG1  =`MAROUTG'
    mat list MAROUTG1

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_1_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC1  =`MARSAMEOCC'
    mat list  MARSAMEOCC1

    svmat OUTG1
    svmat SAMEOCC1
    svmat SAMEOUT1 
    svmat MAROUTG1
    svmat MARSAMEOCC1

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG11)
    keep OUTG11 SAMEOCC11 SAMEOUT11 MAROUTG11 MARSAMEOCC11
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t1_`outcome' =mat_pval'
    matrix list     mat_pval_t1_`outcome'
    mat colnames    mat_pval_t1_`outcome' =   "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup"  
    estadd matrix   mat_pval_t1_`outcome'

restore





preserve

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0_`outcome'[1,1],mat_pval_t0_`outcome'[1,2],mat_pval_t0_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_0_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_0_`outcome'  

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_0_`outcome'


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1_`outcome'[1,1],mat_pval_t1_`outcome'[1,2],mat_pval_t1_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store OLS_1_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store MAROG_1_`outcome'

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store MARSO_1_`outcome' 

restore




            *********************************************
            ****** SECOND HETEROGENOUS ANALYSIS *********
            *********************************************
            *** REMOVING WRONG UNEMPLOYED OCCUPATIONS ***
            *********************************************

    preserve 

    drop if flag_unemp_wrong == 1 


    **************** 
    ***  HOSTS   ***
    ****************


    eststo DMEAN_`outcome' :  estpost su `outcome'

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
     * estimates store OLS_0_`outcome', title(Model `outcome')

** EXTRACTION Q VALUES 
*BEGIN
*preserve
    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG0  =`OUTG'
    mat list OUTG0

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC0  =`SAMEOCC'
    mat list  SAMEOCC0

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT0  =`SAMEOUT'
    mat list  SAMEOUT0

        qui gen     smpl_0 = 0
        qui replace smpl_0 = 1 if e(sample)==1

     eststo DMEAN_0_`outcome':  estpost su `outcome'  if smpl_0 == 1 [aw=$weight]

     drop smpl_0 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_0_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG0  =`MAROUTG'
    mat list MAROUTG0

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_0_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC0  =`MARSAMEOCC'
    mat list  MARSAMEOCC0

    svmat OUTG0
    svmat SAMEOCC0
    svmat SAMEOUT0
    svmat MAROUTG0
    svmat MARSAMEOCC0

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG01)
    keep OUTG01 SAMEOCC01 SAMEOUT01 MAROUTG01 MARSAMEOCC01
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t0_`outcome' = mat_pval'
    matrix list     mat_pval_t0_`outcome'
    mat colnames    mat_pval_t0_`outcome' = "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup" 
    estadd matrix   mat_pval_t0_`outcome'

 restore 

 preserve

     drop if flag_unemp_wrong == 1 


    **************** 
    *** REFUGEES ***
    ****************

    reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      *estimates store OLS_1_`outcome', title(Model `outcome')

    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG1  =`OUTG'
    mat list OUTG1

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC1  =`SAMEOCC'
    mat list  SAMEOCC1

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT1  =`SAMEOUT'
    mat list  SAMEOUT1
 
        qui gen     smpl_1 = 0
        qui replace smpl_1 = 1 if e(sample)==1

     eststo DMEAN_1_`outcome':  estpost su `outcome'  if smpl_1 == 1 [aw=$weight]

     drop smpl_1

    ** MARGINS ** REFUGEES **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
               ,  cluster($cluster) 
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_1_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG1  =`MAROUTG'
    mat list MAROUTG1

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_1_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC1  =`MARSAMEOCC'
    mat list  MARSAMEOCC1

    svmat OUTG1
    svmat SAMEOCC1
    svmat SAMEOUT1 
    svmat MAROUTG1
    svmat MARSAMEOCC1

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG11)
    keep OUTG11 SAMEOCC11 SAMEOUT11 MAROUTG11 MARSAMEOCC11
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t1_`outcome' =mat_pval'
    matrix list     mat_pval_t1_`outcome'
    mat colnames    mat_pval_t1_`outcome' =   "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup"  
    estadd matrix   mat_pval_t1_`outcome'

restore




preserve

    drop if flag_unemp_wrong == 1 


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0_`outcome'[1,1],mat_pval_t0_`outcome'[1,2],mat_pval_t0_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store DOLS_0_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store DMAROG_0_`outcome'  

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store DMARSO_0_`outcome'


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1_`outcome'[1,1],mat_pval_t1_`outcome'[1,2],mat_pval_t1_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store DOLS_1_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store DMAROG_1_`outcome'

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store DMARSO_1_`outcome' 



  restore








            *********************************************
            ******* THIRD HETEROGENOUS ANALYSIS *********
            *********************************************
            ***     REMOVING ALL THE UNEMPLOYED       ***
            *********************************************

    preserve 

    drop if employed == 0 

*estimates drop _all 


    **************** 
    ***  HOSTS   ***
    ****************


    eststo EMEAN_`outcome' :  estpost su `outcome'

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
     * estimates store OLS_0_`outcome', title(Model `outcome')

** EXTRACTION Q VALUES 
*BEGIN
*preserve
    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG0  =`OUTG'
    mat list OUTG0

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC0  =`SAMEOCC'
    mat list  SAMEOCC0

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT0  =`SAMEOUT'
    mat list  SAMEOUT0

        qui gen     smpl_0 = 0
        qui replace smpl_0 = 1 if e(sample)==1

     eststo EMEAN_0_`outcome':  estpost su `outcome'  if smpl_0 == 1 [aw=$weight]

     drop smpl_0 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_0_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG0  =`MAROUTG'
    mat list MAROUTG0

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_0_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC0  =`MARSAMEOCC'
    mat list  MARSAMEOCC0

    svmat OUTG0
    svmat SAMEOCC0
    svmat SAMEOUT0
    svmat MAROUTG0
    svmat MARSAMEOCC0

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG01)
    keep OUTG01 SAMEOCC01 SAMEOUT01 MAROUTG01 MARSAMEOCC01
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t0_`outcome' = mat_pval'
    matrix list     mat_pval_t0_`outcome'
    mat colnames    mat_pval_t0_`outcome' = "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup" 
    estadd matrix   mat_pval_t0_`outcome'

 restore 

 preserve

      drop if employed == 0 


    **************** 
    *** REFUGEES ***
    ****************

    reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      *estimates store OLS_1_`outcome', title(Model `outcome')

    local OUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb1 =string(round(`OUTG',.001),"%9.3f")
    mat OUTG1  =`OUTG'
    mat list OUTG1

    local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
    mat SAMEOCC1  =`SAMEOCC'
    mat list  SAMEOCC1

    local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup#1.exp_same_occup]/_se[1.exp_outgroup#1.exp_same_occup])))  
    local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
    mat SAMEOUT1  =`SAMEOUT'
    mat list  SAMEOUT1
 
        qui gen     smpl_1 = 0
        qui replace smpl_1 = 1 if e(sample)==1

     eststo EMEAN_1_`outcome':  estpost su `outcome'  if smpl_1 == 1 [aw=$weight]

     drop smpl_1

    ** MARGINS ** REFUGEES **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
               ,  cluster($cluster) 
    margins , dydx(exp_outgroup) post
    *estimates store MAROG_1_`outcome', title(Model `outcome')

    local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.exp_outgroup]/_se[1.exp_outgroup])))  
    local pb4 =string(round(`MAROUTG',.001),"%9.3f")
    mat MAROUTG1  =`MAROUTG'
    mat list MAROUTG1

    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    *estimates store MARSO_1_`outcome', title(Model `outcome')

    local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.exp_same_occup]/_se[1.exp_same_occup])))  
    local pb5 =string(round(`MARSAMEOCC',.001),"%9.3f")
    mat MARSAMEOCC1  =`MARSAMEOCC'
    mat list  MARSAMEOCC1

    svmat OUTG1
    svmat SAMEOCC1
    svmat SAMEOUT1 
    svmat MAROUTG1
    svmat MARSAMEOCC1

    *ONLY KEEP THE BETAS AND PVALUES
    keep if !mi(OUTG11)
    keep OUTG11 SAMEOCC11 SAMEOUT11 MAROUTG11 MARSAMEOCC11
    xpose  , clear   varname f(%9.2fc)

    ren v1 pval 
    set more on

    do "$do/2a.fdr_qvalues.do"
    drop original_sorting_order rank pval

    mkmat           bky06_qval , mat(mat_pval) 
    mat             mat_pval_t1_`outcome' =mat_pval'
    matrix list     mat_pval_t1_`outcome'
    mat colnames    mat_pval_t1_`outcome' =   "1.exp_outgroup" "1.exp_same_occup" ///
                                    "1.exp_outgroup#1.exp_same_occup" ///
                                    "1.exp_outgroup" "1.exp_same_occup"  
    estadd matrix   mat_pval_t1_`outcome'

restore






preserve

    drop if employed == 0 


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0_`outcome'[1,1],mat_pval_t0_`outcome'[1,2],mat_pval_t0_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store EOLS_0_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store EMAROG_0_`outcome'  

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t0_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store EMARSO_0_`outcome'


reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1_`outcome'[1,1],mat_pval_t1_`outcome'[1,2],mat_pval_t1_`outcome'[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.exp_outgroup" "1.exp_same_occup"  "1.exp_outgroup#1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store EOLS_1_`outcome'

reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,4] 
mat colnames pval_`outcome'= "1.exp_outgroup"
estadd matrix pval_`outcome'
estimates store EMAROG_1_`outcome'

reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
margins , dydx(exp_same_occup) post
mat pval_`outcome' = mat_pval_t1_`outcome'[1,5] 
mat colnames pval_`outcome'= "1.exp_same_occup"
estadd matrix pval_`outcome'
estimates store EMARSO_1_`outcome' 


  restore


        ******************************
        ********** TABLES ************
        ******************************



* CREATE EMPTY MODEOL TO FILLE EMPTY COLLUMNS IN THE TABLE
preserve
    clear  
    set obs 2
    gen x = 0 
    gen y = 0 
    reg y x 
    lab var x "Nbr Refugees (ln)"
    ereturn list 
    return list
    estadd scalar N = . , replace
    eststo OLS
    estimates store M_EMPTY
    drop x y
restore


*OLS 
esttab  OLS_0_`outcome' OLS_1_`outcome'  /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\  \multicolumn{5}{c}{\textit{PANEL A: Full Sample of Employed and Unemployed}} \\  \midrule ") ///
        compress replace label fragment noobs wide ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  OLS_0_`outcome' OLS_1_`outcome'  /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label wide noline ///
        nonumbers noobs nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAROG_0_`outcome' MAROG_1_`outcome'   /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label wide noline ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARSO_0_`outcome' MARSO_1_`outcome'   /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label wide noline ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
         stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        prefoot(" ") //

esttab  MEAN_0_`outcome' M_EMPTY MEAN_1_`outcome' M_EMPTY ///
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
       starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean")


**************************************
**** REMOVING THE ODD STATEMENTS *****
**************************************

esttab  DOLS_0_`outcome' DOLS_1_`outcome'  /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL B: SubSet of Cleaned Unemployed Occupations}} \\  \midrule ") ///
        fragment append label wide noobs noline ///
        nonumbers nomtitles ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  DOLS_0_`outcome' DOLS_1_`outcome'  /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label wide noline ///
        nonumbers noobs nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  DMAROG_0_`outcome' DMAROG_1_`outcome'   /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label wide noline ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  DMARSO_0_`outcome' DMARSO_1_`outcome'   /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label wide noline ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        prefoot(" ") //

esttab  DMEAN_0_`outcome' M_EMPTY DMEAN_1_`outcome' M_EMPTY ///
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") 



*************************************
**** REMOVING THE ALL UNEMPLOYED ****
*************************************

esttab  EOLS_0_`outcome' EOLS_1_`outcome'  /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        posthead(" \multicolumn{5}{c}{\textit{PANEL C: Employed Only}} \\  \midrule ") ///
        fragment append label wide noobs noline ///
        nonumbers nomtitles ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //


esttab  EOLS_0_`outcome' EOLS_1_`outcome'  /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label wide noline ///
        nonumbers noobs nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  EMAROG_0_`outcome' EMAROG_1_`outcome'   /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label wide noline ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  EMARSO_0_`outcome' EMARSO_1_`outcome'   /// 
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label wide noline ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //


esttab  EMEAN_0_`outcome' M_EMPTY EMEAN_1_`outcome' M_EMPTY ///
        using "$out_tab/TA15_Analysis_EmploymentDef.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")





}










/*====================================================================
Section 7:       Experiment - PValues and Comparison in mean
----------------------------------------------------------------------
====================================================================*/

/*====================================================================
                       0: Set Up
====================================================================*/


*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global weight   w 



/*====================================================================
                       1: Analysis
====================================================================*/


use "$data_final/04_UGA_ETH_Prepared.dta", clear


    *****************
    * ADDIS - HOSTS *
    *****************

    reg prej_aind_byL i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 1 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETAD1_0_prej_aind_byL, title(Model prej_aind_byL)

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MAD1_0_prej_aind_byL:  estpost su prej_aind_byL  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOSTS**
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 1 
    margins , dydx(exp_outgroup) post
    estimates store MARADOG1_0_prej_aind_byL, title(Model prej_aind_byL)
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 1 
    margins , dydx(exp_same_occup) post
    estimates store MARADSO1_0_prej_aind_byL, title(Model prej_aind_byL)

    ******************
    * JIJIGA - HOSTS *
    ******************

    reg prej_aind_byL i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 2  

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETJI2_0_prej_aind_byL, title(Model prej_aind_byL)

        qui gen     smpl2_0 = 0
        qui replace smpl2_0 = 1 if e(sample)==1

     eststo MJI2_0_prej_aind_byL:  estpost su prej_aind_byL  if smpl2_0 == 1 [aw=$weight]

        drop smpl2_0

    ** MARGINS ** HOSTS **
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 2  
    margins , dydx(exp_outgroup) post
    estimates store MARJIOG2_0_prej_aind_byL, title(Model prej_aind_byL)
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 2 
    margins , dydx(exp_same_occup) post
    estimates store MARJISO2_0_prej_aind_byL, title(Model prej_aind_byL)

    *******************
    * KAMPALA - HOSTS *
    *******************

   reg prej_aind_byL i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 3   
      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETKA3_0_prej_aind_byL, title(Model prej_aind_byL)

        qui gen     smpl3_0 = 0
        qui replace smpl3_0 = 1 if e(sample)==1

     eststo MKA3_0_prej_aind_byL:  estpost su prej_aind_byL  if smpl3_0 == 1 [aw=$weight]

        drop smpl3_0

    ** MARGINS ** HOSTS **
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 3  
    margins , dydx(exp_outgroup) post
    estimates store MARKAOG3_0_prej_aind_byL, title(Model prej_aind_byL)
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 3 
    margins , dydx(exp_same_occup) post
    estimates store MARKASO3_0_prej_aind_byL, title(Model prej_aind_byL)


    ******************
    *ISINGIRO - HOSTS*
    ******************

   reg prej_aind_byL i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 4   

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETIS4_0_prej_aind_byL, title(Model prej_aind_byL)

        qui gen     smpl4_0 = 0
        qui replace smpl4_0 = 1 if e(sample)==1

     eststo MIS4_0_prej_aind_byL:  estpost su prej_aind_byL  if smpl4_0 == 1 [aw=$weight]

        drop smpl4_0

    ** MARGINS ** HOSTS **
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 4  
    margins , dydx(exp_outgroup) post
    estimates store MARISOG4_0_prej_aind_byL, title(Model prej_aind_byL)
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 4 
    margins , dydx(exp_same_occup) post
    estimates store MARISSO4_0_prej_aind_byL, title(Model prej_aind_byL)


    ********************
    * ADDIS - REFUGEES *
    ********************

    reg prej_aind_byL i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 1  

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETAD1_1_prej_aind_byL, title(Model prej_aind_byL)

        qui gen     smpl1_1 = 0
        qui replace smpl1_1 = 1 if e(sample)==1

     eststo MAD1_1_prej_aind_byL:  estpost su prej_aind_byL  if smpl1_1 == 1 [aw=$weight]

        drop smpl1_1
    
    ** MARGINS ** HOSTS **
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 1 
    margins , dydx(exp_outgroup) post
    estimates store MARADOG1_1_prej_aind_byL, title(Model prej_aind_byL)
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 1  
    margins , dydx(exp_same_occup) post
    estimates store MARADSO1_1_prej_aind_byL, title(Model prej_aind_byL)

    *********************
    * JIJIGA - REFUGEES *
    *********************

    reg prej_aind_byL i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 2 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETJI2_1_prej_aind_byL, title(Model prej_aind_byL)

        qui gen     smpl2_1 = 0
        qui replace smpl2_1 = 1 if e(sample)==1

     eststo MJI2_1_prej_aind_byL:  estpost su prej_aind_byL  if smpl2_1 == 1 [aw=$weight]

        drop smpl2_1

    ** MARGINS ** HOSTS **
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 2 
    margins , dydx(exp_outgroup) post
    estimates store MARJIOG2_1_prej_aind_byL, title(Model prej_aind_byL)
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 2 
    margins , dydx(exp_same_occup) post
    estimates store MARJISO2_1_prej_aind_byL, title(Model prej_aind_byL)


    *********************
    * KAMPALA -REFUGEES *
    *********************

    reg prej_aind_byL i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 3 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETKA3_1_prej_aind_byL, title(Model prej_aind_byL)

        qui gen     smpl3_1 = 0
        qui replace smpl3_1 = 1 if e(sample)==1

     eststo MKA3_1_prej_aind_byL:  estpost su prej_aind_byL  if smpl3_1 == 1 [aw=$weight]

        drop smpl3_1

    ** MARGINS ** HOSTS **
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 3 
    margins , dydx(exp_outgroup) post
    estimates store MARKAOG3_1_prej_aind_byL, title(Model prej_aind_byL)
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 3 
    margins , dydx(exp_same_occup) post
    estimates store MARKASO3_1_prej_aind_byL, title(Model prej_aind_byL)


    ***********************
    * ISINGIRO - REFUGEES *
    ***********************

        reg prej_aind_byL i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 4 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETIS4_1_prej_aind_byL, title(Model prej_aind_byL)

        qui gen     smpl4_1 = 0
        qui replace smpl4_1 = 1 if e(sample)==1

     eststo MIS4_1_prej_aind_byL:  estpost su prej_aind_byL  if smpl4_1 == 1 [aw=$weight]

        drop smpl4_1

    ** MARGINS ** HOSTS **
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 4 
    margins , dydx(exp_outgroup) post
    estimates store MARISOG4_1_prej_aind_byL, title(Model prej_aind_byL)
    qui reg prej_aind_byL i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 4 
    margins , dydx(exp_same_occup) post
    estimates store MARISSO4_1_prej_aind_byL, title(Model prej_aind_byL)


***********************************************
*** WITH RESPECT TO ADDIS ABABA AS BASELINE ***
***********************************************

// Extract p-values from hypothesis tests and store as local macros

// **Addis Ababa vs Jijiga**
suest HETAD1_0_prej_aind_byL HETJI2_0_prej_aind_byL, cluster(cluster_psu)

// OutGroup comparison
test _b[HETAD1_0_prej_aind_byL_mean:1.exp_outgroup] = _b[HETJI2_0_prej_aind_byL_mean:1.exp_outgroup]
local p_AD_JI_OG = string(r(p), "%9.2f")

// Same Occupation comparison
test _b[HETAD1_0_prej_aind_byL_mean:1.exp_same_occup] = _b[HETJI2_0_prej_aind_byL_mean:1.exp_same_occup]
local p_AD_JI_SO = string(r(p), "%9.2f")

// Interaction comparison
test _b[HETAD1_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup] = _b[HETJI2_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup]
local p_AD_JI_OGxSO = string(r(p), "%9.2f")

// **Addis Ababa vs Kampala**
suest HETAD1_0_prej_aind_byL HETKA3_0_prej_aind_byL, cluster(cluster_psu)

// OutGroup comparison
test _b[HETAD1_0_prej_aind_byL_mean:1.exp_outgroup] = _b[HETKA3_0_prej_aind_byL_mean:1.exp_outgroup]
local p_AD_KA_OG = string(r(p), "%9.2f")

// Same Occupation comparison
test _b[HETAD1_0_prej_aind_byL_mean:1.exp_same_occup] = _b[HETKA3_0_prej_aind_byL_mean:1.exp_same_occup]
local p_AD_KA_SO = string(r(p), "%9.2f")

// Interaction comparison
test _b[HETAD1_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup] = _b[HETKA3_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup]
local p_AD_KA_OGxSO = string(r(p), "%9.2f")

// **Addis Ababa vs Isingir**
suest HETAD1_0_prej_aind_byL HETIS4_0_prej_aind_byL, cluster(cluster_psu)

// OutGroup comparison
test _b[HETAD1_0_prej_aind_byL_mean:1.exp_outgroup] = _b[HETIS4_0_prej_aind_byL_mean:1.exp_outgroup]
local p_AD_IS_OG = string(r(p), "%9.2f")

// Same Occupation comparison
test _b[HETAD1_0_prej_aind_byL_mean:1.exp_same_occup] = _b[HETIS4_0_prej_aind_byL_mean:1.exp_same_occup]
local p_AD_IS_SO = string(r(p), "%9.2f")

// Interaction comparison
test _b[HETAD1_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup] = _b[HETIS4_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup]
local p_AD_IS_OGxSO = string(r(p), "%9.2f")




*********************************************
**** WITH RESPECT TO ISINGIRO AS BASELINE ***
*********************************************

// **Isingiro vs Addis Ababa**
suest HETIS4_0_prej_aind_byL HETAD1_0_prej_aind_byL, cluster(cluster_psu)

// OutGroup comparison
test _b[HETIS4_0_prej_aind_byL_mean:1.exp_outgroup] = _b[HETAD1_0_prej_aind_byL_mean:1.exp_outgroup]
local p_IS_AD_OG = string(r(p), "%9.2f")

// Same Occupation comparison
test _b[HETIS4_0_prej_aind_byL_mean:1.exp_same_occup] = _b[HETAD1_0_prej_aind_byL_mean:1.exp_same_occup]
local p_IS_AD_SO = string(r(p), "%9.2f")

// Interaction comparison
test _b[HETIS4_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup] = _b[HETAD1_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup]
local p_IS_AD_OGxSO = string(r(p), "%9.2f")


// **Isingiro vs Jijiga**
suest HETIS4_0_prej_aind_byL HETJI2_0_prej_aind_byL, cluster(cluster_psu)

// OutGroup comparison
test _b[HETIS4_0_prej_aind_byL_mean:1.exp_outgroup] = _b[HETJI2_0_prej_aind_byL_mean:1.exp_outgroup]
local p_IS_JI_OG = string(r(p), "%9.2f")

// Same Occupation comparison
test _b[HETIS4_0_prej_aind_byL_mean:1.exp_same_occup] = _b[HETJI2_0_prej_aind_byL_mean:1.exp_same_occup]
local p_IS_JI_SO = string(r(p), "%9.2f")

// Interaction comparison
test _b[HETIS4_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup] = _b[HETJI2_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup]
local p_IS_JI_OGxSO = string(r(p), "%9.2f")


// **Isingiro vs Kampala**
suest HETIS4_0_prej_aind_byL HETKA3_0_prej_aind_byL, cluster(cluster_psu)

// OutGroup comparison
test _b[HETIS4_0_prej_aind_byL_mean:1.exp_outgroup] = _b[HETKA3_0_prej_aind_byL_mean:1.exp_outgroup]
local p_IS_KA_OG = string(r(p), "%9.2f")

// Same Occupation comparison
test _b[HETIS4_0_prej_aind_byL_mean:1.exp_same_occup] = _b[HETKA3_0_prej_aind_byL_mean:1.exp_same_occup]
local p_IS_KA_SO = string(r(p), "%9.2f")

// Interaction comparison
test _b[HETIS4_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup] = _b[HETKA3_0_prej_aind_byL_mean:1.exp_outgroup#1.exp_same_occup]
local p_IS_KA_OGxSO = string(r(p), "%9.2f")



** PANEL A

// Export main table
esttab HETAD1_0_prej_aind_byL HETJI2_0_prej_aind_byL HETKA3_0_prej_aind_byL HETIS4_0_prej_aind_byL    ///  
        using "$out_tab/TA17_Analysis_PValues.tex",  ///
        prehead("\begin{tabular}{l*{8}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{Variable}}} & \multicolumn{2}{c}{\textit{\textbf{Addis Ababa}}} & \multicolumn{2}{c}{\textit{\textbf{Jijiga/Kebribeyah}}} & \multicolumn{2}{c}{\textit{\textbf{Kampala}}} & \multicolumn{2}{c}{\textit{\textbf{Isingiro/Nakivale}}} \\ \midrule  \multicolumn{8}{l}{\textbf{Panel A: Regression Coefficients (Addis Ababa as Baseline)}} \\   ") ///
        compress replace label fragment noobs wide nonumbers ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) nose starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " " " " " ") ///
        prefoot(" ") // 

// Open LaTeX file to append p-values
file open myfile using "$out_tab/TA17_Analysis_PValues.tex", write append
file write myfile "Difference of $\alpha_1$ to baseline (Addis Ababa) & & &  p = `p_AD_JI_OG' & & p = `p_AD_KA_OG' & & p = `p_AD_IS_OG' & \\ "
file close myfile

// Export main table
esttab HETAD1_0_prej_aind_byL HETJI2_0_prej_aind_byL HETKA3_0_prej_aind_byL HETIS4_0_prej_aind_byL    ///  
        using "$out_tab/TA17_Analysis_PValues.tex",  ///
        compress fragment append label wide noobs noline nonumbers nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) nose starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") // 

// Open LaTeX file to append p-values
file open myfile using "$out_tab/TA17_Analysis_PValues.tex", write append
file write myfile "Difference of $\alpha_2$ to baseline (Addis Ababa) & & & p = `p_AD_JI_SO' & & p = `p_AD_KA_SO' & & p = `p_AD_IS_SO' & \\ "
file close myfile

// Export main table
esttab HETAD1_0_prej_aind_byL HETJI2_0_prej_aind_byL HETKA3_0_prej_aind_byL HETIS4_0_prej_aind_byL    ///  
        using "$out_tab/TA17_Analysis_PValues.tex",  ///
        compress fragment append label wide noobs noline nonumbers nomtitles ///
        keep(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///
        b(%8.2f) nose starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") // 

// Open LaTeX file to append p-values
file open myfile using "$out_tab/TA17_Analysis_PValues.tex", write append
file write myfile "Difference of $\alpha_3$ to baseline (Addis Ababa) & & & p = `p_AD_JI_OGxSO' & & p = `p_AD_KA_OGxSO' & & p = `p_AD_IS_OGxSO' & \\ "
file close myfile
 
esttab  MAD1_0_prej_aind_byL M_EMPTY MJI2_0_prej_aind_byL M_EMPTY MKA3_0_prej_aind_byL M_EMPTY MIS4_0_prej_aind_byL M_EMPTY ///
        using "$out_tab/TA17_Analysis_PValues.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Addis"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") 



*** PANEL B 

// Export main table
esttab HETAD1_0_prej_aind_byL HETJI2_0_prej_aind_byL HETKA3_0_prej_aind_byL HETIS4_0_prej_aind_byL    ///  
        using "$out_tab/TA17_Analysis_PValues.tex",  ///
        posthead("  \midrule  \multicolumn{8}{l}{\textbf{Panel B: Regression Coefficients (Isingiro as Baseline)}} \\   ") ///
        compress fragment append label wide noobs noline nonumbers nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) nose starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") // 

// Open LaTeX file to append p-values
file open myfile using "$out_tab/TA17_Analysis_PValues.tex", write append
file write myfile "Difference of $\alpha_1$ to baseline (Isingiro) &  p = `p_IS_AD_OG' & & p = `p_IS_JI_OG' & & p = `p_IS_KA_OG' & & &  \\ "
file close myfile

// Export main table
esttab HETAD1_0_prej_aind_byL HETJI2_0_prej_aind_byL HETKA3_0_prej_aind_byL HETIS4_0_prej_aind_byL    ///  
        using "$out_tab/TA17_Analysis_PValues.tex",  ///
        compress fragment append label wide noobs noline nonumbers nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) nose starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") // 


// Open LaTeX file to append p-values
file open myfile using "$out_tab/TA17_Analysis_PValues.tex", write append
file write myfile "Difference of $\alpha_2$ to baseline (Isingiro) & p = `p_IS_AD_SO' & & p = `p_IS_JI_SO' & & p = `p_IS_KA_SO' & & &  \\ "
file close myfile

// Export main table
esttab HETAD1_0_prej_aind_byL HETJI2_0_prej_aind_byL HETKA3_0_prej_aind_byL HETIS4_0_prej_aind_byL    ///  
        using "$out_tab/TA17_Analysis_PValues.tex",  ///
        compress fragment append label wide noobs noline nonumbers nomtitles ///
        keep(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///
        b(%8.2f) nose starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") // 

// Open LaTeX file to append p-values
file open myfile using "$out_tab/TA17_Analysis_PValues.tex", write append
file write myfile "Difference of $\alpha_3$ to baseline (Isingiro) & p = `p_IS_AD_OGxSO' & & p = `p_IS_JI_OGxSO' & & p = `p_IS_KA_OGxSO' & & & \\ "
file close myfile
 
esttab  MAD1_0_prej_aind_byL M_EMPTY MJI2_0_prej_aind_byL M_EMPTY MKA3_0_prej_aind_byL M_EMPTY MIS4_0_prej_aind_byL M_EMPTY ///
        using "$out_tab/TA17_Analysis_PValues.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Isingiro"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")








        

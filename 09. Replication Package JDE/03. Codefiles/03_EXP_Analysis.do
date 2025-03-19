
/*====================================================================
project:       Experiment - Analysis Do File
Authors:       Julie Bousquet/Mark Marvin Kadigo/Anna Gasten 
Description    

This do file generates
            - Section 1 - Main analysis: Table A11:     TA11_Analysis_PrejudiceIndex
            - Section 2 - Main analysis: Figure 4:  FIG4_CFP_Analysis
            - Section 3 - By localities: Table A16: TA16_Analysis_byLocality
            - Section 4 - By localities: Figure 5:  FIG5_CFP_Analysis_byLocalities

*Note: the following dofiles uses the dofile to correct 
*for MHT "$do/2a.fdr_qvalues.do"

----------------------------------------------------------------------
Creation Date:    30-10-2022
====================================================================*/






/*====================================================================
Section 1:       Experiment - Analysis 
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster 	cluster_psu 
global weight 	w 

global outcome_1    prej_aind_byR // anderson index by refugee


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


********************************************
************* PREJUDICE INDEX **************
********************************************

esttab  OLS_0_prej_aind_byR OLS_1_prej_aind_byR  /// 
        using "$out_tab/TA11_Analysis_PrejudiceIndex.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\  \multicolumn{5}{c}{\textit{PANEL A: Prejudice Index}} \\  \midrule  ") ///
        compress replace label fragment noobs wide collab(none) ///
        keep(1.exp_outgroup 1.exp_same_occup 1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation" ///
                 1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_aind_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  MAROG_0_prej_aind_byR MAROG_1_prej_aind_byR   /// 
        using "$out_tab/TA11_Analysis_PrejudiceIndex.tex",  ///
        compress fragment append label wide noline  collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_outgroup) ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_aind_byR) star) se(par fmt(2))") ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") //

esttab  MARSO_0_prej_aind_byR  MARSO_1_prej_aind_byR   /// 
        using "$out_tab/TA11_Analysis_PrejudiceIndex.tex",  ///
        compress fragment append label wide noline collab(none)  ///
        nonumbers noobs nomtitles ///
        keep(1.exp_same_occup) ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        cells("b(fmt(%8.2f) pvalue(pval_prej_aind_byR) star) se(par fmt(2))") ///
        stats(N, fmt(0) labels("\\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        starlevels(* 0.1 ** 0.05 *** 0.01)    ///
        prefoot(" ") 

esttab  MEAN_0_prej_aind_byR M_EMPTY MEAN_1_prej_aind_byR M_EMPTY ///
        using "$out_tab/TA11_Analysis_PrejudiceIndex.tex",  ///
        compress fragment append label noobs nonumbers nomtitles wide ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")







/*====================================================================
Section 2:       Experiment - Coefplots Main Analysis
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/


*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byR // anderson index by refugee
      

/*====================================================================
                        1: Analysis
====================================================================*/


use "$data_final/04_UGA_ETH_Prepared.dta", clear
 

    *****************************
    * **** OLS REGRESSIONS **** *
    *****************************

    gen A1_exp_outgroup = exp_outgroup
    gen A1_exp_same_occup = exp_same_occup

    gen A2_exp_outgroup = exp_outgroup
    gen A2_exp_same_occup = exp_same_occup

    gen H3_exp_outgroup = exp_outgroup
    gen H3_exp_same_occup = exp_same_occup

    gen H1_exp_outgroup = exp_outgroup
    gen H1_exp_same_occup = exp_same_occup

    gen H2_exp_outgroup = exp_outgroup
    gen H2_exp_same_occup = exp_same_occup


foreach outcome of global outcome_1 {

    *** HOSTS ***

        preserve 

            ** alpha 1 
            reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                        , cluster($cluster) 
            *estimates store A1_0_`outcome' 
    
            local OUTG = (2 * ttail(e(df_r), abs(_b[1.A1_exp_outgroup]/_se[1.A1_exp_outgroup])))  
            local pb1 =string(round(`OUTG',.001),"%9.3f")
            mat OUTG0  =`OUTG'
            mat list OUTG0

            ** alpha 2 
            reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                        , cluster($cluster)
            *estimates store A2_0_`outcome' 

            local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.A2_exp_same_occup]/_se[1.A2_exp_same_occup])))  
            local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
            mat SAMEOCC0  =`SAMEOCC'
            mat list  SAMEOCC0

            ** H3 
            reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                        , cluster($cluster)
            *estimates store H3_0_`outcome' 

            local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.H3_exp_outgroup#1.H3_exp_same_occup]/_se[1.H3_exp_outgroup#1.H3_exp_same_occup])))  
            local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
            mat SAMEOUT0  =`SAMEOUT'
            mat list  SAMEOUT0

            ** MARGINS ****
            ** H1 
            qui reg `outcome' i.H1_exp_outgroup##i.H1_exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                        , cluster($cluster)
            margins , dydx(H1_exp_outgroup) post
            *estimates store H1_0_`outcome' 

            local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.H1_exp_outgroup]/_se[1.H1_exp_outgroup])))  
            local pb4 =string(round(`MAROUTG',.001),"%9.3f")
            mat MAROUTG0  =`MAROUTG'
            mat list MAROUTG0

            ** H2
            qui reg `outcome' i.H2_exp_outgroup##i.H2_exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                        , cluster($cluster)
            margins , dydx(H2_exp_same_occup) post
            *estimates store H2_0_`outcome' 

            local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.H2_exp_same_occup]/_se[1.H2_exp_same_occup])))  
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
            mat             mat_pval_t0 = mat_pval'
            matrix list     mat_pval_t0
            mat colnames    mat_pval_t0 =  "1.A1_exp_outgroup" "1.A2_exp_same_occup" ///
                                            "1.H3_exp_outgroup#1.H3_exp_same_occup" ///
                                            "1.H1_exp_outgroup" "1.H2_exp_same_occup"  
            estadd matrix   mat_pval_t0

        restore

    *** REFUGEES ***
        preserve 

            ** alpha 1
            reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                        , cluster($cluster)
            *estimates store A1_1_`outcome' 

            local OUTG = (2 * ttail(e(df_r), abs(_b[1.A1_exp_outgroup]/_se[1.A1_exp_outgroup])))  
            local pb1 =string(round(`OUTG',.001),"%9.3f")
            mat OUTG1  =`OUTG'
            mat list OUTG1

            ** alpha 2 
            reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                        , cluster($cluster)
            *estimates store A2_1_`outcome' 

            local SAMEOCC = (2 * ttail(e(df_r), abs(_b[1.A2_exp_same_occup]/_se[1.A2_exp_same_occup])))  
            local pb2 =string(round(`SAMEOCC',.001),"%9.3f")
            mat SAMEOCC1  =`SAMEOCC'
            mat list  SAMEOCC1

            ** H3 
            reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                        , cluster($cluster)
            *estimates store H3_1_`outcome' 

            local SAMEOUT = (2 * ttail(e(df_r), abs(_b[1.H3_exp_outgroup#1.H3_exp_same_occup]/_se[1.H3_exp_outgroup#1.H3_exp_same_occup])))  
            local pb3 =string(round(`SAMEOUT',.001),"%9.3f")
            mat SAMEOUT1  =`SAMEOUT'
            mat list  SAMEOUT1

          ** MARGINS ****
            ** H1 
            qui reg `outcome' i.H1_exp_outgroup##i.H1_exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                        , cluster($cluster)
            margins , dydx(H1_exp_outgroup) post
            *estimates store H1_1_`outcome' 

            local MAROUTG = (2 * ttail(e(df_r), abs(_b[1.H1_exp_outgroup]/_se[1.H1_exp_outgroup])))  
            local pb4 =string(round(`MAROUTG',.001),"%9.3f")
            mat MAROUTG1  =`MAROUTG'
            mat list MAROUTG1

            ** H2
            qui reg `outcome' i.H2_exp_outgroup##i.H2_exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                        , cluster($cluster)
            margins , dydx(H2_exp_same_occup) post
            *estimates store H2_1_`outcome' 
         
            local MARSAMEOCC = (2 * ttail(e(df_r), abs(_b[1.H2_exp_same_occup]/_se[1.H2_exp_same_occup])))  
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
            mat             mat_pval_t1 =mat_pval'
            matrix list     mat_pval_t1
            mat colnames    mat_pval_t1 =   "1.A1_exp_outgroup" "1.A2_exp_same_occup" ///
                                            "1.H3_exp_outgroup#1.H3_exp_same_occup" ///
                                            "1.H1_exp_outgroup" "1.H2_exp_same_occup"  
            estadd matrix   mat_pval_t1

    restore

*************
*** HOSTS ***
*************

*A1
reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0[1,1]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.A1_exp_outgroup"
estadd matrix pval_`outcome'
estimates store A1_0_`outcome'

*A2
reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0[1,2]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.A2_exp_same_occup" 
estadd matrix pval_`outcome'
estimates store A2_0_`outcome'

*H3
reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t0[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'=  "1.H3_exp_outgroup#1.H3_exp_same_occup"
estadd matrix pval_`outcome'
estimates store H3_0_`outcome'

*H1
reg `outcome' i.H1_exp_outgroup##i.H1_exp_same_occup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
    margins , dydx(H1_exp_outgroup) post
mat pval_`outcome' = mat_pval_t0[1,4] 
mat colnames pval_`outcome'= "1.H1_exp_outgroup"
estadd matrix pval_`outcome'
estimates store H1_0_`outcome'  

*H2
reg `outcome' i.H2_exp_same_occup##i.H2_exp_outgroup $controls [aw=$weight] if refugee == 0 ///
                , cluster($cluster)
margins , dydx(H2_exp_same_occup) post
mat pval_`outcome' = mat_pval_t0[1,5] 
mat colnames pval_`outcome'= "1.H2_exp_same_occup"
estadd matrix pval_`outcome'
estimates store H2_0_`outcome'

***************
*** REFUGEE ***
***************

*A1
reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1[1,1]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.A1_exp_outgroup"
estadd matrix pval_`outcome'
estimates store A1_1_`outcome'

*A2
reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1[1,2]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.A2_exp_same_occup"
estadd matrix pval_`outcome'
estimates store A2_1_`outcome'

*H3
reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
mat pval_`outcome' = mat_pval_t1[1,3]
matrix list pval_`outcome'
mat colnames pval_`outcome'= "1.H3_exp_outgroup#1.H3_exp_same_occup"
estadd matrix pval_`outcome'
estimates store H3_1_`outcome'

*H1
reg `outcome' i.H1_exp_outgroup##i.H1_exp_same_occup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
margins , dydx(H1_exp_outgroup) post
mat pval_`outcome' = mat_pval_t1[1,4] 
mat colnames pval_`outcome'= "1.H1_exp_outgroup"
estadd matrix pval_`outcome'
estimates store H1_1_`outcome'

*H2
reg `outcome' i.H2_exp_same_occup##i.H2_exp_outgroup $controls [aw=$weight] if refugee == 1 ///
                , cluster($cluster)
margins , dydx(H2_exp_same_occup) post
mat pval_`outcome' = mat_pval_t1[1,5] 
mat colnames pval_`outcome'= "1.H2_exp_same_occup"
estadd matrix pval_`outcome'
estimates store H2_1_`outcome' 

} 


foreach outcome of global outcome_1 {


*set scheme plotplainblind
*graph set window fontface "Arial Narrow"

 coefplot(A1_0_`outcome', offset(1) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) ) ) label("") msymbol(d) mlwidth(thick) mlabgap(*2) mlabsize(small) ///
             mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6) levels(90)   ciopts(lwidth(thick) lcolor(gs6))) ///
            (A2_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s)  mlwidth(thick) mlabgap(*2) mlabsize(small) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) ciopts(lwidth(thick)  lcolor(gs6))) ///
            (H3_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t) mlabgap(*2) mlwidth(thick) mlabsize(small)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) ciopts(lwidth(thick) lcolor(gs6))) ///
                 , bylabel("Hosts")   ///
            || (A1_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(d) mlabgap(*2) mlwidth(thick) mlabsize(small)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) ciopts(lwidth(thick) lcolor(gs6))) ///
             (A2_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s) mlabgap(*2) mlwidth(thick) mlabsize(small)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) ciopts(lwidth(thick) lcolor(gs6)))  ///
             (H3_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t) mlabgap(*2) mlwidth(thick)  mlabsize(small)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) ciopts(lwidth(thick)  lcolor(gs6))) ///
          , bylabel("Refugees")  ///
            ||  , keep(1.A1_exp_outgroup 1.A2_exp_same_occup ///
                1.H3_exp_outgroup#1.H3_exp_same_occup) ///
            xline(0, lpattern(dash) lcolor(black)) msymbol(d)  ///
              label subtitle(, size(large) fcolor(white) nobox ) ///
             xlabel("")   ///
               mlabposition(15) mlabsize(large) ///
             byopts( graphregion(color(white) margin(zero) ) bgcolor(white) ///
              title(" ", size(large)) ///
              legend(off) plotregion(margin(zero)) )  ///
                  xscale( noline alt )   lwidth(large ) ///
              xla(none)  xtitle("") yscale(noline  ) xlabel(,  noticks) bylabel(, noticks)  ///
            coeflabel(1.A1_exp_outgroup= "{&alpha}1, Out Group" 1.A2_exp_same_occup= "{&alpha}2, Same Occupation" ///
                1.H3_exp_outgroup#1.H3_exp_same_occup = "{&alpha}3, Out Group * Same Occupation", labsize(small) wrap(15)) ///
            ylabel(, tlstyle(none) angle(horizontal)) subtitle(, size(medium))


graph export "$out_fig/FIG4_CFP_Analysis.pdf",   replace

}









/*====================================================================
Section 3:       Experiment - Analysis by locality
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1   prej_aind_byL 

/*====================================================================
                        1: Analysis
====================================================================*/


use "$data_final/04_UGA_ETH_Prepared.dta", clear


foreach outcome of global outcome_1 {
 

******************************************************
************* HETEROGENEITY BY LOCALITY **************
******************************************************

    *****************
    * ADDIS - HOSTS *
    *****************

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 1 ///
                , cluster($cluster) 

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETAD1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MAD1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 1   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARADOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 1 ///
               ,  cluster($cluster) 
    margins , dydx(exp_same_occup) post
    estimates store MARADSO1_0_`outcome', title(Model `outcome')

    ******************
    * JIJIGA - HOSTS *
    ******************

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 2   ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETJI2_0_`outcome', title(Model `outcome')

        qui gen     smpl2_0 = 0
        qui replace smpl2_0 = 1 if e(sample)==1

     eststo MJI2_0_`outcome':  estpost su `outcome'  if smpl2_0 == 1 [aw=$weight]

        drop smpl2_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 2  ///
                , cluster($cluster) 
    margins , dydx(exp_outgroup) post
    estimates store MARJIOG2_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 2 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    estimates store MARJISO2_0_`outcome', title(Model `outcome')

    *******************
    * KAMPALA - HOSTS *
    *******************

   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 3   ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETKA3_0_`outcome', title(Model `outcome')

        qui gen     smpl3_0 = 0
        qui replace smpl3_0 = 1 if e(sample)==1

     eststo MKA3_0_`outcome':  estpost su `outcome'  if smpl3_0 == 1 [aw=$weight]

        drop smpl3_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 3  ///
                , cluster($cluster) 
    margins , dydx(exp_outgroup) post
    estimates store MARKAOG3_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 3 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    estimates store MARKASO3_0_`outcome', title(Model `outcome')


    ******************
    *ISINGIRO - HOSTS*
    ******************


   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 4   ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETIS4_0_`outcome', title(Model `outcome')

        qui gen     smpl4_0 = 0
        qui replace smpl4_0 = 1 if e(sample)==1

     eststo MIS4_0_`outcome':  estpost su `outcome'  if smpl4_0 == 1 [aw=$weight]

        drop smpl4_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 4  ///
                , cluster($cluster) 
    margins , dydx(exp_outgroup) post
    estimates store MARISOG4_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & region_short == 4 ///
                , cluster($cluster) 
    margins , dydx(exp_same_occup) post
    estimates store MARISSO4_0_`outcome', title(Model `outcome')


    ********************
    * ADDIS - REFUGEES *
    ********************

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 1  ///
               ,  cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETAD1_1_`outcome', title(Model `outcome')

        qui gen     smpl1_1 = 0
        qui replace smpl1_1 = 1 if e(sample)==1

     eststo MAD1_1_`outcome':  estpost su `outcome'  if smpl1_1 == 1 [aw=$weight]

        drop smpl1_1
    
    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 1  ///
               ,  cluster($cluster) 
    margins , dydx(exp_outgroup) post
    estimates store MARADOG1_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 1  ///
               ,  cluster($cluster) 
    margins , dydx(exp_same_occup) post
    estimates store MARADSO1_1_`outcome', title(Model `outcome')

    *********************
    * JIJIGA - REFUGEES *
    *********************

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 2 ///
               ,  cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETJI2_1_`outcome', title(Model `outcome')

        qui gen     smpl2_1 = 0
        qui replace smpl2_1 = 1 if e(sample)==1

     eststo MJI2_1_`outcome':  estpost su `outcome'  if smpl2_1 == 1 [aw=$weight]

        drop smpl2_1

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 2 ///
               ,  cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARJIOG2_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 2 ///
               ,  cluster($cluster) 
    margins , dydx(exp_same_occup) post
    estimates store MARJISO2_1_`outcome', title(Model `outcome')


    *********************
    * KAMPALA -REFUGEES *
    *********************

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 3 ///
               ,  cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETKA3_1_`outcome', title(Model `outcome')

        qui gen     smpl3_1 = 0
        qui replace smpl3_1 = 1 if e(sample)==1

     eststo MKA3_1_`outcome':  estpost su `outcome'  if smpl3_1 == 1 [aw=$weight]

        drop smpl3_1

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 3 ///
               ,  cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARKAOG3_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 3 ///
               ,  cluster($cluster) 
    margins , dydx(exp_same_occup) post
    estimates store MARKASO3_1_`outcome', title(Model `outcome')


    ***********************
    * ISINGIRO - REFUGEES *
    ***********************

        reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 4 ///
               ,  cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETIS4_1_`outcome', title(Model `outcome')

        qui gen     smpl4_1 = 0
        qui replace smpl4_1 = 1 if e(sample)==1

     eststo MIS4_1_`outcome':  estpost su `outcome'  if smpl4_1 == 1 [aw=$weight]

        drop smpl4_1

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 4 ///
               ,  cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARISOG4_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & region_short == 4 ///
               ,  cluster($cluster) 
    margins , dydx(exp_same_occup) post
    estimates store MARISSO4_1_`outcome', title(Model `outcome')

}

**** ADDIS ****

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


*HETEROGENOUS
foreach outcome of global outcome_1 {

esttab  HETAD1_0_`outcome' HETAD1_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\   \multicolumn{5}{c}{\textit{PANEL A.1: Addis Ababa}} \\  \midrule  ") ///
        compress replace label fragment noobs wide ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  HETAD1_0_`outcome' HETAD1_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noobs noline nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARADOG1_0_`outcome' MARADOG1_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARADSO1_0_`outcome' MARADSO1_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAD1_0_`outcome' M_EMPTY MAD1_1_`outcome' M_EMPTY ///
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Addis"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //



esttab  HETJI2_0_`outcome' HETJI2_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL A.2: Jijiga/Kebribeyah}} \\  \midrule  ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETJI2_0_`outcome' HETJI2_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noobs noline nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARJIOG2_0_`outcome' MARJIOG2_1_`outcome'  /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARJISO2_0_`outcome' MARJISO2_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MJI2_0_`outcome' M_EMPTY MJI2_1_`outcome' M_EMPTY ///
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
      cells(mean(fmt(2) transpose  label("Mean Men"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //




esttab  HETKA3_0_`outcome' HETKA3_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL A.3: Kampala}} \\  \midrule  ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //


esttab  HETKA3_0_`outcome' HETKA3_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label noobs wide noline nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARKAOG3_0_`outcome' MARKAOG3_1_`outcome'  /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARKASO3_0_`outcome' MARKASO3_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MKA3_0_`outcome' M_EMPTY MKA3_1_`outcome' M_EMPTY ///
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Men"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //



esttab  HETIS4_0_`outcome' HETIS4_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL A.4: Isingiro/Nakivale}} \\  \midrule   ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETIS4_0_`outcome' HETIS4_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noobs noline nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") ///  
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //


esttab  MARISOG4_0_`outcome' MARISOG4_1_`outcome'  /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARISSO4_0_`outcome' MARISSO4_1_`outcome'   /// 
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MIS4_0_`outcome' M_EMPTY MIS4_1_`outcome' M_EMPTY ///
        using "$out_tab/TA16_Analysis_byLocality.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Men"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")




}













/*====================================================================
Section 4:       Experiment - Coefplots by localities Main Analysis
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/


*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byL 
        


/*====================================================================
                        1: Analysis
====================================================================*/

                **************************************************
                ********** MAIN ANALYSIS BY LOCALITY *************
                **************************************************


foreach outcome of global outcome_1 {

use "$data_final/04_UGA_ETH_Prepared.dta", clear

    
    gen A1_exp_outgroup = exp_outgroup
    gen A1_exp_same_occup = exp_same_occup

    gen A2_exp_outgroup = exp_outgroup
    gen A2_exp_same_occup = exp_same_occup

    gen H3_exp_outgroup = exp_outgroup
    gen H3_exp_same_occup = exp_same_occup

    *****************
    * ADDIS - HOSTS *
    *****************


    ** alpha 1 
    reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 1 ///
                , cluster($cluster) 
      estimates store A1_HETAD1_0_`outcome' 

   ** alpha 2
    reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 1 ///
                , cluster($cluster) 
      estimates store A2_HETAD1_0_`outcome' 

   ** H3
    reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 1 ///
                , cluster($cluster) 
      estimates store H3_HETAD1_0_`outcome' 
 
    ******************
    * JIJIGA - HOSTS *
    ******************

    *A1
    reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 2   ///
                , cluster($cluster)
      estimates store A1_HETJI2_0_`outcome' 

    *A2
    reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 2   ///
                , cluster($cluster)
      estimates store A2_HETJI2_0_`outcome' 

    *H3
    reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 2   ///
                , cluster($cluster)
      estimates store H3_HETJI2_0_`outcome' 


    *******************
    * KAMPALA - HOSTS *
    *******************

    *A1
   reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 3   ///
                , cluster($cluster)
      estimates store A1_HETKA3_0_`outcome' 

    *A2
   reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 3   ///
                , cluster($cluster)
      estimates store A2_HETKA3_0_`outcome' 

    *H3
   reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 3   ///
                , cluster($cluster)
     estimates store H3_HETKA3_0_`outcome' 

    ******************
    *ISINGIRO - HOSTS*
    ******************

    *A1
   reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 4   ///
                , cluster($cluster)
      estimates store A1_HETIS4_0_`outcome' 

    *A2
   reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 4   ///
                , cluster($cluster)
      estimates store A2_HETIS4_0_`outcome' 

    *H3
   reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 0 & region_short == 4   ///
                , cluster($cluster)
      estimates store H3_HETIS4_0_`outcome' 


    ********************
    * ADDIS - REFUGEES *
    ********************

    *A1
    reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 1  ///
               ,  cluster($cluster)
      estimates store A1_HETAD1_1_`outcome' 

    *A2
    reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 1  ///
               ,  cluster($cluster)
      estimates store A2_HETAD1_1_`outcome' 
 
     *H3
    reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 1  ///
               ,  cluster($cluster)
      estimates store H3_HETAD1_1_`outcome' 
     

    *********************
    * JIJIGA - REFUGEES *
    *********************

    *A1
    reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 2 ///
               ,  cluster($cluster)
      estimates store A1_HETJI2_1_`outcome' 

    *A2
    reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 2 ///
               ,  cluster($cluster)
      estimates store A2_HETJI2_1_`outcome' 

    *H3
    reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 2 ///
               ,  cluster($cluster)
      estimates store H3_HETJI2_1_`outcome' 


    *********************
    * KAMPALA -REFUGEES *
    *********************

    *A1
    reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 3 ///
               ,  cluster($cluster)
      estimates store A1_HETKA3_1_`outcome' 

    *A2
    reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 3 ///
               ,  cluster($cluster)
      estimates store A2_HETKA3_1_`outcome' 

    *H3
    reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 3 ///
               ,  cluster($cluster)
      estimates store H3_HETKA3_1_`outcome' 


    ***********************
    * ISINGIRO - REFUGEES *
    ***********************

    *A1
    reg `outcome' i.A1_exp_outgroup##i.A1_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 4 ///
               ,  cluster($cluster)
      estimates store A1_HETIS4_1_`outcome' 

    *A2
    reg `outcome' i.A2_exp_outgroup##i.A2_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 4 ///
               ,  cluster($cluster)
      estimates store A2_HETIS4_1_`outcome' 

    *H3
    reg `outcome' i.H3_exp_outgroup##i.H3_exp_same_occup $controls [aw=$weight] if refugee == 1 & region_short == 4 ///
               ,  cluster($cluster)
      estimates store H3_HETIS4_1_`outcome' 



}





foreach outcome of global outcome_1 {



*********************
**** ADDIS ABADA ****
*********************

 coefplot(A1_HETAD1_0_`outcome', offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) ) ) label("") msymbol(d)  mlabgap(*2) mlabsize(large) ///
             mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6) levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            (A2_HETAD1_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s) mlabgap(*2) mlabsize(large)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            (H3_HETAD1_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t) mlabgap(*2) mlabsize(large)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            , bylabel("Hosts")  ///
            || (A1_HETAD1_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(d)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
             (A2_HETAD1_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6)))  ///
             (H3_HETAD1_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t) mlabgap(*2) mlabsize(large)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
          , bylabel("Refugees")  ///
            ||  , keep(1.A1_exp_outgroup 1.A2_exp_same_occup 1.H3_exp_outgroup#1.H3_exp_same_occup ) ///
            xline(0, lcolor(black) lpattern(dash)) msymbol(d)  ///
              label subtitle(, size(large) fcolor(white) nobox ) ///
             xlabel("")   ///
               mlabposition(15) mlabsize(large) /// Here change for Nbrs labels small
             byopts( graphregion(color(white) margin(zero) ) bgcolor(white) ///
              title("{bf:Addis Ababa}", size(huge)) ///
              legend(off) plotregion(margin(zero)) )  ///
                  xscale( noline alt )   lwidth(large thin) ///
              xla(none)  xtitle("") yscale(noline  ) xlabel(, noticks) bylabel(, noticks)  ///
            coeflabel(1.A1_exp_outgroup= "{&alpha}1, Out Group" 1.A2_exp_same_occup= "{&alpha}2, Same Occupation" ///
                1.H3_exp_outgroup#1.H3_exp_same_occup = "{&alpha}3, Out Group*Same Occupation" , ///
                 labsize(large)  wrap(15))  ylabel(, tlstyle(none))   subtitle(, size(medium)) ///
                saving("$out_fig/g2_allresults_AD.gph", replace)
      

*****************
**** KAMPALA ****
*****************

 coefplot(A1_HETKA3_0_`outcome', offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) ) ) label("") msymbol(d) mlabgap(*2) mlabsize(large)  ///
             mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6) levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            (A2_HETKA3_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s) mlabgap(*2) mlabsize(large)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            (H3_HETKA3_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t) mlabgap(*2) mlabsize(large)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
             , bylabel("Hosts")  ///
            || (A1_HETKA3_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(d) mlabgap(*2) mlabsize(large)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
             (A2_HETKA3_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s) mlabgap(*2) mlabsize(large)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6)))  ///
             (H3_HETKA3_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t) mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
           , bylabel("Refugees")  ///
            ||  , keep(1.A1_exp_outgroup 1.A2_exp_same_occup 1.H3_exp_outgroup#1.H3_exp_same_occup ) ///
            xline(0, lcolor(black) lpattern(dash)) msymbol(d)  ///
              label subtitle(, size(large) fcolor(white) nobox ) ///
             xlabel("")   ///
               mlabposition(15) mlabsize(large) ///
             byopts( graphregion(color(white) margin(zero) ) bgcolor(white) ///
              title("{bf:Kampala}", size(huge)) ///
              legend(off) plotregion(margin(zero)) )  ///
                  xscale( noline alt )   lwidth(large thin) ///
              xla(none)  xtitle("") yscale(noline  ) xlabel(, noticks) bylabel(, noticks)  ///
            coeflabel(1.A1_exp_outgroup= " " 1.A2_exp_same_occup= " " ///
                1.H3_exp_outgroup#1.H3_exp_same_occup = " "   ) /// 
                ylabel(, tlstyle(none))  subtitle(, size(medium)) ///
                saving("$out_fig/g2_allresults_KA.gph", replace)


****************
**** JIJIGA ****
****************

 coefplot(A1_HETJI2_0_`outcome', offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) ) ) label("") msymbol(d) mlabgap(*2) mlabsize(large)  ///
             mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6) levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            (A2_HETJI2_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s) mlabgap(*2) mlabsize(large)  ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            (H3_HETJI2_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
             , bylabel("Hosts")  ///
            || (A1_HETJI2_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(d)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
             (A2_HETJI2_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6)))  ///
             (H3_HETJI2_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            , bylabel("Refugees")  ///
            ||  , keep(1.A1_exp_outgroup 1.A2_exp_same_occup 1.H3_exp_outgroup#1.H3_exp_same_occup ) ///
            xline(0, lcolor(black) lpattern(dash)) msymbol(d)  ///
              label subtitle(, size(large) fcolor(white) nobox ) ///
             xlabel("")   ///
               mlabposition(15) mlabsize(large) ///
             byopts( graphregion(color(white) margin(zero) ) bgcolor(white) ///
              title("{bf:Jijiga/Kebribeyah}", size(huge)) ///
              legend(off) plotregion(margin(zero)) )  ///
                  xscale( noline alt )   lwidth(large thin) ///
              xla(none)  xtitle("") yscale(noline  ) xlabel(, noticks) bylabel(, noticks)  ///
            coeflabel(1.A1_exp_outgroup= "{&alpha}1, Out Group" 1.A2_exp_same_occup= "{&alpha}2, Same Occupation" ///
                1.H3_exp_outgroup#1.H3_exp_same_occup = "{&alpha}3, Out Group*Same Occupation"  , labsize(large)  wrap(15)) ///
                  ylabel(, tlstyle(none))  subtitle(, size(medium)) ///
                saving("$out_fig/g2_allresults_JI.gph", replace)
      
******************
**** ISINGIRO ****
******************

 coefplot(A1_HETIS4_0_`outcome', offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) ) ) label("") msymbol(d) mlabgap(*2) mlabsize(large)  ///
             mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6) levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            (A2_HETIS4_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            (H3_HETIS4_0_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
              , bylabel("Hosts")  ///
            || (A1_HETIS4_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(d)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
             (A2_HETIS4_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(s)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6)))  ///
             (H3_HETIS4_1_`outcome',  offset(0.00) mlabel(" " + " {it:b} = " + cond(@pval<.01, string(@b,"%9.2f") + "***", ///
             cond(@pval<.05, string(@b,"%9.2f") + "**", ///
             cond(@pval<.1, string(@b,"%9.2f") + "*", ///
             string(@b, "%5.2f")  ) ) )) label("") msymbol(t)  mlabgap(*2) mlabsize(large) ///
              mlabcolor(gs6) mcolor(gs6) mlcolor(gs6) lcolor(gs6)  levels(90) mlwidth(thick) ciopts(lwidth(thick) lcolor(gs6))) ///
            , bylabel("Refugees")  ///
            ||  , keep(1.A1_exp_outgroup 1.A2_exp_same_occup 1.H3_exp_outgroup#1.H3_exp_same_occup ) ///
            xline(0, lcolor(black) lpattern(dash)) msymbol(d)  ///
              label subtitle(, size(large) fcolor(white) nobox ) ///
             xlabel("")   ///
               mlabposition(15) mlabsize(large) ///
             byopts( graphregion(color(white) margin(zero) ) bgcolor(white) ///
              title("{bf:Isingiro/Nakivale}", size(huge)) ///
              legend(off) plotregion(margin(zero)) )  ///
                  xscale( noline alt )   lwidth(large thin) ///
              xla(none)  xtitle("") yscale(noline  ) xlabel(, noticks) bylabel(, noticks)  ///
            coeflabel(1.A1_exp_outgroup= " " 1.A2_exp_same_occup= " " ///
                1.H3_exp_outgroup#1.H3_exp_same_occup = " "  ) /// 
                ylabel(, tlstyle(none))  subtitle(, size(medium)) ///
                saving("$out_fig/g2_allresults_IS.gph", replace)



graph combine "$out_fig/g2_allresults_AD.gph" "$out_fig/g2_allresults_KA.gph" ///
        "$out_fig/g2_allresults_JI.gph" "$out_fig/g2_allresults_IS.gph" ///
        , ycommon row(2)    ///
        graphregion(lcolor(none) ilcolor(none) fcolor(white) ifcolor(white)) ///
        plotregion(lcolor(none) ilcolor(none) style(none))   scale(0.8) 
    
    graph export "$out_fig/FIG5_CFP_Analysis_byLocalities.pdf", replace


}



erase "$out_fig/g2_allresults_AD.gph"
erase "$out_fig/g2_allresults_KA.gph" 
erase "$out_fig/g2_allresults_JI.gph" 
erase "$out_fig/g2_allresults_IS.gph"


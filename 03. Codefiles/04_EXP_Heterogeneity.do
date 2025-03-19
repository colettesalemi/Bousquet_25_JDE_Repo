

/*====================================================================
project:       Experiment - Heterogenous Analysis
Authors:       Julie Bousquet/Mark Marvin Kadigo/Anna Gasten 
Description:   

This do file generates
            - Section 1 - By gender and education: Table A18: TA18_Analysis_Gender_Education
            - Section 2 - By Over-work: Table A19: TA19_Analysis_OverWork
            - Section 3 - By Occupation Pressure: Table A20: TA20_Analysis_OccupationPressure
            - Section 4 - By network/contact: Table A21: TA21_Analysis_Contact
            - Section 5 - By language shared with in group: Table A22: TA22_Analysis_LanguageShare
            - Section 6 - By language fractionalization: Table A23: TA23_Analysis_LanguageFraction
            - Section 7 - Table 1: TAB1_Analysis_HeterogMutli
                          Aggregates for hosts of tables
                            - By Over-work: Table A19
                            - By Occupation Pressure: Table A20
                            - By network/contact: Table A21
                            - By language shared with in group: Table A22

----------------------------------------------------------------------
Creation Date:    30-10-2022
====================================================================*/











/*====================================================================
Section 1:      Experiment -  Heterogeneity by Gender and education
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/


*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byG
global outcome_2    prej_aind_byE


/*====================================================================
                        1: Analysis
====================================================================*/
       


                    ***********************************
                    *      GENDER AND EDUCATION       *
                    ***********************************

use "$data_final/04_UGA_ETH_Prepared.dta", clear

bys ethiopia: tab qirefugee
bys ethiopia: tab refugee
tab region


foreach outcome of global outcome_1 {

*estimates drop _all 


     **************
     **** GENDER ***
     **************

tab male 

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & male == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETGEN0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MGEN0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & male == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARGEOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & male == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARGESO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & male == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETGEN1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MGEN1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & male == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARGEOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & male == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARGESO1_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & male == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETGEN0_1_`outcome', title(Model `outcome')

        qui gen     smpl0_1 = 0
        qui replace smpl0_1 = 1 if e(sample)==1

     eststo MGEN0_1_`outcome':  estpost su `outcome'  if smpl0_1 == 1 [aw=$weight]

        drop smpl0_1

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & male == 0  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARGEOG0_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & male == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARGESO0_1_`outcome', title(Model `outcome')
    



    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & male == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETGEN1_1_`outcome', title(Model `outcome')

        qui gen     smpl1_1 = 0
        qui replace smpl1_1 = 1 if e(sample)==1

     eststo MGEN1_1_`outcome':  estpost su `outcome'  if smpl1_1 == 1 [aw=$weight]

        drop smpl1_1

   ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & male == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARGEOG1_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & male == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARGESO1_1_`outcome', title(Model `outcome')


}



     ******************
     **** EDUCATION ***
     ******************
foreach outcome of global outcome_2 {

tab educ_primary

    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & educ_primary == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETEDU0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MEDU0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & educ_primary == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAREDOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & educ_primary == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAREDSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & educ_primary == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETEDU1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MEDU1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & educ_primary == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAREDOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & educ_primary == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAREDSO1_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & educ_primary == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETEDU0_1_`outcome', title(Model `outcome')

        qui gen     smpl0_1 = 0
        qui replace smpl0_1  = 1 if e(sample)==1

     eststo MEDU0_1_`outcome':  estpost su `outcome'  if smpl0_1  == 1 [aw=$weight]

        drop smpl0_1 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & educ_primary == 0  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAREDOG0_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & educ_primary == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAREDSO0_1_`outcome', title(Model `outcome')
    


    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & educ_primary == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETEDU1_1_`outcome', title(Model `outcome')

        qui gen     smpl1_1 = 0
        qui replace smpl1_1 = 1 if e(sample)==1

     eststo MEDU1_1_`outcome':  estpost su `outcome'  if smpl1_1 == 1 [aw=$weight]

        drop smpl1_1

   ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & educ_primary == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAREDOG1_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & educ_primary == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAREDSO1_1_`outcome', title(Model `outcome')



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





*HETEROGENOUS
foreach outcome of global outcome_1 {
foreach outcome2 of global outcome_2 {


*OLS 
esttab  HETGEN0_0_`outcome' HETGEN0_1_`outcome'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\ \midrule   \multicolumn{5}{c}{\textbf{PANEL A: GENDER}} \\ \multicolumn{5}{c}{\textit{PANEL A.1: Women}} \\  \midrule  ") ///
        compress replace label fragment noobs wide ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  HETGEN0_0_`outcome' HETGEN0_1_`outcome'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARGEOG0_0_`outcome' MARGEOG0_1_`outcome'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARGESO0_0_`outcome' MARGESO0_1_`outcome'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MGEN0_0_`outcome' M_EMPTY MGEN0_1_`outcome' M_EMPTY ///
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Women"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //



esttab  HETGEN1_0_`outcome' HETGEN1_1_`outcome'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL A.2: Men}} \\  \midrule  ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETGEN1_0_`outcome' HETGEN1_1_`outcome'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARGEOG1_0_`outcome' MARGEOG1_1_`outcome'  /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARGESO1_0_`outcome' MARGESO1_1_`outcome'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        prefoot(" ") //

esttab  MGEN1_0_`outcome' M_EMPTY MGEN1_1_`outcome' M_EMPTY ///
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Men"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //


**** EDUCATION ****


esttab  HETEDU0_0_`outcome2' HETEDU0_1_`outcome2' /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        posthead(" \midrule \midrule  \multicolumn{5}{c}{\textbf{PANEL B: EDUCATION LEVEL}} \\  \multicolumn{5}{c}{\textit{PANEL B.1: Below Primary Education}} \\  \midrule  ") ///
        fragment append label wide noobs noline ///
        nonumbers nomtitles ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETEDU0_0_`outcome2' HETEDU0_1_`outcome2'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAREDOG0_0_`outcome2' MAREDOG0_1_`outcome2'  /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAREDSO0_0_`outcome2' MAREDSO0_1_`outcome2'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MEDU0_0_`outcome2' M_EMPTY MEDU0_1_`outcome2' M_EMPTY ///
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //



esttab  HETEDU1_0_`outcome2' HETEDU1_1_`outcome2'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL B.2: At Least Primary Education}} \\  \midrule  ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETEDU1_0_`outcome2' HETEDU1_1_`outcome2'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAREDOG1_0_`outcome2' MAREDOG1_1_`outcome2'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAREDSO1_0_`outcome2' MAREDSO1_1_`outcome2'   /// 
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MEDU1_0_`outcome2' M_EMPTY MEDU1_1_`outcome2' M_EMPTY ///
        using "$out_tab/TA18_Analysis_Gender_Education.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")




}
}
 



/*====================================================================
Section 2:      Experiment -  Heterogeneity by variable of Competition
                with respection to over work
----------------------------------------------------------------------
====================================================================*/

/*====================================================================
                        0: Set up
====================================================================*/

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byOWK


/*====================================================================
                        1: Analysis
====================================================================*/
       
use "$data_final/04_UGA_ETH_Prepared.dta", clear


foreach outcome of global outcome_1 {


    **************************
    * **** HETEROGENOUS **** *
    **************************


   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & over_work_m == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETOWK0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MOWK0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & over_work_m == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAROWKOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & over_work_m == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAROWKSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & over_work_m == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETOWK1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MOWK1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & over_work_m == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAROWKOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & over_work_m == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAROWKSO1_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & over_work_m == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETOWK0_1_`outcome', title(Model `outcome')

        qui gen     smpl0_1 = 0
        qui replace smpl0_1  = 1 if e(sample)==1

     eststo MOWK0_1_`outcome':  estpost su `outcome'  if smpl0_1  == 1 [aw=$weight]

        drop smpl0_1 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & over_work_m == 0  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAROWKOG0_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & over_work_m == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAROWKSO0_1_`outcome', title(Model `outcome')
    


    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & over_work_m == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETOWK1_1_`outcome', title(Model `outcome')

        qui gen     smpl1_1 = 0
        qui replace smpl1_1 = 1 if e(sample)==1

     eststo MOWK1_1_`outcome':  estpost su `outcome'  if smpl1_1 == 1 [aw=$weight]

        drop smpl1_1

   ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & over_work_m == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAROWKOG1_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & over_work_m == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAROWKSO1_1_`outcome', title(Model `outcome')



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





esttab  HETOWK0_0_`outcome' HETOWK0_1_`outcome'  /// 
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\ \midrule   \multicolumn{5}{c}{\textbf{Working hours beyond legal threshold}} \\ \multicolumn{5}{c}{\textit{PANEL A.1: Low share over-worked}} \\  \midrule  ") ///
        compress replace label fragment noobs wide ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  HETOWK0_0_`outcome' HETOWK0_1_`outcome'   /// 
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAROWKOG0_0_`outcome' MAROWKOG0_1_`outcome'  /// 
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAROWKSO0_0_`outcome' MAROWKSO0_1_`outcome'   /// 
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MOWK0_0_`outcome' M_EMPTY MOWK0_1_`outcome' M_EMPTY ///
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Linguistic Minority"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //



esttab  HETOWK1_0_`outcome' HETOWK1_1_`outcome'   /// 
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL A.2: High share over-worked}} \\  \midrule  ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETOWK1_0_`outcome' HETOWK1_1_`outcome'   /// 
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        compress fragment append label wide noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAROWKOG1_0_`outcome' MAROWKOG1_1_`outcome'   /// 
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAROWKSO1_0_`outcome' MAROWKSO1_1_`outcome'   /// 
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MOWK1_0_`outcome' M_EMPTY MOWK1_1_`outcome' M_EMPTY ///
        using "$out_tab/TA19_Analysis_OverWork.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")

}





/*====================================================================
Section 3:      Experiment -  Heterogeneity by variable of Competition
                with respection to occupation pressure
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/


*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byPOG
   
/*====================================================================
                        1: Analysis
====================================================================*/               


use "$data_final/04_UGA_ETH_Prepared.dta", clear


foreach outcome of global outcome_1 {


             *************************************
             *       OCCCUPATION-PRESSURE        *
             *************************************


   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & ref_overrep == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETPOG0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MPOG0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & ref_overrep == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARPOGOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & ref_overrep == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARPOGSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & ref_overrep == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETPOG1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MPOG1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & ref_overrep == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARPOGOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & ref_overrep == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARPOGSO1_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & ref_overrep == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETPOG0_1_`outcome', title(Model `outcome')

        qui gen     smpl0_1 = 0
        qui replace smpl0_1  = 1 if e(sample)==1

     eststo MPOG0_1_`outcome':  estpost su `outcome'  if smpl0_1  == 1 [aw=$weight]

        drop smpl0_1 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & ref_overrep == 0  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARPOGOG0_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & ref_overrep == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARPOGSO0_1_`outcome', title(Model `outcome')
    


    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & ref_overrep == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETPOG1_1_`outcome', title(Model `outcome')

        qui gen     smpl1_1 = 0
        qui replace smpl1_1 = 1 if e(sample)==1

     eststo MPOG1_1_`outcome':  estpost su `outcome'  if smpl1_1 == 1 [aw=$weight]

        drop smpl1_1

   ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & ref_overrep == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARPOGOG1_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & ref_overrep == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARPOGSO1_1_`outcome', title(Model `outcome')



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




esttab  HETPOG0_0_`outcome' HETPOG0_1_`outcome'  /// 
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\ \midrule   \multicolumn{5}{c}{\textbf{Refugee and Host Over-Representation by Industry}} \\ \multicolumn{5}{c}{\textit{PANEL A.1: Hosts overrepresented}} \\  \midrule  ") ///
        compress replace label fragment noobs wide ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  HETPOG0_0_`outcome' HETPOG0_1_`outcome'   /// 
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARPOGOG0_0_`outcome' MARPOGOG0_1_`outcome'  /// 
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARPOGSO0_0_`outcome' MARPOGSO0_1_`outcome'   /// 
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MPOG0_0_`outcome' M_EMPTY MPOG0_1_`outcome' M_EMPTY ///
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Linguistic Minority"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //



esttab  HETPOG1_0_`outcome' HETPOG1_1_`outcome'   /// 
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL A.2: Refugees overrepresented}} \\  \midrule  ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETPOG1_0_`outcome' HETPOG1_1_`outcome'   /// 
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        compress fragment append label wide noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARPOGOG1_0_`outcome' MARPOGOG1_1_`outcome'   /// 
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARPOGSO1_0_`outcome' MARPOGSO1_1_`outcome'   /// 
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MPOG1_0_`outcome' M_EMPTY MPOG1_1_`outcome' M_EMPTY ///
        using "$out_tab/TA20_Analysis_OccupationPressure.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")

}












/*====================================================================
Section 4:       Experiment - Heterogeous by Network/Contact
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byN
     


/*====================================================================
                        1: Analysis
====================================================================*/
       

use "$data_final/04_UGA_ETH_Prepared.dta", clear


bys ethiopia: tab qirefugee
tab region



foreach outcome of global outcome_1 {


     ***************
     *** CONTACT ***
     ***************

   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & bi_network_outgroup == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETCON0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MCON0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & bi_network_outgroup == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARCOOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & bi_network_outgroup == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARCOSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & bi_network_outgroup == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETCON1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MCON1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & bi_network_outgroup == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARCOOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & bi_network_outgroup == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARCOSO1_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & bi_network_outgroup == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETCON0_1_`outcome', title(Model `outcome')

        qui gen     smpl0_1 = 0
        qui replace smpl0_1  = 1 if e(sample)==1

     eststo MCON0_1_`outcome':  estpost su `outcome'  if smpl0_1  == 1 [aw=$weight]

        drop smpl0_1 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & bi_network_outgroup == 0  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARCOOG0_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & bi_network_outgroup == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARCOSO0_1_`outcome', title(Model `outcome')
    


    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & bi_network_outgroup == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETCON1_1_`outcome', title(Model `outcome')

        qui gen     smpl1_1 = 0
        qui replace smpl1_1 = 1 if e(sample)==1

     eststo MCON1_1_`outcome':  estpost su `outcome'  if smpl1_1 == 1 [aw=$weight]

        drop smpl1_1

   ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & bi_network_outgroup == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARCOOG1_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & bi_network_outgroup == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARCOSO1_1_`outcome', title(Model `outcome')



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


esttab  HETCON0_0_`outcome' HETCON0_1_`outcome'  /// 
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\ \midrule   \multicolumn{5}{c}{\textbf{PANEL A: CONTACT}} \\ \multicolumn{5}{c}{\textit{PANEL A.1: No out-group friends}} \\  \midrule  ") ///
        compress replace label fragment noobs wide ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  HETCON0_0_`outcome' HETCON0_1_`outcome'   /// 
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARCOOG0_0_`outcome' MARCOOG0_1_`outcome'  /// 
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARCOSO0_0_`outcome' MARCOSO0_1_`outcome'   /// 
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MCON0_0_`outcome' M_EMPTY MCON0_1_`outcome' M_EMPTY ///
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //



esttab  HETCON1_0_`outcome' HETCON1_1_`outcome'   /// 
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL A.2: Some out-group friends}} \\  \midrule  ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETCON1_0_`outcome' HETCON1_1_`outcome'   /// 
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        compress fragment append label wide noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARCOOG1_0_`outcome' MARCOOG1_1_`outcome'   /// 
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARCOSO1_0_`outcome' MARCOSO1_1_`outcome'   /// 
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MCON1_0_`outcome' M_EMPTY MCON1_1_`outcome' M_EMPTY ///
        using "$out_tab/TA21_Analysis_Contact.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")




}





/*====================================================================
Section 5:       Experiment - Heterogeous by Language Sharing 
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/


          *************************
          **** LANGUAGE SHARING	***
          *************************

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byLOG
 

/*====================================================================
                        1: Analysis
====================================================================*/
       

use "$data_final/04_UGA_ETH_Prepared.dta", clear


bys ethiopia: tab qirefugee
tab region



foreach outcome of global outcome_1 {



   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & maj_lang_og == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETLOG0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MLOG0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_og == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLOGOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_og == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLOGSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & maj_lang_og == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETLOG1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MLOG1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_og == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLOGOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_og == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLOGSO1_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & maj_lang_og == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETLOG0_1_`outcome', title(Model `outcome')

        qui gen     smpl0_1 = 0
        qui replace smpl0_1  = 1 if e(sample)==1

     eststo MLOG0_1_`outcome':  estpost su `outcome'  if smpl0_1  == 1 [aw=$weight]

        drop smpl0_1 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & maj_lang_og == 0  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLOGOG0_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & maj_lang_og == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLOGSO0_1_`outcome', title(Model `outcome')
    


    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & maj_lang_og == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETLOG1_1_`outcome', title(Model `outcome')

        qui gen     smpl1_1 = 0
        qui replace smpl1_1 = 1 if e(sample)==1

     eststo MLOG1_1_`outcome':  estpost su `outcome'  if smpl1_1 == 1 [aw=$weight]

        drop smpl1_1

   ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & maj_lang_og == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLOGOG1_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & maj_lang_og == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLOGSO1_1_`outcome', title(Model `outcome')



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



esttab  HETLOG0_0_`outcome' HETLOG0_1_`outcome'  /// 
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\ \midrule   \multicolumn{5}{c}{\textbf{PANEL A: OUT-GROUP LANGUAGE}} \\ \multicolumn{5}{c}{\textit{PANEL A.1: Different language (main out-group language)}} \\  \midrule  ") ///
        compress replace label fragment noobs wide ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  HETLOG0_0_`outcome' HETLOG0_1_`outcome'   /// 
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLOGOG0_0_`outcome' MARLOGOG0_1_`outcome'  /// 
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLOGSO0_0_`outcome' MARLOGSO0_1_`outcome'   /// 
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MLOG0_0_`outcome' M_EMPTY MLOG0_1_`outcome' M_EMPTY ///
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Linguistic Minority"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //



esttab  HETLOG1_0_`outcome' HETLOG1_1_`outcome'   /// 
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL A.2: Shared language (main out-group language)}} \\  \midrule  ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETLOG1_0_`outcome' HETLOG1_1_`outcome'   /// 
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        compress fragment append label wide noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLOGOG1_0_`outcome' MARLOGOG1_1_`outcome'   /// 
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLOGSO1_0_`outcome' MARLOGSO1_1_`outcome'   /// 
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MLOG1_0_`outcome' M_EMPTY MLOG1_1_`outcome' M_EMPTY ///
        using "$out_tab/TA22_Analysis_LanguageShare.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")

}


				   
				   

/*====================================================================
Section 6:       Experiment - Heterogeous by  Language Fractionalization
----------------------------------------------------------------------
====================================================================*/


/*====================================================================
                        0: Set up
====================================================================*/
		   
				   
*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byLIG


/*====================================================================
                        1: Analysis
====================================================================*/
       

use "$data_final/04_UGA_ETH_Prepared.dta", clear


bys ethiopia: tab qirefugee
tab region



foreach outcome of global outcome_1 {


   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & maj_lang_ig == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETLIG0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MLIG0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_ig == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLIGOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_ig == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLIGSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & maj_lang_ig == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETLIG1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MLIG1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_ig == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLIGOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_ig == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLIGSO1_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & maj_lang_ig == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETLIG0_1_`outcome', title(Model `outcome')

        qui gen     smpl0_1 = 0
        qui replace smpl0_1  = 1 if e(sample)==1

     eststo MLIG0_1_`outcome':  estpost su `outcome'  if smpl0_1  == 1 [aw=$weight]

        drop smpl0_1 

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & maj_lang_ig == 0  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLIGOG0_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & maj_lang_ig == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLIGSO0_1_`outcome', title(Model `outcome')
    


    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 1 & maj_lang_ig == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETLIG1_1_`outcome', title(Model `outcome')

        qui gen     smpl1_1 = 0
        qui replace smpl1_1 = 1 if e(sample)==1

     eststo MLIG1_1_`outcome':  estpost su `outcome'  if smpl1_1 == 1 [aw=$weight]

        drop smpl1_1

   ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & maj_lang_ig == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLIGOG1_1_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 1  & maj_lang_ig == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLIGSO1_1_`outcome', title(Model `outcome')



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





esttab  HETLIG0_0_`outcome' HETLIG0_1_`outcome'  /// 
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] \multicolumn{1}{c}{\textit{\textbf{TREATMENT VARIABLE}}} & \multicolumn{2}{c}{\textit{\textbf{HOSTS}}} & \multicolumn{2}{c}{\textit{\textbf{REFUGEES}}} \\ \midrule   \multicolumn{5}{c}{\textbf{PANEL A: ETHNO-LINGUISTIC MAJORITY/ MINORITY}} \\ \multicolumn{5}{c}{\textit{PANEL A.1: Linguistic minority (own group)}} \\  \midrule  ") ///
        compress replace label fragment noobs wide ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  HETLIG0_0_`outcome' HETLIG0_1_`outcome'   /// 
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLIGOG0_0_`outcome' MARLIGOG0_1_`outcome'  /// 
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLIGSO0_0_`outcome' MARLIGSO0_1_`outcome'   /// 
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MLIG0_0_`outcome' M_EMPTY MLIG0_1_`outcome' M_EMPTY ///
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean Linguistic Minority"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //



esttab  HETLIG1_0_`outcome' HETLIG1_1_`outcome'   /// 
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        posthead("  \multicolumn{5}{c}{\textit{PANEL A.2: Linguistic majority (own group)}} \\  \midrule  ") ///
        fragment append label wide noobs  noline  ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        nonumbers nomtitles ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETLIG1_0_`outcome' HETLIG1_1_`outcome'   /// 
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        compress fragment append label wide noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLIGOG1_0_`outcome' MARLIGOG1_1_`outcome'   /// 
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLIGSO1_0_`outcome' MARLIGSO1_1_`outcome'   /// 
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MLIG1_0_`outcome' M_EMPTY MLIG1_1_`outcome' M_EMPTY ///
        using "$out_tab/TA23_Analysis_LanguageFraction.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")

}






































/*====================================================================
Section 7:      Experiment -  Heterogeneity by variable of Competition
                with respection to over work

            - By Overwork: Table 1 -panel A
            - By Occupation Pressure: Table 1 -panel B
            - By network/contact: Table 1 -panel C
            - By language shared with in group: Table 1 -panel D

----------------------------------------------------------------------
====================================================================*/


***************************************************
* Panel A  Heterogeneity by variable of over work *
***************************************************


/*====================================================================
                        A.0: Set up
====================================================================*/

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byOWK


/*====================================================================
                        A.1: Analysis
====================================================================*/

use "$data_final/04_UGA_ETH_Prepared.dta", clear


foreach outcome of global outcome_1 {

   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & over_work_m == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETOWK0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MOWK0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & over_work_m == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAROWKOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & over_work_m == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAROWKSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & over_work_m == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETOWK1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MOWK1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & over_work_m == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MAROWKOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & over_work_m == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MAROWKSO1_0_`outcome', title(Model `outcome')


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



esttab  HETOWK1_0_`outcome' HETOWK0_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        prehead("\begin{tabular}{l*{4}{l}} \toprule ") ///
        posthead("\\[-0.6cm] & \multicolumn{4}{c}{\textit{Hosts as respondents}}  \\ \midrule \multicolumn{5}{c}{\textbf{PANEL A: Working hours beyond legal threshold}} \\ & \multicolumn{2}{c}{\textit{High share over-worked}} & \multicolumn{2}{c}{\textit{Low share over-worked}}   \\  \midrule  ") ///
        compress replace label fragment noobs wide ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        mtitles(" "  " ") ///
        prefoot(" ") //

esttab  HETOWK1_0_`outcome' HETOWK0_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAROWKOG1_0_`outcome' MAROWKOG0_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MAROWKSO1_0_`outcome' MAROWKSO0_0_`outcome'    /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MOWK1_0_`outcome' M_EMPTY MOWK0_0_`outcome' M_EMPTY ///
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") 

}



*************************************************************
* Panel B  Heterogeneity by variable of occupation pressure *
*************************************************************


/*====================================================================
                        B.0: Set up
====================================================================*/


*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byPOG
   
/*====================================================================
                        B.1: Analysis
====================================================================*/               


use "$data_final/04_UGA_ETH_Prepared.dta", clear


foreach outcome of global outcome_1 {


             *************************************
             *       OCCCUPATION-PRESSURE        *
             *************************************


   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & ref_overrep == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETPOG0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MPOG0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & ref_overrep == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARPOGOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & ref_overrep == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARPOGSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & ref_overrep == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETPOG1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MPOG1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & ref_overrep == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARPOGOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & ref_overrep == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARPOGSO1_0_`outcome', title(Model `outcome')


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






esttab  HETPOG0_0_`outcome' HETPOG1_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        posthead(" \\ \midrule \multicolumn{5}{c}{\textbf{PANEL B: Over-representation by industry}} \\ & \multicolumn{2}{c}{\textit{Hosts overrepresented}} & \multicolumn{2}{c}{\textit{Refugees overrepresented}}   \\  \midrule  ") ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETPOG0_0_`outcome' HETPOG1_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARPOGOG0_0_`outcome' MARPOGOG1_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARPOGSO0_0_`outcome' MARPOGSO1_0_`outcome'    /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MPOG0_0_`outcome' M_EMPTY MPOG1_0_`outcome' M_EMPTY ///
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") 

}













*********************************************************
* Panel C  Heterogeneity by variable of network/contact *
*********************************************************

/*====================================================================
                        C.0: Set up
====================================================================*/

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byN


/*====================================================================
                        C.1: Analysis
====================================================================*/
          

use "$data_final/04_UGA_ETH_Prepared.dta", clear


bys ethiopia: tab qirefugee
tab region



foreach outcome of global outcome_1 {


     ***************
     *** CONTACT ***
     ***************

   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & bi_network_outgroup == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETCON0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MCON0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & bi_network_outgroup == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARCOOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & bi_network_outgroup == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARCOSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & bi_network_outgroup == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETCON1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MCON1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & bi_network_outgroup == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARCOOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & bi_network_outgroup == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARCOSO1_0_`outcome', title(Model `outcome')


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



esttab  HETCON0_0_`outcome' HETCON1_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        posthead(" \\ \midrule \multicolumn{5}{c}{\textbf{PANEL C: Contact}} \\ & \multicolumn{2}{c}{\textit{No out-group friends}} & \multicolumn{2}{c}{\textit{Some out-group friends}}   \\  \midrule  ") ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETCON0_0_`outcome' HETCON1_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARCOOG0_0_`outcome' MARCOOG1_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARCOSO0_0_`outcome' MARCOSO1_0_`outcome'    /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MCON0_0_`outcome' M_EMPTY MCON1_0_`outcome' M_EMPTY ///
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") //





}




*********************************************************
* Panel D  Heterogeneity by variable of language shared *
*********************************************************

/*====================================================================
                        D.0: Set up
====================================================================*/


          *************************
          **** LANGUAGE SHARING ***
          *************************

*controls 
global controls ethiopia urban male age hhsize educ_primary employed  refugee 
global cluster  cluster_psu 
global weight   w 

global outcome_1    prej_aind_byLOG
 

/*====================================================================
                        D.1: Analysis
====================================================================*/
                 
use "$data_final/04_UGA_ETH_Prepared.dta", clear


bys ethiopia: tab qirefugee
tab region



foreach outcome of global outcome_1 {



   reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & maj_lang_og == 0  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup)
      estimates store HETLOG0_0_`outcome', title(Model `outcome')

        qui gen     smpl0_0 = 0
        qui replace smpl0_0 = 1 if e(sample)==1

     eststo MLOG0_0_`outcome':  estpost su `outcome'  if smpl0_0 == 1 [aw=$weight]

        drop smpl0_0

    ** MARGINS ** HOST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_og == 0   ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLOGOG0_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_og == 0  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLOGSO0_0_`outcome', title(Model `outcome')




    reg `outcome' i.exp_outgroup##i.exp_same_occup $controls [aw=$weight] if refugee == 0 & maj_lang_og == 1  ///
                , cluster($cluster)

      estimates table, k(1.exp_outgroup##1.exp_same_occup) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(1.exp_outgroup##1.exp_same_occup) 
      estimates store HETLOG1_0_`outcome', title(Model `outcome')

        qui gen     smpl1_0 = 0
        qui replace smpl1_0 = 1 if e(sample)==1

     eststo MLOG1_0_`outcome':  estpost su `outcome'  if smpl1_0 == 1 [aw=$weight]

        drop smpl1_0

    ** MARGINS ** HOTST **
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_og == 1  ///
                , cluster($cluster)
    margins , dydx(exp_outgroup) post
    estimates store MARLOGOG1_0_`outcome', title(Model `outcome')
    qui reg `outcome' i.exp_same_occup##i.exp_outgroup $controls [aw=$weight] if refugee == 0  & maj_lang_og == 1  ///
                , cluster($cluster)
    margins , dydx(exp_same_occup) post
    estimates store MARLOGSO1_0_`outcome', title(Model `outcome')


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




esttab  HETLOG0_0_`outcome' HETLOG1_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        posthead(" \\ \midrule \multicolumn{5}{c}{\textbf{PANEL D: Out-group language}} \\ & \multicolumn{2}{c}{\textit{Different language}} & \multicolumn{2}{c}{\textit{Shared language}}   \\  & \multicolumn{2}{c}{\textit{(main out-group language)}} & \multicolumn{2}{c}{\textit{(main out-group language)}}  \\ \midrule  ") ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        keep(1.exp_outgroup 1.exp_same_occup) ///
        varlabel(1.exp_outgroup "$\alpha1$: OutGroup (1) vs InGroup (0)" ///
                 1.exp_same_occup "$\alpha2$: Same (1) vs Different (0) Occupation") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  HETLOG0_0_`outcome' HETLOG1_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide  noline noobs nonumbers nomtitles ///
        k(1.exp_outgroup#1.exp_same_occup) ///
        varlabel(1.exp_outgroup#1.exp_same_occup "$\alpha3$: OutGroup x Same Occupation") /// 
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLOGOG0_0_`outcome' MARLOGOG1_0_`outcome'   /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_outgroup) nonumbers noobs nomtitles ///
        varlabel(1.exp_outgroup "H1: OutGroup (1) vs InGroup (0)") ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MARLOGSO0_0_`outcome' MARLOGSO1_0_`outcome'    /// 
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label wide noline ///
        keep(1.exp_same_occup) nonumbers noobs nomtitles ///
        varlabel(1.exp_same_occup "H2: Same (1) vs Different (0) Occupation") ///
        stats(N, fmt(0) labels("  \\\\[-0.5cm] N \\\\[-0.6cm]")) ///
        b(%8.2f) se(%8.2f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
        prefoot(" ") //

esttab  MLOG0_0_`outcome' M_EMPTY MLOG1_0_`outcome' M_EMPTY ///
        using "$out_tab/TAB1_Analysis_HeterogMutli.tex",  ///
        compress fragment append label noobs nonumbers nomtitles ///
        cells(mean(fmt(2) transpose  label("Mean"))) collabels(none) ///
        starlevels(* 0.1 ** 0.05 *** 0.01) noline ///
        prefoot(" ")  nodepvars  varlabels(r1 "Mean") ///
        postfoot("\bottomrule  \end{tabular}  ")




}


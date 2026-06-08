
/*

This file creates Appendix Table B-1.

The purpose of this table is to justify excluding women who report being only
1 or 2 months pregnant from the main pregnant-women analytic sample.

It estimates, separately by NFHS round, whether reporting 1 or 2 months of
pregnancy is associated with education, rural residence, son status, age,
parity, household wealth, and social group.

The table shows whether early pregnancy reports are selective on observed
characteristics. For this reason, the main analysis restricts the pregnant
sample to women who report being 3 or more months pregnant.

This file uses the final analytic dataset created by 10_assemble_data.do.
You need to have defined all required paths in 00_paths.do and have run
10_assemble_data.do for this file to work.

*/

do "$paths"
use "$all_nfhs_ir", clear

eststo clear


keep if v213 == 1
keep if !missing(gestdur)
keep if inlist(round, 3, 4, 5)

gen gestdur_1or2 = inlist(gestdur, 1, 2) // self-reports 1 or 2 months pregnant


drop if group==6

*---------------------------------
* Regress an indicator "reports being 1 or 2 months pregnant" on sociodemographic characteristics
* the coefficients on each variable will tell if women who report being 1 or 2 months pregnant are different than other pregnant women
*---------------------------------

foreach r in 3 4 5 {

    #delimit ;
    reghdfe gestdur_1or2
        i.less_edu
        i.rural
        i.noboy
        i.agebin
        i.parity
        i.wealth
        i.group
        [aw=v005]
        if round == `r',
        cluster(psu) absorb(state);
    #delimit cr

    eststo model_`r'
}


*---------------------------------
* LaTeX export
*---------------------------------

#delimit ;
esttab model_3 model_4 model_5 using "tables/tableB1_predicting_early_pregnancy.tex",
    replace
    booktabs
    nonumbers
    nonote
    label
    se
    star(* 0.10 ** 0.05 *** 0.01)
    b(3) se(4)
    mtitle("2005-2006" "2015-2016" "2019-2021")
    mgroups("reports of 1 or 2 months of pregnancy", pattern(1 0 0) ///
        span prefix(\multicolumn{@span}{c}{) suffix(}) ///
        erepeat(\cmidrule(lr){@span}))
    drop(0.less_edu 0.rural 0.noboy 1.agebin 1.parity 1.wealth 1.group)
    coeflabels( ///
        1.less_edu "\hspace*{1em}Less than primary education" ///
        1.rural    "\hspace*{1em}Rural resident" ///
        1.noboy    "\hspace*{1em}Does not have boy child" ///
        2.agebin   "\hspace*{1em}20--24" ///
        3.agebin   "\hspace*{1em}25--29" ///
        4.agebin   "\hspace*{1em}30--49" ///
        2.parity   "\hspace*{1em}1" ///
        3.parity   "\hspace*{1em}2" ///
        4.parity   "\hspace*{1em}3+" ///
        2.wealth   "\hspace*{1em}2nd quartile" ///
        3.wealth   "\hspace*{1em}3rd quartile" ///
        4.wealth   "\hspace*{1em}4th quartile" ///
        2.group    "\hspace*{1em}Dalit" ///
        3.group    "\hspace*{1em}OBC" ///
        4.group    "\hspace*{1em}Forward caste" ///
        5.group    "\hspace*{1em}Muslim" ///
        _cons      "\hspace*{1em}Constant") ///
    refcat( ///
        2.agebin "\textbf{Age categories} \\ (15--19 omitted)" ///
        2.parity "\textbf{Parity (live births)} \\ (0 omitted)" ///
        2.wealth "\textbf{Wealth quartiles} \\ (1st quartile omitted)" ///
        2.group "\textbf{Social group} \\ (Adivasi omitted)", nolabel)
    stats(N, fmt(%15.0fc) label("\textbf{N}"));
#delimit cr





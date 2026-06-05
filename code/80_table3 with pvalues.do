
/*

This file creates Table 3, which tests whether the difference in outcomes between women in patrilocal
extended households and women in nuclear households changed across NFHS rounds.

The file runs regressions with an interaction between survey round and
patrilocal extended household residence. The interaction term is the change in
the patrilocal-nuclear gap between rounds.

It does this for four outcomes: no say in own healthcare, no say in visits to
family or friends, birth in a health facility, and 4+ prenatal visits.

For the autonomy outcomes, the file uses the pregnant sample and state-module
weights. For the healthcare-use outcomes, the file uses the recent birth sample
and regular women's weights.

All regressions include wealth-group controls and state fixed effects. Standard
errors are clustered at the PSU level. The table reports 95% confidence
intervals for the coefficient estimates.

This file uses the final analytic dataset created by 10_assemble_data.do.
You need to have defined all required paths in 00_paths.do for this file to work.

*/

clear
set more off

do "$paths"
use "$all_nfhs_ir", clear

keep if inlist(round,3,4,5)
keep if ever_married==1
keep if inlist(hh_struc,1,2)

*******************************************************
* 1) Create samples and variables
*******************************************************

gen nfhs3to4 = inlist(round,3,4)
gen nfhs4to5 = inlist(round,4,5)
gen all_nfhs = 1

* facility birth
capture drop facility_birth
gen facility_birth = (home_birth==0) if !missing(home_birth)

*******************************************************
* 2) Prepare postfile to store results
*******************************************************

tempfile results
capture postclose hh

postfile hh ///
    str30 outcome ///
    str30 column ///
    double b ll ul N ///
    using `results', replace

*******************************************************
* 3) Loop over outcomes and samples and run regressions
*******************************************************

foreach outcome in nosay_healthcare nosay_visits facility_birth anc_four {

    foreach sample in nfhs3to4 nfhs4to5 all_nfhs {

        preserve
        keep if `sample'==1

        if inlist("`outcome'","nosay_healthcare","nosay_visits") {
            local ifcond "sample==2"
            local wt "[aw=w_state]"
        }
        else {
            local ifcond "sample==1"
            local wt "[aw=v005]"
        }
		
        quietly reghdfe `outcome' i.round##i.patrilocal i.wealth_group ///
            `wt' if `ifcond', cluster(psu) absorb(v024)

        matrix M = r(table)
        local N = e(N)

        * 3 -> 4
        if "`sample'"=="nfhs3to4" {
            local c = colnumb(M,"4.round#1.patrilocal")
            post hh ("`outcome'") ("NFHS-3 to 4") ///
                (M[1,`c']) (M[5,`c']) (M[6,`c']) (`N')
        }

        * 4 -> 5
        if "`sample'"=="nfhs4to5" {
            local c = colnumb(M,"5.round#1.patrilocal")
            post hh ("`outcome'") ("NFHS-4 to 5") ///
                (M[1,`c']) (M[5,`c']) (M[6,`c']) (`N')
        }

        * pooled
        if "`sample'"=="all_nfhs" {
            local c4 = colnumb(M,"4.round#1.patrilocal")
            local c5 = colnumb(M,"5.round#1.patrilocal")

            post hh ("`outcome'") ("Stacked 3 vs 4") ///
                (M[1,`c4']) (M[5,`c4']) (M[6,`c4']) (`N')

            post hh ("`outcome'") ("Stacked 3 vs 5") ///
                (M[1,`c5']) (M[5,`c5']) (M[6,`c5']) (`N')
        }

        restore
    }
}

postclose hh
use `results', clear

*******************************************************
* 4) Labels + formatting
*******************************************************

replace outcome = "No say in own healthcare$^1$"            if outcome=="nosay_healthcare"
replace outcome = "No say in visits to family/friends$^1$"  if outcome=="nosay_visits"
replace outcome = "Gave birth in a health facility$^2$"     if outcome=="facility_birth"
replace outcome = "Had 4+ prenatal visits$^2$"              if outcome=="anc_four"

gen cell = string(b,"%9.3f")
gen cicell = "[" + string(ll,"%9.3f") + ", " + string(ul,"%9.3f") + "]"
gen ncell = "N = " + string(N,"%12.0fc")

*******************************************************
* 5) Reshape wide
*******************************************************

gen colkey = ""
replace colkey = "y0506vs1516"      if column=="NFHS-3 to 4"
replace colkey = "y1516vs1921"      if column=="NFHS-4 to 5"
replace colkey = "stack0506vs1516"  if column=="Stacked 3 vs 4"
replace colkey = "stack0506vs1921"  if column=="Stacked 3 vs 5"

tempfile coefs cis ns

preserve
    keep outcome colkey cell
    reshape wide cell, i(outcome) j(colkey) string
    save `coefs'
restore

preserve
    keep outcome colkey cicell
    reshape wide cicell, i(outcome) j(colkey) string
    save `cis'
restore

keep outcome colkey ncell
reshape wide ncell, i(outcome) j(colkey) string
merge 1:1 outcome using `coefs', nogen
merge 1:1 outcome using `cis', nogen

*******************************************************
* 6) Order + expand to 3 rows + insert blank rows
*******************************************************

gen order = .
replace order = 1 if outcome=="No say in own healthcare$^1$"
replace order = 2 if outcome=="No say in visits to family/friends$^1$"
replace order = 3 if outcome=="Gave birth in a health facility$^2$"
replace order = 4 if outcome=="Had 4+ prenatal visits$^2$"
sort order

* 3 rows per outcome: coef / 95% CI / N
expand 3
bys outcome: gen line = _n

gen rowlabel = outcome if line==1
replace rowlabel = "" if line>1

foreach col in y0506vs1516 y1516vs1921 stack0506vs1516 stack0506vs1921 {
    gen c_`col' = ""
    replace c_`col' = cell`col'   if line==1
    replace c_`col' = cicell`col' if line==2
    replace c_`col' = ncell`col'  if line==3
}

* insert a blank row after each outcome block except the last
gen blankafter = (line==3 & order<4)
expand 2 if blankafter, gen(isblank)

replace rowlabel = "" if isblank==1
replace c_y0506vs1516 = "" if isblank==1
replace c_y1516vs1921 = "" if isblank==1
replace c_stack0506vs1516 = "" if isblank==1
replace c_stack0506vs1921 = "" if isblank==1

* make blank row come after the N row
gen rowsort = line
replace rowsort = 4 if isblank==1

sort order rowsort

*******************************************************
* 7) Export LaTeX
*******************************************************

#delimit ;

listtex rowlabel c_y0506vs1516 c_y1516vs1921 c_stack0506vs1516 c_stack0506vs1921 
    using "tables/table3_narrowing_gaps.tex", replace 
    rstyle(tabular) 
    head(
        "\begin{tabular}{lcccc}"
        "\toprule"
        " & \multicolumn{1}{c}{\shortstack{$\delta$ (Eq.~\ref{eq:tworounds})\\2005--2006 vs.\\2015--2016}} & \multicolumn{1}{c}{\shortstack{$\delta$ (Eq.~\ref{eq:tworounds})\\2015--2016 vs.\\2019--2021}} & \multicolumn{1}{c}{\shortstack{$\delta_4$ (Eq.~\ref{eq:stacked})\\2005--2006 vs.\\2015--2016}} & \multicolumn{1}{c}{\shortstack{$\delta_5$ (Eq.~\ref{eq:stacked})\\2005--2006 vs.\\2019--2021}} \\\\"
        "\midrule"
    )
    foot(
        "\bottomrule"
        "\end{tabular}"
    );

#delimit cr
```

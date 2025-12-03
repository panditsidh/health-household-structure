use $all_nfhs_ir, clear



keep if inlist(round,3,4,5)


*--------------------------------------------------------------------
* 1. Define outcome groups by regression spec
*--------------------------------------------------------------------
* these we use all pregnant sample
local outcomes_pregnant ///
    meat_egg_fish_weekly ///
    dairy_daily  

* these we use state module sample
local outcomes_state ///
    nosay_healthcare ///
    nosay_visits

* these we need to adjust for gestdur
local outcomes_adjusted ///
    anemic ///
    bmi

* these we use dv sample
local outcomes_dv ///
    dv_phys ///
    dv_sex 

* these we need to use all women with recent births
local outcomes_recentbirth ///
    home_birth_312 ///
    c_section_312

* master list of all outcomes
local outcomes `outcomes_pregnant' `outcomes_state' ///
               `outcomes_adjusted' `outcomes_dv' ///
               `outcomes_recentbirth'




*--------------------------------------------------------------------
* 2. Postfile setup: patrilocal–nuclear gaps by NFHS round
*--------------------------------------------------------------------
capture postclose handle

tempfile results
postfile handle str30 outcome str50 NFHS3 str50 NFHS4 str50 NFHS5 using `results', replace

*--------------------------------------------------------------------
* 3. Main loop: outcomes × rounds with different specs
*--------------------------------------------------------------------
*--------------------------------------------------------------------
* 3. Main loop: outcomes × rounds with different specs
*--------------------------------------------------------------------
foreach y of local outcomes {

    local NFHS3 ""
    local NFHS4 ""
    local NFHS5 ""

    foreach r in 3 4 5 {

        local sample   "inlist(hh_struc,1,2) & round==`r'"
        local wvar     "wt"
        local controls ""
        local addcond  ""

        * outcomes_pregnant: all pregnant sample
        if strpos(" `outcomes_pregnant' ", " `y' ") {
            local wvar "wt"
            local addcond " & pregnant==1"
        }

        * outcomes_state: state module
        if strpos(" `outcomes_state' ", " `y' ") {
            local wvar "w_state"
            local addcond " & pregnant==1"
        }

        * outcomes_adjusted: gestdur controls
        if strpos(" `outcomes_adjusted' ", " `y' ") {
            local wvar "wt"
            local controls "i.gestdur"
            local addcond " & pregnant==1"
        }

        * outcomes_dv: dv-weighted sample
        if strpos(" `outcomes_dv' ", " `y' ") {
            local wvar "w_dv"
            local addcond " & pregnant==1"
        }

        * outcomes_recentbirth: recent birth sample
        if strpos(" `outcomes_recentbirth' ", " `y' ") {
            local wvar "w_dv"
            local addcond ""
        }

        local fullsample "`sample'`addcond'"

        quietly count if `fullsample' & !missing(`y')
        if r(N)==0 {
            local out ""
        }
        else {

            *-------------------------
            * Run regression
            *-------------------------
			
			
            quietly reghdfe `y' patrilocal `controls' ///
                i.v149 i.v013 i.group i.parity ///
                i.prob_facility_distance i.rural i.v190 ///
                [aw=`wvar'] if `fullsample', absorb(state) cluster(psu)

                     *-------------------------
            * Use r(table) to extract everything
            *-------------------------
            matrix R = r(table)

            local b    = R[1, "patrilocal"]   // coefficient
            local se   = R[2, "patrilocal"]   // standard error
            local p    = R[4, "patrilocal"]   // p-value
            local lb   = R[5, "patrilocal"]   // lower CI
            local ub   = R[6, "patrilocal"]   // upper CI
			
			

            *-------------------------
            * Significance stars
            *-------------------------
            local stars ""
            if (`p'<0.01)      local stars "***"
            else if (`p'<0.05) local stars "**"
            else if (`p'<0.10) local stars "*"

            *-------------------------
            * Pretty formatting
            *-------------------------
            local coef : display %5.3f `b'
            local LCI  : display %5.3f `lb'
            local UCI  : display %5.3f `ub'

            *-------------------------
            * Final stored string
            *-------------------------
            local out "`coef' (`LCI', `UCI')`stars'"
        }

        * Assign to column
        if `r'==3 local NFHS3 "`out'"
        if `r'==4 local NFHS4 "`out'"
        if `r'==5 local NFHS5 "`out'"
    }

    post handle ("`y'") ("`NFHS3'") ("`NFHS4'") ("`NFHS5'")
}

postclose handle

use `results', clear

replace outcome = "Consumes meat/egg/fish at least weekly"       if outcome == "meat_egg_fish_weekly"
replace outcome = "Consumes dairy daily"                  if outcome == "dairy_daily"
replace outcome = "No say in own healthcare"              if outcome == "nosay_healthcare"
replace outcome = "No say in family visits"               if outcome == "nosay_visits"
replace outcome = "Any anemia"                            if outcome == "anemic"
replace outcome = "Body mass index (BMI)"                 if outcome == "bmi"
replace outcome = "Physical domestic violence"            if outcome == "dv_phys"
replace outcome = "Sexual domestic violence"              if outcome == "dv_sex"
replace outcome = "Home birth (3–12 months ago)"          if outcome == "home_birth_312"
replace outcome = "C-section (3–12 months ago)"           if outcome == "c_section_312"
         *-------------------------
            * Use r(table) to extract everything
            *-------------------------
            matrix R = r(table)

            local b    = R[1, "patrilocal"]   // coefficient
            local se   = R[2, "patrilocal"]   // standard error
            local p    = R[4, "patrilocal"]   // p-value
            local lb   = R[5, "patrilocal"]   // lower CI
            local ub   = R[6, "patrilocal"]   // upper CI

            *-------------------------
            * Significance stars
            *-------------------------
            local stars ""
            if (`p'<0.01)      local stars "***"
            else if (`p'<0.05) local stars "**"
            else if (`p'<0.10) local stars "*"

            *-------------------------
            * Pretty formatting
            *-------------------------
            local coef : display %5.3f `b'
            local LCI  : display %5.3f `lb'
            local UCI  : display %5.3f `ub'

            *-------------------------
            * Final stored string
            *-------------------------
            local out "`coef' [`LCI', `UCI']`stars'"



listtex outcome NFHS3 NFHS4 NFHS5 using "tables/table_adjusted.tex", ///
    replace rstyle(tabular) ///
    head("\begin{tabular}{lccc}" ///
         "\hline" ///
         "Outcome & 2005-06 & 2015-16 & 2019-21 \\\\" ///
         "\hline") ///
    foot("\hline" "\end{tabular}")


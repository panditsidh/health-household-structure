use $all_nfhs_ir, clear



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
postfile handle str30 outcome str12 NFHS3 str12 NFHS4 str12 NFHS5 using `results', replace

*--------------------------------------------------------------------
* 3. Main loop: outcomes × rounds with different specs
*--------------------------------------------------------------------
foreach y of local outcomes {

    * clear round-specific locals for this outcome
    local NFHS3 ""
    local NFHS4 ""
    local NFHS5 ""

    foreach r in 3 4 5 {

        *-------------------------
        * Base sample and defaults
        *-------------------------
        local sample   "inlist(hh_struc,1,2) & round==`r'"
        local wvar     "wt"
        local controls ""
        local addcond  ""      // extra condition (pregnant==1, etc.)

        * outcomes_pregnant: all pregnant sample, wt
        if strpos(" `outcomes_pregnant' ", " `y' ") {
            local wvar "wt"
            local addcond " & pregnant==1"
        }

        * outcomes_state: state module sample, w_state, pregnant
        if strpos(" `outcomes_state' ", " `y' ") {
            local wvar "w_state"
            local addcond " & pregnant==1"
        }

        * outcomes_adjusted: gestdur controls, pregnant sample, wt
        if strpos(" `outcomes_adjusted' ", " `y' ") {
            local wvar "wt"
            local controls "i.gestdur"
            local addcond " & pregnant==1"
        }

        * outcomes_dv: dv weights, pregnant sample
        if strpos(" `outcomes_dv' ", " `y' ") {
            local wvar "w_dv"
            local addcond " & pregnant==1"
        }

        * outcomes_recentbirth: recent-birth sample, no pregnant==1 filter
        if strpos(" `outcomes_recentbirth' ", " `y' ") {
            local wvar "w_dv"      // or w_birth if you have one
            local addcond ""       // assume y is only defined for recent births
        }

        * full sample condition for this outcome & round
        local fullsample "`sample'`addcond'"

        *-------------------------
        * Skip empty cells
        *-------------------------
        quietly count if `fullsample' & !missing(`y')
        if r(N)==0 {
            local out ""
        }
        else {
            *-------------------------
            * Run reghdfe with spec for this outcome
            *-------------------------
            quietly reghdfe `y' patrilocal `controls' ///
                [aw=`wvar'] if `fullsample', absorb(state) cluster(psu)

            *-------------------------
            * Extract coefficient & stars
            *-------------------------
            scalar b = _b[patrilocal]
            scalar p = 2*ttail(e(df_r), abs(_b[patrilocal]/_se[patrilocal]))

            local stars ""
            if (p<0.01)      local stars "***"
            else if (p<0.05) local stars "**"
            else if (p<0.10) local stars "*"

            local coef : display %5.3f b
            local out = "`coef'`stars'"
        }

        * store in correct survey column
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




listtex outcome NFHS3 NFHS4 NFHS5 using "tables/table_unadjusted.tex", ///
    replace rstyle(tabular) ///
    head("Table 2. Patrilocal–Nuclear Gaps without controls by NFHS Round" ///
         "\begin{tabular}{lccc}" ///
         "\hline" ///
         "Outcome & 2005-06 & 2015-16 & 2019-21 \\\\" ///
         "\hline") ///
    foot("\hline" "\end{tabular}")


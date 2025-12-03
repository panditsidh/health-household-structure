use $all_nfhs_ir, clear

*--------------------------------------------------------------------
* 1. Define outcome groups by regression spec
*--------------------------------------------------------------------
local outcomes_pregnant       meat_egg_fish_weekly dairy_daily
local outcomes_state          nosay_healthcare nosay_visits
local outcomes_adjusted       anemic bmi
local outcomes_dv             dv_phys dv_sex 
local outcomes_recentbirth    home_birth_312 c_section_312

local outcomes `outcomes_pregnant' `outcomes_state' `outcomes_adjusted' ///
               `outcomes_dv' `outcomes_recentbirth'

*--------------------------------------------------------------------
* 2. Postfile setup (UNADJUSTED)
*--------------------------------------------------------------------
capture postclose handle

tempfile unadj
postfile handle str50 outcome str60 NFHS3 str60 NFHS4 str60 NFHS5 using `unadj', replace

*--------------------------------------------------------------------
* 3. Loop: outcomes × rounds (UNADJUSTED)
*--------------------------------------------------------------------
foreach y of local outcomes {

    local NFHS3 ""
    local NFHS4 ""
    local NFHS5 ""

    foreach r in 3 4 5 {

        local sample   "inlist(hh_struc,1,2) & round==`r'"
        local wvar     "wt"
        local addcond  ""

        if strpos(" `outcomes_pregnant' ", " `y' ") {
            local addcond " & pregnant==1"
        }
        if strpos(" `outcomes_state' ", " `y' ") {
            local wvar "w_state"
            local addcond " & pregnant==1"
        }
        if strpos(" `outcomes_adjusted' ", " `y' ") {
            local addcond " & pregnant==1"
        }
        if strpos(" `outcomes_dv' ", " `y' ") {
            local wvar "w_dv"
            local addcond " & pregnant==1"
        }
        if strpos(" `outcomes_recentbirth' ", " `y' ") {
            local wvar "w_dv"
        }

        local fullsample "`sample'`addcond'"

        quietly count if `fullsample' & !missing(`y')
        if r(N)==0 {
            local out ""
        }
        else {

            quietly reghdfe `y' patrilocal ///
                [aw=`wvar'] if `fullsample', absorb(state) vce(cluster psu)

            matrix R = r(table)

            local b  = R[1,"patrilocal"]
            local se = R[2,"patrilocal"]
            local p  = R[4,"patrilocal"]
            local lb = R[5,"patrilocal"]
            local ub = R[6,"patrilocal"]

            local stars ""
            if (`p'<0.01)      local stars "***"
            else if (`p'<0.05) local stars "**"
            else if (`p'<0.10) local stars "*"

            local coef : display %7.4f `b'
            local LCI  : display %7.4f `lb'
            local UCI  : display %7.4f `ub'

            local out "`coef' (`LCI', `UCI')`stars'"
        }

        if `r'==3 local NFHS3 "`out'"
        if `r'==4 local NFHS4 "`out'"
        if `r'==5 local NFHS5 "`out'"
    }

    post handle ("`y'") ("`NFHS3'") ("`NFHS4'") ("`NFHS5'")
}

postclose handle

use `unadj', clear
save "tables/unadjusted.dta", replace


// use `unadj', clear
//
// replace outcome = "Consumes meat/egg/fish at least weekly" if outcome=="meat_egg_fish_weekly"
// replace outcome = "Consumes dairy daily"                   if outcome=="dairy_daily"
// replace outcome = "No say in own healthcare"               if outcome=="nosay_healthcare"
// replace outcome = "No say in family visits"                if outcome=="nosay_visits"
// replace outcome = "Any anemia"                             if outcome=="anemic"
// replace outcome = "Body mass index (BMI)"                  if outcome=="bmi"
// replace outcome = "Physical domestic violence"             if outcome=="dv_phys"
// replace outcome = "Sexual domestic violence"               if outcome=="dv_sex"
// replace outcome = "Home birth (3–12 months ago)"           if outcome=="home_birth_312"
// replace outcome = "C-section (3–12 months ago)"            if outcome=="c_section_312"

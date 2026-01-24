
* outcomes
local nat_outcomes   meat_egg_fish_weekly meat_egg_fish_daily dairy_daily home_birth bmi home_birth_312 c_section_312  anemic severe c_section v191 wealth_z 

local dv_outcomes    beating_justified dv_phys dv_sex

local state_outcomes nosay_healthcare nosay_ownearnings nosay_purchases nosay_visits

// local outcomes `nat_outcomes' `state_outcomes' `dv_outcomes'


replace nosay_purchases = . if round==2

*--------------------------------------------------------------------
* 3. Choose correct weights for this outcome
*--------------------------------------------------------------------


local outcomes c_section_312 home_birth_312

cd "/Users/sidhpandit/Documents/GitHub/household-structure/figures/"

foreach outcome in `outcomes' {



* Nutrition indicators
local lab_meat_egg_fish_weekly   "Consumes meat,egg,fish at least weekly"
local lab_meat_egg_fish_daily    "Consumes meat,egg,fish daily"
local lab_dairy_daily            "Consumes dairy daily"
local lab_home_birth_312             "Last birth occurred at home within 3-12 mo."

* Health outcomes
local lab_bmi                    "Body Mass Index (BMI)"
local lab_anemic                 "Any anemia (DHS cutoff for pregnancy)"
local lab_severe                 "Severe anemia (below 7 gdL)"
local lab_c_section              "Delivered by Csection"
local lab_c_section_312              "Delivered by Csection last 3-12 mo."

* Domestic violence (DHS D105 series)
local lab_beating_justified      "Believes husband is justified in beating wife"
local lab_dv_phys                "Experienced physical domestic violence"
local lab_dv_sex                 "Experienced sexual domestic violence"

* Decision-making indicators
local lab_nosay_healthcare       "No say in own healthcare"
local lab_nosay_ownearnings      "No say in spending earnings"
local lab_nosay_visits           "No say in visiting family and friends"

local lab_nosay_purchases         "No say in large purchases"

local lab_wealth_z           "Wealth index z score"







capture postclose handle
capture postutil clear



preserve

local ylab `lab_`outcome''

*-----------------

if strpos(" `nat_outcomes' ", " `outcome' ")   local wvar wt
if strpos(" `dv_outcomes' ",  " `outcome' ")   local wvar w_dv
if strpos(" `state_outcomes' ", " `outcome' ") local wvar w_state



svyset psu [pweight=`wvar'], strata(strata) singleunit(centered)



*--------------------------------------------------------------------
* 4. Create postfile to store results
*--------------------------------------------------------------------
tempfile results
postfile handle nfhs_round hh_type preg mean ci_low ci_high using `results', replace




*--------------------------------------------------------------------
* 5. FAST MAIN LOOP (no preserve/restore)
*--------------------------------------------------------------------
foreach r of numlist 2/5 {
	
	count if round==`r' & pregnant==0 & !missing(`outcome')
	local round`r'0 = r(N)
	count if round==`r' & pregnant==1 & !missing(`outcome')
	local round`r'1 = r(N) 
	
	
	
	
    foreach i of numlist 1/3 {
        foreach p of numlist 0/1 {
            
			
			
            * skip empty cells (important)
            quietly count if sub_`i'_`r'_`p'
            if r(N)==0 continue
			
			local a`i'_`r'_`p' = r(N)

            * calculate mean + CI
			
			if `round`r'`p''!=0 {
				quietly svy, subpop(sub_`i'_`r'_`p'): mean `outcome'
				matrix M = r(table)
				local mean = M[1,1]
				local low  = M[5,1]
				local high = M[6,1]

			}
			
			else {
				local mean = .
				local low = . 
				local high = .
			}
			
			
            
            
            * store results
            post handle (`r') (`i') (`p') (`mean') (`low') (`high')

        }
    }
}

postclose handle


*--------------------------------------------------------------------
* 6. Load results dataset
*--------------------------------------------------------------------
use `results', clear
gen year = 1998 if nfhs_round==2
replace year = 2005 if nfhs_round==3
replace year = 2015 if nfhs_round==4
replace year = 2020 if nfhs_round==5

gen survey_year_nuclear = year - 0.8
gen survey_year_sasural = year
gen survey_year_natal   = year + 0.8

gen prop_label = string(round(mean, .01), "%4.2f")

#delimit ;
twoway 
    (rcap ci_low ci_high survey_year_nuclear if hh_type==1 & preg==0,
        lcolor(black)
        lwidth(medthick)
    )
    (scatter mean survey_year_nuclear if hh_type==1 & preg==0,
        msymbol(Oh)
        mcolor(black)
        mfcolor(white)
        msize(medium)
        mlabel(prop_label)
        mlabpos(9)
        mlabsize(tiny)
        mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_sasural if hh_type==2 & preg==0,
        lcolor(black)
        lwidth(medthick)
    )
    (scatter mean survey_year_sasural if hh_type==2 & preg==0,
        msymbol(square)
        mcolor(black)
        msize(medium)
        mlabel(prop_label)
        mlabpos(12)
        mlabsize(tiny)
        mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_natal if hh_type==3 & preg==0,
        lcolor(gs8)
        lwidth(medthick)
    )
    (scatter mean survey_year_natal if hh_type==3 & preg==0,
        msymbol(triangle)
        mcolor(gs8)
        msize(medium)
        mlabel(prop_label)
        mlabpos(3)
        mlabsize(tiny)
        mlabcolor(black)
    ),
    xlabel(1998 "1998-1999" 2005 "2005-2006" 2015 "2015-2016" 2020 "2019-2021", 
        labsize(small) angle(0)
    )
    ylabel(0(.2)1, labsize(medium) grid)
    yscale(range(0 1))
    ytitle("`ylab'", size(medium))
    xtitle("Survey year", size(medium))
    legend(
        order(
            2 "Nuclear"
            4 "Patrilocal"
            6 "Natal"
        )
        row(1)
        pos(6)
        size(medium)
    )
    graphregion(color(white))
    aspect(0.7)
	caption("1998–99: `round20' nonpregnant, 2005–06: `round30' nonpregnant" ///
				"2015–16: `round40' nonpregnant, 2019–21: `round50' nonpregnant");

#delimit cr

graph save "`ylab'_nonpregnant", replace
graph export "`ylab'_nonpregnant.png", as(png) replace




restore

}

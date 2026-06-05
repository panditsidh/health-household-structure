/*

This file creates Appendix Table A-3.

The table decomposes the total change in each outcome between NFHS-3 and NFHS-5.

For each outcome, the total change is split into two parts:
1. the part explained by changes in the share of women living in nuclear versus
   patrilocal extended households, and
2. the part due to changes in outcomes within household structure categories.

The autonomy outcomes use the pregnant sample and state-module weights. The
healthcare-use outcomes use the recent birth sample and regular women's weights.

This file uses the final analytic dataset created by 10_assemble_data.do.
You need to have defined all required paths in 00_paths.do for this file to work.

*/


clear
set more off

do "$paths"

use "$all_nfhs_ir", clear

keep if ever_married==1


keep if inlist(hh_struc,1,2)

keep if inlist(round,3,4,5)


capture postclose h
tempfile results
postfile h ///
    str25 outcome ///
    double total_gap pct_explained pct_unexplained ///
    using `results', replace



foreach outcome in nosay_healthcare nosay_visits anc_four facility_birth  {
	
	preserve 
	
	if "`outcome'"=="nosay_healthcare" | "`outcome'"=="nosay_visits" {
		local outcome_wt w_state
		keep if sample==2
		
	}
	else {
		local outcome_wt  wt
		keep if sample==1
	} 
	
	foreach h in 1 2 {
		
		
		foreach r in 3 5 {
			
			* weights for the decomposition, shares of women in each sample x round in each household structure
			sum nuclear [aw=wt] if round==`r'
			local wt_1`r' = r(mean)
			
			sum patrilocal [aw=wt] if round==`r'
			local wt_2`r' = r(mean)
			
			
			* outcomes for the decomposition, within round x hhstructure
			sum `outcome' [aw=`outcome_wt'] if hh_struc==`h' & round==`r'
			local outcome_`h'`r' = r(mean)
			
			
			sum `outcome' [aw=wt] if round==`r'
			local outcome_`r' = r(mean)
			

		}
		
		
		
		
		* components of the gap
		local within_`h' = (`outcome_`h'5' - `outcome_`h'3') * (`wt_`h'3' + `wt_`h'5')/2
		
		
		
		local between_`h' = (`outcome_`h'3' + `outcome_`h'5')/2 * (`wt_`h'5' - `wt_`h'3')
		
		
	}
	
	local total_gap =  `outcome_5'  - `outcome_3' 
	
	local pct_explained = (`between_1' + `between_2')/`total_gap' * 100 
	
	local pct_unexplained = (`within_1' + `within_2')/`total_gap' * 100
	
	
	display("total gap is `total_gap'")
	display("pct explained is `pct_explained'")
	
	
	post h ("`outcome'") (`total_gap') (`pct_explained') (`pct_unexplained')
	
	
	restore
}


postclose h

use `results', clear




*******************************************************
* Format Table 3 + export with listtex (LaTeX)
* Assumes current data in memory has:
* outcome total_gap pct_explained pct_unexplained
*******************************************************

* 1) Clean + rename
rename total_gap      total_change
rename pct_explained  share_hhstruc

* If your pct_unexplained is off (it is, given negatives), rebuild it:
gen share_within = 100 - share_hhstruc

* 2) Make outcome labels (nice names)
gen outcome_name = ""
replace outcome_name = "No say in own healthcare$^1$"              if outcome=="nosay_healthcare"
replace outcome_name = "No say in visits to family/friends$^1$"    if outcome=="nosay_visits"
replace outcome_name = "Four or more prenatal visits$^2$"         if outcome=="anc_four"
replace outcome_name = "Birth in a health facility$^2$"            if outcome=="facility_birth"

* 3) Convert total change to percentage points (pp) and round to 2 decimals
gen total_change_pp = 100*total_change

gen total_pp_r   = round(total_change_pp, 0.01)
gen share_hh_r   = round(share_hhstruc,    0.01)
gen share_wi_r   = round(share_within,     0.01)

* 4) String versions for display/export (keeps trailing zeros)
gen disp_total = string(total_pp_r, "%9.2f")
gen disp_hh    = string(share_hh_r, "%9.2f")
gen disp_with  = string(share_wi_r, "%9.2f")

* 5) Keep only what you want in the exported table
keep outcome_name disp_total disp_hh disp_with
order outcome_name disp_total disp_hh disp_with



#delimit ;

listtex outcome_name disp_total disp_hh disp_with ///
    using "tables/tableA3 outcomes decomposition.tex", replace ///
    rstyle(tabular) ///
    head("\begin{tabular}{lccc}"
         "\toprule"
         "Outcome & \makecell{Total change\\(pp)} & \makecell{Share explained by \\household structure (\%)} & \makecell{Share from within-\\household structure changes (\%)} \\"
         "\midrule") ///
    foot("\bottomrule"
         "\end{tabular}");

#delimit cr

*------------------------------------------------------------
* Table: % patrilocal among pregnant women, NFHS-3/4/5
* by region, group, v025, v013 + significance (3 vs 5)
* with section headers, indentation, and blank row after each group
*------------------------------------------------------------

set more off

* Start from your big IR file
use $all_nfhs_ir, clear

* Keep only what we need and restrict sample
keep patrilocal wt round region group v025 v013 pregnant
keep if pregnant == 1 & inlist(round, 3, 4, 5)

*------------------------------------------------------------
* Set up postfile
*------------------------------------------------------------

capture postclose handle

tempfile results
postfile handle ///
    str20 panel ///      // which variable: region, group, v025, v013
    str60 category ///   // value label or section header (with indentation)
    str12 NFHS3 ///
    str12 NFHS4 ///
    str12 NFHS5 ///
    str12 significance ///
    using `results', replace

* Over-variables to loop over
local overvars "region group v025 v013"

*------------------------------------------------------------
* Main loop
*------------------------------------------------------------

foreach ov of local overvars {

    di "Processing `ov' ..."

    * ---------- Section header row for this panel ----------
    local hdr ""
    if "`ov'" == "region" local hdr "\textbf{Region}"
    if "`ov'" == "group"  local hdr "\textbf{Social group}"
    if "`ov'" == "v025"   local hdr "\textbf{Residence}"
    if "`ov'" == "v013"   local hdr "\textbf{Age group}"

    * post header row (no indentation, no values)
    post handle ("`ov'") ("`hdr'") ("") ("") ("") ("")

    * Get the levels that actually appear in this restricted sample
    levelsof `ov', local(levels)

    foreach lvl of local levels {

        * Reset strings for this subgroup
        local s3 ""
        local s4 ""
        local s5 ""
        local sig ""

        * ---- Means for each round ----
        foreach r in 3 4 5 {
            quietly summarize patrilocal [aw=wt] ///
                if round==`r' & `ov'==`lvl'

            if r(N) > 0 {
                local m`r' = r(mean)*100
                local s`r' : display %4.1f `m`r''
            }
        }

        * ---- Significance: NFHS-3 vs NFHS-5 ----
        quietly regress patrilocal i.round ///
            if inlist(round,3,5) & `ov'==`lvl' [aw=wt]

        capture noisily lincom 5.round - 3.round
        if _rc == 0 {
            local p = r(p)
            if `p' < 0.10 local sig "*"
            if `p' < 0.05 local sig "**"
            if `p' < 0.01 local sig "***"
        }

        * ---- Category label (with indentation) ----
        local rawlbl : label (`ov') `lvl'
        if "`rawlbl'" == "" local rawlbl "`ov'=`lvl'"

        * indent everything that is not a header
        * (headers all start with \textbf, which only appear in hdr above)
        local lbl "\hspace{1em}`rawlbl'"

        * ---- Post one row ----
        post handle ("`ov'") ("`lbl'") ("`s3'") ("`s4'") ("`s5'") ("`sig'")
    }

    * ---- Blank row at the END of this group/panel ----
    post handle ("`ov'") ("") ("") ("") ("") ("")
}

*------------------------------------------------------------
* Close and look
*------------------------------------------------------------

postclose handle

use `results', clear
order panel category NFHS3 NFHS4 NFHS5 significance
list, sepby(panel)

*----------------------------------------------------------------
* Prepare for LaTeX export
*----------------------------------------------------------------
* make sure panel is gone
capture drop panel

* optional: order columns
order category NFHS3 NFHS4 NFHS5 significance

#delimit ;
listtex category NFHS3 NFHS4 NFHS5 significance using ///
"tables/patrilocal_table.tex", replace ///
  rstyle(tabular) ///
  head("\begin{tabular}{lcccc}" ///
       "\toprule" ///
       "Category & NFHS-3 & NFHS-4 & NFHS-5 & Sig. \\\\" ///
       "\midrule") ///
  foot("\bottomrule" ///
       "\end{tabular}");
#delimit cr

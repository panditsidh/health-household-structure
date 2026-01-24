*******************************************************
* Table: mean nosay_healthcare by group, HH structure,
*        and NFHS round (2–5), for ever-married women
*******************************************************

use $all_nfhs_ir, clear

* Restrict sample if desired
// keep if ever_married == 1

svyset psu [pweight=wt], strata(strata) singleunit(centered)


keep if pregnant==1
keep if inlist(hh_struc, 1, 2, 3)   // 1=Nuclear, 2=Patrilocal, 3=Natal

* Define groups, structures, and rounds
local groups 1 2 3 4 5              // Adivasi, Dalit, OBC, Forward, Muslim
local ngrps : word count `groups'
local nstruc 3                      // Nuclear, Patrilocal, Natal
local rounds 2 3 4 5                // NFHS-2 to NFHS-5

* Create a results matrix for each round: ngrps x nstruc
foreach r of local rounds {

    matrix res`r' = J(`ngrps', `nstruc', .)

    local row = 1
    foreach g of local groups {
        forvalues s = 1/`nstruc' {

            * Check there are observations in this cell
            quietly count if round == `r' & group == `g' & hh_struc == `s'
            if r(N) > 0 {
                quietly mean nosay_healthcare [aw = wt] ///
                    if round == `r' & group == `g' & hh_struc == `s'
                matrix T = r(table)
                matrix res`r'[`row', `s'] = T[1,1]   // mean
            }
            else {
                matrix res`r'[`row', `s'] = .
            }

        }
        local ++row
    }
}

* Two-row blank spacer matrix
matrix blank = J(2, `nstruc', .)
matrix blank1 = J(1, `nstruc', .)

* Stack the round-specific matrices with blank rows between
matrix results_all = blank1 \ res2 \ blank \ ///
                    res3 \ blank \ ///
                    res4 \ blank \ ///
                    res5

* Bring matrix into Stata as variables
clear


* Add LaTeX-friendly row labels: 5 groups per round + 2 blanks between
input str80 row
"\textbf{NFHS-2 (1998–99)}"
"\hspace*{2em}Adivasi"
"\hspace*{2em}Dalit"
"\hspace*{2em}OBC"
"\hspace*{2em}Forward caste"
"\hspace*{2em}Muslim"
""
"\textbf{NFHS-3 (2005–06)}"
"\hspace*{2em}Adivasi"
"\hspace*{2em}Dalit"
"\hspace*{2em}OBC"
"\hspace*{2em}Forward caste"
"\hspace*{2em}Muslim"
""
"\textbf{NFHS-4 (2015–16)}"
"\hspace*{2em}Adivasi"
"\hspace*{2em}Dalit"
"\hspace*{2em}OBC"
"\hspace*{2em}Forward caste"
"\hspace*{2em}Muslim"
""
"\textbf{NFHS-5 (2019–21)}"
"\hspace*{2em}Adivasi"
"\hspace*{2em}Dalit"
"\hspace*{2em}OBC"
"\hspace*{2em}Forward caste"
"\hspace*{2em}Muslim"
end

svmat results_all, names(col)

* Name the columns
rename c1 Nuclear
rename c2 Patrilocal
rename c3 Natal


* Format numbers as strings and blank them out on spacer rows
foreach col in Nuclear Patrilocal Natal {
    gen str20 ci_`col' = substr(string(`col', "%4.2f"), 2, .)
    replace ci_`col' = "" if row == ""
}

* Keep only what we need for the LaTeX table
keep row ci_*

* Export using listtex
#delimit ;
listtex row ///
    ci_Nuclear ci_Patrilocal ci_Natal ///
    using "tables/nosay_by_hhstruct_round.tex", replace ///
    rstyle(tabular) ///
    head("\begin{tabular}{l*{3}{>{\centering\arraybackslash}p{1.4cm}}}" ///
         "\toprule" ///
         " & Nuclear & Patrilocal & Natal \\\\" ///
         "\midrule") ///
    foot("\bottomrule" ///
         "\end{tabular}");
#delimit cr

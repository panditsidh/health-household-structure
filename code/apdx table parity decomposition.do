*******************************************************
* Kitagawa decomposition of increase in patrilocal residence
* explained by parity composition
* NFHS-3 vs NFHS-5
*
* Assumes in $all_nfhs_ir:
*   - round == 3 or 5
*   - pregnant == 1 for currently pregnant women
*   - hh_struc: 1 = nuclear, 2 = patrilocal
*   - parity variable is named parity
*   - wt is analysis weight





*******************************************************

clear
set more off

use $all_nfhs_ir, clear

keep if ever_married==1
keep if inlist(hh_struc,1,2)

drop parity*

* true parity (number of children before current pregnancy)
gen parity_true = .
replace parity_true = 0 if missing(bord_01)
replace parity_true = bord_01 if !missing(bord_01)

* grouped parity for decomposition
gen parity = .
replace parity = 1 if parity_true==0          // first pregnancy
replace parity = 2 if parity_true==1
replace parity = 3 if parity_true==2
replace parity = 4 if parity_true>=3

label define paritylbl ///
    1 "Parity 0 (first pregnancy)" ///
    2 "Parity 1" ///
    3 "Parity 2" ///
    4 "Parity 3+", replace
label values parity paritylbl

gen parity1 = parity==1
gen parity2 = parity==2
gen parity3 = parity==3
gen parity4 = parity==4


drop if missing(parity)


*-----------------------------*
* Sample
*-----------------------------*
keep if pregnant==1
keep if inlist(round,3,5)
keep if inlist(hh_struc,1,2)

*-----------------------------*



*
*-----------------------------*
* Overall patrilocal rates
*-----------------------------*
foreach r in 3 5 {
    quietly sum patrilocal [aw=wt] if round==`r'
    local pat_`r' = r(mean)
}

local total_change = `pat_5' - `pat_3'

*-----------------------------*
* Post decomposition pieces by parity category
*-----------------------------*
capture postclose h
tempfile results
postfile h ///
    str15 group ///
    double share3 share5 ///
    double rate3 rate5 ///
    double explained unexplained ///
    using `results', replace

foreach j in 1 2 3 4 {

    * weighted share in each round
    quietly sum parity`j' [aw=wt] if round==3
    local share3_`j' = r(mean)

    quietly sum parity`j' [aw=wt] if round==5
    local share5_`j' = r(mean)

    * patrilocal rate within parity category in each round
    quietly sum patrilocal [aw=wt] if round==3 & parity==`j'
    local rate3_`j' = r(mean)

    quietly sum patrilocal [aw=wt] if round==5 & parity==`j'
    local rate5_`j' = r(mean)

    * Kitagawa components
    local explained_`j'   = (`share5_`j'' - `share3_`j'') * ///
                            ((`rate5_`j'' + `rate3_`j'')/2)

    local unexplained_`j' = (`rate5_`j'' - `rate3_`j'') * ///
                            ((`share5_`j'' + `share3_`j'')/2)
	
	
	if `j'==4 local row "Parity 4+"
	else local row "Parity `j'"
    post h ///
        ("`row'") ///
        (`share3_`j'') ///
        (`share5_`j'') ///
        (`rate3_`j'') ///
        (`rate5_`j'') ///
        (`explained_`j'') ///
        (`unexplained_`j'')
}

* totals
local total_explained = `explained_1' + `explained_2' + `explained_3' + `explained_4'
local total_unexplained = `unexplained_1' + `unexplained_2' + `unexplained_3' + `unexplained_4'
local pct_explained = (`total_explained'/`total_change')*100
local pct_unexplained = (`total_unexplained'/`total_change')*100

post h ///
    ("Total") ///
    (1) ///
    (1) ///
    (`pat_3') ///
    (`pat_5') ///
    (`total_explained') ///
    (`total_unexplained')

postclose h

use `results', clear

*******************************************************
* Format for appendix table
* Show shares and rates in percent
* Show explained and unexplained as percent of total change
*******************************************************

* save total change in percentage points before altering variables
local total_change_pp = 100*`total_change'

* convert shares and rates to percents
foreach v in share3 share5 rate3 rate5 {
    replace `v' = 100*`v'
}

* convert explained and unexplained to percent of total change
gen explained_pct   = (explained/`total_change')*100
gen unexplained_pct = (unexplained/`total_change')*100

* rounded display vars
gen share3_r          = round(share3, 0.01)
gen share5_r          = round(share5, 0.01)
gen rate3_r           = round(rate3, 0.01)
gen rate5_r           = round(rate5, 0.01)
gen explained_pct_r   = round(explained_pct, 0.01)
gen unexplained_pct_r = round(unexplained_pct, 0.01)

* string vars for export
gen disp_share3          = string(share3_r, "%9.2f")
gen disp_share5          = string(share5_r, "%9.2f")
gen disp_rate3           = string(rate3_r, "%9.2f")
gen disp_rate5           = string(rate5_r, "%9.2f")
gen disp_explained_pct   = string(explained_pct_r, "%9.2f")
gen disp_unexplained_pct = string(unexplained_pct_r, "%9.2f")

* order rows
gen roworder = .
replace roworder = 1 if group=="Parity 1"
replace roworder = 2 if group=="Parity 2"
replace roworder = 3 if group=="Parity 3"
replace roworder = 4 if group=="Parity 4+"
replace roworder = 5 if group=="Total"
sort roworder

* keep export vars
keep group disp_share3 disp_share5 disp_rate3 disp_rate5 disp_explained_pct disp_unexplained_pct roworder
order group disp_share3 disp_share5 disp_rate3 disp_rate5 disp_explained_pct disp_unexplained_pct
sort roworder

list group disp_share3 disp_share5 disp_rate3 disp_rate5 disp_explained_pct disp_unexplained_pct, noobs sep(0)

*******************************************************
* Export LaTeX appendix table
*******************************************************

#delimit ;

listtex ///
    group disp_share3 disp_share5 disp_rate3 disp_rate5 disp_explained_pct disp_unexplained_pct ///
    using "tables/appendix table_decomp_patrilocal_parity.tex", replace ///
    rstyle(tabular) ///
    head("\begin{tabular}{lcccccc}"
         "\toprule"
         "Parity group & \makecell{Share in\\05-06 (\%)} & \makecell{Share in\\19-21 (\%)} & \makecell{Share patrilocal\\extended 05-06 (\%)} & \makecell{Share patrilocal\\extended 19-21 (\%)} & \makecell{Explained\\share of total\\change (\%)} & \makecell{Unexplained\\share of total\\change (\%)} \\"
         "\midrule") ///
    foot("\bottomrule"
         "\end{tabular}");

#delimit cr

*******************************************************
* Display summary numbers for text
*******************************************************

display "Total change in patrilocal residence (pp): " `total_change_pp'
display "Explained by parity composition (pp): " 100*`total_explained'
display "Unexplained (pp): " 100*`total_unexplained'
display "Percent explained by parity composition: " `pct_explained'
display "Percent unexplained: " `pct_unexplained'

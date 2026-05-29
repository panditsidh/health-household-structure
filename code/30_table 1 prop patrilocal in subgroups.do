
****************************************************************** OLD CODE BEFORE THE W_STATE STUFF ****************************************************************************************


do "code/31_sigstars for table 1.do"


use $all_nfhs_ir, clear

keep if inlist(hh_struc, 1, 2)
keep if inlist(round, 3, 4, 5)

cap drop sample
gen sample = .
replace sample = 1 if inrange(months_ago_last_birth, 3, 12)
replace sample = 2 if pregnant == 1 

capture label drop samplelbl
label define samplelbl ///
    1 "postpartum" ///
    2 "pregnant"
label values sample samplelbl




preserve

tempfile N
keep if sample==2
collapse (count) patrilocal, by(round sample)
reshape wide patrilocal, i(sample) j(round)
save `N', replace
restore


*------------------------------------------------------*
* Build "sample" separately because weights differ
*------------------------------------------------------*
tempfile sample group region v013 parity samp1 samp2

preserve
    keep if sample == 1
    collapse (mean) patrilocal [aw=wt], by(round sample)
    save `samp1'
restore

preserve
    keep if sample == 2
    collapse (mean) patrilocal [aw=wt], by(round sample)
    save `samp2'
restore

use `samp1', clear
append using `samp2'
reshape wide patrilocal, i(sample) j(round)
drop if sample == .
save `sample', replace



use `sample', clear

*------------------------------------------------------*
* Pregnant state-module sample for all subgroup rows
*------------------------------------------------------*
use $all_nfhs_ir, clear

keep if inlist(hh_struc, 1, 2)
keep if inlist(round, 3, 4, 5)
keep if pregnant == 1 & !missing(nosay_visits) & !missing(nosay_healthcare)

label define paritylbl ///
    1 "1 (no live births)" ///
    2 "2 (1 live birth)" ///
    3 "3 (2 live births)" ///
    4 "4+ (3+ live births)", replace
label values parity paritylbl

foreach overvar in group region v013 parity {
  
    preserve
  
    collapse (mean) patrilocal [aw=wt], by(round `overvar')
  
    reshape wide patrilocal, i(`overvar') j(round)
  
    drop if `overvar' == .
  
    save ``overvar'', replace
  
    restore
}


*------------------------------------------------------*
* Append all pieces together
*------------------------------------------------------*
use `sample', clear
append using `group'
append using `region'
append using `v013'
append using `parity'
append using `N'

gen row = ""
foreach overvar in sample group region v013 parity {
    capture confirm variable `overvar'
    if !_rc {
        capture decode `overvar', gen(`overvar'str)
        replace row = `overvar'str if !missing(`overvar'str)
    }
}

keep row patrilocal*
order row

gen order = _n

replace order = 27 if row == "postpartum"

sort order
expand 3 if inlist(order, 2, 3, 9, 16, 23, 26)

sort order

drop if _n == 2
drop if _n == 3
drop if _n == 35

capture drop row_fmt
input str150 row_fmt
"\textbf{All currently pregnant women}"
""
"\textbf{Social group}"
"\hspace*{2em}Forward caste"
"\hspace*{2em}OBC"
"\hspace*{2em}Dalit"
"\hspace*{2em}Adivasi"
"\hspace*{2em}Muslim"
"\hspace*{2em}Sikh/Jain/Christian"
""
"\textbf{Region}"
"\hspace*{2em}Focus states$^1$"
"\hspace*{2em}Central"
"\hspace*{2em}East"
"\hspace*{2em}West"
"\hspace*{2em}North"
"\hspace*{2em}South"
"\hspace*{2em}Northeast"
""
"\textbf{Age}"
"\hspace*{2em}15--19"
"\hspace*{2em}20--24"
"\hspace*{2em}25--29"
"\hspace*{2em}30--34"
"\hspace*{2em}35--39"
"\hspace*{2em}40--44"
"\hspace*{2em}45--49"
""
"\textbf{Parity (live births)}"
"\hspace*{2em}0"
"\hspace*{2em}1"
"\hspace*{2em}2"
"\hspace*{2em}3+"
""
"\textbf{All women 3--12 months postpartum}" 
"\textbf{N (currently pregnant women)}"  end

keep row_fmt patrilocal*
order row_fmt


*******************************************************
* Create display columns for Table 1
*******************************************************

* 1) Create string display columns
foreach r in 3 4 5 {
    gen str12 disp`r' = ""
}

* 2) Fill numeric rows with formatted values (2 decimals)
foreach r in 3 4 5 {
    replace disp`r' = string(patrilocal`r', "%4.2f") ///
        if row_fmt != "" & row_fmt!="\textbf{N (currently pregnant women)}"
		
	replace disp`r' = string(patrilocal`r', "%6.0fc") ///
        if row_fmt=="\textbf{N (currently pregnant women)}"
}

* 3) Blank out section headers + spacer rows
*    Keep only the two "overall" bold rows numeric
foreach r in 3 4 5 {
    replace disp`r' = "" ///
        if strpos(row_fmt, "\textbf{") ///
        & row_fmt != "\textbf{All currently pregnant women}" ///
        & row_fmt != "\textbf{All women 3--12 months postpartum}" ///
		& row_fmt != "\textbf{N (currently pregnant women)}"
}

* 4) Also blank explicit spacer rows (row_fmt == "")
foreach r in 3 4 5 {
    replace disp`r' = "" if row_fmt == ""
}

*******************************************************
* Optional: sanity check
*******************************************************
list row_fmt disp3 disp4 disp5, noobs sep(0)

drop if row_fmt == "\textbf{All women 3--12 months postpartum}"

gen master_order = _n

merge m:1 row_fmt using "tables/table1_rowfmt_sig_only.dta", nogen keepusing(sig)

sort master_order
drop master_order


*******************************************************
* Export Table 1
*******************************************************
#delimit ;
listtex ///
    row_fmt disp3 disp4 disp5 sig ///
    using "tables/DR/table 1 patrilocal in subgroups.tex", replace ///
    rstyle(tabular) ///
    head( ///
        "\begin{tabular}{lcccc}" ///
        "\toprule" ///
        " & \multicolumn{1}{c}{2005--2006} & \multicolumn{1}{c}{2015--2016} & \multicolumn{1}{c}{2019--2021} & \multicolumn{1}{c}{\shortstack{2005--2006 vs.\\2019--2021}} \\" ///
        "\midrule" ///
    ) ///
    foot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
    );
#delimit cr

**** OLD CODE, w_state stuff
// * first run 21 to make sure the significance stars columns are saved and ready to join
//
// do "code/21_sigstars for table 1.do"
//
// * now start getting the main proportions
//
// use $all_nfhs_ir, clear
//
// keep if inlist(hh_struc,1,2)
//
// * for the pregnant sample, we need to use state weights. so we have to get this part seperately
//
// tempfile sample
//
// preserve
// 	* 3-12 month postpartum
//     keep if sample==1
//     collapse (mean) patrilocal [aw=wt], by(round sample)
//     tempfile samp1
//     save `samp1'
// restore
//
// preserve
// 	* currently pregnant
//     keep if pregnant==1
//     collapse (mean) patrilocal [aw=w_state], by(round sample)
//     tempfile samp2
//     save `samp2'
// restore
//
// preserve
// use `samp1', clear
// append using `samp2'
// reshape wide patrilocal, i(sample) j(round)
// save `sample', replace
// restore
//
//
// * now we can easily collapse by the overvars and append everything
//
// foreach overvar in group region v013 parity {
//	
// 	keep if pregnant==1
//	
// 	preserve
//	
// 	collapse (mean) patrilocal [aw=w_state], by(round `overvar')
//	
// 	reshape wide patrilocal, i(`overvar') j(round)
//	
// 	drop if `overvar'==.
//	
// 	tempfile `overvar'
// 	save ``overvar''
//	
// 	restore
//	
// }
//
//
// use `sample', clear
//
// append using `group'
//
// append using `region'
//
// append using `v013'
//
// append using `parity'
//
//
// * the rest is formatting and exporting
//
// gen row = ""
// foreach overvar in sample group region v013 parity {
//	
// 	decode `overvar', gen(`overvar'str)
//	
// 	replace row = `overvar'str if  !missing(`overvar'str)
// }
//
//
// keep row patrilocal*
//
// order row
//
//
//
// gen order = _n
//
//
//
// replace order = 27 if row=="postpartum"
//
// sort order
//
// expand 3 if inlist(order,2,3,9,16,23,26)
//
//
// sort order
//
//
// drop if _n==2
//
// drop if _n==3
//
// drop if _n==35
//
//
// capture drop row_fmt
//
// input str150 row_fmt
// "\textbf{All currently pregnant women}"
// ""
// "\textbf{Social group}"
// "\hspace*{2em}Forward caste"
// "\hspace*{2em}OBC"
// "\hspace*{2em}Dalit"
// "\hspace*{2em}Adivasi"
// "\hspace*{2em}Muslim"
// "\hspace*{2em}Sikh/Jain/Christian"
// ""
// "\textbf{Region}"
// "\hspace*{2em}Focus states$^1$"
// "\hspace*{2em}Central"
// "\hspace*{2em}East"
// "\hspace*{2em}West"
// "\hspace*{2em}North"
// "\hspace*{2em}South"
// "\hspace*{2em}Northeast"
// ""
// "\textbf{Age}"
// "\hspace*{2em}15--19"
// "\hspace*{2em}20--24"
// "\hspace*{2em}25--29"
// "\hspace*{2em}30--34"
// "\hspace*{2em}35--39"
// "\hspace*{2em}40--44"
// "\hspace*{2em}45--49"
// ""
// "\textbf{Parity (live births)}"
// "\hspace*{2em}0"
// "\hspace*{2em}1"
// "\hspace*{2em}2"
// "\hspace*{2em}3+"
// ""
// "\textbf{All women 3--12 months postpartum}" end
//
//
//
// keep row_fmt patrilocal*
//
// order row_fmt
//
//
//
// *******************************************************
// * Create display columns for Table 1
// *******************************************************
//
// * 1) Create string display columns
// foreach r in 3 4 5 {
//     gen str12 disp`r' = ""
// }
//
// * 2) Fill numeric rows with formatted values (2 decimals)
// foreach r in 3 4 5 {
//     replace disp`r' = string(patrilocal`r', "%4.2f") ///
//         if row_fmt!="" 
// }
//
// * 3) Blank out section headers + spacer rows
// *    Keep only the two "overall" bold rows numeric
// foreach r in 3 4 5 {
//     replace disp`r' = "" ///
//         if strpos(row_fmt, "\textbf{") ///
//         & row_fmt!="\textbf{All currently pregnant women}" ///
//         & row_fmt!="\textbf{All women 3--12 months postpartum}"
// }
//
// * 4) Also blank explicit spacer rows (row_fmt == "")
// foreach r in 3 4 5 {
//     replace disp`r' = "" if row_fmt==""
// }
//
// *******************************************************
// * Optional: sanity check
// *******************************************************
// list row_fmt disp3 disp4 disp5, noobs sep(0)
//
//
//
// drop if row_fmt=="\textbf{All women 3--12 months postpartum}"
//
//
// gen master_order = _n
//
// merge m:1 row_fmt using "tables/table1_rowfmt_sig_only w_state.dta", nogen keepusing(sig)
//
// sort master_order
// drop master_order
//
//
// *******************************************************
// * Export Table 1
// *******************************************************
// #delimit ;
// listtex ///
//     row_fmt disp3 disp4 disp5 sig ///
//     using "tables/table1_patrilocal_by_subgroup w_state.tex", replace ///
//     rstyle(tabular) ///
//     head( ///
//         "\begin{tabular}{lcccc}" ///
//         "\toprule" ///
//         " & \multicolumn{1}{c}{NFHS-3} & \multicolumn{1}{c}{NFHS-4} & \multicolumn{1}{c}{NFHS-5} & \multicolumn{1}{c}{\makecell[c]{Sig.\\(2005--2006 vs.\\2019--2021)}} \\\\" ///
//         " & \multicolumn{1}{c}{(2005--2006)} & \multicolumn{1}{c}{(2015--2016)} & \multicolumn{1}{c}{(2019--2021)} & \\\\" ///
//         "\midrule" ///
//     ) ///
//     foot( ///
//         "\bottomrule" ///
//         "\end{tabular}" ///
//     );
// #delimit cr
//
//
//


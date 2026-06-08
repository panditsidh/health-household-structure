/*

This file creates Table 1.

Table 1 reports the proportion of currently pregnant women living in patrilocal
extended households in NFHS-3, NFHS-4, and NFHS-5. It reports these proportions
overall and by social group, region, age group, and parity.

The sample is restricted to women in either nuclear or patrilocal extended
households who are in the pregnant-women analytic sample.

The file first runs 31_sigstars_for_table_1.do, which creates the significance
stars for the difference between NFHS-3 and NFHS-5. It then uses collapse (mean)
to calculate weighted subgroup-level shares of women living in patrilocal
extended households. Finally, it formats the rows, merges in the significance
stars, and exports the LaTeX table.

You need to have defined all required paths in 00_paths.do for this file to work.

*/


do "$paths"
do "code/31_helper pvalues for table1.do"



use "$all_nfhs_ir", clear

* focus on nuclear and patrilocal
keep if inlist(hh_struc, 1, 2)

* only NFHS-3, 4 and 5
keep if inlist(round, 3, 4, 5)

keep if ever_married==1


* get overall sample sizes
preserve

tempfile N
keep if sample==2
collapse (count) patrilocal, by(round sample)
reshape wide patrilocal, i(sample) j(round)
save `N', replace
restore


tempfile sample group region v013 parity samp1 samp2


* get overall shares patrilocal within each sample
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



* now get shares patrilocal in different subgroups
use $all_nfhs_ir, clear

keep if inlist(hh_struc, 1, 2)
keep if inlist(round, 3, 4, 5)
keep if pregnant == 1 & !missing(nosay_visits) & !missing(nosay_healthcare)



foreach overvar in group region v013 parity {
  
    preserve
  
    collapse (mean) patrilocal [aw=wt], by(round `overvar')
  
    reshape wide patrilocal, i(`overvar') j(round)
  
    drop if `overvar' == .
  
    save ``overvar'', replace
  
    restore
}


*------------------------------------------------------*
* Append all pieces together and format nicely
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
"\textbf{N (currently pregnant women)}"
""  end

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



drop if row_fmt == "\textbf{All women 3--12 months postpartum}"

gen master_order = _n


// * merge in the significance stars column
merge m:1 row_fmt using "tables/table1_rowfmt_sig_only.dta", nogen keepusing(sig)

sort master_order
drop master_order





*******************************************************
* Export Table 1
*******************************************************
#delimit ;
listtex ///
    row_fmt disp3 disp4 disp5 sig ///
    using "tables/table1_patrilocal_increasing_inall_subgroups.tex", replace ///
    rstyle(tabular) ///
    head( ///
        "\begin{tabular}{lcccc}" ///
        "\toprule" ///
        " & \multicolumn{1}{c}{2005-2006} & \multicolumn{1}{c}{2015-2016} & \multicolumn{1}{c}{2019-2021} & \multicolumn{1}{c}{\shortstack{p-value\\2005-2006 vs.\\2019-2021}} \\" ///
        "\midrule" ///
    ) ///
    foot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
    );
#delimit cr

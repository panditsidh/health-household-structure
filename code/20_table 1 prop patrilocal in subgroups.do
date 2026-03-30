

use $all_nfhs_ir, clear

keep if inlist(hh_struc,1,2)

keep if inlist(round, 3,4,5)


gen months_ago_last_birth = v008 - b3_01
gen sample = 1 if inrange(months_ago_last_birth, 3, 12)
replace sample = 2 if pregnant==1
label define samplelbl ///
    1 "postpartum" ///
    2 "pregnant" 
label values sample samplelbl


label define paritylbl ///
    1 "1 (no live births)" ///
    2 "2 (1 live birth)" ///
	3 "3 (2 live births)" ///
	4 "4+ (3+ live births)" 	
label values parity paritylbl


foreach overvar in sample group region v013 parity {
	
	if "`overvar'"!="sample" keep if pregnant==1
	
	preserve
	
	collapse (mean) patrilocal [aw=wt], by(round `overvar')
	
	reshape wide patrilocal, i(`overvar') j(round)
	
	drop if `overvar'==.
	
	tempfile `overvar'
	save ``overvar''
	
	restore
	
}



use `sample', clear

append using `group'

append using `region'

append using `v013'

append using `parity'



gen row = ""
foreach overvar in sample group region v013 parity {
	
	decode `overvar', gen(`overvar'str)
	
	replace row = `overvar'str if  !missing(`overvar'str)
}


keep row patrilocal*

order row



gen order = _n



replace order = 27 if row=="postpartum"

sort order

expand 3 if inlist(order,2,3,9,16,23,26)


sort order


drop if _n==2

drop if _n==3

drop if _n==35


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
"\hspace*{2em}Focus states"
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
end



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
        if row_fmt!="" 
}

* 3) Blank out section headers + spacer rows
*    Keep only the two "overall" bold rows numeric
foreach r in 3 4 5 {
    replace disp`r' = "" ///
        if strpos(row_fmt, "\textbf{") ///
        & row_fmt!="\textbf{All currently pregnant women}" ///
        & row_fmt!="\textbf{All women 3--12 months postpartum}"
}

* 4) Also blank explicit spacer rows (row_fmt == "")
foreach r in 3 4 5 {
    replace disp`r' = "" if row_fmt==""
}

*******************************************************
* Optional: sanity check
*******************************************************
list row_fmt disp3 disp4 disp5, noobs sep(0)



drop if row_fmt=="\textbf{All women 3--12 months postpartum}"


*******************************************************
* Export Table 1
*******************************************************
#delimit ;

listtex ///
    row_fmt disp3 disp4 disp5 ///
    using "tables/table1 patrilocal_by_subgroup.tex", replace ///
    rstyle(tabular) ///
    head( ///
        "\begin{tabular}{lccc}" ///
        "\toprule" ///
        " & \multicolumn{1}{c}{NFHS-3} & \multicolumn{1}{c}{NFHS-4} & \multicolumn{1}{c}{NFHS-5} \\\\" ///
        " & \multicolumn{1}{c}{(2005--06)} & \multicolumn{1}{c}{(2015--16)} & \multicolumn{1}{c}{(2019--21)} \\\\" ///
        "\midrule" ///
    ) ///
    foot( ///
    "\bottomrule" ///
    "\end{tabular}" ///
);
#delimit cr

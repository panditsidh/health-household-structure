

use $all_nfhs_ir, clear



keep if inlist(round,3,4,5)

gen age_bin = v013
replace age_bin = 5 if inlist(age_bin,6,7)

* Labels
label define agelbl ///
    1 "15-19" ///
    2 "20-24" ///
    3 "25-29" ///
    4 "30-34" ///
    5 "35-49" 
	

label values age_bin agelbl

* Labels
label define paritylbl ///
    1 "Parity 1" ///
    2 "Parity 2" ///
    3 "Parity 3" ///
    4 "Parity 4+" 
	
label values parity paritylbl
	

label values age_bin agelbl


label define grouplabel ///
    1 "Currently pregnant women" ///
    2 "3-12 mo. postpartum women" 
 


gen months_ago_last_birth = v008 - b3_01
gen postpartum = inrange(months_ago_last_birth, 3, 12)


preserve

keep if postpartum==1

collapse (mean) patrilocal [aw=v005], by(round)
gen ones = 1

reshape wide patrilocal, i(ones) j(round)

drop ones

gen lab = "3-12 mo. postpartum women"

order lab

tempfile postpartum
save `postpartum'

restore

preserve

keep if preg==1

collapse (mean) patrilocal [aw=v005], by(round)
gen ones = 1

reshape wide patrilocal, i(ones) j(round)

drop ones

gen lab = "Currently pregnant women"

order lab

tempfile pregnant
save `pregnant'

restore


preserve

keep if preg==1

collapse (mean) patrilocal [aw=v005], by(round)

restore

foreach overvar in region group age_bin parity {
	
	display("`overvar'")
	
	preserve
	
	keep if preg==1
	
	drop if missing(`overvar')
	
	collapse (mean) patrilocal [aw=v005], by(round `overvar')
	
	reshape wide patrilocal, i(`overvar') j(round)
	
	decode(`overvar'), gen(lab)
	
	
	
	
	tempfile `overvar'
	save ``overvar''
	
	restore
}


use `pregnant', clear

append using `postpartum'

append using `region'

append using `group'

append using `age_bin'

append using `parity'


keep lab patrilocal*




*============================================================*
* Format patrilocal shares table into LaTeX (with subheaders)
* Data in memory must have: lab patrilocal3 patrilocal4 patrilocal5
*============================================================*

cap which listtex
if _rc ssc install listtex, replace

* 1) Round + display strings
foreach v in patrilocal3 patrilocal4 patrilocal5 {
    replace `v' = round(`v', .01)
    gen str8 disp_`v' = string(`v', "%4.2f")
}

* 2) Build ordering variable + bold where needed
gen int ord = .
gen str80 rowlab = lab

* Bold the two key rows
replace rowlab = "\textbf{Currently pregnant women}"      if lab=="Currently pregnant women"
replace rowlab = "\textbf{3-12 mo. postpartum women}"     if lab=="3-12 mo. postpartum women"

* Assign order for existing rows
replace ord = 10  if lab=="Currently pregnant women"
replace ord = 20  if lab=="3-12 mo. postpartum women"

replace ord = 110 if lab=="UP and Bihar"
replace ord = 120 if lab=="central"
replace ord = 130 if lab=="east"
replace ord = 140 if lab=="west"
replace ord = 150 if lab=="north"
replace ord = 160 if lab=="south"
replace ord = 170 if lab=="northeast"

replace ord = 210 if lab=="Forward Caste"
replace ord = 220 if lab=="OBC"
replace ord = 230 if lab=="Dalit"
replace ord = 240 if lab=="Adivasi"
replace ord = 250 if lab=="Muslim"
replace ord = 260 if lab=="Sikh, Jain, Christian"

replace ord = 310 if lab=="15-19"
replace ord = 320 if lab=="20-24"
replace ord = 330 if lab=="25-29"
replace ord = 340 if lab=="30-34"
replace ord = 350 if lab=="35-49"

replace ord = 410 if lab=="Parity 1"
replace ord = 420 if lab=="Parity 2"
replace ord = 430 if lab=="Parity 3"
replace ord = 440 if lab=="Parity 4+"

* Drop anything unexpected (optional; comment out if you want to keep)
drop if missing(ord)

tempfile core
keep ord rowlab disp_patrilocal3 disp_patrilocal4 disp_patrilocal5
save `core', replace

* 3) Create header + blank rows dataset, then append
clear
set obs 0
gen int ord = .
gen str80 rowlab = ""
gen str8 disp_patrilocal3 = ""
gen str8 disp_patrilocal4 = ""
gen str8 disp_patrilocal5 = ""

* helper: add one row
local i = 0
local ++i
set obs `i'
replace ord = 15 in `i'
replace rowlab = "" in `i'

local ++i
set obs `i'
replace ord = 25 in `i'
replace rowlab = "" in `i'

* Region header (bold) before region rows, plus blank after region block
local ++i
set obs `i'
replace ord = 100 in `i'
replace rowlab = "\textbf{Region (currently pregnant)}" in `i'

local ++i
set obs `i'
replace ord = 180 in `i'
replace rowlab = "" in `i'

* Social group header (bold) + blank after block
local ++i
set obs `i'
replace ord = 200 in `i'
replace rowlab = "\textbf{Social group (currently pregnant)}" in `i'

local ++i
set obs `i'
replace ord = 270 in `i'
replace rowlab = "" in `i'

* Age bins header (bold)  (no blank requested after, but you can add if you want)
local ++i
set obs `i'
replace ord = 300 in `i'
replace rowlab = "\textbf{Age bins (currently pregnant)}" in `i'

* Parity header (bold)
local ++i
set obs `i'
replace ord = 400 in `i'
replace rowlab = "\textbf{Parity (currently pregnant)}" in `i'

tempfile inserts
save `inserts', replace

* Bring back core + append inserts, then sort
use `core', clear
append using `inserts'
sort ord



listtex rowlab disp_patrilocal3 disp_patrilocal4 disp_patrilocal5 using "tables/table 1 share patrilocal", replace ///
    rstyle(tabular) delimiter("&") end("\\") nolabel ///
    head("\begin{tabular}{lccc}\toprule & 2005-2006 & 2015-2016 & 2019-2021 \\\\ \midrule") ///
    foot("\bottomrule\end{tabular}")

di as txt "Wrote: `texout'"



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


expand 3 if inlist(order,1,3,9,16,23)


sort order






input str150 row_fmt
"\textbf{Sample}"
"Gave birth 3-12 mo. ago"
"Currently pregnant"
"\textbf{}"
"\hspace*{2em}No say in own healthcare"
"\hspace*{2em}No say in visits to family/friends"
""
"\textbf{Wealth measures}"
"\hspace*{2em}Finished floor"
"\hspace*{2em}Electricity"
"\hspace*{2em}Owns radio"
"\hspace*{2em}Owns TV"
"\hspace*{2em}Owns refrigerator"
"\hspace*{2em}Owns bicycle"
"\hspace*{2em}Owns car"
"\hspace*{2em}Uses toilet/latrine"
"\hspace*{2em}Owns land"
""
"\textbf{N}"
""
"\textbf{Women who gave birth 3--12 months before the survey}"
""
"\textbf{Healthcare measures}"
"\hspace*{2em}Birth in a health facility"
"\hspace*{2em}4+ antenatal visits"
""
"\textbf{Wealth measures}"
"\hspace*{2em}Finished floor"
"\hspace*{2em}Electricity"
"\hspace*{2em}Owns radio"
"\hspace*{2em}Owns TV"
"\hspace*{2em}Owns refrigerator"
"\hspace*{2em}Owns bicycle"
"\hspace*{2em}Owns car"
"\hspace*{2em}Uses toilet/latrine"
"\hspace*{2em}Owns land"
""
"\textbf{N}" 
end

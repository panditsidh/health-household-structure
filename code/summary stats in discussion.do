
// median year of pregnant women's years of schooling//

tabstat v133 [aw=wt] if pregnant==1, by(round) stat(median)

// edu gap between husband and wife//
replace v133 = 20 if v133 > 20 & !missing(v133)
replace v715 = 20 if v715 > 20 & !missing(v715)
drop edu_gap
gen edu_gap = v715 - v133 if !missing(v715,v133)
tabstat edu_gap [aw=wt] if pregnant==1, by(round) stat(mean median)
tabstat edu_gap [aw=v005] if pregnant==1, by(round) stat(mean median)


// clean fuel//

gen cleanfuel = v161==2
tab round cleanfuel if pregnant==1 & patrilocal==1 [aw=wt], row

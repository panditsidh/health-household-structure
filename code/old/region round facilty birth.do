
use $all_nfhs_ir, clear

capture postclose handle
tempfile results

postfile handle nfhs_round region hh_struc hh_struc_share hh_struc_n public private home using `results', replace


foreach round of numlist 2/5 {
	
	
	foreach region of numlist 1/7 {
		
		
		
		
		foreach hh_struc of numlist 1/3 {
			
			count if round==`round' & region==`region' & hh_struc==`hh_struc'
			local hh_struc_n = r(N)
			
			sum hh_struc`hh_struc' if round==`round' & region==`region' [aw=wt]
			
			local hh_struc_share = r(mean)
			
			
			foreach facility of numlist 1/3 {
				
				
				sum facility`facility' if round==`round' & region==`region' & hh_struc==`hh_struc' [aw=wt]
				
				local facility`facility' = r(mean)
				
			}
			
			
			post handle (`round') (`region') (`hh_struc') (`hh_struc_share') (`hh_struc_n') (`facility1') (`facility2') (`facility3')
			
			
		}

		
		
		
	}
	
}

postclose handle

use `results', clear



label define regionlbl 1 "UP & Bihar" 2 "Central" 3 "East" 4 "West" 5 "North" 6 "South" 7 "Northeast", replace
label values region regionlbl



preserve

keep if nfhs_round==5

*----------------------------------------------*
* 2. Label household structure and regions     *
*    (edit labels to match your coding)        *
*----------------------------------------------*
label define hh_lbl 1 "Nuclear" 2 "Patrilocal" 3 "Natal"
label values hh_struc hh_lbl


*----------------------------------------------*
* 3. Make the 7-panel 100%-stacked bar graph   *
*----------------------------------------------*
graph bar home public private, ///
    over(hh_struc, gap(20)) /// 3 bars: one per household type
    asyvars stack /// stack the three vars within each bar
    ylabel(0(.2)1, format(%3.1f) angle(0)) ///
    ytitle("Share of births (home / public / private)") ///
    legend(order(1 "Home" 2 "Public" 3 "Private") pos(6) ring(0)) ///
    by(region, cols(3) ///
        title("Place of delivery by household structure and region, NFHS-5") ///
        note("Women with last birth 3–12 months before interview")) ///
    bargap(10) graphregion(color(white)) blabel(bar, format(%4.2f) position(inside) size(tiny))

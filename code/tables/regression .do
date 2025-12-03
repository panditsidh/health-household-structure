use $all_nfhs_ir, clear






reghdfe neonatal_death patrilocal ///
                [aw=wt] if round==5 & inlist(hh_struc,1,2), absorb(state) cluster(psu)


				
reghdfe neonatal_death patrilocal i.v149 i.v013 i.group i.parity i.prob_facility_distance i.rural ///
                [aw=wt] if round==5 & inlist(hh_struc,1,2), absorb(state) cluster(psu)	
				
				
reghdfe neonatal_death patrilocal private public i.v149 i.v013 i.group i.parity i.prob_facility_distance i.rural ///
                [aw=wt] if round==5 & inlist(hh_struc,1,2), absorb(state) cluster(psu)					


				
reghdfe neonatal_death i.patrilocal##i.region private public ///
    i.v149 i.v013 i.group i.parity i.prob_facility_distance i.rural [aw=wt] if round==5 & inlist(hh_struc,1,2), ///
    absorb(state) cluster(psu)



	
local outcome prob_health_permission

local r=3

reghdfe `outcome' patrilocal ///
                [aw=wt] if round==`r' & inlist(hh_struc,1,2), absorb(state) cluster(psu)


				
reghdfe `outcome' patrilocal i.v149 i.v013 i.group i.parity i.prob_facility_distance i.rural ///
                [aw=wt] if round==`r' & inlist(hh_struc,1,2), absorb(state) cluster(psu)		
				
				
				



reghdfe underweight patrilocal ///
                [aw=wt] if round==5 & inlist(hh_struc,1,2), absorb(state) cluster(psu)


				
reghdfe underweight patrilocal i.v149 i.v013 i.group i.parity i.prob_facility_distance i.rural ///
                [aw=wt] if round==5 & inlist(hh_struc,1,2), absorb(state) cluster(psu)						
				
reghdfe neonatal_death patrilocal private public ///
                [aw=wt] if round==5, absorb(state) cluster(psu)

				

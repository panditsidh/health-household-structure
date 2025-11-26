*==============================================================
* HARMONIZED 7-REGION CODING FOR NFHS-1 THROUGH NFHS-5
*==============================================================

* Step 1: Initialize
gen region = .

*==============================================================
* NFHS-5  (round == 5)
*==============================================================
replace region = 1 if inlist(v024, 9, 10)              & round==5   // UP, Bihar
replace region = 2 if inlist(v024, 23, 22)             & round==5   // MP, Chhattisgarh
replace region = 3 if inlist(v024, 19, 20, 21)         & round==5   // WB, Jharkhand, Odisha
replace region = 4 if inlist(v024, 24, 27, 30)         & round==5   // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 1,2,3,5,6,7,8)      & round==5   // J&K, HP, Punjab, Uttarakhand, Delhi, Haryana, Rajasthan
replace region = 6 if inlist(v024, 28,29,32,33,36)     & round==5   // AP, Karnataka, Kerala, TN, Telangana
replace region = 7 if inlist(v024, 12,13,14,15,16,18)  & round==5   // NE states

*==============================================================
* NFHS-4 (round == 4)
*==============================================================
replace region = 1 if inlist(v024, 33, 5)              & round==4   // UP, Bihar
replace region = 2 if inlist(v024, 19, 7)              & round==4   // MP, Chhattisgarh
replace region = 3 if inlist(v024, 35, 15, 26)         & round==4   // WB, Jharkhand, Odisha
replace region = 4 if inlist(v024, 11, 20, 10)         & round==4   // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 14,13,28,12,34,6)   & round==4   // J&K, HP, Punjab, Uttarakhand, Delhi, Haryana
replace region = 6 if inlist(v024, 2,36,17,31,16)      & round==4   // AP, Telangana, Kerala, TN, Karnataka
replace region = 7 if inlist(v024, 3,23,24,21,32,22,4,30) & round==4  // NE

*==============================================================
* NFHS-3 (round == 3)
*==============================================================
replace region = 1 if inlist(v024, 9, 10)              & round==3   // UP, Bihar
replace region = 2 if inlist(v024, 23, 22)             & round==3   // MP, Chhattisgarh
replace region = 3 if inlist(v024, 19, 20, 21)         & round==3   // WB, Jharkhand, Odisha
replace region = 4 if inlist(v024, 24, 27, 30)         & round==3   // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 1,2,3,5,6,8)        & round==3   // J&K, HP, Punjab, Uttarakhand, Haryana, Rajasthan
replace region = 6 if inlist(v024, 28,29,32,33)        & round==3   // AP, Karnataka, Kerala, TN
replace region = 7 if inlist(v024, 12,13,14,15,16,18)  & round==3   // NE

*==============================================================
* NFHS-2 (round == 2)
*==============================================================
replace region = 1 if inlist(v024, 9,10)               & round==2   // UP, Bihar
replace region = 2 if inlist(v024, 23,22)              & round==2   // MP, Chhattisgarh
replace region = 3 if inlist(v024, 19,20,21)           & round==2   // WB, Jharkhand, Orissa
replace region = 4 if inlist(v024, 24,27,30)           & round==2   // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 1,2,3,5,6,7,8)      & round==2   // J&K, HP, Punjab, Uttarakhand, Haryana, Delhi, Rajasthan
replace region = 6 if inlist(v024, 28,29,32,33)        & round==2   // AP, Karnataka, Kerala, TN
replace region = 7 if inlist(v024, 11,12,13,14,15,16,17,18) & round==2  // NE

*==============================================================
* NFHS-1 (round == 1)
*==============================================================
replace region = 1 if inlist(v024, 24,4)               & round==1   // UP, Bihar
replace region = 2 if v024 == 12                       & round==1   // MP (Chhattisgarh part of MP)
replace region = 3 if inlist(v024, 23,18)              & round==1   // WB, Orissa
replace region = 4 if inlist(v024, 6,13,5)             & round==1   // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 9,8,19,20,7,30)     & round==1   // Jammu, HP, Punjab, Rajasthan, Haryana, Delhi
replace region = 6 if inlist(v024, 2,10,11,22)         & round==1   // AP, Karnataka, Kerala, TN
replace region = 7 if inlist(v024, 3,14,15,16,17,34,35) & round==1  // NE

*==============================================================
* Dummies
*==============================================================
gen india     = 1
gen focus     = region==1
gen central   = region==2
gen east      = region==3
gen west      = region==4
gen north     = region==5
gen south     = region==6
gen northeast = region==7

* Optional Labels
label define regionlbl 1 "UP & Bihar" 2 "Central" 3 "East" 4 "West" 5 "North" 6 "South" 7 "Northeast", replace
label values region regionlbl
label var region "Macro-region (7-fold, NFHS 1–5 harmonized)"

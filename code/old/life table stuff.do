use $all_nfhs_ir, clear


/*

v730 - husband's age

were nuclear households more likely to have had an older person who died in older nfhs 

assumption: person who died would have made the household patrilocal



40-49 range: sons a woman has vs living with
no change in proportion of women who live without sons?
2+ married sons still in household?
any son is more likely to be living with his mom
proportion of adult sons who live with mom


round | woman | mil survival prob | fil survival prob | 


*/

tab v730

gen pil_age_imputed = v730+25

import delimited "IND.csv", clear 

label define regionlbl                                   ///
    0   "Whole country"                                  ///
    10  "Amritsar"                                       ///
    20  "Andhra Pradesh"                                 ///
    30  "Assam"                                          ///
    40  "Bihar"                                          ///
    50  "Central India"                                  ///
    60  "Chhattisgarh"                                   ///
    70  "East India"                                     ///
    80  "Gujarat"                                        ///
    90  "Gurdaspur"                                      ///
    100 "Haryana"                                        ///
    110 "Himachal Pradesh"                               ///
    120 "Jammu and Kashmir"                              ///
    130 "Jharkhand"                                      ///
    140 "Karnataka"                                      ///
    150 "Kerala"                                         ///
    160 "Madhya Pradesh"                                 ///
    170 "Maharashtra"                                    ///
    180 "NCT of Delhi"                                   ///
    190 "North India"                                    ///
    200 "Odisha"                                         ///
    210 "Punjab"                                         ///
    220 "Rajasthan"                                      ///
    230 "South India"                                    ///
    240 "Tamil Nadu"                                     ///
    250 "Telangana"                                      ///
    260 "Uttar Pradesh"                                  ///
    270 "Uttarakhand"                                    ///
    280 "West Bengal"                                    ///
    290 "West India"
    
label values region regionlbl


gen state_nfhs = .

replace state_nfhs = 28 if region == 20   // Andhra Pradesh
replace state_nfhs = 18 if region == 30   // Assam
replace state_nfhs = 10 if region == 40   // Bihar
replace state_nfhs = 22 if region == 60   // Chhattisgarh
replace state_nfhs = 24 if region == 80   // Gujarat
replace state_nfhs = 6  if region == 100  // Haryana
replace state_nfhs = 2  if region == 110  // Himachal Pradesh
replace state_nfhs = 1  if region == 120  // Jammu and Kashmir
replace state_nfhs = 20 if region == 130  // Jharkhand
replace state_nfhs = 29 if region == 140  // Karnataka
replace state_nfhs = 32 if region == 150  // Kerala
replace state_nfhs = 23 if region == 160  // Madhya Pradesh
replace state_nfhs = 27 if region == 170  // Maharashtra
replace state_nfhs = 7  if region == 180  // NCT of Delhi
replace state_nfhs = 21 if region == 200  // Odisha
replace state_nfhs = 3  if region == 210  // Punjab
replace state_nfhs = 8  if region == 220  // Rajasthan
replace state_nfhs = 33 if region == 240  // Tamil Nadu
replace state_nfhs = 36 if region == 250  // Telangana
replace state_nfhs = 9  if region == 260  // Uttar Pradesh
replace state_nfhs = 5  if region == 270  // Uttarakhand
replace state_nfhs = 19 if region == 280  // West Bengal



gen total = residence=="0"
gen urban = residence=="S010"
gen rural = residence=="S020"


gen v025 = 1 if urban==1
replace v025 = 2 if rural==1
replace v025 = 0 if total==1


label define typelt_lbl ///
    1 "Complete life table (1-year ages)" ///
    2 "Abridged life table (5-year ages)" ///
    4 "Smoothed/model life table (reconstructed)"

label values typelt typelt_lbl

gen survival_prob = lx/100000

gen repyear = floor((year1 + year2)/2)

gen len = year2-year1


gen round = .
replace round = 2 if inrange(year1, 1990, 1996)
replace round = 3 if inrange(year1, 1997,2003)
replace round = 4 if inrange(year1, 2007,2011)
replace round = 5 if inrange(year1, 2013,2016)


egen tag = tag(round state sex age)



/*




merge on
- year of interview
- region
- residence
- sex 
- age of parent in law


each individual has to match to 1 life table row

every 50 year old in nfhs-5 in a given state must match to 1 life table row


for each nfhs, consider these life tables
1998-99 - year1 between 1990-1995
2005-06 - year1 between 1997-2003
2015-16 - year1 between 2007-2011
2019-21 - year1 between 2011-2016 (max)





*/

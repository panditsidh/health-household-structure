/*

This file creates harmonized state and district variables across NFHS rounds.

State and district codes are not fully consistent across survey rounds, so this
file standardizes them for use in pooled analyses and regional classifications.

You do not need to run this file directly. It is called by 10_assemble_data.do.

*/


* NFHS-4 (IA6) in terms of NFHS-5 codes
gen state = .  

replace state = 28 if v024 == 1  & v000 == "IA6"   // Andaman & Nicobar -> Andhra Pradesh
replace state = 28 if v024 == 2  & v000 == "IA6"   // Andhra Pradesh -> Andhra Pradesh
replace state = 12 if v024 == 3  & v000 == "IA6"   // Arunachal Pradesh
replace state = 18 if v024 == 4  & v000 == "IA6"   // Assam
replace state = 10 if v024 == 5  & v000 == "IA6"   // Bihar
replace state = 4  if v024 == 6  & v000 == "IA6"   // Chandigarh
replace state = 22 if v024 == 7  & v000 == "IA6"   // Chhattisgarh
replace state = 25 if v024 == 8  & v000 == "IA6"   // Dadra & Nagar Haveli
replace state = 25 if v024 == 9  & v000 == "IA6"   // Daman & Diu
replace state = 30 if v024 == 10 & v000 == "IA6"   // Goa
replace state = 24 if v024 == 11 & v000 == "IA6"   // Gujarat
replace state = 6  if v024 == 12 & v000 == "IA6"   // Haryana
replace state = 2  if v024 == 13 & v000 == "IA6"   // Himachal Pradesh
replace state = 1  if v024 == 14 & v000 == "IA6"   // Jammu & Kashmir
replace state = 20 if v024 == 15 & v000 == "IA6"   // Jharkhand
replace state = 29 if v024 == 16 & v000 == "IA6"   // Karnataka
replace state = 32 if v024 == 17 & v000 == "IA6"   // Kerala
replace state = 31 if v024 == 18 & v000 == "IA6"   // Lakshadweep
replace state = 23 if v024 == 19 & v000 == "IA6"   // Madhya Pradesh
replace state = 27 if v024 == 20 & v000 == "IA6"   // Maharashtra
replace state = 14 if v024 == 21 & v000 == "IA6"   // Manipur
replace state = 17 if v024 == 22 & v000 == "IA6"   // Meghalaya
replace state = 15 if v024 == 23 & v000 == "IA6"   // Mizoram
replace state = 13 if v024 == 24 & v000 == "IA6"   // Nagaland
replace state = 7  if v024 == 25 & v000 == "IA6"   // Delhi -> NCT of Delhi
replace state = 21 if v024 == 26 & v000 == "IA6"   // Odisha
replace state = 34 if v024 == 27 & v000 == "IA6"   // Puducherry
replace state = 3  if v024 == 28 & v000 == "IA6"   // Punjab
replace state = 8  if v024 == 29 & v000 == "IA6"   // Rajasthan
replace state = 11 if v024 == 30 & v000 == "IA6"   // Sikkim
replace state = 33 if v024 == 31 & v000 == "IA6"   // Tamil Nadu
replace state = 16 if v024 == 32 & v000 == "IA6"   // Tripura
replace state = 9  if v024 == 33 & v000 == "IA6"   // Uttar Pradesh
replace state = 5  if v024 == 34 & v000 == "IA6"   // Uttarakhand
replace state = 19 if v024 == 35 & v000 == "IA6"   // West Bengal
replace state = 36 if v024 == 36 & v000 == "IA6"   // Telangana

* NFHS-5 (IA7): already in NFHS-5 codes
replace state = v024 if v000 == "IA7"


* NFHS-3 (IA5) in terms of NFHS-5 codes
* Start with identity, then apply your two overrides
replace state = v024 if v000 == "IA5" 

* Your choice: NFHS-3 Jammu & Kashmir (1) -> Ladakh (37)
replace state = 37 if v024 == 1  & v000 == "IA5" 

* Your choice: NFHS-3 Andhra Pradesh (28) -> Telangana (36)
replace state = 36 if v024 == 28 & v000 == "IA5"


* NFHS-2 (IA4) in terms of NFHS-5 codes
* Map NFHS-2 v024 states to NFHS-5 codes, mirroring your NFHS-3 choices

* Andhra Pradesh (2) -> Telangana (36), by analogy with NFHS-3
replace state = 36 if v024 == 2  & v000 == "IA3"

* Assam (3) -> 18
replace state = 18 if v024 == 3  & v000 == "IA3"

* Bihar (4) -> 10
replace state = 10 if v024 == 4  & v000 == "IA3"

* Goa (5) -> 30
replace state = 30 if v024 == 5  & v000 == "IA3"

* Gujarat (6) -> 24
replace state = 24 if v024 == 6  & v000 == "IA3"

* Haryana (7) -> 6
replace state = 6  if v024 == 7  & v000 == "IA3"

* Himachal Pradesh (8) -> 2
replace state = 2  if v024 == 8  & v000 == "IA3"

* Jammu (9) -> Ladakh (37), to match your NFHS-3 J&K -> 37 choice
replace state = 37 if v024 == 9  & v000 == "IA3"

* Karnataka (10) -> 29
replace state = 29 if v024 == 10 & v000 == "IA3"

* Kerala (11) -> 32
replace state = 32 if v024 == 11 & v000 == "IA3"

* Madhya Pradesh (12) -> 23
replace state = 23 if v024 == 12 & v000 == "IA3"

* Maharashtra (13) -> 27
replace state = 27 if v024 == 13 & v000 == "IA3"

* Manipur (14) -> 14
replace state = 14 if v024 == 14 & v000 == "IA3"

* Meghalaya (15) -> 17
replace state = 17 if v024 == 15 & v000 == "IA3"

* Mizoram (16) -> 15
replace state = 15 if v024 == 16 & v000 == "IA3"

* Nagaland (17) -> 13
replace state = 13 if v024 == 17 & v000 == "IA3"

* Orissa (18) -> Odisha (21)
replace state = 21 if v024 == 18 & v000 == "IA3"

* Punjab (19) -> 3
replace state = 3  if v024 == 19 & v000 == "IA3"

* Rajasthan (20) -> 8
replace state = 8  if v024 == 20 & v000 == "IA3"

* Sikkim (21) -> 11
replace state = 11 if v024 == 21 & v000 == "IA3"

* Tamil Nadu (22) -> 33
replace state = 33 if v024 == 22 & v000 == "IA3"

* West Bengal (23) -> 19
replace state = 19 if v024 == 23 & v000 == "IA3"

* Uttar Pradesh (24) -> 9
replace state = 9  if v024 == 24 & v000 == "IA3"

* New Delhi (30) -> NCT of Delhi (7)
replace state = 7  if v024 == 30 & v000 == "IA3"

* Arunachal Pradesh (34) -> 12
replace state = 12 if v024 == 34 & v000 == "IA3"

* Tripura (35) -> 16
replace state = 16 if v024 == 35 & v000 == "IA3"



label define state_lbl ///
1  "Jammu & Kashmir" ///
2  "Himachal Pradesh" ///
3  "Punjab" ///
4  "Chandigarh" ///
5  "Uttarakhand" ///
6  "Haryana" ///
7  "NCT of Delhi" ///
8  "Rajasthan" ///
9  "Uttar Pradesh" ///
10 "Bihar" ///
11 "Sikkim" ///
12 "Arunachal Pradesh" ///
13 "Nagaland" ///
14 "Manipur" ///
15 "Mizoram" ///
16 "Tripura" ///
17 "Meghalaya" ///
18 "Assam" ///
19 "West Bengal" ///
20 "Jharkhand" ///
21 "Odisha" ///
22 "Chhattisgarh" ///
23 "Madhya Pradesh" ///
24 "Gujarat" ///
25 "Dadra & Nagar Haveli and Daman & Diu" ///
27 "Maharashtra" ///
28 "Andhra Pradesh" ///
29 "Karnataka" ///
30 "Goa" ///
31 "Lakshadweep" ///
32 "Kerala" ///
33 "Tamil Nadu" ///
34 "Puducherry" ///
35 "Andaman & Nicobar Islands" ///
36 "Telangana" ///
37 "Ladakh"

label values state state_lbl



* Step 1: Define region value labels
label define regionlbl ///
    1 "UP and Bihar" ///
    2 "central" ///
    3 "east" ///
    4 "west" ///
    5 "north" ///
    6 "south" ///
    7 "northeast"

* Step 2: Generate the numeric variable
gen region = .

* Step 3: NFHS-5 (round == 5)
replace region = 1 if inlist(v024, 9, 10) & round == 5 // UP, Bihar
replace region = 2 if inlist(v024, 23, 22) & round == 5 // MP, Chhattisgarh
replace region = 3 if inlist(v024, 19, 20, 21) & round == 5 // WB, Jharkhand, Odisha
replace region = 4 if inlist(v024, 24, 27, 30) & round == 5 // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 1, 2, 3, 5, 6, 8) & round == 5 // J&K, HP, Punjab, Uttarakhand, Haryana, Rajasthan
replace region = 6 if inlist(v024, 28, 29, 32, 33, 36) & round == 5 // AP, Karnataka, Kerala, TN, Telangana
replace region = 7 if inlist(v024, 12, 13, 14, 15, 16, 18) & round == 5 // NE states

* Step 4: NFHS-4 (round == 4)
replace region = 1 if inlist(v024, 33, 5) & round == 4 // UP, Bihar
replace region = 2 if inlist(v024, 19, 7) & round == 4 // MP, Chhattisgarh
replace region = 3 if inlist(v024, 35, 15, 26) & round == 4 // WB, Jharkhand, Odisha
replace region = 4 if inlist(v024, 11, 20, 10) & round == 4 // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 14, 13, 28, 12, 34, 6) & round == 4 // J&K, HP, Punjab, Uttarakhand, Delhi, Haryana
replace region = 6 if inlist(v024, 2, 36, 17, 31, 16) & round == 4 // AP, Telangana, Kerala, TN, Karnataka
replace region = 7 if inlist(v024, 3, 23, 24, 21, 32, 22, 4, 30) & round == 4 // NE states

* Step 5: NFHS-3 (round == 3)
replace region = 1 if inlist(v024, 9, 10) & round == 3 // UP, Bihar
replace region = 2 if inlist(v024, 23, 22) & round == 3 // MP, Chhattisgarh
replace region = 3 if inlist(v024, 19, 20, 21) & round == 3 // WB, Jharkhand, Odisha
replace region = 4 if inlist(v024, 24, 27, 30) & round == 3 // Gujarat, Maharashtra, Goa
replace region = 5 if inlist(v024, 1, 2, 3, 5, 6, 8) & round == 3 // J&K, HP, Punjab, Uttarakhand, Haryana, Rajasthan
replace region = 6 if inlist(v024, 28, 29, 32, 33) & round == 3 // AP, Karnataka, Kerala, TN
replace region = 7 if inlist(v024, 12, 13, 14, 15, 16, 18) & round == 3 // NE states

gen india=1
gen focus = region==1
gen central = region==2
gen east = region==3
gen west = region==4
gen north = region==5
gen south = region==6
gen northeast = region==7


* Step 6: Apply value labels
label values region regionlbl



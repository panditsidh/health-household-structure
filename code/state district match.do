*Match states across surveys
*--------------------------------------*
* Harmonize state to NFHS-5 codes      *
*--------------------------------------*

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


*Match districts across surveys 
//
// gen district = .
// replace district = sdist if v000=="IA7"
// replace district = sdistri if v000=="IA6"
// replace district = 2000 if inlist(sdist,879,880) | inlist(sdistri,43)
// replace district = 2001 if inlist(sdist,881,882) | inlist(sdistri,35)
// replace district = 2002 if inlist(sdist,865,866) | inlist(sdistri,81)
// replace district = 2003 if inlist(sdist,837,838,839,840,841,842,843,844,845,846,847) | inlist(sdistri,90,91,92,93,94,95,96,97,98)
// replace district = 2004 if inlist(sdist,921,927,930) | inlist(sdistri,158,179)
// replace district = 2005 if inlist(sdist,923,924) | inlist(sdistri,140)
// replace district = 2006 if inlist(sdist,922,925,928) | inlist(sdistri,135,149)
// replace district = 2007 if inlist(sdist,926,929) | inlist(sdistri,133)
// replace district = 2008 if inlist(sdist,802,803) | inlist(sdistri,256)
// replace district = 2009 if inlist(sdist,804,806) | inlist(sdistri,259)
// replace district = 2010 if inlist(sdist,805,808) | inlist(sdistri,254)
// replace district = 2011 if inlist(sdist,801,807,809) | inlist(sdistri,250,251)
// replace district = 2012 if inlist(sdist,915,917,920) | inlist(sdistri,289)
// replace district = 2013 if inlist(sdist,914,918) | inlist(sdistri,290)
// replace district = 2014 if inlist(sdist,916,919) | inlist(sdistri,292)
// replace district = 2015 if inlist(sdist,871,873) | inlist(sdistri,294)
// replace district = 2016 if inlist(sdist,872,877) | inlist(sdistri,299)
// replace district = 2017 if inlist(sdist,875,878) | inlist(sdistri,296)
// replace district = 2018 if inlist(sdist,874,876) | inlist(sdistri,293)
// replace district = 2019 if inlist(sdist,810,819) | inlist(sdistri,306)
// replace district = 2020 if inlist(sdist,811,818) | inlist(sdistri,311)
// replace district = 2021 if inlist(sdist,813,817) | inlist(sdistri,305)
// replace district = 2022 if inlist(sdist,812,820) | inlist(sdistri,301)
// replace district = 2023 if inlist(sdist,815,821) | inlist(sdistri,314)
// replace district = 2024 if inlist(sdist,814,816) | inlist(sdistri,312)
// replace district = 2025 if inlist(sdist,931,932) | inlist(sdistri,335)
// replace district = 2026 if inlist(sdist,822,826,829) | inlist(sdistri,409)
// replace district = 2027 if inlist(sdist,823,830,833) | inlist(sdistri,410)
// replace district = 2028 if inlist(sdist,824,835,836) | inlist(sdistri,401)
// replace district = 2029 if inlist(sdist,825,831) | inlist(sdistri,414)
// replace district = 2030 if inlist(sdist,827,832) | inlist(sdistri,406)
// replace district = 2031 if inlist(sdist,828,834) | inlist(sdistri,416)
// replace district = 2032 if inlist(sdist,867,868) | inlist(sdistri,436)
// replace district = 2033 if inlist(sdist,849,862) | inlist(sdistri,472)
// replace district = 2034 if inlist(sdist,848,850,851) | inlist(sdistri,474,481)
// replace district = 2035 if inlist(sdist,852,864) | inlist(sdistri,486)
// replace district = 2036 if inlist(sdist,857,858,860) | inlist(sdistri,483,484)
// replace district = 2037 if inlist(sdist,853,855,859,861,863) | inlist(sdistri,475,476,477)
// replace district = 2038 if inlist(sdist,854,856) | inlist(sdistri,479)
// replace district = 2039 if inlist(sdist,869,870) | inlist(sdistri,517)
// replace district = 2040 if inlist(sdist,883,893,896,901) | inlist(sdistri,532)
// replace district = 2041 if inlist(sdist,884,886,887,888,891,892,894,897) | inlist(sdist,900,903,904,906,907,908,911,912,913) | inlist(sdistri,534,535,539,540,541)
// replace district = 2042 if inlist(sdist,885) | inlist(sdistri,536)
// replace district = 2043 if inlist(sdist,898,905,909) | inlist(sdistri,537)
// replace district = 2044 if inlist(sdist,889,895,899,910) | inlist(sdistri,538)
// replace district = 2045 if inlist(sdist,890,902) | inlist(sdistri,533)
//


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

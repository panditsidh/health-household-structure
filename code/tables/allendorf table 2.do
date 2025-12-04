*------------------------------------------------------------
* NFHS-3,4,5, pregnant women
* Table 2-style: All vs Nuclear vs Patrilocal + sig
*------------------------------------------------------------
use $all_nfhs_ir, clear

keep if round==5
regress bmi i.gestdur [aw=wt]
predict bmi_resid, resid

keep if inlist(round,3,4,5)
keep if inlist(hh_struc,1,2)
keep if pregnant==1

* Percent (default weight: wt)
local natvars bmi_resid underweight anemic ///
    meat_egg_fish_weekly dairy_daily ///
    prob_facility_distance prob_health_money anc_four ///
    north central east west south northeast ///
    forward obc dalit adivasi muslim sjc ///
    no_educ primary secondary higher ///
    poorest poorer middle richer richest ///
    fridge tv motorcycle ///
    parity1 parity2 parity3 parity4

* State-weighted
local statevars nosay_healthcare prob_health_permission nosay_visits nosay_purchases

* DV-weighted
local dvvars dv_phys dv_sex

local allvars `natvars' `statevars' `dvvars'

*------------------------------------------------------------
* Set up postfile: var name, means, and nuclear–patrilocal diff + stars
*------------------------------------------------------------
capture postclose handle

tempfile tbl2
postfile handle ///
    str30 varname ///
    double mean_all mean_nuclear mean_patrilocal diff_np ///
    str4 stars ///
    using `tbl2', replace

*------------------------------------------------------------
* Main loop
*------------------------------------------------------------
foreach var of local allvars {

    * choose weight
    local wvar "wt"
    if strpos(" `statevars' ", " `var' ") local wvar "w_state"
    if strpos(" `dvvars' ",    " `var' ") local wvar "w_dv"

    * overall mean
    quietly summarize `var' [aw=`wvar']
    local all = r(mean)

    * nuclear (hh_struc==1)
    quietly summarize `var' [aw=`wvar'] if hh_struc==1
    local nuclear = r(mean)

    * patrilocal (hh_struc==2)
    quietly summarize `var' [aw=`wvar'] if hh_struc==2
    local patrilocal = r(mean)

    * significance test: patrilocal vs nuclear (clustered by psu)
    quietly regress `var' i.hh_struc [aw=`wvar'], vce(cluster psu)

    matrix R = r(table)
    * coefficient on 2.hh_struc = (mean_patrilocal - mean_nuclear)
    local b = R[1,"2.hh_struc"]
    local p = R[4,"2.hh_struc"]

    local stars ""
    if (`p' < 0.01)      local stars "***"
    else if (`p' < 0.05) local stars "**"
    else if (`p' < 0.10) local stars "*"

    * post one row
    post handle ("`var'") (`all') (`nuclear') (`patrilocal') (`b') ("`stars'")
}

postclose handle

use `tbl2', clear


format mean_all        %6.3f
format mean_nuclear    %6.3f
format mean_patrilocal %6.3f
format diff_np         %6.3f





replace varname = "BMI (residualized)"                    if varname=="bmi_resid"
replace varname = "Underweight"                           if varname=="underweight"
replace varname = "Any anemia"                            if varname=="anemic"

replace varname = "Consumes meat/egg/fish weekly"         if varname=="meat_egg_fish_weekly"
replace varname = "Consumes dairy daily"                  if varname=="dairy_daily"

replace varname = "Distance is a problem (facility)"      if varname=="prob_facility_distance"
replace varname = "Money is a problem (healthcare)"       if varname=="prob_health_money"
replace varname = "4+ ANC visits"                         if varname=="anc_four"

replace varname = "North region"                          if varname=="north"
replace varname = "Central region"                        if varname=="central"
replace varname = "East region"                           if varname=="east"
replace varname = "West region"                           if varname=="west"
replace varname = "South region"                          if varname=="south"
replace varname = "Northeast region"                      if varname=="northeast"

replace varname = "Forward caste"                         if varname=="forward"
replace varname = "OBC"                                   if varname=="obc"
replace varname = "Dalit"                                 if varname=="dalit"
replace varname = "Adivasi"                               if varname=="adivasi"
replace varname = "Muslim"                                if varname=="muslim"
replace varname = "Sikh/Jain/Christian"                   if varname=="sjc"

replace varname = "No education"                          if varname=="no_educ"
replace varname = "Primary education"                     if varname=="primary"
replace varname = "Secondary education"                   if varname=="secondary"
replace varname = "Higher education"                      if varname=="higher"

replace varname = "Poorest quintile"                      if varname=="poorest"
replace varname = "Poorer quintile"                       if varname=="poorer"
replace varname = "Middle quintile"                       if varname=="middle"
replace varname = "Richer quintile"                       if varname=="richer"
replace varname = "Richest quintile"                      if varname=="richest"

replace varname = "Owns fridge"                           if varname=="fridge"
replace varname = "Owns television"                       if varname=="tv"
replace varname = "Owns motorcycle"                       if varname=="motorcycle"

replace varname = "Parity: 1 child"                       if varname=="parity1"
replace varname = "Parity: 2 children"                    if varname=="parity2"
replace varname = "Parity: 3 children"                    if varname=="parity3"
replace varname = "Parity: 4+ children"                   if varname=="parity4"

replace varname = "No say in own healthcare"              if varname=="nosay_healthcare"
replace varname = "Permission is a problem"               if varname=="prob_health_permission"
replace varname = "No say in family visits"               if varname=="nosay_visits"
replace varname = "No say in purchases"                   if varname=="nosay_purchases"

replace varname = "Physical domestic violence"            if varname=="dv_phys"
replace varname = "Sexual domestic violence"             if varname=="dv_sex"



*******************************************************
* Assumes current data in memory:
* varname mean_all mean_nuclear mean_patrilocal diff_np stars
*******************************************************

*******************************************************
* Assumes current data in memory:
* varname mean_all mean_nuclear mean_patrilocal diff_np stars
*******************************************************

*------------------------------------------------------------
* 1. Assign category to each varname
*------------------------------------------------------------
gen str30 category = ""

replace category = "Health"             if inlist(varname, ///
    "BMI (residualized)", ///
    "Underweight", ///
    "Any anemia")

replace category = "Diet"               if inlist(varname, ///
    "Consumes meat/egg/fish weekly", ///
    "Consumes dairy daily")

replace category = "Healthcare access"  if inlist(varname, ///
    "Distance is a problem (facility)", ///
    "Money is a problem (healthcare)", ///
    "4+ ANC visits")

replace category = "Region"             if inlist(varname, ///
    "North region","Central region","East region","West region","South region","Northeast region")

replace category = "Social group"       if inlist(varname, ///
    "Forward caste","OBC","Dalit","Adivasi","Muslim","Sikh/Jain/Christian")

replace category = "Education"          if inlist(varname, ///
    "No education","Primary education","Secondary education","Higher education")

replace category = "Wealth"             if inlist(varname, ///
    "Poorest quintile","Poorer quintile","Middle quintile","Richer quintile","Richest quintile")

replace category = "Assets"             if inlist(varname, ///
    "Owns fridge","Owns television","Owns motorcycle")

replace category = "Parity"             if inlist(varname, ///
    "Parity: 1 child","Parity: 2 children","Parity: 3 children","Parity: 4+ children")

replace category = "Decision making"    if inlist(varname, ///
    "No say in own healthcare","Permission is a problem","No say in family visits","No say in purchases")

replace category = "Domestic violence"  if inlist(varname, ///
    "Physical domestic violence","Sexual domestic violence")

* (optional sanity check)
* tab category


*******************************************************
* Assumes data in memory:
* varname mean_all mean_nuclear mean_patrilocal diff_np stars category
*******************************************************

*------------------------------------------------------------
* 1. Create an explicit category order (so it's not alphabetical)
*------------------------------------------------------------
gen byte catord = .
replace catord = 1  if category == "Health"
replace catord = 2  if category == "Diet"
replace catord = 3  if category == "Healthcare access"
replace catord = 4  if category == "Region"
replace catord = 5  if category == "Social group"
replace catord = 6  if category == "Education"
replace catord = 7  if category == "Wealth"
replace catord = 8  if category == "Assets"
replace catord = 9  if category == "Parity"
replace catord = 10 if category == "Decision making"
replace catord = 11 if category == "Domestic violence"

* if anything is uncategorized, throw it at the end
replace catord = 99 if missing(catord)

* preserve original row order within category
gen long id = _n

sort catord id

*------------------------------------------------------------
* 2. Tag the first row of each category
*------------------------------------------------------------
bysort catord: gen byte first = _n == 1

*------------------------------------------------------------
* 3. Expand data: for each first row, make 3 copies
*    (blank row, header row, original row)
*------------------------------------------------------------
expand cond(first, 3, 1)

* After expand, each "first" row now has 3 identical copies
* We want to distinguish them as blank/header/data
sort catord id
bysort catord id: gen byte seq = _n   // seq = 1,2,3 for first rows; 1 for others

*------------------------------------------------------------
* 4. Make seq==1 the BLANK row, seq==2 the HEADER, seq>=3 data
*------------------------------------------------------------

* Blank row before header
replace varname        = "" if first == 1 & seq == 1
replace mean_all       = .  if first == 1 & seq == 1
replace mean_nuclear   = .  if first == 1 & seq == 1
replace mean_patrilocal= .  if first == 1 & seq == 1
replace diff_np        = .  if first == 1 & seq == 1
replace stars          = "" if first == 1 & seq == 1

* Header row: \textbf{Category}
replace varname        = "\textbf{" + category + "}" if first == 1 & seq == 2
replace mean_all       = .                           if first == 1 & seq == 2
replace mean_nuclear   = .                           if first == 1 & seq == 2
replace mean_patrilocal= .                           if first == 1 & seq == 2
replace diff_np        = .                           if first == 1 & seq == 2
replace stars          = ""                          if first == 1 & seq == 2

* Data rows:
* - all non-first rows (first==0, seq==1)
* - plus the third copy of first rows (first==1, seq==3)
* indent the labels for all non-header, non-blank rows
replace varname = "    " + varname if varname != "" & !(first == 1 & inlist(seq,1,2))

*------------------------------------------------------------
* 5. Clean up and format
*------------------------------------------------------------
drop id seq first catord

format mean_all        %6.3f
format mean_nuclear    %6.3f
format mean_patrilocal %6.3f
format diff_np         %6.3f

* sanity check
list, clean noobs

listtex varname mean_all mean_nuclear mean_patrilocal stars using "tables/table_grouped.tex", ///
    replace rstyle(tabular) ///
    head( ///
        "\begin{tabular}{lcccc}" ///
        "\toprule" ///
        "Outcome & All & Nuclear & Patrilocal & Sig. \\\\" ///
        "\midrule" ///
    ) ///
    foot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
    )


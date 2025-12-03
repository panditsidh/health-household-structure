clear
set obs 1

gen outcome = "\textbf{Panel A. Patrilocal coefficient without controls}" if _n==1

append using "tables/unadjusted.dta"

replace outcome = "Consumes meat/egg/fish at least weekly"       if outcome == "meat_egg_fish_weekly"
replace outcome = "Consumes dairy daily"                  if outcome == "dairy_daily"
replace outcome = "No say in own healthcare"              if outcome == "nosay_healthcare"
replace outcome = "No say in family visits"               if outcome == "nosay_visits"
replace outcome = "Any anemia"                            if outcome == "anemic"
replace outcome = "Body mass index (BMI)"                 if outcome == "bmi"
replace outcome = "Physical domestic violence"            if outcome == "dv_phys"
replace outcome = "Sexual domestic violence"              if outcome == "dv_sex"
replace outcome = "Home birth (3–12 months ago)"          if outcome == "home_birth_312"
replace outcome = "C-section (3–12 months ago)"           if outcome == "c_section_312"

replace outcome = "    " + outcome if _n!=1 


preserve
clear
set obs 2
gen outcome = "" if _n==1
replace outcome = "\textbf{Panel B. Patrilocal coefficient with controls}" if _n==2
tempfile blank
save `blank'
restore

append using `blank'


append using "tables/adjusted.dta"
replace outcome = "    " + outcome if _n>13



listtex outcome NFHS3 NFHS4 NFHS5 using "tables/coefficient_table.tex", ///
    replace rstyle(tabular) ///
    head( ///
        "\begin{tabular}{lccc}" ///
        "\toprule" ///
        "Outcome & 2005-06 & 2015-16 & 2019-21 \\\\" ///
        "\midrule" ///
    ) ///
    foot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
    )

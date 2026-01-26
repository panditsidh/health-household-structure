
do "code/42_table 1 get 3-12 mo.ago birth results.do"

tempfile postpartum_sample
save `postpartum_sample'

do "code/41_table 1 get results for pregnant women.do"



append using `postpartum_sample'


input order
4
3
11
13
1
2
9
10
8
12
6
7
15
17
14
16
24
27
22
23
21
25
19
20 end


sort order


drop order

gen order = _n


expand 4 if varname=="nosay_healthcare" // header comes above

expand 2 if varname=="nosay_visits" // blank below

expand 2 if varname=="finished_floor" // header above

expand 2 if varname=="owns_land" // blank below

expand 2 if varname=="n" // blank below

expand 4 if varname=="facility_birth" // 2 headers and a space

expand 2 if varname=="anc_four"



sort order






input str150 rows
"\textbf{Currently pregnant women}"
""
"\textbf{Autonomy measures}"
"\hspace*{2em}Say in own healthcare"
"\hspace*{2em}Say in visits to family/friends"
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

order rows




*******************************************************
* Keep only display variables
*******************************************************
keep rows mean1 mean2 mean3 mean4 mean5 mean6

*******************************************************
* Create string display columns
*******************************************************
foreach j of numlist 1/6 {
    gen str12 disp`j' = ""
}

*******************************************************
* Fill display columns
*******************************************************
foreach j of numlist 1/6 {

    * Blank rows (headers / spacing)
    replace disp`j' = "" if missing(rows)

    * N rows: integers with commas
    replace disp`j' = string(round(mean`j'), "%9.0fc") ///
        if rows=="\textbf{N}"

    * All other rows: proportions with 2 decimals
    replace disp`j' = string(mean`j', "%4.2f") ///
        if !missing(rows) & rows!="\textbf{N}"
}

*******************************************************
* Optional: drop numeric means now
*******************************************************
drop mean1 mean2 mean3 mean4 mean5 mean6

*******************************************************
* Sanity check
*******************************************************
list rows disp1 disp2 disp3 disp4 disp5 disp6, noobs clean


foreach j of numlist 1/6 {
    replace disp`j' = "" if strpos(rows, "\textbf") & rows != "\textbf{N}"
}





listtex ///
    rows disp1 disp2 disp3 disp4 disp5 disp6 ///
    using "tables/table 1 summary stats.tex", ///
    replace rstyle(tabular) ///
    head( ///
        "\begin{tabular}{lcccccc}" ///
        "\toprule" ///
        " & \multicolumn{2}{c}{NFHS-3} & \multicolumn{2}{c}{NFHS-4} & \multicolumn{2}{c}{NFHS-5} \\\\" ///
        "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}" ///
        " & Joint & Nuclear & Joint & Nuclear & Joint & Nuclear \\\\" ///
        "\midrule" ///
    ) ///
    foot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
    )



clear all
set more off

*******************************************************
* 0. Load paths
*******************************************************

* This lets the master file work whether it is run from the project root
* or from inside the code folder.


do "$paths"


*******************************************************
* 1. Create final analytic dataset
*******************************************************

do "code/10_assemble data.do"


*******************************************************
* 2. Appendix table on early pregnancy reporting
*******************************************************

do "code/20_tableB1 selection into detecting pregnancy early.do"


*******************************************************
* 3. Table 1
*******************************************************

do "code/30_table1 proportion patrilocal increasing in all subgroups.do"


*******************************************************
* 4. Appendix figures on household structure composition
*******************************************************

do "code/40_figureC1 change in hh structure composition for all women.do"

do "code/41_figureC2 change in hh structure composition for men.do"

do "code/42_figureC3 change in hh structure composition in allendorf2013 sample.do"


*******************************************************
* 5. Appendix table decomposing increase in patrilocal residence
*******************************************************

do "code/50_tableA1 decomposition of increasing patrilocal residence by parity.do"


*******************************************************
* 6. Table 2
*******************************************************

do "code/60_table2 summary statistics within survey round and household structure.do"


*******************************************************
* 7. Figure 1
*******************************************************

do "code/70_figure1 patrilocal differences and mediating role of wealth.do"


*******************************************************
* 8. Table 3
*******************************************************

do "code/80_table3 narrowing differences in outcomes across household structure .do"


*******************************************************
* 9. Appendix table decomposing outcome changes
*******************************************************

do "code/90_tableD1 decomposition of improving outcomes over time by household structure.do"


*******************************************************
* Done
*******************************************************

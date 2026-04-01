do "code/31_figure 1 panels A and B.do"

do "code/32_figure 1 panels C and D.do"

grc1leg ///
    "figures/figure 2 panel A.gph" ///
    "figures/figure 2 panel B.gph" ///
    "figures/figure 2 panel C.gph" ///
    "figures/figure 2 panel D.gph", ///
    cols(2) ///
    imargin(0 0 0 0) ///
    graphregion(margin(2 2 2 2) color(white)) ///
    xsize(10) ///
    ysize(7) ///
    name(fig2_fourpanel, replace)

graph save   "figures/figure 2 four panel.gph", replace
graph export "figures/figure 2 four panel.pdf", replace

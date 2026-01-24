graph combine ///
    "figures/figure 2 panel A.gph" ///
    "figures/figure 2 panel B.gph" ///
    "figures/figure 2 panel C.gph" ///
    "figures/figure 2 panel D.gph", ///
    cols(2) ///
    scale(0.8) ///
    iscale(0.6) ///
    imargin(6 6 6 6) ///
    xsize(10) ///
    ysize(7) ///
    graphregion(color(white)) ///
    name(fig2_fourpanel, replace)

graph save   "figures/figure 2 four panel.gph", replace
graph export "figures/figure 2 four panel.pdf", replace

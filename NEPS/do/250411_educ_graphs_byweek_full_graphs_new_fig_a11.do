local word "weighted"
foreach ds of local word {
use "$results\educ_by_week_full_`ds'_neu.dta", clear


** aase
preserve
keep if samp_aase == 1
twoway scatter aase run_week, color(gs8) || line fit0_aase run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_aase run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(6 7)) ylabel(6(0.2)7) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Age at school entry", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\aase_$date_full_`ds'_neu", replace
graph export "${graphs}\aase_$date_full_`ds'_neu.pdf", replace
restore


** acadt_filled
preserve
keep if samp_acadt_filled == 1
twoway scatter acadt_filled run_week, color(gs8) || line fit0_acadt_filled run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_acadt_filled run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.1 0.35)) ylabel(0.1(0.05)0.35) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Abitur (Kamila, missing as zero)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\acadt_filled_$date_full_`ds'_neu", replace
graph export "${graphs}\acadt_filled_$date_full_`ds'_neu.pdf", replace
restore



}


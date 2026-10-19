**********Lifecycle graphs***************
*** The original figure has been produced locally, however, differs only in terms of style and formatting

***1 year mobility
*BL	
use "$results\temp\bl_flow1_cycle_donut_avg3.dta", clear	
	keep if inrange(age,8,63)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.1(0.02)0.1)) ylabel(-0.1(0.02)0.1, labsize(small)) yline(0, lcolor(red)) ///
			title("1945-1964", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\bl_flow1_cycle_donut_avg3", replace
	graph export "$graphs\bl_flow1_cycle_donut_avg3.pdf", as(pdf) replace		

	
	
***5 year mobility
*BL		
use "$results\temp\bl_flow5_cycle_donut_avg3.dta", clear	
	keep if inrange(age,8,63)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.1(0.02)0.1)) ylabel(-0.1(0.02)0.1, labsize(small)) yline(0, lcolor(red)) ///
			title("1945-1964", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\bl_flow5_cycle_donut_avg3", replace
	graph export "$graphs\bl_flow5_cycle_donut_avg3.pdf", as(pdf) replace		


	
***Lifetime mobility
*BL
use "$results\temp\bl_stock_cycle_donut_avg3.dta", clear
	keep if inrange(age,8,63)

	
	sum obs if age <= 63
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.1(0.02)0.1)) ylabel(-0.1(0.02)0.1, labsize(small)) yline(0, lcolor(red)) ///
			title("1945-1964", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\bl_stock_cycle_donut_avg3", replace
	graph export "$graphs\bl_stock_cycle_donut_avg3.pdf", as(pdf) replace	
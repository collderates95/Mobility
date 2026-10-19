*** COmbine Wooldridge and TWFE into one graph ***

use "$results\Dataset_Event_TWFE_mig_stock.gph", clear
append using "$results\Dataset_Event_mig_stock.gph"


*** Make Graphs (Combined) ***
egen VarType = group(var)
sum VarType

gen WoolDummy = ( strpos(var, "Wool") > 1 )
tab WoolDummy
replace event = event +0.5 if WoolDummy == 1


*** Mig_Stock ***
twoway ///
	(rcap ub lb event if WoolDummy == 0, lcolor(gs0)) (scatter b event if WoolDummy == 0, mcolor(gs0) msymbol(D)) (rcap ub lb event if WoolDummy == 1, lcolor(gs9)) (scatter b event if WoolDummy == 1, mcolor(gs9) msymbol(Oh)), ///
	yline(0, lwidth(thin) lpattern(dash) ) xline(-1, lwidth(thin) lpattern(dash) ) ///
	xtitle("Event Time (Reform)") ///
	ytitle("ATT") ylab(,nogrid) xlab(,nogrid) ///
	title("Lifetime Mobility: State") ///
	xlab(-25 (5)  25) ylab(-1.5 (0.5) 1.5) legend(order(2 4) label(2 "TWFE") label(4 "ETWFE") col(1) pos(6)) 
	
	graph save "Graph" "$results\GraphEventTWFEWoolCombined_mig_stock.gph", replace
	graph export "$results\GraphEventTWFEWoolCombined_mig_stock.pdf", as(pdf) name("Graph") replace

ssc install estout,replace
ssc install diff,replace
ssc install coefplot,replace
ssc install dpplot,replace
ssc install asdoc,replace
ssc install logout,replace
ssc install outreg2
*raw data
import delimited "C:\Users\Administrator\Desktop\data raw.csv"
xtset id year

*drop missing value
egen mis = rowmiss(_all)
drop if mis

*build some possible dependent variables
gen asset = liability + equity
gen performance = netprofit/asset
gen current_ratio = current_asset/current_liability
gen average = (asset_beginning + asset_end)/2
gen ROA = netprofit/average
gen ROE = netprofit/equity

*dummy variables
gen post= year>=2014
gen treat = suitandbelt>0
gen did = post*treat

bysort treat:outreg2 using sw1.doc, replace sum(log) eqkeep(N mean sd) keep(netprofit asset_beginning asset_end equity liability current_asset current_liability performance current_ratio ROA ROE) title(Decriptive statistics)

*try different variables but coef of did are not statistically significant
xtreg performance did treat post,r
est store model1
xtreg current_ratio post treat did,r
est store model2
xtreg ROA post treat did,r
est store model3
xtreg ROE post treat did,r
est store model4
xtreg current_ratio post treat did ROA,r
est store model5
esttab model1 model2 model3 model4 model5

esttab model1 model2 model3 model4 model5 using test1.rtf





*or
*diff performance, t(treat) p(time)

*diff current_ratio, t(treat) p(time)

*diff ROA, t(treat) p(time)

*diff ROE, t(treat) p(time)

*diff ebit, t(treat) p(time)

*parallel trend
gen period = year - 2014
forvalues i = 6(-1)1{
gen pre_`i' = (period == -`i' & treat == 1)
}
gen current = (period == 0 & treat== 1)
forvalues j = 1(1)6{
gen  time_`j' = (period == `j' & treat == 1)
 }
xtreg performance post treat pre_* current time_* i.year,fe 
est sto reg1
coefplot reg1,keep(pre_* current time_*) vertical recast(connect) yline(0) xline(7,lp(dash)) title(parallel trend (performance))

xtreg ROA post treat pre_* current time_* i.year,fe 
est sto reg2
coefplot reg2,keep(pre_* current time_*) vertical recast(connect) yline(0) xline(7,lp(dash)) title(parallel trend (ROA))

xtreg ROE post treat pre_* current time_* i.year,fe 
est sto reg3
coefplot reg3,keep(pre_* current time_*) vertical recast(connect) yline(0) xline(7,lp(dash)) title(parallel trend (ROE))


xtreg current_ratio post treat pre_* current time_* i.year,fe 
est sto reg4
coefplot reg4,keep(pre_* current time_*) vertical recast(connect) yline(0) xline(7,lp(dash)) title(parallel trend current_ratio)

xtreg current_ratio post treat ROA pre_* current time_* i.year,fe 
est sto reg5
coefplot reg5,keep(pre_* current time_*) vertical recast(connect) yline(0) xline(7,lp(dash)) title(parallel trend current_ratio)

xtreg performance post treat pre_* current time_* i.year,fe 
est store model99
xtreg ROA post treat pre_* current time_* i.year,fe
est store model98
xtreg ROE post treat pre_* current time_* i.year,fe 
est store model97
xtreg current_ratio post treat pre_* current time_* i.year,fe 
est store model96
xtreg current_ratio post treat ROA pre_* current time_* i.year,fe 
est store model95
esttab model1 model2 model3 model4 model5 using PT.rtf



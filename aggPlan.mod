# Kushal Mehta & Nick Morris
# ISEE 720 - Production Control - Midterm Exam
# Aggregate Planning Model

# This is a linear program that determines:
	# the resource allocation,
	# the inventory levels,
	# the production levels,
# for JK lawn mower company at minimal cost while meeting forecasted sales

# --------------------------------------------------------------------
# ---- Sets ----------------------------------------------------------
# --------------------------------------------------------------------

# sizes
param nt := 12;  # number of time periods
param np := 4;  # number of product families
param nr := 1;  # number of resources

# elements
set P := 1..np;  # set of product families
set T := 1..nt;  # set of time periods
set R := 1..nr;  # set of resources

# --------------------------------------------------------------------
# ---- Parameters ----------------------------------------------------
# --------------------------------------------------------------------

# production/inventory parameters
param v{P,T} default 35.50325636;  # production cost to make one unit of product family i in period t
param d{P,T}; # demand of product family i in period t
param c{P,T} default 32.01045;  # cost of carrying a unit of product family i in inventory from period t to t + 1
param IO{P};  # initial available inventory of product family i
param b{P,T} default 24.24836301;  # cost of backordering a unit of product family i from period t to t + 1 (lost profit on a sale)
param SO{P} default 0;  # initial backlog of product family i
param S{P,T} default 0;  # units of product family i in shortage at the end of period t
param ss{P};  # safety stock of product family i

# resource parameters
param nd := 72;  # initial size of resource 1 (number of direct workers)
param z{R,T} default 1828.49;  # cost of using a unit of resource r during regular time in period t
param o{R,T} default 561.68;  # cost of using a unit of resource r during overtime in period t
param mUL{R,T} default 172;  # upper limit on the amount of resource r for use during regular time in period t
param mLL{R,T} default 152;  # lower limit on the amount of resource r for use during regular time in period t
param krt{R,P} default 1/83;  # amount of resource r needed to produce a unit of product family i during regular time
param kot{R,P} default 1/17;  # amount of resource r needed to produce a unit of product family i during over time
param h{R,T} default 800;  # cost of adding (hiring) a unit of the resource r in period t
param f{R,T} default 1500;  # cost of releasing (firing) a unit of resource r in period t

# --------------------------------------------------------------------
# ---- Variables -----------------------------------------------------
# --------------------------------------------------------------------

# production/inventory variables
var Xrt{P,T} >= 0;  # number of units of product family i made in period t during regular time
var Xot{P,T} >= 0;  # number of units of product family i made in period t during over time
var I{P,T} >= 0;  # number of units of product family i available at the end of period t

# resource variables
var O{R,T} >= 0;  # amount of resource r used in overtime during period t
var W{R,T union {0}} >= 0;  # amount of resource r used in regular time during period t 
var H{R,T} >= 0;  # units of resource r added (hired) in period t
var F{R,T} >= 0;  # units of resource r released (fired) in period t

# --------------------------------------------------------------------
# ---- Model ---------------------------------------------------------
# --------------------------------------------------------------------

# minimize the total production cost
minimize Cost: sum{i in P, t in T}((v[i,t] * (Xrt[i,t] + Xot[i,t])) + (c[i,t] * I[i,t]) + (b[i,t] * S[i,t])) + sum{r in R, t in T}((h[r,t] * H[r,t]) + (f[r,t] * F[r,t]) + (o[r,t] * O[r,t]) + (z[r,t] * W[r,t]));

# production/inventory constraints
s.t. ProductionBalance{i in P, t in 2..card(T)}: Xrt[i,t] + Xot[i,t] + I[i,t-1] - d[i,t] - S[i, t-1] = I[i,t] - S[i,t]; 
s.t. StartingProductionBalance{i in P}: Xrt[i,1] + Xot[i,1] + IO[i] - d[i,1] - SO[i] = I[i,1] - S[i, 1];

# resource constraints
s.t. ResourceBalance{r in R, t in 1..card(T)}: W[r,t] = W[r,t-1] - F[r,t] + H[r,t];
s.t. StartingResourceUsage{r in R}: W[r,0] = nd;
s.t. ResourceLimit_RT{t in T, r in R}: sum{i in P}(krt[r,i] * Xrt[i,t]) <= W[r,t];
s.t. ResourceLimit_OT{t in T, r in R}: sum{i in P}(kot[r,i] * Xot[i,t]) <= O[r,t];
s.t. RegularTimeLimit{r in R, t in T}: mLL[r,t] <= W[r,t] <= mUL[r,t];
s.t. OverTimeLimit{r in R, t in T}: O[r,t] <= W[r,t];
s.t. SafteyStock{i in P, t in T}: I[i,t] >= ss[i];



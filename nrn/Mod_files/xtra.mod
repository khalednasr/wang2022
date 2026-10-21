: $Id: xtra.mod,v 1.4 2014/08/18 23:15:25 ted Exp ted $
: xtra.mod for two E-fields that are independently modulated by different waveforms

NEURON {
	SUFFIX xtra
	RANGE es1, es2 : (es = max amplitude of the potential)
	RANGE Ex1, Ey1, Ez1
	RANGE Ex2, Ey2, Ez2
	RANGE Dx, Dy, Dz
	RANGE x,  y,  z
	RANGE type, order
	GLOBAL stim1, stim2 : (stim1 = normalized waveform of first E-field, stim2 scales second E-field vs first E-field)
	POINTER ex
}

PARAMETER {
	: default transfer resistance between stim electrodes and axon
	: rx = 1 (megohm) : mV/nA
	es1 = 0 (mV)
	Ex1 = 0 (1) : E-field components
	Ey1 = 0 (1)
	Ez1 = 0 (1)
	es2 = 0 (mV)
	Ex2 = 0 (1) : E-field components
	Ey2 = 0 (1)
	Ez2 = 0 (1)
	x = 0 (1) : spatial coords
	y = 0 (1)
	z = 0 (1)
	Dx = 0 (1) : unit vector of orientation of compartment (central-diff)
	Dy = 0 (1)
	Dz = 0 (1)
	type = 0 (1) : numbering system for morphological category of section - unassigned is 0
	order = 0 (1) : order of branch/collateral. 
}

ASSIGNED {
	v (millivolts)
	ex (millivolts)
	stim1 (unitless) 
	stim2 (unitless) 	
	:im (milliamp/cm2)
	:er (microvolts)
	area (micron2)
}

INITIAL {
	ex = stim1*es1 + stim2*es2
	:er = (10)*rx*im*area
}

BEFORE BREAKPOINT { : before each cy' = f(y,t) setup
  ex = stim1*es1 + stim2*es2
}

: AFTER SOLVE { : after each solution step
:   er = (10)*rx*im*area
: }

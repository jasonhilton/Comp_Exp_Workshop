
library(RNetLogo)
nl.path<- "C:\\Program Files (x86)\\NetLogo 5.1.0"
NLStart(nl.path, gui=F)

model.path <- "/models/Sample Models/Earth Science/Fire.nlogo"

NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("set density 77")
NLCommand("setup")
NLDoCommand(1000,"go")
initial<- NLReport("initial-trees")
burned<- NLReport("burned-trees")

NLCommand("set density 77")
NLCommand("setup")

burned <- NLDoReport(100, "go", "(burned-trees / initial-trees) * 100") # records at each point. 







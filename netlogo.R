
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

NLQuit()
NLStart(nl.path, gui=T)
model.path <- "/models/Sample Models/Social Science/Segregation.nlogo"
NLLoadModel(paste(nl.path,model.path,sep=""))

NLCommand("set %-similar-wanted 20")




NLCommand("setup")
NLDoCommand(100,"go")
NLReport("percent-similar")

repetitions<-10

doSimSingleParam<-function(x){
  NLCommand("setup")
  NLDoCommand(100,"go")
  return(NLReport("percent-similar"))
}

percentSimilar<-sapply(1:repetitions, doSimSingleParam)


system.time(percentSimilar<-sapply(1:repetitions, doSimSingleParam))

NLQuit()
NLStart(nl.path, gui=F)
NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("set %-similar-wanted 20")
system.time(percentSimilar<-sapply(1:repetitions, doSimSingleParam))

repetitions<-100
system.time(percentSimilar<-sapply(1:repetitions, doSimSingleParam))
hist(percentSimilar)


NLCommand("set %-similar-wanted 70")
percentSimilar<-sapply(1:repetitions, doSimSingleParam)
hist(percentSimilar)
shapiro.test(percentSimilar)
qqnorm(percentSimilar)
qqline(percentSimilar)


## Parallelisation

#see vignette("parallelProcessing","RNetLogo")
library(parallel)
n_processors<-detectCores()-1

cl<-makeCluster(n_processors)

setupModel<-function(nl.path,model.path){
  library(RNetLogo)
  NLStart(nl.path,gui=F)
  NLLoadModel(paste(nl.path,model.path,sep="")) 
}

setConstantInput<-function(inputValue, inputName){
  NLCommand("set", inputName, inputValue)
}

runModel<-function(inputValue, inputName, outputName="percent-similar"){
  NLCommand("set", inputName, inputValue)
  NLCommand("setup")
  NLDoCommand(100,"go")
  return(NLReport(outputName))
}


closeModel<-function(x){
  NLQuit()
}

parLapply(cl, rep(nl.path, n_processors), setupModel, model.path=model.path)
percentSimilar<- parSapply(cl, seq(0,100,1), runModel, inputName="%-similar-wanted")
#c 1 min vs 2 min serial. 3 cores. 

parLapply(cl, rep(30, n_processors), setConstantInput, inputName="%-similar-wanted")
percentSimilar_number<- parSapply(cl, seq(500,51*51,100), runModel, inputName="number")

parLapply(cl,1:n_processors, closeModel)

stopCluster(cl)





#linux/mac equivalent ( untested)
# setupModelUnix<-function(nl.path,model.path){
#   NLStart(nl.path,gui=F)
#   NLLoadModel(paste(nl.path,model.path,sep="")) 
# }

#mclapply(rep(nl.path, n_processors), setupModelUnix, model.path=model.path)

#mclapply(seq(0,100,2), runModel, inputName="%-similar-wanted")



  






library("XML")


# experiment_template<-  xmlInternalTreeParse("experiments.xml")
# 
# getNodeSet(experiment_template, "//enumeratedValueSet")

# create an xml node corresponding to one experiment
# With variables 
make_experiment_xml <- function(variables, values, metric,repetitions=1, timeLimit=50){
  if (length(variables)!= length(values)){
    stop("Need one value for each variable in the experiment")
  }
  valueSets <- mapply(make_value_set, variables, values)
  setup <- newXMLNode("setup","setup")
  go <- newXMLNode("go","go")
  metric <- newXMLNode("metric", metric)
  timeLimit <- newXMLNode("timeLimit", attrs = c(steps="500"))
  exp_node <- newXMLNode("experiment", 
                         attrs = c(name ="experiment",
                                   repetitions ="1",
                                   runMetricsEveryStep="false"),
                         .children = list(setup, go, timeLimit, metric, valueSets))
  return (exp_node)
}

make_value_set<-function(variable, value){
  valueSet <- newXMLNode("enumeratedValueSet", attrs = c(variable = variable),
                         .children = list(newXMLNode("value", attrs=c(value=value))))
  return ( valueSet)
}

make_experiments_doc <- function(variables, values, metric,repetitions=1, timeLimit=50){
  experiment_xml <-make_experiment_xml(variables, values, metric,repetitions, timeLimit)
  exp_doc <-xmlTree("experiments", 
                          dtd = c("experiments", "", "behaviorspace.dtd"))
  exp_doc$addNode(experiment_xml)
  return(exp_doc)
}

construct_nl_command<-function(nl_path, model_path, experiment_path,out_path=F){
  jar_path <- shQuote(file.path(nl_path, "NetLogo.jar"))
  cmd <- paste("java -Xmx1024m -Dfile.encoding=UTF-8 -cp" , jar_path)
  cmd <- paste(cmd, "org.nlogo.headless.Main")
  cmd <- paste(cmd, "--model", shQuote(model_path))
  cmd <- paste(cmd, "--setup-file", shQuote(experiment_path))
  cmd <- paste(cmd, "--experiment experiment")
  if (out_path){
    cmd <- paste(cmd, "--table", shQuote(out_path))
  }
  else {
    cmd <- paste(cmd, "--table -")
  }
  return(cmd)
}


parse_results<-function(results){
  # just get the bit we are interested in 
  final_line <- strsplit(results[length(results)], split='\"')[[1]]
  return(as.numeric(final_line[length(final_line)]))
}

make_run_model_command <- function(nl_path, model_path, experiment_path, 
                                   metric,variables, timeLimit=50){
  runModel <- function(...){
    values <- c(...)
    prefix <- '<?xml version="1.0" encoding="us-ascii"?>'
    exp_doc <- make_experiments_doc(variables, values, metric ,timeLimit=timeLimit)
    saveXML(exp_doc, file=experiment_path, prefix = prefix, 
            encoding = "us-ascii")
    cmd <- construct_nl_command(nl_path, model_path, experiment_path)
    out <- system(cmd, intern=T)
    return(parse_results(out))
  }
  return(runModel)
}

runSegregationModel <-function(runModel){
  runModelWithArgs <- function(similar, den){
    return ( runModel(similar, density) )
  }
  return(runModelWithArgs)
}



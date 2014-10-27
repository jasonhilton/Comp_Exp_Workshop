---
output: html_document
---
Design and Analysis of Computer Experiments
========================================================


**Jason Hilton and Jakub Bijak** - University of Southampton 

Workshop given for IDEM 112 'Agent-based modelling and simulation'  
Part of the MPIDR [International Advanced Studies in Demography series](http://www.demogr.mpg.de/en/education_career/international_advanced_studies_in_demography_3279/default.htm)

Location: Max Planck Institute for Demographic Research, Rostock  
Date: 30^th^ October 2014

***

#Introduction 

In this workshop, we shall work through examples of a number of the techniques discussed in the preceding lectures. 

All files and supporting information are available on the github page [https://github.com/jasonhilton/Comp_Exp_Workshop](https://github.com/jasonhilton/Comp_Exp_Workshop).

I shall try to keep the R code is clear as possible throughout, and include comments and explanations in the text, but remember that you can use the '?' command to access the R help for any command if necessary.
Try this for the *lapply* is you are not already familiar with it. 

This workshop leans heavily on ideas from 
Managing Uncertainty in Complex Models Toolkit (2011), MUCM project, [http://mucm.aston.ac.uk/toolkit/index.php?page=MetaHomePage.html](http://mucm.aston.ac.uk/toolkit/index.php?page=MetaHomePage.html)
Santer, W., Williams, B, and Notz, W (2003)  *'Design and Analysis of Computer Experiements'*

#Part 1: Experimental Designs and Simple Metamodels  

## A First Experiment  
We will start by running some very simple experiments to examine some of the ideas discussed in the lecture. 

We will run netlogo through R using the RNetLogo Library, which you are all familiar with. 
You will need to edit the nl.path variable to point to the folder where netlogo is installed on your machine.

Notice the 'gui' option has been set to false throughout this workshop, as running in 'headless' mode results in quicker runs. The gui is great for development, debugging and demonstration, but not necessarily much use for 'production' runs (ie, those required to produce your results).


```r
library(RNetLogo)
### CHANGE THIS PATH if necessary ###
nl.path<- "C:\\Program Files (x86)\\NetLogo 5.0.4"
NLStart(nl.path, gui=F)
```

```
## Error: Name of object (nl.obj) to store the NetLogo instance
##       is already in use. Please quit the used object first or choose a different name.
```

Our first experiment subject is Schelling's famous segregation model. Most of you will I expect already be familiar with this model by now, but a brief summary is given below in any case.

This examines how individual's moderate preference for living with those similar to themselves can lead to almost complete separation of different types of people. The model aims to show how observed macro-level racial segregation patterns in American cities need not have been caused by explicit racism, but may emerged out of weaker micro-level preferences.

This is one of the standard NetLogo models, so we can load it from the model library as below. 


```r
model.path <- "/models/Sample Models/Social Science/Segregation.nlogo"
NLLoadModel(paste(nl.path,model.path,sep=""))
```

Recall, we are interested in how our model **inputs** map to outputs or **responses**.
In this case we have two main inputs - the micro-level preference for similar agents, and the total number of agents present. Given the fixed grid size of $51*51$ patches, this latter input can also be thought of as the population density of the area in question. The output is the average proportion of similar neighbours over all agents - a proxy for segregation. 

Let's run the simulation at one combination of inputs and print the output to the screen.

```r
NLCommand("set %-similar-wanted 50")
NLCommand("set number 1500")
NLCommand("setup")
NLDoCommand(100,"go")
NLReport("percent-similar")
```

```
## [1] 88.44
```

Here we see that for agents desiring at least half of their neighbours to be similar to themselves, together with a population density of $\frac{1500}{51^{2}} = $ 0.5767, the average proportion of similar agents in a neighbourhood is around about 90%. 

##Exploring the Parameter Space

We want to examine how this response varies over the parameter space. An obvious - though not necessarily optimal - place to start is to hold one input steady while varying the other. 


```r
# Our desired inputs - a sequence from 0 to 100 increasing by 10 for similar
similar_desired_range <- seq(0,100,10)
number<-1500

runModel<-function(similar,num){
  # function running the model for 50 ticks at inputs 'similar' and 'num' 
  # returning the global proportion similar
  NLCommand("set %-similar-wanted", similar)
  NLCommand("set number", num)
  NLCommand("setup")
  NLDoCommand(50,"go")
  return(NLReport("percent-similar"))
}

# Apply the function runModel to each value in similar_desired, 
# holding number of agents constant at 'number', returning results as an array.
global_similar<-sapply(similar_desired_range, runModel, num=number)

# plot the results 
plot(similar_desired_range, global_similar, 
     main=paste("Response by values of '%-similar-desired',", number, "agents"))
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 

By observation, it seems that segregation increases with micro-level preference for similar neighbours up to a threshold of about 70-80% desired similar neighbours, at which point there is a sharp decrease to the 50%. Why might this be the case?

Similarly, we can hold '%-similar-desired' steady, and vary only the number of agents in the simulation ( and by extension the population density)


```r
  similar_desired <- 50
  number_range<-seq(500,2500,250)
  global_similar2<-sapply(X=number_range, runModel, similar = similar_desired)
  plot(number_range, global_similar2, 
       main = paste("Response by number of agents. %-similar-wanted = ", similar_desired ))
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 

Here it seems as though increasing the number of agents decreases segregation, although note the scale on the y-axis.

By holding the one parameter fixed while varying the other, we are preventing ourselves from identifying any interaction between the variables, and leaving large areas of the parameter space unobserved. 

We can see this by simply plotting our design:


```r
# here I simply combine all inputs in a single data frame. 
design<-data.frame(similar_desired=c(similar_desired_range,
                                   rep(similar_desired, length(number_range))),
                  number=c(rep(number,length(similar_desired_range)), 
                                     number_range))
plot(design)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 

To examine the corners of the parameter space, and to attempt to capture interactions between the variables, we will now run our simulation on a full factorial design. 
We will use 5 levels (this may take a few moments to run)  


```r
fact_design<-expand.grid(similar_desired=seq(0,100,25), number=seq(500,2500,500))

plot(fact_design)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 

```r
fact_response<-mapply(runModel, fact_design$similar_desired, fact_design$number)
```

We can plot this as a surface using the persp command:


```r
persp(unique(fact_design$similar_desired),
      unique(fact_design$number), 
      matrix(fact_response,nrow=5),
      xlab="Similar Desired",
      ylab="Number of Agents",
      zlab="Response",
      theta=220,
      phi=30,
      shade=0.6,
      col="lightblue"
      )
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 

This looks nice, but generally a contour plot is easier to interpret, and requires
less tuning to find a good viewing angle. 


```r
filled.contour(unique(fact_design$similar_desired),
      unique(fact_design$number), 
      matrix(fact_response,nrow=5),
      xlab="Similar Desired",
      ylab="Number of Agents",
      main="Average % Neighbour Similar by % similar desired and number of agents",
      cex.main=0.9)
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 

With both these methods, we have to be carefull to realise that the plot algorithms are interpolating between the points we have observed using a simple (meta)model.


# Response surfaces
Now we can start fitting some simple meta-models.
Often it is preferable to standardise the input space so that we can easily compare the effect of different inputs through their regression coefficients.


```r
transformInput<-function(input){
  transformed_input<-input-min(input)
  return(transformed_input/max(transformed_input))
}

trans_design<-data.frame(apply(fact_design, 2, transformInput))

# for convenience, lets add our outputs as a column in the same data frame
trans_design$response<-fact_response
```

We will start by fitting just a main effect to each input


```r
model1<-with(trans_design, lm(response~ similar_desired + number))
summary(model1)
```

```
## 
## Call:
## lm(formula = response ~ similar_desired + number)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -27.57 -12.24  -2.11  16.85  24.07 
## 
## Coefficients:
##                 Estimate Std. Error t value Pr(>|t|)    
## (Intercept)        70.26       7.81    9.00  7.9e-09 ***
## similar_desired    15.74       9.88    1.59     0.13    
## number            -15.42       9.88   -1.56     0.13    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 17.5 on 22 degrees of freedom
## Multiple R-squared:  0.184,	Adjusted R-squared:  0.11 
## F-statistic: 2.49 on 2 and 22 DF,  p-value: 0.106
```

This is not a good fit to the data, and 

# Validation



# Other designs


# Note on the purpose of meta-models 

It might appear that meta-models don't add much to simple plotting of outputs.
For the example we have used here, this may be the case. We have studied a simple and above all low-dimension problem. 

Once you include more parameters,


#Part 2: Uncertainty and Emulation


## Assessing uncertainty using Monte Carlo

In the lectures we discussed using Monte Carlo techniques to assess uncertainty at



# Reading and Software

A number of R packages might be able to help you in designing and analysing computer experiments.

##R packages
1. 'lhs':  Provides simple functions to calculate latin hypercube samples. Note that optimumLHS can sometimes be expensive in high dimensions, so the other options are general best. Augment is also a useful function if you need to add more points eg for crossvalidation
2. 'DiceKriging': excellent non-bayesian computater experiment package
3. 'tgp':  a bit more complex. Fits 'treed' gaussian process
4. 'BACCO': implementation of Kennedy and O'Hagan's emulator framework. Deterministic models only, so not always useful
5. 'AlgDesign' :  For generating fraction factorials
6. 'rsm' : Response surface methodology package.

##Other Software
1. Gaussian Process Matlab packages : Algorithms relating to the Rasmussen and Williams excellent book on Gaussian processes. Cutting edge. 
2. GEM-SA :  Marc Kennedy's stand-alone gui for Gaussian Processes.



```r
#NLQuit()
```



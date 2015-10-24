---
output: 
  html_document: 
    keep_md: yes
---


Design and Analysis of Computer Experiments
========================================================

**Jason Hilton and Jakub Bijak** - University of Southampton 


Workshop given for IDEM 112 'A stochastic process approach to agent-based modeling and simulation'  
Part of the MPIDR [International Advanced Studies in Demography series](http://www.demogr.mpg.de/en/education_career/international_advanced_studies_in_demography_3279/default.htm)

Location: Max Planck Institute for Demographic Research, Rostock  
Date: 26<sup>th</sup> October 2015

***

#Introduction 

```r
library(knitr)
set.seed(14533)
opts_chunk$set(cache=F)
```

**NOTE: this is a version of the workshop for Mac users who can't get RNetLogo to work**

In this workshop, we shall work through examples of a number of the techniques discussed in the preceding lectures. 

All files and supporting information are available on the github page [https://github.com/jasonhilton/Comp_Exp_Workshop](https://github.com/jasonhilton/Comp_Exp_Workshop). If you are familiar with the git version control software, you should be able to clone into this repository using the command `git clone https://github.com/jasonhilton/Comp_Exp_Workshop.git`
If not you can also download the files as a zip. To run the workshop code on a mac you will need at least the `apple_funcs.R` file, which contains R functions enabling communication with netlogo.

I shall try to keep the R code is clear as possible throughout, and include comments and explanations in the text, but remember that you can use the '?' command to access the R help for any command if necessary.
Try this for the *lapply* function. The apply family of functions are used a lot in the workshop below. If you are not familiar with them, there's a brief introduction at 

[https://github.com/jasonhilton/Comp_Exp_Workshop/blob/master/apply_basics.md](https://github.com/jasonhilton/Comp_Exp_Workshop/blob/master/apply_basics.md)


This workshop leans heavily on ideas from:  

**Managing Uncertainty in Complex Models Toolkit** (2011), MUCM project, [http://mucm.aston.ac.uk/toolkit/index.php?page=MetaHomePage.html](http://mucm.aston.ac.uk/toolkit/index.php?page=MetaHomePage.html) 

**Santer, W., Williams, B, and Notz, W** (2003)  *'Design and Analysis of Computer Experiments'*, Springer  


We are also using fewer simulation runs than we might generally wish for. This is largely because we want you to spend more time trying out the various methods, and less time waiting for simulations to finish running!

I suggest working through the examples below, executing the code yourself at each stage. There are several tasks throughout the workshop for you to try yourself. Solutions are available for some of these if you get stuck.

#Part 1: Experimental Designs and Simple Metamodels  

## A First Experiment  
We will start by running some very simple experiments to examine some of the ideas discussed in the lecture. 

Problems with RNetLogo on Macs mean that a slightly different approach is needed than is used in the main workshop, for which some setting up is required
Firstly,  you will need to install the XML package. You will also need to edit the 'nl.path' variable defined below to point to the folder where NetLogo is installed on your machine.
We also need to give a path where an temporary .xml file can be safely created.



```r
# We need to install the XML package - this is to create 'experiment' files that netlogo can read.
install.packages("XML")
```

```
## Installing package into 'C:/rpackages'
## (as 'lib' is unspecified)
```

```
## package 'XML' successfully unpacked and MD5 sums checked
## 
## The downloaded binary packages are in
## 	C:\Users\jdh4g10\AppData\Local\Temp\Rtmp6nfYwS\downloaded_packages
```

```r
library(XML)
### V CHANGE THIS PATH V ###
nl.path <- "C:\\Program Files (x86)\\NetLogo 5.2.1"
#nl.path <- path.expand("~/netlogo-5.2.0/")
# V some directory where a temporary file can be created V (Choose your own!)
experiment_path <- path.expand("~")


#load some helper functions 
# you need to set your working directory to the location where this file apple_funcs is saved
#setwd("")
source("apple_funcs.R")
```

Our first experiment subject is Schelling's famous segregation model , as mentioned briefly this morning. Most of you will I expect already be familiar with this model by now, but a brief summary is given below. For these examples, the substance of the model is not that important in any case.

Schelling's model examines how individual's moderate preference for living near those similar to themselves can lead to almost complete separation of different types of people at the 'city' level. The model aims to show how observed macro-level racial segregation patterns in American cities need not have been caused by explicit racism, but may emerged out of weaker micro-level preferences.

This is one of the standard NetLogo models, so we can load it from the model library. 



```r
model.path <- file.path(nl.path, "models/Sample Models/Social Science/Segregation.nlogo")
```

Recall, we are interested in how our model **inputs** map to outputs or **responses**.
In this case we have two main inputs - the micro-level preference for similar agents, and the spatial population density. Given the fixed grid size of 51x51 patches, this latter input can also be thought of as relating to the proportion of occupied patches. The output is the average proportion of similar neighbours over all agents - a proxy for segregation. 

Let's run the simulation at one combination of inputs and print the output to the screen.

```r
metric <-  "percent-similar"
variables <- c("%-similar-wanted",  "density")
# create a function to allow running the model in a similar way to using NetLogo
runModel <- make_run_model_command(nl.path, model.path, experiment_path, 
                                 metric,variables)

percent_similar_wanted <- 50
density <- 58
runModel(percent_similar_wanted, density)
```

```
## [1] 88.47125
```

Here we see that for agents desiring at least half of their neighbours to be similar to themselves, together with a population density of 58%, the average proportion of similar agents in a neighbourhood is around about 90%. 

##Exploring the Parameter Space

We want to examine how this response varies over the parameter space. An obvious - though not necessarily optimal - place to start is to hold one input steady while varying the other. 


```r
# Our desired inputs - a sequence from 0 to 100 increasing by 10 for similar
similar_desired_range <- seq(0, 100, 10)
density <- 58


# Apply the function runModel to each value in similar_desired, 
# holding population density constant at the value of 'density', returning results as an array.
global_similar <- sapply(similar_desired_range, runModel, den = density)

# plot the results 
plot(similar_desired_range, global_similar, 
     main = paste("Response by values of '%-similar-desired', population density =", density, "%"))
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4-1.png) 

By observation, it seems that segregation increases with micro-level preference for similar neighbours up to a threshold of about 70-80% desired similar neighbours, at which point there is a sharp decrease to the 50%. Why might this be the case?


### *Task*

Try holding '%-similar-desired' steady, and vary only the population density.
Keep %-similar desired at 50, and run the model at values between 15% and 95%, at increments of 5%. Plot the results



The results should imply that increasing the density of agents tends to decrease segregation, although note the scale on the y-axis.

By holding the one parameter fixed while varying the other, we are preventing ourselves from identifying any interaction between the variables, and leaving large areas of the parameter space unobserved. 

We can see this by simply plotting our design:


```r
# this looks complicated, but I simply combine all inputs points we have already run into a single data frame, and plot them 
design <- data.frame(
  similar_desired = c( similar_desired_range, rep(50, length(seq(15,95,5)))),
  density = c(rep(density,length(similar_desired_range)), seq(15,95,5)))

plot(design)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png) 

To examine the corners of the parameter space, and to attempt to capture interactions between the variables, we will now run our simulation on a full factorial design. 
We will use 5 levels (this may take a few moments to run)  


```r
# expand.grid creates an array with all combination of the two arguments given
fact_design <- expand.grid(similar_desired=seq(0,100,25), density = seq(20,98,19))

# plot the design 
plot(fact_design)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png) 

```r
  variables <- c("%-similar-wanted", "density")
  # create a function to allow running the model in a similar way to using NetLogo
  runModel <- make_run_model_command(nl.path, model.path, experiment_path, 
                                 metric,variables)
# fun the model at these combinations, using mapply to iterate through pairs of inputs
fact_response<-mapply(runModel, similar=fact_design$similar_desired, den=fact_design$density)
```

We can plot this as a surface using the persp command:


```r
persp(
      # get the unique values of each input
      unique(fact_design$similar_desired),
      unique(fact_design$density), 
      # create a matrix of the output values
      matrix(fact_response,nrow =5),
      xlab = "Similar Desired",
      ylab = "Density of Agents",
      zlab = "Response",
      # some parameters governing viewing angle
      theta = 220,
      phi = 30,
      shade = 0.6,
      col = "lightblue"
      )
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png) 

This looks nice, but generally a contour plot is easier to interpret, and requires
less tuning to find a good viewing angle. 


```r
filled.contour(unique(fact_design$similar_desired),
      unique(fact_design$density), 
      matrix(fact_response,nrow=5),
      xlab = "Similar Desired",
      ylab = "Density of Agents",
      main = "Average % Neighbour Similar by % similar desired and density of agents",
      cex.main = 0.9)
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png) 

With both these methods, we have to be carefull to realise that the plot algorithms are interpolating between the points we have observed using a simple meta-model. Also note that the surface is pretty uneven. This is because we are dealling with a *stochastic simulator*, so the unevenness is likely to be attributible to random noise from NetLogo's random number generator. We will talk more about randomness in the part 2 of this workshop. 


# Response surfaces
Now we can start fitting some simple meta-models.
Often it is preferable to standardise the input space so that we can easily compare the effect of different inputs through their regression coefficients.


```r
# transform the input so that it range between 0 and 1.
transformInput <- function(input, location, multiplier){
  transformed_input <- input - location
  return( transformed_input / multiplier )
}

# we need to save these values for later transformations.
locations <- apply(fact_design,2,min)
multipliers <- apply(fact_design,2,max)- locations

# do the transformation by applying the transformInput function
trans_design<-data.frame(mapply(transformInput, fact_design, locations, multipliers))

# for convenience, lets add our outputs as a column in the same data frame
trans_design$response<-fact_response
```

We will start by fitting just a simple linear term for each input.


```r
# we use the standard R linear model command. 
model1<-with(trans_design, lm(response ~ similar_desired + density))
summary(model1)
```

```
## 
## Call:
## lm(formula = response ~ similar_desired + density)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -31.488 -11.871  -3.083  15.989  25.167 
## 
## Coefficients:
##                 Estimate Std. Error t value Pr(>|t|)    
## (Intercept)       68.716      8.578   8.011 5.77e-08 ***
## similar_desired   21.067     10.850   1.942   0.0651 .  
## density          -13.146     10.850  -1.212   0.2385    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 19.18 on 22 degrees of freedom
## Multiple R-squared:  0.1923,	Adjusted R-squared:  0.1189 
## F-statistic: 2.619 on 2 and 22 DF,  p-value: 0.09544
```

This is not a good fit to the data, which is unsurprising given we observed significant curvature in our response surface. This curvature cannot be captured by linear terms in our model.
Problems with this model can clearly be identified by plotting the standardised residuals against the similar desired input - we would hope that there is no pattern to these residuals.


```r
# rstandard computes the standarised residuals.
plot(trans_design$similar_desired, rstandard(model1))
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11-1.png) 

Let's try adding higher order terms, and an interaction term: 


```r
# Model with interaction and squared terms
model2<- with(trans_design, 
              lm( response ~ similar_desired * density + I (density**2) 
                  + I(similar_desired**2)))
summary(model2)
```

```
## 
## Call:
## lm(formula = response ~ similar_desired * density + I(density^2) + 
##     I(similar_desired^2))
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -18.5465  -7.4705   0.3759   7.2394  18.5499 
## 
## Coefficients:
##                         Estimate Std. Error t value Pr(>|t|)    
## (Intercept)               48.409      7.525   6.433 3.62e-06 ***
## similar_desired          173.536     23.479   7.391 5.32e-07 ***
## density                  -22.021     23.479  -0.938    0.360    
## I(density^2)              18.306     20.896   0.876    0.392    
## I(similar_desired^2)    -143.038     20.896  -6.845 1.56e-06 ***
## similar_desired:density  -18.862     17.483  -1.079    0.294    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 10.93 on 19 degrees of freedom
## Multiple R-squared:  0.7736,	Adjusted R-squared:  0.714 
## F-statistic: 12.99 on 5 and 19 DF,  p-value: 1.396e-05
```
This model fits the data much better, and a higher proportion of variance is accounted for, as can be observed from the value of R<sup>2</sup>.
The residuals are still not perfect, but are considerably better than before.


```r
plot(trans_design$similar_desired, rstandard(model2))
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13-1.png) 

```r
plot(trans_design$density, rstandard(model2))
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13-2.png) 

```r
qqnorm(rstandard(model2))
qqline(rstandard(model2))
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13-3.png) 


## Validation
If we are to trust the results of meta-model, we need to confirm that it is a good fit for the underlying simulation. The best way of doing this is to run the simulation at new points, and compare these to the model predictions. 


```r
new_points <- data.frame(similar_desired = runif(10, 0, 100), density = runif(10, 20, 95))
valid_response <- mapply(runModel, new_points$similar_desired, new_points$density)


trans_new_points <- data.frame(mapply(transformInput, 
                                    new_points, locations, multipliers))
model_predictions <- predict(model2, trans_new_points)

error <- valid_response - model_predictions

# Root Mean Squared Error
RMSE <- sqrt(sum(error**2) / length(error))

# 'Normalised' RMSE
RMSE/diff(range(trans_design$response))
```

```
## [1] 0.328832
```

The normalised RMSE is probably too high for this model. The RMSE is a metric for assessing prediction error  based on the root of the average squared error, divided by the range over which the training set response varies. 

This result might be due to the low number of data-points, but more likely it is due to the inadequacy of model we fit. ABM simulation are often too non-linear to expect simple response surfaces such as the one fitted above to do a good job of 'standing in' for the simulation. However, fitting a response surface does help us to understand the way in which the model responds to different inputs.  


The inadequacy of the model in prediction helps to motivate the non-parameteric methods such as kriging used in the next part of the workshop, where no specific functional form is assumed for the meta-model.


## Sensitivity Analysis

We can crudely examine the sensitivity of the model to inputs by considering the
ANOVA decomposition of our model, and comparing the ratios of effect-specific sum of squares to the total:

```r
model_an<-anova(model2)

model_an["Sum Sq"]/sum(model_an["Sum Sq"])
```

```
##                              Sum Sq
## similar_desired         0.138408554
## density                 0.053894964
## I(density^2)            0.009144034
## I(similar_desired^2)    0.558304015
## similar_desired:density 0.013868869
## Residuals               0.226379564
```
Note the percentages sum to one by construction. This indicates that the squared effect of similar-desired is the most significant in our model. This fits with our eyeball intuition, noting the curved nature of the response surface. 

## Other designs
The R package 'lhs' allows easy generation of the LHS sample designs. 

### *Task*
Try using this package and the improvedLHS command to generate an LHS design for the Schelling model, running the model at these points, and fitting a simple metamodel  to the data. 

How does the RMSE for the lhs design compare to the factorial design using the same validation points, the same model and the same number of points?

- *Tip* : The function improvedLHS takes two arguments - the number of inputs to generate, and the number of dimensions.
- *Tip* : It also produces a design scaled to between 0 and 1 You will need to scale it up again to lie in the range of the individual inputs before you run the model.





The main advantage of LHS designs, however, is that you can get away with many fewer runs, particularly in higher dimensions, and when use in combined with kriging-type models.  

## Note on the purpose of meta-models 

It might appear that meta-models don't add much to simple plotting of outputs.
For the example we have used here, this may be the case. We have studied a simple and above all low-dimension problem. 

Once you include more parameters, it becomes more and more difficult to identify interactions by eye, and model-based solutions become imperative. 


#Part 2: Uncertainty quantification and Kriging-based Emulation

In the first part of this workshop we have paid very little attention to the uncertainty inherent in simulation. We will start by examining how Monte Carlo techniques can be used to assess the effect of uncertainty. 

## Assessing uncertainty using Monte Carlo
We will start by working with the forest fire model, again from the NetLogo model library. This model display displays a lot of stochasticity in outputs, and so is a good target for uncertainty analysis. 

It models the spread of fire through a forest. It has only one parameter - the density of the trees in the forest in question. The simulation introduces fire to the edge of the fire, and lets it spread to any nearby trees. We are examining the proportion of burnt trees as an output. 



```r
model_path <- file.path(nl.path, "/models/Sample Models/Earth Science/Fire.nlogo")
```

As a test, let's run the simulation a few times at density 60. Note the considerable differences in outputs. 


```r
metric <- "burned-trees"
possible_trees <- 63001
variables <- "density"
runModel<-make_run_model_command(nl.path,model_path,experiment_path, 
                                 metric,variables, timeLimit=1000)

density <- 60

for (i in 1:4) {
  print(runModel(density)/(possible_trees * (density/100.0 )))
}
```

```
## [1] 0.5426633
## [1] 0.768374
## [1] 0.655069
## [1] 0.7080311
```



Now lets run the simulation 50 times at the density 60 to start to examine what the output *distribution* looks like at this point. When we are doing this sort of experiment it is useful to check how long each set of runs is going to take - otherwise we might be waiting for simulations that will never end!  

The function'*system.time*' is our friend in this context - look at the third column in the output, "elapsed time" to assess the time taken. When working on this yourself, try this with a small number of runs and mutliply up to get an idea of how long it should take for the desired number.


```r
density <- rep(60,50)
system.time( proportion_burned_60 <- sapply(density, runModel )/(possible_trees * (density/100.0 )))
```

```
##    user  system elapsed 
##    0.42    0.28  159.84
```

```r
hist(proportion_burned_60)
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19-1.png) 

Notice how the results are spread over almost all the whole of the output space, with most of the density concentrated at the right of the distribution. Ideally we want to consider how this distribution changes across the parameter space.

As we are going to need to repeat our simulation a number of times,  it may be worth harnessing the advantages of parallel computing to speed the process up. 
If your computer has multiple cores, with a bit of setup you can use parallel versions of the apply family of functions to split the work over a number of processors.

This section is based on the RNetLogo package Parallel Processing vignette by Jan Thiele, which you can access by typing "vignette("parallelProcessing","RNetLogo")"

We will try running a larger number of simulations using the parallel version of mapply, `mcmapply` : 


```r
# run model using mclapply, and combine results with those from before.
library("parallel")

# I wasn't able to test this on a MAC unfortunately - but it should work

# how many processors shall I use?
cores=detectCores() - 1 

system.time(
  # For technical reasons relating to the way this runModel works, we need to also supply a 
  # unique run number to each simulation when parallelising. Don't worry about this!
  number_burned_60_par <- mcmapply(runModel,rep(60,100), run_no=1:100, mc.cores=cores)
)
```

```
## Error in mcmapply(runModel, rep(60, 100), run_no = 1:100, mc.cores = cores): 'mc.cores' > 1 is not supported on Windows
```

```
## Timing stopped at: 0 0 0
```

```r
proportion_burned_60_par <- number_burned / (possible_trees * (60/100.0 ))
```

```
## Error in eval(expr, envir, enclos): object 'number_burned' not found
```

```r
proportion_burned_60 <- c( proportion_burned_60,  proportion_burned_60_par)
```

```
## Error in eval(expr, envir, enclos): object 'proportion_burned_60_par' not found
```
Hopefully you should notice that this took less time per run than before! We did twice as many runs this time, so we would hope the elapsed time is considerably less than twice the previous value. If not, this is probably due to the overhead associated with sending information to different cores and putting it back together again. The more runs you are hoping to do, the more likely it is that you will be able to see benefits from parallelising your model runs.


Let's plot our outputs. We can also use the 'density' command to plot the smoothed continuous density of our observations.


```r
hist(proportion_burned_60,breaks = 15)
```

![plot of chunk unnamed-chunk-21](figure/unnamed-chunk-21-1.png) 

```r
plot( density( proportion_burned_60 ) )
```

![plot of chunk unnamed-chunk-21](figure/unnamed-chunk-21-2.png) 

```r
var(proportion_burned_60)
```

```
## [1] 0.02631019
```

We now have 150 runs, and we can see from the above histogram that the distribution is pretty irregular. Clearly, a normality assumption will not be appropriate in this case. 


### *Task*
Try and build up a picture of the uncertainty caused by simulation stochasticity across the following values of density by running repeat trials at each value, and examine the variance.
There is no need to do 150 runs at each point given time constraints, however - try around 25.


```r
densities<-seq(51, 81, 6)
```



###*Task*
Next, let's assume we have some prior information about the density of a particular forest we are interested in. We want to know what the probability of various proportions of forest destruction is, given our prior information, which is expressed as a probability distribution over possible density values.

Our prior assumption is that the density of the forest has a normal distribution with mean 56 and sd 1.5 . Sample from this distribution using rnorm, and run the simulation at the sampled points. Plot the density of this output distribution. 

Now try the same exercise, but just hold the input steady at its mean value, and examine the difference between the two distributions. 



This is an example of incorporating the effect of *input uncertainty* into our output predictions. (Note this is NOT a case of full Bayesian updating - we have not applied Bayes rule to get a posterior, but used the prior and the model to induce a distribution on our output variable).



# Kriging and Gaussian Processes

## Kriging Models with DiceKriging

Here we will go back to our Schelling model and fit two different kriging models. 

We will start by examining the `DiceKriging` package, which you will need to install from CRAN. This package uses the `km` command to create a kriging model object in the same way as the `lm` linear model command.

Use the LHS sample and associated response you created earlier to fit the model.


```r
lhs_design$response<-lhs_response
library("DiceKriging")

kriging_m1<-km(response~similar_desired + density, lhs_design[,c(1,2)], lhs_design[,3], nugget.estim=T)
```

```
## 
## optimisation start
## ------------------
## * estimation method   : MLE 
## * optimisation method : BFGS 
## * analytical gradient : used
## * trend model : ~similar_desired + density
## * covariance model : 
##   - type :  matern5_2 
##   - nugget : unknown homogenous nugget effect 
##   - parameters lower bounds :  1e-10 1e-10 
##   - parameters upper bounds :  193.2312 145.7616 
##   - upper bound for alpha   :  1 
##   - best initial criterion value(s) :  -86.51435 
## 
## N = 3, M = 5 machine precision = 2.22045e-16
## At X0, 0 variables are exactly at the bounds
## At iterate     0  f=       86.514  |proj g|=      0.08172
## At iterate     1  f =       84.622  |proj g|=       0.99633
## At iterate     2  f =       84.621  |proj g|=        0.0149
## At iterate     3  f =       84.619  |proj g|=      0.011769
## At iterate     4  f =       84.619  |proj g|=       0.13932
## At iterate     5  f =       84.619  |proj g|=      0.017579
## At iterate     6  f =       84.619  |proj g|=      0.011243
## At iterate     7  f =       84.619  |proj g|=      0.011261
## At iterate     8  f =       84.619  |proj g|=      0.011199
## At iterate     9  f =       84.619  |proj g|=      0.010868
## At iterate    10  f =       84.619  |proj g|=      0.010266
## At iterate    11  f =       84.619  |proj g|=      0.010313
## At iterate    12  f =       84.619  |proj g|=      0.010365
## At iterate    13  f =       84.619  |proj g|=       0.12548
## At iterate    14  f =       84.619  |proj g|=      0.011356
## At iterate    15  f =       84.619  |proj g|=       0.11497
## At iterate    16  f =       84.619  |proj g|=       0.72646
## At iterate    17  f =       84.618  |proj g|=       0.99579
## At iterate    18  f =       84.617  |proj g|=       0.99583
## At iterate    19  f =       84.613  |proj g|=       0.99566
## At iterate    20  f =       84.611  |proj g|=       0.99622
## At iterate    21  f =       84.602  |proj g|=        0.9959
## At iterate    22  f =        84.57  |proj g|=       0.09139
## At iterate    23  f =       84.538  |proj g|=      0.088209
## At iterate    24  f =       84.521  |proj g|=      0.036953
## At iterate    25  f =       84.515  |proj g|=       0.99543
## At iterate    26  f =       84.513  |proj g|=     0.0046856
## At iterate    27  f =       84.513  |proj g|=      0.019316
## At iterate    28  f =       84.513  |proj g|=    4.4806e-05
## 
## iterations 28
## function evaluations 41
## segments explored during Cauchy searches 29
## BFGS updates skipped 0
## active bounds at final generalized Cauchy point 1
## norm of the final projected gradient 4.48058e-05
## final function value 84.5134
## 
## F = 84.5134
## final  value 84.513444 
## converged
```

```r
kriging_m1
```

```
## 
## Call:
## km(formula = response ~ similar_desired + density, design = lhs_design[, 
##     c(1, 2)], response = lhs_design[, 3], nugget.estim = T)
## 
## Trend  coeff.:
##                   Estimate
##     (Intercept)    81.4726
## similar_desired     0.0737
##         density    -0.2158
## 
## Covar. type  : matern5_2 
## Covar. coeff.:
##                          Estimate
## theta(similar_desired)    11.7281
##         theta(density)   145.7616
## 
## Variance estimate: 286.3421
## 
## Nugget effect estimate: 1.343017
```

The dice kriging command fits a kriging model, so that data point estimates are the sum of a linear trend and deviations from this trend drawn from a Gaussian process.

The trend coefficients are the first elements of the output, and include an intercept and a linear term for each parameter. The output also tells us that the a matern5_2 kernel was used - which defines the shape of the covariance function. Other kernels are available - experiment with them if you wish.  It also gives us the estimates of the correlation parameters (here 'theta'), and the variance and nugget effects. 

The nugget effect here accounts for simulation stochasticity, while the variance parameter refers to input related variance. 

We can make predictions for new values using the predict command. Lets make predictions across the whole parameter space. 


```r
similar_ins<-seq(0,100,2)
densities_ins<-seq(20,95,5)

fullSpace<- data.frame(expand.grid(similar_ins, densities_ins))
dim(fullSpace)
```

```
## [1] 816   2
```

```r
#lots of points!

colnames(fullSpace)<-colnames(lhs_design[,1:2])


predictions<-predict(kriging_m1, fullSpace, "UK")

prediction.surface<-matrix(predictions$mean, 51)

filled.contour(similar_ins, densities_ins, prediction.surface )
```

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

### *Optional Task*
Try constructing the same plot for predictions from the earlier quadratic model using lm.
What do you notice? 


## Gaussian Process Models with GEM-SA
We can also try fitting the same model in the software GEM-SA (with kind thanks to Marc Kennedy for permission).
This is available as a stand-alone application here: [http://ctcd.group.shef.ac.uk/gem.html](http://ctcd.group.shef.ac.uk/gem.html)

To use the software, we first of all need to save our simulation inputs and results in a format that can be read by the software.




```r
#set your working directory somewhere sensible so you can find these files later!
write.table(lhs_design[,1:2], file="inputs.txt",row.names=F, col.names=F)
write.table(lhs_design[,3], file="outputs.txt",row.names=F, col.names=F)
```

Now open GEM-SA. 

1. From the menu, choose the 'Project / new ' option.  

2. Next, in the resulting dialogue box, pick the inputs file you have just saved from the browse menu.  

3. Similarly, browse to your outputs file. Leave predictions blank for the moment.  
![gemsa1](figure/gemsa1.png) 

4. Now, click on the options tab. We have two inputs, so input '2' in the number of inputs box. You can name them appropriately if you wish by pressing the 'Names' button.     

5. Tick the 'code has numerical error' box. In our language, this means that we have a simulation stochasticity, and we want GEM-SA to estimate a nugget term.  

6. Under the Input uncertainty options, check the All unknown, product normal option.
This states that we do not know for certain the true values of the parameters in questions, but we expect them to be jointly normal.  
![gemsa2](figure/gemsa2.png) 

7. Don't worry about the simulations tab - this refers only to the MCMC parameter estimation procedure.  

8. Press OK. You will be prompted to enter prior means and variance for your input variables. Press the 'use default' button to set use empirical estimated parameters based on the input values we have given GEM-SA.  

9. We're ready to go. Press the red play button at the top of the window!  

#Output Analysis
You should be able to see some plots of the main effects for our two variables. 
If you go to the sensitivity analysis tab, you will a variance based sensitivity analysis - this takes into account the non-parametric deviations from the linear trend that were unable to capture with our ANOVA earlier in the workshop.   

In the 'Output summary' tab, you should be able to see the variance (sigma-squared) and nugget parameters, and roughness parameters which we also estimated using DiceKriging.  


At the bottom of the screen, you can also see the mean expected of the simulation output **given the distributions of our inputs**, and the variance of this expectation.
The final value is the total expected variance of the output, again given our input priors.   

## Task
Try changing some of the other options (click on the pen to get back to the options screen). In particular, ask GEM-SA to calculate joint effects, and also attempt to validate the emulator accuracy using leave one out validation - the root mean squared standardised error should ideally be less than two.  

Try examining how changes in the prior distributions impact upon the sensitivity and uncertainty analyses. Does this fit with your expectations?   



# Appendix: Reading and Software

A number of R packages might be able to help you in designing and analysing computer experiments.

##R packages
1. 'lhs':  Provides simple functions to calculate latin hypercube samples. Note that optimumLHS can sometimes be expensive in high dimensions, so the other options are generally best. Augment is also a useful function if you need to add more points eg. for -crossvalidation
2. 'DiceKriging': excellent non-Bayesian computater experiment package
3. 'tgp':  a bit more complex. Fits 'treed' Gaussian process
4. 'BACCO': implementation of Kennedy and O'Hagan's emulator framework. Deterministic models only, so not always useful
5. 'AlgDesign' :  For generating fraction factorials
6. 'rsm' : Response surface methodology package.

##Other Software
1. Gaussian Process Matlab packages : Algorithms relating to the Rasmussen and Williams excellent book on Gaussian Processes for Machine learning. Both book and software available free online here:
[http://www.gaussianprocess.org/](http://www.gaussianprocess.org/)
Cutting edge. 
2. GEM-SA :  Marc Kennedy's stand-alone gui for Gaussian Processes. Works very well, but is opaque and difficult to integrate with R. [http://ctcd.group.shef.ac.uk/gem.html](http://ctcd.group.shef.ac.uk/gem.html)

##Reading

**Managing Uncertainty in Complex Models Toolkit** (2011), MUCM project, [http://mucm.aston.ac.uk/toolkit/index.php?page=MetaHomePage.html](http://mucm.aston.ac.uk/toolkit/index.php?page=MetaHomePage.html) 

**Santer, W., Williams, B, and Notz, W** (2003)  *'Design and Analysis of Computer Experiments'*, Springer  

##Model Citations
Wilensky, U. (1997). NetLogo Segregation model. http://ccl.northwestern.edu/netlogo/models/Segregation. Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

Wilensky, U. (1997). NetLogo Fire model. http://ccl.northwestern.edu/netlogo/models/Fire. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

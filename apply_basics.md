---
title: "apply tutorial"
author: "Jason Hilton"
date: "Tuesday, October 28, 2014"
output: html_document
---
# Apply Tutorial
The apply family of functions in R may not be familiar to all of you, so I include a brief tutorial here as they are used extensively in the tutorial. 

The family of functions is very powerful, and it allows for faster, clearer and  more concise code. 

The basic concept is that we want to avoid the use of for loops, which (in R) are often slow and difficult to understand. 

Instead of iterating through each row or column of an R array or data-frame and doing some operation (like transforming the data) we can instead *apply* a *function* to each row. 



```r
#We have some data.
data<-data.frame(a=seq(1,50), b=runif(50,2,4),c=rnorm(50,1,0.01))

# R has some functions that compute the column and row means

colMeans(data)
```

```
##      a      b      c 
## 25.500  2.929  1.000
```

```r
rowMeans(data)
```

```
##  [1]  1.379  1.795  2.052  2.496  2.967  3.249  3.997  4.085  4.042  4.938
## [11]  4.762  5.110  5.507  5.872  6.417  6.903  7.015  7.237  7.895  7.770
## [21]  8.196  8.883  9.223  9.009  9.506  9.861 10.179 10.643 10.930 11.500
## [31] 11.781 12.104 12.386 12.887 13.025 13.309 13.843 14.133 14.124 14.385
## [41] 15.272 15.173 15.747 15.740 16.316 16.512 17.272 17.224 17.585 18.244
```


Say we want the geometric mean of each row. There isn't a built-in function for this operation, so lets create a function the computes this value

```r
geom_mean<-function(input){
  # geometric mean
  return(exp(sum(log(input)))**(1/length(input)))
}
```

If we just call it on the whole data frame we just get the geometric mean of the all the numbers it contains 

```r
geom_mean(data)
```

```
## [1] 1.382e+29
```

We can however compute the result row by row using for-loops

```r
# test it on one row of the data
geom_mean(data[1,])
```

```
## [1] 1.288
```

```r
row_G_means<-rep(0,dim(data)[1])
for (i in 1:dim(data)[1]){
  row_G_means[i]<-geom_mean(data[i,])
}
```

All this subsetting and indexing is a bit of a pain, however. 
Let's apply our function instead:


```r
# ?apply
# note that for the MARGIN argument, 1 indicates apply to each row, 2 to each column
row_G_means2<- apply(data,MARGIN=1,FUN=geom_mean)

#check we get the same answer
all(row_G_means2==row_G_means)
```

```
## [1] TRUE
```

There are other functions that have similar effects.

##lapply

'lapply'  (List Apply) applies a function to each element of an R list, returning another R list . The margin element is not used here. 
Applied to our data frame, it gives us the geometric column means, as an R data.frame is in essence a list of the columns


```r
lapply(data, geom_mean)
```

```
## $a
## [1] 19.48
## 
## $b
## [1] 2.875
## 
## $c
## [1] 1
```

##sapply

'sapply' (Simplify Apply) does exactly the same thing, except it simplifies the resultant list to an array:

```r
sapply(data, geom_mean)
```

```
##      a      b      c 
## 19.483  2.875  1.000
```

##mapply
Finally, 'mapply' (for 'Multivariate Apply') can be used to apply a function that takes two inputs to two lists or arrays:


```r
ab_func<-function(a,b){
  #an arbitrary, stupid but non-vectorisable function of a and b
  if (b>a){
    return(b)
  }
  else{
    return(a)
  }
}

# note the function comes FIRST in mapply. 
head( mapply(ab_func, data$a, data$b ))
```

```
## [1] 2.139 2.397 3.000 4.000 5.000 6.000
```

```r
# in this example ab_func(data$a,data$b) will not work 
```

## Further information
Note that you can hold some arguments constant while varying others. 

Say we extend our geom_mean function to include an extra argument


```r
geom_mean2<-function(input, constant){
  # geometric mean
  return(constant  * exp(sum(log(input)))**(1/length(input)))
}
```

We can use apply again to but specifiy the value the additional value for all function applications. 

```r
apply(data, 1, geom_mean2, constant=4)
```

```
##  [1]  5.152  6.720  7.450  8.596  9.752 10.185 12.176 11.831 10.725 13.469
## [11] 11.721 12.171 12.750 13.309 14.617 15.577 14.887 14.571 16.538 14.326
## [21] 15.183 17.230 17.602 14.618 15.896 16.249 16.428 17.383 17.270 18.876
## [31] 18.785 18.934 18.771 20.000 19.021 18.950 20.257 20.224 18.131 17.728
## [41] 21.505 18.853 20.808 18.403 20.324 19.534 22.592 20.155 20.571 22.788
```


Similar things are possible with the other apply functions. 
Note things are slightly different for mapply  - you have to give additional arguments in a named list 


```r
ab_func<-function(a,b,c){
  #an arbitrary, stupid but non-vectorisable function of a and b
  if (b>c){
    return(b)
  }
  else{
    return(a)
  }
}

# value of c contained in named list MoreArgs
head( mapply(ab_func, data$a, data$b, MoreArgs=list(c=3)))
```

```
## [1] 1 2 3 4 5 6
```

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
##         a         b         c 
## 25.500000  2.830376  1.001292
```

```r
rowMeans(data)
```

```
##  [1]  1.390386  1.811789  2.383206  2.626644  2.699581  3.330750  3.494236
##  [8]  3.682244  4.612746  4.383784  5.038371  5.245175  5.594291  6.280627
## [15]  6.207642  6.363643  6.759055  7.128455  7.815474  8.073724  8.278047
## [22]  8.394654  8.979113  9.585928  9.460579 10.230332 10.423016 10.499867
## [29] 11.008659 11.528828 11.643062 11.839545 12.119325 12.344263 12.883412
## [36] 13.211873 13.695076 13.939635 14.187302 14.802809 15.164643 15.003288
## [43] 15.574648 15.780193 16.454598 16.846963 16.761773 17.595762 17.374143
## [50] 18.327972
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
## [1] 7.74663e+28
```

We can however compute the result row by row using for-loops

```r
# test it on one row of the data
geom_mean(data[1,])
```

```
## [1] 1.29733
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
## [1] 19.48325
## 
## $b
## [1] 2.774254
## 
## $c
## [1] 1.001242
```

##sapply

'sapply' (Simplify Apply) does exactly the same thing, except it simplifies the resultant list to an array:

```r
sapply(data, geom_mean)
```

```
##         a         b         c 
## 19.483254  2.774254  1.001242
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
## [1] 2.160532 2.448148 3.150345 4.000000 5.000000 6.000000
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

We can use apply again to but specifiy the additional value for all function applications. 

```r
apply(data, 1, geom_mean2, constant=4)
```

```
##  [1]  5.189321  6.763226  8.455015  9.044201  8.754493 10.532441 10.352354
##  [8] 10.179919 13.025236 11.161019 12.983849 12.784276 13.231128 15.110578
## [15] 13.628274 12.901243 13.553669 14.046868 16.207295 16.050093 15.628523
## [22] 14.571821 16.249938 17.916483 15.657719 18.211517 17.816568 16.472634
## [29] 17.749212 19.033449 18.013029 17.237454 17.091651 16.424937 18.122942
## [36] 18.176850 19.409703 18.968674 18.540835 20.600155 20.959102 17.559472
## [43] 19.593278 18.710908 21.318290 21.834882 19.069919 22.548569 18.782262
## [50] 23.346726
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
## [1] 1.000000 2.000000 3.150345 4.000000 5.000000 6.000000
```

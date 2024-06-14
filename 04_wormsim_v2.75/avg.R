
# first we define a pattern (a regular expression) for getting the set of outputfiles

regex = "^examplr7\\.[0-9]{1,2}$"

# ^ means start of line
# [0-9] any digit
# {3} 3 times
# \\. the literal "." in the filename needs to be doubly escaped by backslashes
# $ end of line

# now we can get a list of files

files = dir(pattern=regex)

# the function below reads each individual file into a data frame 
# and stores the sum of the values in the data.frame S and the sum of squares in S2
# see also the R function read.table (read.delim is based on read.table with tab as delimiter, header=T, and a decimal point as decimal symbol)
# Note that we skip the first two lines in each file and then read the header. Make sure the header has one field less than the nr of columns
# to get the years into the row.names of the data.frame!!

S.and.S2.from.file.list = function(file.list,skip){
  n = length(file.list)
  for (i in 1:n){
    df = read.delim(file=file.list[i],skip=skip)
    if (i==1){
      sigma = data.frame(df)
      sigma2= data.frame(df*df)
    }
    else if (i>1){
      sigma = sigma+df
      sigma2= sigma2+df*df
    }
  }
  list(n=n,S=sigma,S2=sigma2)
}

# in the function below we simply calculate mean and sd 
# the default value for sample is TRUE meaning that we calculate sd for a sample of a population

mean.and.sd.from.n.S.S2 = function(n,S,S2,sample=T){ # x is a list of n, S and S2
     m = S/n;
     if (sample)
        denom = n*(n-1)
	else
	  denom = n*n	
     sd   = sqrt((n*S2-S*S)/denom)
     list(mean=m,sd=sd)
}

z = S.and.S2.from.file.list(files,7)
y = mean.and.sd.from.n.S.S2(z$n,z$S,z$S2)

plot(row.names(y$mean),y$mean[,"foi"])
edit(y$mean)
write.table(y$mean,file="avgxxx.txt",sep='\t')
write.table(y$sd,file="sdxxx.txt",sep='\t')


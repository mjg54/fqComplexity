Args=commandArgs(TRUE)
complexity.log = Args[1]

print(complexity.log)
prefix.name = strsplit(complexity.log, "_complexity.log")[[1]][1]
complexity = read.table(complexity.log, header=FALSE)

reads = c(0, complexity[,1][rep(c(TRUE, FALSE), length(complexity[,1])/2)])
unique = c(0, complexity[,1][rep(c(FALSE, TRUE), length(complexity[,1])/2)])
df = as.data.frame(cbind(reads, unique))
asymptotic.model = NLSstAsymptotic(sortedXyData(reads, unique))

asm.depth = nls(df$unique ~ b1*(1-exp(-exp(ln.rate.constant) * df$reads)), 
                start = list(b1 = asymptotic.model[2], ln.rate.constant = asymptotic.model[3]))

b1 = coef(asm.depth)[1]
ln.rate.constant = coef(asm.depth)[2]

read.depth.values = seq(0, 100000000, by = 1000000)
unique.at.10mil = b1*(1-exp(-exp(ln.rate.constant ) * 10000000))

pdf(paste(prefix.name,'_complexity.pdf', sep=''), width=6, height=6, useDingbats=FALSE)
par(pty="s")
plot(unique~reads, df, ylim = c(0,100000000), xlim = c(0,100000000),
     pch = 16, cex = 0.5, ylab = 'Unique', xlab = 'Read Depth', yaxs="i", xaxs="i")

lines(read.depth.values, b1*(1-exp(-exp(ln.rate.constant) * read.depth.values)), col='red')
abline(0, 1, col='blue', lty = 2)

text(1000000, 95000000, bquote('unique at 10 million read depth = '~.(unique.at.10mil)),  pos = 4)
text(1000000, 85000000, bquote('Estimate return of any read_depth'), pos = 4, cex = 0.8)
text(1000000, 80000000, bquote('using this equation and parameters:'), pos = 4, cex = 0.8)
text(1000000, 75000000, bquote('unique = b1*(1-exp(-exp(ln.rate.constant ) * read_depth))'), pos = 4, cex = 0.6)
text(1000000, 70000000, bquote('b1 = '~.(b1)), pos = 4, cex = 0.6)
text(1000000, 65000000, bquote('ln.rate.constant = '~.(ln.rate.constant)), pos = 4, cex = 0.6)

dev.off()

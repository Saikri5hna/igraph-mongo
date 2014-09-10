#install.packages("rmongodb")
#install.packages("plyr")
#we also have the package 'Rmongo' but it doesnt work on mac 
library(rmongodb)
library(plyr)
library(data.table)
library(igraph)

----------------------------------------------------------------------------
        #CONNECTION PART
        
        mongo = mongo.create(host = "localhost")
#outputs TRUE if connected
mongo.is.connected(mongo)

if (mongo.is.connected(mongo) == TRUE) {
        
        mongo.get.database.collections(mongo, "Accern")
        
        count <- mongo.count(mongo, "Accern.garbageForIgraph")
        cat(sprintf("Total documents: %s ",count, "\n"))
        n = 10
        
        if(count < n){
                #you'll get a warning msg here saying -- "In mongo.cursor.to.list(cursor) :This fails for most NoSQL data structures. I am working on a new solution"     
                sampleData <- mongo.find.all(mongo,"Accern.garbageForIgraph" , limit = 20)
                dim(sampleData)        
        }else{
                sampleData <- mongo.find.one(mongo,"Accern.garbageForIgraph")
        }
        
        head(sampleData)
}else{
        writeLines("Connection to database error, check if mongodb is up")
}

#you'll get a warning msg here saying -- "In mongo.cursor.to.list(cursor) :This fails for most NoSQL data structures. I am working on a new solution"     
----------------------------------------------------------------------------
        #CONVERSION PART - BSON to Data Frame
        
        random = data.frame(stringsAsFactors = FALSE)
DBNS = "Accern.garbageForIgraph"
cursor = mongo.find(mongo, DBNS)
i=0
while (mongo.cursor.next(cursor)) {
        # iterate and grab the next record
        tmp = mongo.bson.to.list(mongo.cursor.value(cursor))
        # make it a dataframe
        tmp.df = as.data.frame(t(unlist(tmp)), stringsAsFactors = F)
        # bind to the master dataframe
        random = rbind.fill(random, tmp.df)
        #cat('number of items done', i)
        i = i + 1
}

cat('number of items done', i)

err <- mongo.cursor.destroy(cursor)
dim(random)
class(random)
str(random)
random
random[,3]
#Lets break these into Organisation and events seperately.
orgData <- random[c(2,3,5)]
orgData
eveData <- random[c(2,4,5)]
eveData
________________________________________________________________________________________________________________
class(orgData$volume)
orgData$volume <- as.numeric(as.character(orgData$volume))
expand_row_org<-with(orgData, do.call(rbind, 
                                      Map(cbind.data.frame, article_id=article_id, organizations=strsplit(organizations, ", "), volume=volume)
))
expand_row_org

el_org <- do.call(rbind, Filter(length, lapply(split(expand_row$organizations, expand_row$article_id), function(x) 
        if (length(x)>=2) t(combn(as.character(x),2)) )))
el_org

vx_org <- aggregate(volume~organizations, expand_row_org, sum)
vx_org


gg_org <- graph.edgelist(el_org, FALSE)
V(gg_org)[as.character(vx[,1])]$size <- vx_org[,2]
plot(gg_org)

torange<-function(x, new.min=25, new.max=50) {
        (x-min(x))/diff(range(x)) * (new.max-new.min) + new.min
}    
V(gg_org)$size <- torange(V(gg_org)$size)
plot(gg_org)

________________________________________________________________________________________________________________
class(eveData$volume)
#Expanding the organizations and events column so there is one value per row   
eveData$volume <- as.numeric(as.character(eveData$volume))
expand_row_eve<-with(eveData, do.call(rbind, 
                                      Map(cbind.data.frame, article_id=article_id, events=strsplit(events, ", "), volume=volume)))
expand_row_eve

el_eve <- do.call(rbind, Filter(length, lapply(split(expand_row_eve$events, expand_row_eve$article_id), function(x) 
        if (length(x)>=2) t(combn(as.character(x),2)) )))
el_eve


vx_eve <- aggregate(volume~events, expand_row_eve, sum)
vx_eve
vx_eve$volume
class(vx_eve$volume)


gg_eve <- graph.edgelist(el_eve, FALSE)
V(gg_eve)[as.character(vx_eve[,1])]$size <- vx_eve[,2]
plot(gg_eve)


torange<-function(x, new.min=25, new.max=50) {
        (x-min(x))/diff(range(x)) * (new.max-new.min) + new.min}


V(gg_eve)$size <- torange(V(gg_eve)$size)
plot(gg_eve)


#close connection
mongo.destroy(mongo)
sessionInfo()



# V(gg_eve)$label <- V(camp)$name
# set.seed(42)   ## to make this reproducable
# co <- layout.auto(camp)
# 
# plot(0, type="n", ann=FALSE, axes=FALSE, xlim=extendrange(co[,1]), 
#      ylim=extendrange(co[,2]))
# plot(camp, layout=co, rescale=FALSE, add=TRUE,
#      vertex.shape="rectangle",
#      vertex.size=(strwidth(V(camp)$label) + strwidth("oo")) * 100,
#      vertex.size2=strheight("I") * 2 * 100)









# class(orgData$volume)
#     
# #Expanding the organizations and events column so there is one value per row    
# 
# ddf<-with(orgData, do.call(rbind, 
#                       Map(cbind.data.frame, article_id = article_id, organizations=strsplit(organizations, ", "), volume = volume)
# ))
# ddf
# ddf_eve<-with(eveData, do.call(rbind, 
#                           Map(cbind.data.frame, article_id = article_id, events = strsplit(events, ", "), volume = volume)
# ))
# 
# ddf_eve
# #assemble the edge list based on the article_id group number    
# el <- do.call(rbind, Filter(length, lapply(split(ddf$organizations, ddf$article_id), function(x) 
#     if (length(x)>=2) t(combn(as.character(x),2)) )))
# el
# 
# el_eve <- do.call(rbind, Filter(length, lapply(split(ddf$events, ddf$article_id), function(x) 
#     if (length(x)>=2) t(combn(as.character(x),2)) )))
# el_eve
# 
# #i got an error on the 1st time, the volume is showing 'FACTOR' data type, so just in case doing Extrensic Coersion to make it numeric
# #as.numeric(levels(f))[f] 
# ddf$volume
# class(ddf$volume)
# ddf$volume <- as.numeric(as.character(ddf$volume))
# class(ddf_eve$volume)
# ddf_eve$volume <- as.numeric(as.character(ddf_eve$volume))
# ddf_eve$volume
# 
# vx <- aggregate(volume~organizations, ddf, sum)
# vx
# vx_eve <- aggregate(volume~events, ddf_eve, sum)
# vx_eve
# # Its graph time :) 
# gg <- graph.edgelist(el, FALSE)
# V(gg)[as.character(vx[,1])]$volume <- vx[,2]
# plot(gg)
# 
# gg_eve <- graph.edgelist(el_eve, FALSE)
# V(gg_eve)[as.character(vx_eve[,1])]$volume <- vx_eve[,2]
# plot(gg_eve)
# 
# #re-scale the volumes
# torange<-function(x, new.min=25, new.max=50) {
#     (x-min(x))/diff(range(x)) * (new.max-new.min) + new.min
# }    
# V(gg)$volume <- torange(V(gg)$volume)
# plot(gg)
# V(gg_eve)$voulme <- torange(V(gg_eve)$volume)
# plot(gg_eve)



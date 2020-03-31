allDwTable <-function(DB,pre,count,dbms){
    sqlQuery <- paste0("SELECT TABLE_NAME,COLUMN_NAME,DATA_TYPE,CHARACTER_OCTET_LENGTH FROM @DB.INFORMATION_SCHEMA.COLUMNS WHERE DATA_TYPE = 'varchar' AND CHARACTER_MAXIMUM_LENGTH >= @count AND TABLE_NAME LIKE '@pre%'")
    sqlQuery <- SqlRender::renderSql(sqlQuery,
                                     DB= DB,
                                     pre = pre,
                                     count =count
    )$sql
    sqlQuery <- SqlRender::translateSql(sqlQuery,
                                        targetDialect=dbms)$sql
    minQuery <- DatabaseConnector::dbGetQuery(connection,sqlQuery)

    sqlQuery <- paste0("SELECT obj.name AS TABLE_NAME,MAX(idx.rows) AS COUNT FROM sysindexes idx INNER JOIN sysobjects as obj on (idx.id = obj.id) WHERE (obj.type = 'U') AND obj.name IN (",paste(paste0("'",minQuery$TABLE_NAME,"'"),collapse = ','),")",' group by obj.name')
    CountDwTable <- DatabaseConnector::dbGetQuery(connection,sqlQuery)
    resultTable <- merge(minQuery,CountDwTable,by = 'TABLE_NAME')

    return(resultTable)
}
CountNullFunction <- function(path,table,pre){
  
    LenNullTable <- read.csv(path,row.names = 1)

    table <- cbind(table,LenNullTable)
    table <- cbind(table,data.frame('NOT_NULL_RATIO' = (round(table$notNULL/table$COUNT, 4)*100)))

    return(table)
}
detailsFunction <- function(table,info_db,info_table,prefix,dbms){
  
    sqlQuery <- 'SELECT TABLE_NAME,COMMENTS FROM [@infoDb].[dbo].[@infoTable]'
    sqlQuery <- SqlRender::renderSql(sqlQuery,
                                     infoDb= info_db,
                                     infoTable= info_table
    )$sql
    sqlQuery <- SqlRender::translateSql(sqlQuery,
                                        targetDialect=dbms)$sql

    infoTable <- DatabaseConnector::dbGetQuery(connection,sqlQuery)
    infoTable$TABLE_NAME <- paste0(prefix,infoTable$TABLE_NAME)
    table <- merge(table,infoTable,by.x='TABLE_NAME',by.y='TABLE_NAME')

    return(table)
}

eachTableInfoQuery <- function(resultTable){
    sqlQuery <- paste(paste0("SELECT AVG(CONVERT(BIGINT,DATALENGTH(",resultTable[,2],"))) AS AVGLEN",", COUNT(",resultTable[,2],") AS notNULL FROM ",resultTable[,1]))
    return(sqlQuery)
}

sampleTable <- function(table,col,sample,dbms){
    sqlQuery <- paste0("SELECT TOP @sample '[' + CASE WHEN DATALENGTH(@col) > 100 THEN substring(@col, 1, 100 ) + '..' ELSE @col END+ ']' AS TEXT FROM @table WHERE @col is not null")
    sqlQuery <- SqlRender::renderSql(sqlQuery,
                                     sample = sample,
                                     table= table,
                                     col= col
    )$sql
    sqlQuery <- SqlRender::translateSql(sqlQuery,
                                        targetDialect=dbms)$sql
    sampleTable <- DatabaseConnector::dbGetQuery(connection,sqlQuery)
    # Prevent Hangul from tagging
    sampleTable <- apply(sampleTable,2, function(x) gsub('<[^<>]*>','',x))

    return(sampleTable)
}


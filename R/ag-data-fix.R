### Fixing ag_data()

# response from construct

resp_text = "[[\"<http:a>\",\"<http:hasPredicate>\",\"<http:p>\"],
  [\"<http:b>\",\"<http:hasPredicate>\",\"<http:p>\"]]"
parsed = jsonlite::fromJSON(resp_text,simplifyVector = TRUE)
# parsed is a m nx3 matrix of strings, with 3 columns for subject, predicate, and object.
# check if we have any results:
if(length(parsed[,1])==0) stop("Query did not return any results")
ret = as.data.frame(parsed,stringsAsFactors = FALSE)
colnames(ret) = c("subject", "predicate", "object")


###### the original function definition


ag_data = function(service, url,queryargs,body,returnType = NULL,cleanUp,convert = FALSE){


#  resp = GET(url,authenticate(service$user,service$password),body = eval(body), query = queryargs )

  if (!(http_type(resp) %in% c("application/json","text/plain"))) {
    stop("API did not return proper format", call. = FALSE)
  }

  if (http_error(resp) ) {
    stop(
      print(content(resp)),
      call. = FALSE
    )
  }

  if(grepl("ask",tolower(queryargs$query))){
    return(content(resp))
# new case: a construct query
  } else if (grepl("construct",tolower(queryargs$query))){
    return(content(resp, "text"))
# continue with old code;
  } else if(grepl("describe",tolower(queryargs$query))){
# changing what's shown about a DESCRIBE query
    return(content(resp, "text"))
      # parsed = jsonlite::fromJSON(content(resp,"text"),simplifyVector = TRUE)
      # if(is.integer(mean(unlist(lapply(lapply(parsed,as.list),length))))){
      #   ret = do.call(rbind,parsed)
      #   colnames(ret) = paste0("v",1:ncol(ret))
      # } else{
      #   warning("uneven pattern lengths, can not converge to matrix")
      #   ret = parsed
      #   cleanUp = FALSE
      # }
# continuing with old code from here on
  } else if(http_type(resp) == "application/json"){
      parsed = jsonlite::fromJSON(content(resp,"text"),simplifyVector = TRUE)
      if(length(parsed$values)==0) stop("Query did not return any results")
      if(returnType == "data.table"){
        ret = data.table::as.data.table(parsed$values,col.names = parsed$names)
        colnames(ret) = parsed$names
      } else if(returnType == "dataframe"){
        ret = as.data.frame(parsed$values,stringsAsFactors = FALSE)
        colnames(ret) = parsed$names
      } else if(returnType == "matrix"){
        ret = as.matrix(parsed$values)
        colnames(ret) = parsed$names
      } else{
        ret = parsed$values
      }
  } else if(http_type(resp) == "text/plain"){
      parsed = content(resp,"text")
  }
  if(cleanUp){
    ret = removeXMLSchema(ret,convert = convert)
  }
  structure(
    list(
      return = ret,
      response = resp
    ),
    class = "ag_data"
  )
}

ag_data_new = function(service, url,queryargs,body,returnType = NULL,cleanUp,convert = FALSE){

  resp = GET(url,authenticate(service$user,service$password),body = eval(body), query = queryargs )

  if (!(http_type(resp) %in% c("application/json","text/plain"))) {
    stop("API did not return proper format", call. = FALSE)
  }

  if (http_error(resp) ) {
    stop(
      print(content(resp)),
      call. = FALSE
    )
  }

  if(grepl("ask",tolower(queryargs$query))){
    return(content(resp))
    # new case: a construct query
  } else if (grepl("construct",tolower(queryargs$query))){
    return(content(resp, "text"))
    # continue with old code;
  } else if(grepl("describe",tolower(queryargs$query))){
    # changing what's shown about a DESCRIBE query
    return(content(resp, "text"))
    # parsed = jsonlite::fromJSON(content(resp,"text"),simplifyVector = TRUE)
    # if(is.integer(mean(unlist(lapply(lapply(parsed,as.list),length))))){
    #   ret = do.call(rbind,parsed)
    #   colnames(ret) = paste0("v",1:ncol(ret))
    # } else{
    #   warning("uneven pattern lengths, can not converge to matrix")
    #   ret = parsed
    #   cleanUp = FALSE
    # }
    # continuing with old code from here on
  } else if(http_type(resp) == "application/json"){
    parsed = jsonlite::fromJSON(content(resp,"text"),simplifyVector = TRUE)
    if(length(parsed$values)==0) stop("Query did not return any results")
    if(returnType == "data.table"){
      ret = data.table::as.data.table(parsed$values,col.names = parsed$names)
      colnames(ret) = parsed$names
    } else if(returnType == "dataframe"){
      ret = as.data.frame(parsed$values,stringsAsFactors = FALSE)
      colnames(ret) = parsed$names
    } else if(returnType == "matrix"){
      ret = as.matrix(parsed$values)
      colnames(ret) = parsed$names
    } else{
      ret = parsed$values
    }
  } else if(http_type(resp) == "text/plain"){
    parsed = content(resp,"text")
  }
  if(cleanUp){
    ret = removeXMLSchema(ret,convert = convert)
  }
  structure(
    list(
      return = ret,
      response = resp
    ),
    class = "ag_data"
  )
}

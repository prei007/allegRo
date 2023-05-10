# testing access to one of my repos

library(devtools)
# install_github("prei007/allegRo")

install.packages("~/Documents/misc/r-stuff/allegRo2",
                 repos = NULL,
                 type = "source")

library(allegRo)

url = "http://learn-web.com"
user = "agadmin"
password = "willem01<02"
service = service(url, user, password, testConnection = TRUE)

# connect to compumod repo.

cat = catalog(service, "perei")
rep = repository(cat, "testing")

#Add
addStatement(rep,"<http:a>", "<http:p>", '"a"', "<http:c1>")
addStatement(rep,"<http:b>", "<http:p>", '"b"', "<http:c2>")

# Query
evalQuery(rep,"select ?literals {?s <http:p> ?literals }")


evalQuery(rep, "CONSTRUCT {?a <http:hasPredicate> ?p} WHERE
{?a ?p ?o}")

# On my analysis, this fails in ag_data() because the code there seems to
# expect a very different data format returned in the json file from what is actually
# arriving. In particular, the content(resp) and content(resp, "text")
# show that there are no column names around:
# content(resp, "text") yields:
# [1] "[[\"<http:a>\",\"<http:hasPredicate>\",\"<http:p>\"],[\"<http:b>\",\"<http:hasPredicate>\",\"<http:p>\"]]"
# When parsed, the value of parsed is:
# [,1]       [,2]                  [,3]
# [1,] "<http:a>" "<http:hasPredicate>" "<http:p>"
# [2,] "<http:b>" "<http:hasPredicate>" "<http:p>"
# is.atomic(parsed) and is.matrix(parsed) both return TRUE



evalQuery(rep,
          "PREFIX : <http://example.net/>
          describe ?s {?s ?p ?o}"
)

evalQuery(rep,"ask {?a ?b ?c}")


# ---------------------------
# tests from test-sparql.R against my server



url = "http://learn-web.com"
user = "agadmin"
password = "willem01<02"
service = service(url, user, password, testConnection = TRUE)

  cat = catalog(service,"root")
  createRepository(cat,repo = "testRepo",override = TRUE)
  rep = repository(cat,"testRepo")

  addStatement(rep,"<http:a>", "<http:p>", '"a"', "<http:c1>")
  addStatement(rep,"<http:b>", "<http:p>", '"b"', "<http:c2>")

  #select
evalQuery(rep,"select ?literals {?s <http:p> ?literals }")
evalQuery(rep,"select ?literals {?s <http:p> ?literals }")

  #describe
desc = evalQuery(rep,"describe <http:a>")        #Fails

addStatement(rep,"<http:b>", "<http:p>", '"b"')

evalQuery(rep,"describe ?s {?s ?p ?o}")   # Fails


  #ask
evalQuery(rep,"ask {?a ?b ?c}")    # Returns TRUE
evalQuery(rep,"ask {<http:d> ?b ?c }")    # Returns FALSE

  # close

deleteRepository(cat,"testRepo")

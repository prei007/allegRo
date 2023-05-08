# testing access to one of my repos

library(devtools)
install_github("prei007/allegRo", force=TRUE)

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

# addStatement() works, but will construct statements also work?
# Something like this does not work: .

evalQuery(rep, "INSERT {
  <http:c> <http:p> <http:d> } WHERE {}")

# Error: INAPPROPRIATE REQUEST: SPARQL/Update queries can only be
# performed through POST requests.

# But CONSTRUCT does also not work, I think because of a bug
# in/around the function ag_data() (in file http_class_functions
# see https://www.statology.org/r-error-operator-is-invalid-for-atomic-vectors/
# The error is with parsed$values.
# This would need fixing.
# https://allegro.callisto.calmip.univ-toulouse.fr/doc/sparql-reference.html#SELECT-bindings-and-ASK-results
# I think this is due to changes to R that took place in the meantime.
# The error occurs also with the standard tests, from test0sparql.R, see below



evalQuery(rep, "CONSTRUCT {?a <http:hasPredicate> ?p} WHERE
{?a ?p ?o}", returnType = "dataframe" )

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

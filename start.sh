#!/bin/bash

R -e "pr <- plumber::plumb('statifier.R'); if(Sys.getenv('PORT') == '') Sys.setenv(PORT = 8080); pr\$run(host = '0.0.0.0', port=as.numeric(Sys.getenv('PORT')), swagger = T)"


create_db_connection <- function(env = parent.frame()){

        con <- DBI::dbConnect(odbc::odbc(),
                driver="PostgreSQL Unicode",
                database = "test_postgres12_odbc",
                 server = "db_postgres12_odbc",
                 port = 5432,
                 UID   = "admin",
                 PWD    = "admin"
                 )

        withr::defer({
            vec_ <- DBI::dbListTables(con)
            lapply(vec_, DBI::dbRemoveTable, conn = con)
            DBI::dbDisconnect(con)
        },
        envir = env
        )
        return(con)
}
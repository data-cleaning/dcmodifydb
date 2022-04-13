create_db_connection <- function(env = parent.frame()){

        con_type <-Sys.getenv("CONNECTION_TYPE")
        host <- Sys.getenv("DB_HOST")
        db_name <- Sys.getenv("DB_NAME")
        user <- Sys.getenv("USER")
        password <- Sys.getenv("PASSWORD")
        port <- Sys.getenv("PORT")

        if (con_type == "ssl") {
            con <- create_ssl_connection(host = host, db_name = db_name, user = user, password = password, port = port)
         } else if (con_type == "mssql") {
          driver <- Sys.getenv("DRIVER")
          con <- create_odbc_mssql_connection(host = host, db_name = db_name, user = user, password = password, port = port, driver = driver)
         } else if (con_type == "odbc") {
        driver <- Sys.getenv("DRIVER")
          con <- create_odbc_postgres_connection(host = host, db_name = db_name, user = user, password = password, port = port, driver = driver)
        }


        return(con)
}



create_odbc_postgres_connection <- function(env = parent.frame(),driver , host, db_name, user, password, port) {
       con <-DBI::dbConnect(odbc::odbc(),
                driver=driver,
                server = host,
                database = db_name,
                UID   = user,
                PWD    = password,
                port = port
                )
        withr::defer({
            created_tables <- DBI::dbListTables(con)
            lapply(created_tables, DBI::dbRemoveTable, conn = con)
            DBI::dbDisconnect(con)
        },
        envir = env
        )

        return(con)
}
create_odbc_mssql_connection <- function(env = parent.frame(),driver, host, db_name, user, password, port) {


        full_server <- paste(host, port, sep = ",")

        con <-DBI::dbConnect(odbc::odbc(),
                        Driver=driver,
                        server = host,
                        database = db_name,
                        UID   = user,
                        PWD    = password,
                        trustend_connection = "Yes"
                        )



        return(con)
}


create_ssl_connection <- function(env = parent.frame(), host, db_name, user, password) {
       con <-DBI::dbConnect(RPostgres::Postgres(),
                host = host,
                dbname = db_name,           
                user   = user,
                password = password,
                port = 5432
                 )

        withr::defer({
            vec_ <- DBI::dbListTables(con)
            lapply(created_tables, DBI::dbRemoveTable, conn = con)
            DBI::dbDisconnect(con)
        },
        envir = env
        )


        return(con)
}
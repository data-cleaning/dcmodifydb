
# Small sleep to allow the database to start up
sleep 10 



echo "Hello World!"
echo "I have got the power"

Rscript --no-save run_tests.R

sleep 300000

#rpm -qa | grep -i odbc


#isql -v -k "DRIVER={PostgreSQL Unicode};server=db_postgres12_odbc;database=test_postgres12_odbc;UID=admin;PWD=admin;port=5432"




package main

import (
	"database/sql"
	"rentroll/rlib"
	"flag"
	"fmt"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

// App is the global application structure used for onesite csv importer
var App struct {
	dbdir    *sql.DB  // phonebook db
	dbrr     *sql.DB  // rentroll db
	DBDir    string   // phonebook database
	DBRR     string   // rentroll database
	DBUser   string   // user for all databases
	BID      int64    // Business ID
}

func main() {

	bid := flag.Int64("bid", -1, "ID of the business you want to delete recoreds for")

	flag.Parse()

	if *bid == -1 {
		fmt.Println("Please, provide ID of the business you want to delete records for")
		os.Exit(1)
	}

	App.DBDir = "accord"
	App.DBRR = "rentroll"
	App.DBUser = "ec2-user"
	App.BID = *bid

	var err error

	// DATABASE INITIALIZATION
	rlib.RRReadConfig()

	//----------------------------
	// Open RentRoll database
	//----------------------------
	// s := fmt.Sprintf("%s:@/%s?charset=utf8&parseTime=True", DBUser, DBRR)
	s := rlib.RRGetSQLOpenString(App.DBRR)
	App.dbrr, err = sql.Open("mysql", s)
	if nil != err {
		fmt.Printf("sql.Open for database=%s, dbuser=%s: Error = %v\n", App.DBRR, rlib.AppConfig.RRDbuser, err)
		os.Exit(1)
	}
	defer App.dbrr.Close()
	err = App.dbrr.Ping()
	if nil != err {
		fmt.Printf("DBRR.Ping for database=%s, dbuser=%s: Error = %v\n", App.DBRR, rlib.AppConfig.RRDbuser, err)
		os.Exit(1)
	}

	//----------------------------
	// Open Phonebook database
	//----------------------------
	s = rlib.RRGetSQLOpenString(App.DBDir)
	App.dbdir, err = sql.Open("mysql", s)
	if nil != err {
		fmt.Printf("sql.Open: Error = %v\n", err)
		os.Exit(1)
	}
	err = App.dbdir.Ping()
	if nil != err {
		fmt.Printf("dbdir.Ping: Error = %v\n", err)
		os.Exit(1)
	}

	rlib.RpnInit()
	rlib.InitDBHelpers(App.dbrr, App.dbdir)

	rc, _ := rlib.DeleteBusinessFromDB(App.BID)
	fmt.Println("Deleted Records: ", rc)
}


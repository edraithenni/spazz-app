package controllers

import (
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
	"spazz-app/internal/services"

	_ "github.com/lib/pq"
)

func RememberController(c *gin.Context) {
	dbType, dbPath := services.GetDBCredentials()

	db, err := sql.Open(dbType, dbPath)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	answer := c.Query("answer")
	name := c.Query("name")

	_, err = db.Exec("INSERT INTO talkers (answer, name) VALUES ($1, $2)", answer, name)
	if err != nil {
		panic(err)
	}

	c.String(http.StatusOK, "Got it.\n")
}

func SayController(c *gin.Context) {
	dbType, dbPath := services.GetDBCredentials()

	db, err := sql.Open(dbType, dbPath)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	rows, err := db.Query("SELECT * FROM talkers")
	if err != nil {
		panic(err)
	}
	defer rows.Close()

	count := 0
	for rows.Next() {
		count++
		var id int
		var answer string
		var name string

		err = rows.Scan(&id, &answer, &name)
		if err != nil {
			panic(err)
		}

		c.String(http.StatusOK, answer+", "+name+"!\n")
		break
	}
	if count == 0 {
		c.String(http.StatusOK, "I have nothing to say.\n")
	}
}

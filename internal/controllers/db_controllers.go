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
	
	c.Header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")

	dbType, dbPath := services.GetDBCredentials()

	db, err := sql.Open(dbType, dbPath)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	var id int
	var answer string
	var name string

	err = db.QueryRow("SELECT id, answer, name FROM talkers ORDER BY RANDOM() LIMIT 1").Scan(&id, &answer, &name)
	
	if err == sql.ErrNoRows {
		c.String(http.StatusOK, "I have nothing to say.\n")
		return
	} else if err != nil {
		panic(err)
	}

	c.String(http.StatusOK, answer+", "+name+"!\n")
}


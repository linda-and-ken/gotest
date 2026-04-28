package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/*path", func(c *gin.Context) {
		path := c.Param("path")
		if path == "" {
			path = "/"
		}

		if path == "/aa/bbb" {
			c.String(http.StatusOK, "%s", path)
			return
		}

		c.String(http.StatusOK, "hello , i am linda %s", path)
	})

	addr := ":8080"
	log.Printf("listening on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatal(err)
	}
}

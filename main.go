package main

import (
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/*path", func(c *gin.Context) {
		path := c.Param("path")
		if path == "" {
			path = "/"
		}

		log.Printf("incoming GET %s headers:", path)
		for key, values := range c.Request.Header {
			for _, value := range values {
				log.Printf("header %s: %s", key, value)
			}
		}

		var resp strings.Builder
		resp.WriteString("hello , i am linda ")
		resp.WriteString(path)
		resp.WriteString("\n你本次请求的HTTP header如下:\n")
		for key, values := range c.Request.Header {
			for _, value := range values {
				resp.WriteString(key)
				resp.WriteString(": ")
				resp.WriteString(value)
				resp.WriteString("\n")
			}
		}

		c.String(http.StatusOK, resp.String())
	})

	addr := ":8080"
	log.Printf("listening on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatal(err)
	}
}

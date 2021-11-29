FROM golang:1.17.3 AS BUILD
RUN printf '\n\
package main\n\
\n\
import (\n\
	"log"\n\
	"net/http"\n\
	_ "net/http/pprof"\n\
)\n\
\n\
const (\n\
    serviceAddress string = "0.0.0.0"\n\
    servicePort    string = "8000"\n\
)\n\
func main() {\n\
	http.Handle("/", http.FileServer(http.Dir("/www/")))\n\
    log.Fatalln(http.ListenAndServe(serviceAddress+":"+servicePort, nil))\n\
    }\n\
' >> /go/src/main.go
WORKDIR /go/src
RUN ls
RUN go mod init basic-server
RUN go mod tidy
RUN go build .

FROM ubuntu:20.04
RUN apt-get update && apt-get install -y ca-certificates
COPY *.js *.html *.png *.jpg *.jpeg *.css /www/
COPY --from=BUILD /go/src/basic-server /
ENTRYPOINT ["./basic-server"]


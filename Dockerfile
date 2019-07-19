FROM debian:stretch-slim

RUN apt update && apt install -y wget git make gcc \
  && apt autoclean && apt clean \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz \
  && tar -xvf go1.12.6.linux-amd64.tar.gz \
  && mv go /usr/local/go \
  && mkdir /go

ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/k8s.io/sample-controller
WORKDIR /go/src/k8s.io/sample-controller
RUN CGO_ENABLED=0 GO111MODULE=on go build -gcflags=all='-N -l' -o /foo-controller .

WORKDIR /

RUN go get -u cloud.google.com/go/cmd/go-cloud-debug-agent
COPY source-context.json /source-context.json

CMD ["/go/bin/go-cloud-debug-agent","-sourcecontext=/source-context.json","-appmodule=foo-controller","-appversion=1.0","--","/foo-controller"]

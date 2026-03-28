BINARY := dotctl
CMD := ./cmd/dotctl

.PHONY: build fmt clean

build:
	go build -o $(BINARY) $(CMD)

fmt:
	gofmt -w ./cmd ./internal

clean:
	rm -f $(BINARY)

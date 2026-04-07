# 可通过 build-arg 覆盖基础镜像，便于在国内镜像站拉取（两枚 ARG 须写在首条 FROM 之前，否则后续 FROM 无法解析）
ARG BUILDER_IMAGE=golang:1.24-alpine
ARG RUNTIME_IMAGE=alpine:3.21
FROM ${BUILDER_IMAGE} AS builder

WORKDIR /src

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/server .

FROM ${RUNTIME_IMAGE}

RUN apk add --no-cache ca-certificates

COPY --from=builder /out/server /server

EXPOSE 8080

USER nobody

ENTRYPOINT ["/server"]

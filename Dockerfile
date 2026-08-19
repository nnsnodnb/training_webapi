# hadolint ignore=DL3007
FROM gcr.io/distroless/base-debian13:latest

ARG TARGETARCH

COPY artifacts/${TARGETARCH}/Training /app/Training
COPY Public /app/Public

WORKDIR /app

EXPOSE 8080

ENTRYPOINT ["./Training"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]

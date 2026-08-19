FROM gcr.io/distroless/base-debian13:latest

ARG TARGET_ARCH

COPY artifacts/${TARGET_ARCH}/Training /app/Training
COPY Public /app/Public

WORKDIR /app

EXPOSE 8080

ENTRYPOINT ["./Training"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]

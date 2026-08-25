FROM gcr.io/distroless/base-debian13:nonroot

ARG TARGETARCH

COPY --chmod=755 artifacts/${TARGETARCH}/Training /app/Training
COPY Public /app/Public

WORKDIR /app

EXPOSE 8080

ENTRYPOINT ["./Training"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]

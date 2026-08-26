FROM gcr.io/distroless/base-debian13:nonroot

ARG TARGETARCH

COPY --chmod=755 --chown=nonroot artifacts/${TARGETARCH}/Training /app/Training
COPY --chown=nonroot Public /app/Public

WORKDIR /app

USER nonroot:nonroot

EXPOSE 8080

ENTRYPOINT ["./Training"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]

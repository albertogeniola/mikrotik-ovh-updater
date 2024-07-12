FROM alpine:3.14
COPY --chmod=775 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
FROM ruby:slim-bullseye

COPY entrypoint.sh /entrypoint.sh
COPY actions /actions
ENTRYPOINT ["/entrypoint.sh"]

ARG NAME={{NAME}}
ARG DART_VERSION={{DART_VERSION}}

# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:${DART_VERSION} AS build
ARG NAME
ARG DART_VERSION

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe bin/${NAME}.dart -o bin/${NAME}

# Build minimal serving image from AOT-compiled `/test` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM chainguard/static:latest
ARG NAME

COPY --from=build /runtime/ /
COPY --from=build /app/bin/${NAME} /app/bin/app

CMD ["/app/bin/app"]

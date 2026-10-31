# ---------- BUILD STAGE ----------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY Backend/src/CollegeManagement.API/CollegeManagement.API.csproj ./Backend/src/CollegeManagement.API/
WORKDIR /src/Backend/src/CollegeManagement.API
RUN dotnet restore CollegeManagement.API.csproj

COPY Backend/src/CollegeManagement.API/ ./
RUN dotnet publish CollegeManagement.API.csproj -c Release -o /app/publish --no-restore

# ---------- RUNTIME STAGE ----------
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Native font dependencies used by PDF generation (QuestPDF).
RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig fonts-dejavu-core libfontconfig1 libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .
ENV ASPNETCORE_ENVIRONMENT=Production
EXPOSE 8080

# Render supplies PORT; 8080 is the local/default fallback.
ENTRYPOINT ["sh", "-c", "exec dotnet CollegeManagement.API.dll --urls http://0.0.0.0:${PORT:-8080}"]

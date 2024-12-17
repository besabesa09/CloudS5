# Étape 1: Build avec le SDK .NET
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copier le fichier .csproj
COPY ["CloudS5.csproj", "./"]

# Ajouter les packages nécessaires
RUN dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL \
    && dotnet add package MailKit \
    && dotnet add package Swashbuckle.AspNetCore \
    && dotnet add package Microsoft.EntityFrameworkCore.Tools \
    && dotnet add package Microsoft.Extensions.Configuration.Json \
    && dotnet add package Newtonsoft.Json

# Restaurer les dépendances
RUN dotnet restore "./CloudS5.csproj"

# Copier les fichiers source restants
COPY . .

# Publier l'application en mode Release
RUN dotnet publish "./CloudS5.csproj" -c Release -o /app

# Étape 2: Runtime avec ASP.NET Core
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Copier les fichiers publiés
COPY --from=build /app .

# Configuration des variables d'environnement
ENV ASPNETCORE_ENVIRONMENT=Development
ENV ConnectionStrings__DefaultConnection="Host=postgres;Port=5432;Database=cloudS5;Username=postgres;Password=cloud"

# Configuration SMTP pour MailKit
ENV SMTP__Server="smtp.gmail.com"
ENV SMTP__Port=587
ENV SMTP__Username="rovarazakamanantsoa@gmail.com"
ENV SMTP__Password="yxfc ewzq okek jagv"

# Définir le point d'entrée de l'application
ENTRYPOINT ["dotnet", "CloudS5.dll"]

# Syrx.Npgsql

This project provides Syrx support for Postgres. The overall experience of using [Syrx](https://github.com/Syrx/Syrx) remains the same. The only difference should be during dependency registration. 

## Table of Contents

- [Installation](#installation)
- [Extensions](#extensions)
- [Security](#security)
- [Credits](#credits) 


## Installation 
> [!TIP]
> We recommend installing the Extensions package which includes extension methods for easier configuration. 

|Source|Command|
|--|--|
|.NET CLI|```dotnet add package Syrx.Npgsql.Extensions```
|Package Manager|```Install-Package Syrx.Npgsql.Extensions```
|Package Reference|```<PackageReference Include="Syrx.Npgsql.Extensions" Version="3.0.0" />```|
|Paket CLI|```paket add Syrx.Npgsql.Extensions --version 3.0.0```|

However, if you don't need the configuration options, you can install the standalone package via [nuget](https://www.nuget.org/packages/Syrx.Npgsql/).  

|Source|Command|
|--|--|
|.NET CLI|```dotnet add package Syrx.Npgsql```
|Package Manager|```Install-Package Syrx.Npgsql```
|Package Reference|```<PackageReference Include="Syrx.Npgsql" Version="3.0.0" />```|
|Paket CLI|```paket add Syrx.Npgsql --version 3.0.0```|
## Extensions
The `Syrx.Npgsql.Extensions` package provides dependency injection support via extension methods. 

```csharp
// add a using statement to the top of the file or in a global usings file.
using Syrx.Commanders.Databases.Connectors.Npgsql.Extensions;

public static IServiceCollection Install(this IServiceCollection services)
{
    return services
        .UseSyrx(factory => factory         // inject Syrx
        .UsePostgres(builder => builder        // using the MySql implementation
            .AddConnectionString(/*...*/)   // add/resolve connection string details 
            .AddCommand(/*...*/)            // add/resolve commands for each type/method
            )
        );
}
```

## Security

- Review [SECURITY.md](SECURITY.md) before reporting vulnerabilities.
- Keep secrets in environment variables or a secure secret store.
- In non-debug environments, use `Include Error Detail=false` and `LogParameters=false`.

## Credits
Syrx is inspired by and build on top of [Dapper](https://github.com/DapperLib/Dapper).    
Postgres support is provided by [Npgsql](https://github.com/npgsql/npgsql).

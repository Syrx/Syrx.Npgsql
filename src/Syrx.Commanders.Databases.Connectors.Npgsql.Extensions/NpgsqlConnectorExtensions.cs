namespace Syrx.Commanders.Databases.Connectors.Npgsql.Extensions
{
    /// <summary>
    /// Extension methods to register and configure the PostgreSQL connector and related services.
    /// </summary>
    public static class NpgsqlConnectorExtensions
    {
        /// <summary>
        /// Registers Syrx services configured for PostgreSQL using the provided <paramref name="factory"/>.
        /// </summary>
        /// <param name="builder">The <see cref="SyrxBuilder"/> used to configure Syrx services.</param>
        /// <param name="factory">A configuration action that builds commander settings (connection strings and commands).</param>
        /// <param name="lifetime">The <see cref="ServiceLifetime"/> to use for registered services. Defaults to <see cref="ServiceLifetime.Singleton"/>.</param>
        /// <returns>The same <see cref="SyrxBuilder"/> instance to allow fluent configuration chaining.</returns>
        public static SyrxBuilder UsePostgres(
            this SyrxBuilder builder,
            Action<CommanderSettingsBuilder> factory,
            ServiceLifetime lifetime = ServiceLifetime.Singleton)
        {
            var options = CommanderSettingsBuilderExtensions.Build(factory);
            builder.ServiceCollection
                .AddSingleton<ICommanderSettings, CommanderSettings>(a => options)
                .AddReader(lifetime) // add reader
                .AddPostgres(lifetime) // add connector
                .AddDatabaseCommander(lifetime);

            return builder;
        }

    }
}

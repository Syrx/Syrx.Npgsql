namespace Syrx.Commanders.Databases.Connectors.Npgsql.Extensions
{
    /// <summary>
    /// Helper methods to register PostgreSQL connector services into an <see cref="IServiceCollection"/>.
    /// </summary>
    public static class ServiceCollectionExtensions
    {
        /// <summary>
        /// Registers the <see cref="NpgsqlDatabaseConnector"/> as the implementation for <see cref="IDatabaseConnector"/>.
        /// </summary>
        /// <param name="services">The service collection to modify.</param>
        /// <param name="lifetime">The service lifetime for the registered connector. Defaults to <see cref="ServiceLifetime.Transient"/>.</param>
        /// <returns>The modified <see cref="IServiceCollection"/>.</returns>
        internal static IServiceCollection AddPostgres(this IServiceCollection services, ServiceLifetime lifetime = ServiceLifetime.Transient)
        {
            return services.TryAddToServiceCollection(
                typeof(IDatabaseConnector),
                typeof(NpgsqlDatabaseConnector),
                lifetime);
        }
    }
}

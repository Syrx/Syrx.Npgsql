using Npgsql;
using Syrx.Commanders.Databases.Settings;

namespace Syrx.Commanders.Databases.Connectors.Npgsql
{
    /// <summary>
    /// PostgreSQL implementation of <see cref="IDatabaseConnector"/> for the Syrx framework.
    /// </summary>
    /// <remarks>
    /// This connector delegates connection creation to <see cref="NpgsqlFactory.Instance"/>
    /// and inherits the common behaviour from <see cref="DatabaseConnector"/>.
    /// </remarks>
    public class NpgsqlDatabaseConnector(ICommanderSettings settings) : DatabaseConnector(settings, () => NpgsqlFactory.Instance)
    {
    }
}

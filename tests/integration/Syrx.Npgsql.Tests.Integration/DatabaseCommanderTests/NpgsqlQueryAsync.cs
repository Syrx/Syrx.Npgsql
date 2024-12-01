namespace Syrx.Npgsql.Tests.Integration.DatabaseCommanderTests
{
    [Collection(nameof(NpgsqlFixtureCollection))]
    public class NpgsqlQueryAsync(NpgsqlFixture fixture) : QueryAsync(fixture) { }
}

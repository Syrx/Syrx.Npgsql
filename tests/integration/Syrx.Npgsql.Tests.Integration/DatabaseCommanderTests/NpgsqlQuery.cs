namespace Syrx.Npgsql.Tests.Integration.DatabaseCommanderTests
{
    [Collection(nameof(NpgsqlFixtureCollection))]
    public class NpgsqlQuery(NpgsqlFixture fixture) : Query(fixture) { }
}

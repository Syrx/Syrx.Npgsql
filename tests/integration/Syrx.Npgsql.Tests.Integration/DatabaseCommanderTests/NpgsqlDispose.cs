namespace Syrx.Npgsql.Tests.Integration.DatabaseCommanderTests
{
    [Collection(nameof(NpgsqlFixtureCollection))]
    public class NpgsqlDispose(NpgsqlFixture fixture) : Dispose(fixture) { }
}

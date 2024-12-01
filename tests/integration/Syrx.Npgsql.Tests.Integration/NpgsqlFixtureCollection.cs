namespace Syrx.Npgsql.Tests.Integration
{
    [CollectionDefinition(nameof(NpgsqlFixtureCollection))]
    public class NpgsqlFixtureCollection : ICollectionFixture<NpgsqlFixture> { }
}

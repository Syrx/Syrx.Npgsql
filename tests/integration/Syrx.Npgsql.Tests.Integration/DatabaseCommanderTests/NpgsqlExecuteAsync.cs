using System.Transactions;

namespace Syrx.Npgsql.Tests.Integration.DatabaseCommanderTests
{
    [Collection(nameof(NpgsqlFixtureCollection))]
    public class NpgsqlExecuteAsync(NpgsqlFixture fixture) : ExecuteAsync(fixture) 
    {
        [Theory(Skip = "Not supported by Postgres")]
        [MemberData(nameof(TransactionScopeOptions))] // TransactionScopeOptions is taken from base ExecuteAsync
        public override Task SupportsEnlistingInAmbientTransactions(TransactionScopeOption scopeOption)
        {
            return base.SupportsEnlistingInAmbientTransactions(scopeOption);
        }
    }
}

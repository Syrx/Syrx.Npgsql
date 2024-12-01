using System.Transactions;

namespace Syrx.Npgsql.Tests.Integration.DatabaseCommanderTests
{
    [Collection(nameof(NpgsqlFixtureCollection))]
    public class NpgsqlExecuteAsync(NpgsqlFixture fixture) : ExecuteAsync(fixture) 
    {
        [Theory(Skip = "Not supported by MySQL")]
        [MemberData(nameof(TransactionScopeOptions))] // TransactionScopeOptions is taken from base Exeucte
        public override Task SupportsEnlistingInAmbientTransactions(TransactionScopeOption scopeOption)
        {
            return base.SupportsEnlistingInAmbientTransactions(scopeOption);
        }
    }
}

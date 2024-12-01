using System.Transactions;

namespace Syrx.Npgsql.Tests.Integration.DatabaseCommanderTests
{
    [Collection(nameof(NpgsqlFixtureCollection))]
    public class NpgsqlExecute(NpgsqlFixture fixture) : Execute(fixture) 
    {
        [Theory(Skip = "Not supported by Postgres")]
        [MemberData(nameof(TransactionScopeOptions))] // TransactionScopeOptions is taken from base Execute
        public override void SupportsEnlistingInAmbientTransactions(TransactionScopeOption scopeOption)
        {
            base.SupportsEnlistingInAmbientTransactions(scopeOption);
        }

    }
}

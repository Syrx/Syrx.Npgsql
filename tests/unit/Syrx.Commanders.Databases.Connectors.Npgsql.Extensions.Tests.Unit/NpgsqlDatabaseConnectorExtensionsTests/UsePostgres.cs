namespace Syrx.Commanders.Databases.Connectors.Npgsql.Extensions.Tests.Unit.NpgsqlDatabaseConnectorExtensionsTests
{
    public class UsePostgres
    {
        private IServiceCollection _services;

        public UsePostgres()
        {
            _services = new ServiceCollection();
        }

        [Fact]
        public void Successful()
        {
            _services.UseSyrx(a => a
                .UsePostgres(b => b
                    .AddCommand(c => c
                        .ForType<UsePostgres>(d => d
                            .ForMethod(nameof(Successful), e => e.UseCommandText("test-command").UseConnectionAlias("test-aliase"))))));

            var provider = _services.BuildServiceProvider();
            var connector = provider.GetService<IDatabaseConnector>();
            IsType<NpgsqlDatabaseConnector>(connector);
        }
    }
}

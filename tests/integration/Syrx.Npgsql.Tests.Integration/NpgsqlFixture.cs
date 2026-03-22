namespace Syrx.Npgsql.Tests.Integration
{
    public class NpgsqlFixture : Fixture, IAsyncLifetime
    {
        private readonly PostgreSqlContainer _container;
        private readonly ILogger<NpgsqlFixture> _logger;

        public NpgsqlFixture()
        {
            _logger = LoggerFactory.Create(b => b
                .AddConsole()
                .AddSystemdConsole()
                .AddSimpleConsole()).CreateLogger<NpgsqlFixture>();

            _container = new PostgreSqlBuilder("docker-syrx-postgres-test:latest")
                .WithDatabase("syrx")
                .WithUsername("syrx_user")
                .WithPassword("YourStrong!Passw0rd")
                .WithPortBinding(5432, true)
                .WithWaitStrategy(Wait.ForUnixContainer().UntilInternalTcpPortIsAvailable(5432))
                .WithLogger(_logger)
                .WithStartupCallback((container, token) =>
                {
                    container.Logger.LogInformation(
                        "PostgreSQL test container started: Name={Name}, State={State}, Health={Health}, Image={Image}",
                        container.Name,
                        container.State,
                        container.Health,
                        container.Image.FullName);

                    return Task.CompletedTask;
                }).Build();
        }

        public async Task DisposeAsync()
        {
            await _container.DisposeAsync();
        }

        public async Task InitializeAsync()
        {
            await _container.StartAsync();

            var connectionString = _container.GetConnectionString();
            var alias = "Syrx.Postgres";

            _logger.LogInformation("Initialized PostgreSQL test container connection for alias {Alias}.", alias);

            Install(() => Installer.Install(alias, connectionString));
            Installer.SetupDatabase(base.ResolveCommander<DatabaseBuilder>());

            // set assertion messages for those that change between RDBMS implementations. 
            AssertionMessages.Add<Execute>(nameof(Execute.SupportsTransactionRollback), "22003: value overflows numeric format");
            AssertionMessages.Add<Execute>(nameof(Execute.ExceptionsAreReturnedToCaller), "22012: division by zero");
            AssertionMessages.Add<Execute>(nameof(Execute.SupportsRollbackOnParameterlessCalls), "22012: division by zero");

            AssertionMessages.Add<ExecuteAsync>(nameof(ExecuteAsync.SupportsTransactionRollback), "22003: value overflows numeric format");
            AssertionMessages.Add<ExecuteAsync>(nameof(ExecuteAsync.ExceptionsAreReturnedToCaller), "22012: division by zero");
            AssertionMessages.Add<ExecuteAsync>(nameof(ExecuteAsync.SupportsRollbackOnParameterlessCalls), "22012: division by zero");

            AssertionMessages.Add<Query>(nameof(Query.ExceptionsAreReturnedToCaller), "22012: division by zero");
            AssertionMessages.Add<QueryAsync>(nameof(QueryAsync.ExceptionsAreReturnedToCaller), "22012: division by zero");

            await Task.CompletedTask;
        }

    }
}

namespace Syrx.Npgsql.Tests.Integration
{
    public class NpgsqlFixture : Fixture, IAsyncLifetime
    {
        private readonly PostgreSqlContainer _container;

        public NpgsqlFixture()
        {
            var _logger = LoggerFactory.Create(b => b
                .AddConsole()
                .AddSystemdConsole()
                .AddSimpleConsole()).CreateLogger<NpgsqlFixture>();

            _container = new PostgreSqlBuilder()
                .WithWaitStrategy(Wait.ForUnixContainer().UntilPortIsAvailable(5432))
                .WithReuse(true)
                .WithLogger(_logger)
                .WithStartupCallback((container, token) =>
                {
                    var message = @$"{new string('=', 150)}
Syrx: {nameof(PostgreSqlContainer)} startup callback. Container details:
{new string('=', 150)}
Name ............. : {container.Name}
Id ............... : {container.Id}
State ............ : {container.State}
Health ........... : {container.Health}
CreatedTime ...... : {container.CreatedTime}
StartedTime ...... : {container.StartedTime}
Hostname ......... : {container.Hostname}
Image.Digest ..... : {container.Image.Digest}
Image.FullName ... : {container.Image.FullName}
Image.Registry ... : {container.Image.Registry}
Image.Repository . : {container.Image.Repository}
Image.Tag ........ : {container.Image.Tag}
IpAddress ........ : {container.IpAddress}
MacAddress ....... : {container.MacAddress}
ConnectionString . : {container.GetConnectionString()}
{new string('=', 150)}
";
                    container.Logger.LogInformation(message);
                    return Task.CompletedTask;
                }).Build();

            // start
            _container.StartAsync().Wait();
        }

        public async Task DisposeAsync()
        {
            await Task.Run(() => Console.WriteLine("Done"));
        }

        public async Task InitializeAsync()
        {
            // line up
            var connectionString = _container.GetConnectionString();
            var alias = "Syrx.Sql";

            var provider = Installer.Install(alias, connectionString);

            // call Install() on the base type. 
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

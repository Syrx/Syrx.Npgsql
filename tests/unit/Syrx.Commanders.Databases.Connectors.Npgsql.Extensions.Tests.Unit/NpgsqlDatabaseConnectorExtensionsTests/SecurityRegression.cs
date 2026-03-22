namespace Syrx.Commanders.Databases.Connectors.Npgsql.Extensions.Tests.Unit.NpgsqlDatabaseConnectorExtensionsTests
{
    public class SecurityRegression
    {
        private readonly string[] _documentationPaths;
        private readonly string _fixturePath;
        private readonly Regex _insecurePasswordPattern;

        public SecurityRegression()
        {
            var rootPath = GetRepositoryRootPath();
            _documentationPaths = new[]
            {
                Path.Combine(rootPath, "README.md"),
                Path.Combine(rootPath, ".docs", "overview.md"),
                Path.Combine(rootPath, ".docs", "examples.md"),
                Path.Combine(rootPath, "src", "Syrx.Npgsql", "README.md"),
                Path.Combine(rootPath, "src", "Syrx.Npgsql.Extensions", "README.md"),
                Path.Combine(rootPath, "src", "Syrx.Commanders.Databases.Connectors.Npgsql", "README.md"),
                Path.Combine(rootPath, "src", "Syrx.Commanders.Databases.Connectors.Npgsql.Extensions", "README.md"),
                Path.Combine(rootPath, "tests", "integration", "Syrx.Npgsql.Tests.Integration", "Docker", "README.md")
            };

            _fixturePath = Path.Combine(
                rootPath,
                "tests",
                "integration",
                "Syrx.Npgsql.Tests.Integration",
                "NpgsqlFixture.cs");

            _insecurePasswordPattern = new Regex(
                @"Password\s*=\s*(?!\$\{DB_PASSWORD\}|<your-password>|\{DB_PASSWORD\})([^;\s""\)]+)",
                RegexOptions.IgnoreCase | RegexOptions.Compiled);
        }

        [Fact]
        public void HardcodedPasswordExamplesAreRejected()
        {
            foreach (var path in _documentationPaths)
            {
                var content = File.ReadAllText(path);
                var match = _insecurePasswordPattern.Match(content);
                False(match.Success, $"Insecure password example detected in '{path}'. Matched value: '{match.Value}'.");
            }
        }

        [Fact]
        public void SensitiveLoggingFlagsAreNotEnabledInDocumentation()
        {
            foreach (var path in _documentationPaths)
            {
                var content = File.ReadAllText(path);
                False(
                    content.Contains("Include Error Detail=true", StringComparison.OrdinalIgnoreCase),
                    $"Insecure logging flag found in '{path}': Include Error Detail=true");
                False(
                    content.Contains("LogParameters=true", StringComparison.OrdinalIgnoreCase),
                    $"Insecure logging flag found in '{path}': LogParameters=true");
            }
        }

        [Fact]
        public void FixtureSourceDoesNotContainRawConnectionStringLogging()
        {
            var content = File.ReadAllText(_fixturePath);

            False(
                content.Contains("ConnectionString .", StringComparison.OrdinalIgnoreCase),
                "Fixture source appears to include raw connection string logging output.");
            False(
                content.Contains("startup callback. Container details", StringComparison.OrdinalIgnoreCase),
                "Fixture source appears to include verbose startup callback details that may expose sensitive data.");
        }

        private static string GetRepositoryRootPath()
        {
            var directory = new DirectoryInfo(AppContext.BaseDirectory);

            while (directory != null && !File.Exists(Path.Combine(directory.FullName, "Syrx.Npgsql.sln")))
            {
                directory = directory.Parent;
            }

            NotNull(directory);
            return directory!.FullName;
        }
    }
}
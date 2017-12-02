//  ============================================================================================================================= 
//  author       : david sexton (@sextondjc | sextondjc.com)
//  date         : 2017.09.29 (21:39)
//  modified     : 2017.10.01 (20:41)
//  licence      : This file is subject to the terms and conditions defined in file 'LICENSE.txt', which is part of this source code package.
//  =============================================================================================================================

using System.Data;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using Syrx.Settings.Databases;
using Xunit;
using static Xunit.Assert;

namespace Syrx.Connectors.Databases.Npgsql.Unit.Tests.NpgsqlDatabaseConnectorTests
{
    public class CreateConnection
    {
        private readonly IDatabaseCommanderSettings _settings;
        private readonly IDatabaseConnector _connector;
        public CreateConnection()
        {
            const string settingsFile = "Syrx.Npgsql.Integration.Tests.json";
            _settings = JsonConvert.DeserializeObject<DatabaseCommanderSettings>(File.ReadAllText(settingsFile));

            _connector = new NpgsqlDatabaseConnector(_settings);
        }

        [Fact]
        public void Successfully()
        {
            var setting = _settings.Namespaces.First().Types.First().Commands.First().Value;
            var result = _connector.CreateConnection(setting);
            Equal(ConnectionState.Closed, result.State);
        }
    }
}
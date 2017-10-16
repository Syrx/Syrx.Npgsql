//  ============================================================================================================================= 
//  author       : david sexton (@sextondjc | sextondjc.com)
//  date         : 2017.09.29 (21:39)
//  modified     : 2017.10.01 (20:41)
//  licence      : This file is subject to the terms and conditions defined in file 'LICENSE.txt', which is part of this source code package.
//  =============================================================================================================================

using Npgsql;
using Syrx.Settings.Databases;

namespace Syrx.Connectors.Databases.Npgsql
{
    public class NpgsqlDatabaseConnector : DatabaseConnector
    {
        public NpgsqlDatabaseConnector(IDatabaseCommanderSettings settings)
            : base(settings, () => NpgsqlFactory.Instance)
        {
        }
    }
}
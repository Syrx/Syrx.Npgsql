//  ============================================================================================================================= 
//  author       : david sexton (@sextondjc | sextondjc.com)
//  date         : 2017.09.29 (21:39)
//  modified     : 2017.10.01 (20:41)
//  licence      : This file is subject to the terms and conditions defined in file 'LICENSE.txt', which is part of this source code package.
//  =============================================================================================================================

using System;
using System.Linq;
using Syrx.Tests.Common;

namespace Syrx.Npgsql.Integration.Tests.Setup
{
    public class DatabaseSetup
    {
        private readonly ICommander<DatabaseSetup> _commander;
        private readonly object _lock = new object();

        public DatabaseSetup()
        {
            _commander = CommanderHelper.UseNpgsql<DatabaseSetup>();
        }

        public void Setup(string name = "Syrx")
        {
            Console.WriteLine($"Running environment setup checks against databse '{name}'.");
            if (!DatabaseExists(name))
            {
                Console.WriteLine($"{name} doesn't exist. Attempting to create.");
                CreateDatabase(name);
            }

            if (!TableExists("Poco"))
            {
                Console.WriteLine("Poco table doesn't exist. Attempting to create.");
                CreatePocoTable();
            }
            
            if (IsStale())
            {
                Console.WriteLine("Data in the Poco table is stale. Attempting to refresh.");
                ClearAndPopulate();
            }

            if (!IsConsistent())
            {
                Console.WriteLine("Data in the Poco table is stale. Attempting to refresh.");
                ClearAndPopulate();
            }

            if (!TableExists("DistributedTransaction"))
            {
                Console.WriteLine("DistributedTransaction table doesn't exist. Attempting to create.");
                CreateDistributedTransactionTable();
            }
            
            Console.WriteLine("Finished setting database up. Let the games begin!");
        }

        #region / database /

        private void CreateDatabase(string name = "Syrx")
        {
            // using Query to skip transactionality. 
            _commander.Query<string>(new {name});
            Console.WriteLine($"{name} created!");
        }
        
        private bool DatabaseExists(string name = "Syrx")
        {
            return _commander.Query<bool>(new {name}).SingleOrDefault();
        }
        
        #endregion

        #region / tables / 

        private void CreateDistributedTransactionTable()
        {            
            _commander.Execute<bool>();
        }
        
        private void CreatePocoTable()
        {
            _commander.Execute<bool>();
        }
        
        private bool TableExists(string name)
        {
            return _commander.Query<bool>(new {name}).SingleOrDefault();
        }

        private bool IsStale()
        {
            var modified = _commander.Query<DateTime>().SingleOrDefault();
            return modified.Date != DateTime.UtcNow.Date;
        }

        private bool IsConsistent()
        {
            var result = _commander.Query<int>().SingleOrDefault();
            return result == 150;
        }

        private void ClearAndPopulate()
        {
            // lock until complete
            lock (_lock)
            {
                ClearPocoTable();
                PopulatePocoTable();
            }
        }

        private void ClearPocoTable()
        {
            _commander.Execute<bool>();
        }

        private void PopulatePocoTable()
        {
            // 150 entries, 
            for (var i = 1; i < 151; i++)
            {
                var entry = new
                {
                    Name = i,
                    Value = i + 14,
                    Modified = DateTime.UtcNow
                };

                _commander.Execute(entry);
            }
        }

        #endregion        
    }
}
using Microsoft.Data.SqlClient;
using MPSIP.Application.Interfaces;

namespace MPSIP.Infrastructure.Data;

public class SqlConnectionFactory(string connectionString) : IDbConnectionFactory
{
    public System.Data.IDbConnection Create() => new SqlConnection(connectionString);
}

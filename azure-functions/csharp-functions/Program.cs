using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using FactoryManagementApi.Services;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices((context, services) =>
    {
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();
        
        // 設定値を取得
        var configuration = context.Configuration;
        var cosmosConnectionString = configuration["CosmosDB:ConnectionString"];
        var cosmosDatabaseName = configuration["CosmosDB:DatabaseName"] ?? "FactoryManagementDB";
        
        // Cosmos DB接続情報が設定されている場合は Cosmos DB を使用、そうでなければファイルベースを使用
        if (!string.IsNullOrEmpty(cosmosConnectionString))
        {
            try
            {
                services.AddSingleton<IDataService>(provider => 
                    new CosmosDataService(cosmosConnectionString, cosmosDatabaseName));
                Console.WriteLine("Cosmos DB データサービスを使用します");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Cosmos DB の初期化に失敗したため、ファイルベースサービスを使用します: {ex.Message}");
                services.AddSingleton<IDataService, DataService>();
            }
        }
        else
        {
            Console.WriteLine("Cosmos DB接続情報が設定されていないため、ファイルベースサービスを使用します");
            services.AddSingleton<IDataService, DataService>();
        }
    })
    .Build();

host.Run();
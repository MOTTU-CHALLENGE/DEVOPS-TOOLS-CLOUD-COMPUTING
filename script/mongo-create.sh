az cosmosdb create \
  --name mdb-challenge-mottu \
  --resource-group rg-challenge-mottu \
  --kind MongoDB \
  --locations regionName=canadacentral failoverPriority=0 isZoneRedundant=false \
  --server-version 7.0 \
  --enable-free-tier true \
  --public-network-access ENABLED \
  --disable-key-based-metadata-write-access false \
  --enable-automatic-failover false \
  --enable-analytical-storage false \
  --enable-burst-capacity false

# Esperar uns segundos pro banco ficar pronto 
sleep 15

# az cosmosdb keys list \
#   --name mdb-challenge-mottu \
#   --resource-group rg-challenge-mottu \
#   --type connection-strings


# Criar o database da aplicação
az cosmosdb mongodb database create --name mottuDB \
  --resource-group rg-challenge-mottu

# Criar o usuário da aplicação
az cosmosdb mongodb user definition create --resource-group rg-challenge-mottu --body '{
  "UserName": "mottuser",
  "Password": "mottupass",
  "DatabaseName": "mottuDB",
  "Roles": [
    {
      "Role": "readWrite",
      "Db": "mottuDB"
    }
  ]
}'
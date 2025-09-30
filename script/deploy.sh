# GRUPO DE RECURSOS
export RESOURCE_GROUP_NAME="rg-challenge-mottu"
export LOCATION="canadacentral"

# BANCO DE DADOS
export MYSQL_NAME="mydb-challenge-mottu"
export MONGODB_NAME="mdb-challenge-mottu"
export DATABASE_NAME="mottuDB"
export DATABASE_USER_NAME="mottuser"
export DATABASE_USER_PASSWORD="mottupass"

# WEB APP
export RUNTIME="DOTNETCORE:8.0"
export WEBAPP_NAME="wa-challenge-mottu"
export APP_SERVICE_PLAN="CmApiMvc"
export GITHUB_REPO_NAME="MOTTU-CHALLENGE/ADVANCED-BUSINESS-DEVELOPMENT-WITH-.NET"
export BRANCH="main"
export APP_INSIGHTS_NAME="ai-challenge-mottu"

#RESOUCE GROUP
az group create -l $LOCATION -n $RESOURCE_GROUP_NAME

# MYSQL
az mysql flexible-server create \
  --accelerated-logs Disabled \
  --admin-user $DATABASE_USER_NAME \
  --admin-password $DATABASE_USER_PASSWORD \
  --auto-scale-iops Disabled \
  --backup-retention 7 \
  --database-name $DATABASE_NAME \
  --geo-redundant-backup Disabled \
  --high-availability Disabled \
  --iops 396 \
  --location $LOCATION \
  --name $MYSQL_NAME \
  --public-access 0.0.0.0 \
  --resource-group $RESOURCE_GROUP_NAME \
  --sku-name Standard_B1ms \
  --storage-auto-grow Disabled \
  --storage-size 32 \
  --tier Burstable \
  --version 8.0.21 \
  --yes

# Esperar uns segundos pro banco ficar pronto 
sleep 10

# MONGODB
az cosmosdb create \
  --name $MONGODB_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --kind MongoDB \
  --locations regionName=$LOCATION failoverPriority=0 isZoneRedundant=false \
  --server-version 7.0 \
  --enable-free-tier true \
  --public-network-access ENABLED \
  --disable-key-based-metadata-write-access false \
  --enable-automatic-failover false \
  --enable-analytical-storage false \
  --enable-burst-capacity false

# Esperar uns segundos pro banco ficar pronto 
sleep 10

# Criar o database da aplicação
az cosmosdb mongodb database create \
  --account-name $MONGODB_NAME \
  --name $DATABASE_NAME \
  --resource-group $RESOURCE_GROUP_NAME

# Criar o usuário da aplicação
az cosmosdb mongodb user definition create \
  --account-name $MONGODB_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --body "{
    \"Id\": \"$DATABASE_NAME.$DATABASE_USER_NAME\",
    \"UserName\": \"$DATABASE_USER_NAME\",
    \"Password\": \"$DATABASE_USER_PASSWORD\",
    \"DatabaseName\": \"$DATABASE_NAME\",
    \"Roles\": [
      {
        \"Role\": \"readWrite\",
        \"Db\": \"$DATABASE_NAME\"
      }
    ]
  }"


# Recuperar connection string do CosmosDB
MONGODB_URI=$(az cosmosdb keys list \
  --name $MONGODB_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --type connection-strings \
  --query "connectionStrings[0].connectionString" \
  --output tsv)

# Ajustar para usar o usuário custom
MONGODB_URI=$(echo $MONGODB_URI | sed "s/<username>:<password>/$DATABASE_USER_NAME:$DATABASE_USER_PASSWORD/")

# Criar Application Insights
az monitor app-insights component create \
  --app "$APP_INSIGHTS_NAME" \
  --location "$LOCATION" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --application-type web

# Criar plano de serviço
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku F1 \
  --is-linux

# Criar o WebApp
az webapp create \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --plan $APP_SERVICE_PLAN \
  --runtime $RUNTIME

# Habilita a autenticação Básica (SCM)
az resource update \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --namespace Microsoft.Web \
  --resource-type basicPublishingCredentialsPolicies \
  --name scm \
  --parent sites/"$WEBAPP_NAME" \
  --set properties.allow=true

# Recuperar a String de Conexão do Application Insights
CONNECTION_STRING=$(az monitor app-insights component show \
  --app "$APP_INSIGHTS_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --query connectionString \
  --output tsv)

# Configurar appsettings
az webapp config appsettings set \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --settings \
    APPLICATIONINSIGHTS_CONNECTION_STRING="$CONNECTION_STRING" \
    ApplicationInsightsAgent_EXTENSION_VERSION="~3" \
    XDT_MicrosoftApplicationInsights_Mode="Recommended" \
    XDT_MicrosoftApplicationInsights_PreemptSdk="1" \
    MYSQL_CONNECTION="Server=$MYSQL_NAME.mysql.database.azure.com;Database=$DATABASE_NAME;User ID=$DATABASE_USER_NAME;Password=$DATABASE_USER_PASSWORD;SslMode=Required;" \
    MONGODB_URI="$MONGODB_URI"

# Reiniciar o Web App
az webapp restart \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME"

# Criar a conexão do nosso Web App com o Application Insights
az monitor app-insights component connect-webapp \
  --app "$APP_INSIGHTS_NAME" \
  --web-app "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME"

# Configurar GitHub Actions para Build e Deploy automático
az webapp deployment github-actions add \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --repo "$GITHUB_REPO_NAME" \
  --branch "$BRANCH" \
  --login-with-github


echo "-----------------------------------------"
echo "DEPLOY FINALIZADO COM SUCESSO"
echo "WebApp: https://$WEBAPP_NAME.azurewebsites.net"
echo "-----------------------------------------"

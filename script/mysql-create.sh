az mysql flexible-server create \
  --accelerated-logs Disabled \
  --admin-user franadmin \
  --admin-password '367!Casul' \
  --auto-scale-iops Disabled \
  --backup-retention 7 \
  --database-name mottuDB \
  --geo-redundant-backup Disabled \
  --high-availability Disabled \
  --iops 396 \
  --location canadacentral \
  --name mydb-challenge-mottu \
  --public-access 0.0.0.0 \
  --resource-group rg-challenge-mottu \
  --sku-name Standard_B1ms \
  --storage-auto-grow Disabled \
  --storage-size 32 \
  --tier Burstable \
  --version 8.0.21 \
  --yes

# Esperar uns segundos pro banco ficar pronto 
sleep 15

# Criar o usuário da aplicação via comando inline SQL
mysql -h mydb-challenge-mottu.mysql.database.azure.com \
      -u franadmin@mydb-challenge-mottu \
      -p'367!Casul' \
      -D mottuDB \
      -e "CREATE USER 'mottuser'@'%' IDENTIFIED BY 'mottupass';
          GRANT CREATE, SELECT, INSERT, UPDATE, DELETE ON mottuDB.* TO 'mottuser'@'%';
          FLUSH PRIVILEGES;"
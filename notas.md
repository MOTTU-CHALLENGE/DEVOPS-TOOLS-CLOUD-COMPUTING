name: 'Build and deploy ASP.Net Core app to Azure Web App: wa-challenge-mottu'

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    env:
      MYSQL_CONNECTION: ${{ secrets.MYSQL_CONNECTION }}
      MONGODB_URI: ${{ secrets.MONGODB_URI }}

    steps:
      - uses: actions/checkout@v2

      - name: Set up .NET Core
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: '8.x'

      - name: Restore dependencies
        run: dotnet restore CM-API-MVC/CM-API-MVC.csproj

      - name: Build with dotnet
        run: dotnet build CM-API-MVC/CM-API-MVC.csproj --configuration Release

      - name: dotnet publish
        run: dotnet publish CM-API-MVC/CM-API-MVC.csproj -c Release -o ${{env.DOTNET_ROOT}}/myapp 

      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with: 
          app-name: 'wa-challenge-mottu'
          slot-name: 'production'
          publish-profile: ${{ secrets.AzureAppService_PublishProfile_59420b678f4b4c8da677e496c7ba4471 }}
          package: ${{env.DOTNET_ROOT}}/myapp




### Nesta Sprint, sua equipe deve implementar uma solução baseada em uma das disciplinas a seguir:

- JAVA ADVANCED OU
- ADVANCED BUSINESS DEVELOPMENT WITH .NET
  A solução deve ser implementada junto com um banco de dados na nuvem.
  Escolha uma das opções abaixo:
  Opção 1: ACR + ACI
  Utilize Azure Container Registry (ACR) para armazenar sua imagem Docker e Azure Container Instance (ACI)
  para executar o container. Ambos devem ser utilizados.
  Opção 2: Serviço de Aplicativo (App Service)
  Publique sua aplicação em um App Service na Azure (modelo PaaS), com o banco de dados também na nuvem.

### Sua entrega deve conter os itens abaixo, independentemente da opção escolhida:

1. Descrição da Solução: explique brevemente o que a aplicação faz.
2. Descrição dos Benefícios para o Negócio: explique quais problemas a solução resolve ou quais melhorias ela traz.
3. Banco de Dados em Nuvem (obrigatório):
   - Não serão aceitos: H2 e Oracle na nuvem da FIAP.
   - Serão aceitos Bancos em Containers na nuvem ou Bancos com serviços de PaaS. Por exemplo: Oracle
     (Container em Nuvem, OCI), MySQL, Azure SQL (Azure PaaS), PostgreSQL, MongoDB etc.
4. Implementar um CRUD completo (Inclusão, Alteração, Exclusão e Consulta) sobre ao menos uma tabela da
   aplicação.
5. Inserir e manipular pelo menos 2 registros reais nessa tabela.
6. Código-fonte publicado no GitHub.
7. Arquivo PDF contendo:
   - Nome completo e RM de todos os integrantes
   - Link do repositório no GitHub
     Requisitos Obrigatório
   - Link do vídeo no YouTube

### Requisitos Obrigatório

8. Se escolher ACR + ACI:
   8.1. Use apenas imagens oficiais do Docker Hub ou de provedores confiáveis (Azure, OCI, AWS etc)
   8.2. O container não pode rodar como root ou admin (com privilégios administrativos)
   8.3. Pode usar Dockerfile ou Docker Compose
   8.4. Entregue todos os scripts do build e execução da imagem, como: Dockerfile, docker-compose.yml (se for o caso),
   Comandos utilizados: docker build, docker push, docker run etc.
9. Se escolher Serviço de Aplicativo (App Service):
   9.1. Todos os recursos (App e Banco de Dados) devem ser criados via Azure CLI
   9.2. Entregue todos os scripts dos recursos criados na Azure, como: Grupo de recurso, Plano do serviço, Serviço de
   aplicativo, Banco de dados e Configurações adicionais.
   Requisitos Específicos Por Tipo De Entrega

10. Desenho da arquitetura da solução proposta com fluxos, recursos e explicação do funcionamento, baseado na
    disciplina de DevOps Tools e Cloud Computing (até 10 pontos).
11. DDL das tabelas (tabelas, colunas, chave primária, comentários etc) criado em arquivo de texto separado
    somente com esse DDL com o nome: script_bd.sql com estrutura e comentários (até 10 pontos).
12. Repositório no GitHub separado (crie um repositório para a entrega da disciplina DevOps Tools e Cloud
    Computing), com tudo que é necessário para a execução do projeto e README.md explicativo (com passo a
    passo para realizar o deploy e testes, incluindo os scripts de testes efetuados (POST/PUT em JSON, se for API)
    (até 10 pontos).
13. Vídeo Demonstrativo da Solução – (até 70 pontos):
    Gravar um vídeo (mínimo 720p, com áudio claro e explicação por voz, sem uso de legendas nessa entrega)
    mostrando todo o funcionamento da solução, incluindo:
    - Clone do repositório no GitHub
    - Deploy da aplicação seguindo exatamente os passos descritos no README.md
    - Criação, configuração e testes do App e do Banco de Dados na nuvem
      Critérios de Avaliação (Pontuação)

### Critérios de Avaliação (Pontuação)

14. Demonstração detalhada e individual de todas as operações do CRUD diretamente no Banco de Dados:
    Inserção de um registro → exibir no banco
    Atualização do registro → exibir no banco
    Exclusão do registro → exibir no banco
    Consulta de registros
    Evidenciar claramente a integração total entre o App e o Banco em nuvem, com tudo funcionando 100%
    Observações:
    Não há limite de tempo para o vídeo, mas evite excesso de duração.
    A apresentação deve ser clara, organizada e completa, evidenciando todas as etapas do processo.
    Critérios de Avaliação (Pontuação)
    Critérios de Avaliação (Pontuação)
    Sem item 1 (descrição da solução): -10 pontos
    Sem item 2 (benefício para o negócio): -10 pontos
    Sem um dos itens obrigatório 3, 4 ou 5: -40 pontos
    Sem repositório separado da disciplina: -10 pontos
    Sem código-fonte (item 6): -40 pontos
    Sem o PDF com nome/RM e links (item 7): Nota Z

# Atividade Prática — Docker + Compose + CI

**Curso:** Desenvolvimento Fullstack  
**Módulo:** Módulo 11 - DevOps  
**Professor:** Virgílio Borges  

---

## 🚀 Sobre o Projeto
Este repositório contém a conteinerização e automação de CI/CD para a aplicação *getting-started-app* (gerenciador de tarefas To-Do em Node.js) utilizando **Docker**, **Docker Compose** e **GitHub Actions**.

---

## 📸 Evidências e Telas

### Parte 1 — Dockerfile Multi-Stage
> **Por que o Multi-Stage ajuda no tamanho e na segurança da imagem final?**  
> O multi-stage build permite separar o ambiente de compilação/instalação de dependências do ambiente de execução final. Isso resulta em uma imagem significativamente menor (removendo compiladores e arquivos temporários de build) e mais segura, reduzindo a superfície de ataque ao manter apenas o estritamente necessário para rodar o app e utilizando um usuário não-root.

* **Tamanho da Imagem e Build:**
  ![Docker Build e Tamanho da Imagem](docs/imagens/01-docker-build-images.png)

* **Aplicação rodando no navegador:**
  ![App rodando](docs/imagens/02-app-rodando.png)

---

### Parte 2 — Volume e Persistência

* **Perda de dados (Sem Volume):**  
  Quando o container é destruído e recriado sem volume, o banco SQLite local `/etc/todos/todo.db` é descartado junto com o container.
  ![Sem Volume](docs/imagens/03-sem-volume.png)

* **Persistência de dados (Com Volume):**  
  Com o volume nomeado `todo-db` montado em `/etc/todos`, os dados persistem mesmo após recriar o container.
  ![Com Volume](docs/imagens/04-com-volume.png)

---

### Parte 3 — Rede entre Containers

* **Inspeção da Rede (`docker network inspect todo-net`):**
  ![Rede Inspect](docs/imagens/05-network-inspect.png)

> **Por que o app consegue chamar o host `mysql` sem saber o IP dele?**  
> O Docker possui um servidor DNS interno integrado que resolve automaticamente o nome do serviço ou alias da rede (`mysql`) para o endereço IP interno do container correspondente.

---

### Parte 4 — Docker Compose

* **Serviços rodando (`docker compose ps`):**
  ![Docker Compose PS](docs/imagens/07-compose-ps.png)

> **Diferença entre `docker compose down` e `docker compose down -v`:**  
> O `docker compose down` para e remove os containers e redes da stack, preservando os volumes montados. Já o `docker compose down -v` remove também os volumes nomeados, apagando todos os dados persistidos do banco.

---

### Parte 5 e 6 — CI com GitHub Actions e Quebra Proposital

* **Execução do CI com Sucesso (Verde):**
  ![GitHub Actions Verde](docs/imagens/08-ci-verde.png)

* **Execução do CI com Falha Intencional (Vermelha) + Log do Erro:**
  ![GitHub Actions Vermelho](docs/imagens/09-ci-vermelho.png)
  

> **Relatório da Quebra Proposital do CI:**  
> **O que foi quebrado:** Alterada a URL do *smoke test* de `/items` para uma rota inexistente `/itemsss` no arquivo `ci.yml`.  
> **Como o CI reagiu:** A etapa *Smoke test do CRUD* falhou ao tentar executar o `curl`, pois a API retornou erro HTTP (404 Not Found), interrompendo a execução do workflow e disparando a exibição dos logs do Compose.  
> **Como o problema foi identificado:** Através dos logs do job no GitHub Actions, que mostraram a falha do comando `curl` ao tentar acessar a rota alterada `/itemsss`.

---

## 🛠️ Relatório de Execução: Acertos, Erros e Dificuldades

### Parte 1 — Dockerfile Multi-Stage
* **Acertos:** Configuração adequada do isolamento de camadas mantendo o `package.json` separado para otimizar o cache de build.
* **Dificuldades/Erros:** Garantir que as permissões de usuário não-root fossem aplicadas corretamente nos diretórios de trabalho sem quebrar a execução do Node.js.

### Parte 2 — Volume e Persistência
* **Acertos:** Verificação clara do comportamento do SQLite ao destruir containers avulsos com e sem binding de volumes nomeados.
* **Dificuldades/Erros:** Certificar-se de limpar containers antigos antes de subir novas instâncias sob a mesma porta `3000`.

### Parte 3 — Rede entre Containers
* **Acertos:** Conexão bem-sucedida entre o app e o MySQL na mesma rede bridge customizada usando aliases DNS.
* **Dificuldades/Erros:** Aguardar a inicialização completa das tabelas do MySQL antes de tentar conectar a aplicação Node.js.

### Parte 4 — Docker Compose
* **Acertos:** Criação de uma stack declarativa com `healthcheck` no banco de dados e dependência condicional (`service_healthy`) no container do aplicativo.
* **Dificuldades/Erros:** Mapeamento correto do arquivo `.env` para evitar expor senhas em texto puro no repositório.

### Parte 5 & 6 — CI com GitHub Actions
* **Acertos:** Implementação completa da esteira de automação (validação de sintaxe, build, inicialização da stack, smoke test via `curl` e encerramento limpo da stack).
* **Dificuldades/Erros:** Ajustar o *loop* de espera (`sleep`) na etapa de aquecimento para garantir que o container estivesse 100% pronto antes da execução do *smoke test*.

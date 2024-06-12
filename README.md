<p align="center">
  <div align="center"><img src="./img/cover.png"></div>
</p>

## 💻 Projeto - FINALIZADO ✌️

DEMO com integração com a EVOLUTION API

sobre o projeto: https://github.com/EvolutionAPI/evolution-api

## Run Locally

Clone this project, you'll also need the backend: https://github.com/babingthon/EvolutionAPI_Delphi.git

```bash
  git clone https://github.com/babingthon/EvolutionAPI_Delphi.git
```

Você precisa instalar o servidor do Evolution API. Instale o Docker e depois rode o comando abaixo;

```bash
  docker run --name evolution-api --detach  -p 8080:8080 -e AUTHENTICATION_API_KEY="SUA_CHAVE" atendai/evolution-api node ./dist/src/main.js
```
Depois inicialize o servidor.

Go to the project directory

```bash
  cd EvolutionAPI_Delphi
```

## Enjoy!

<br />

<!--END_SECTION:footer-->

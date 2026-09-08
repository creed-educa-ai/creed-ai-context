# Mock do contrato da CREED-23

Um servidor HTTP de verdade servindo o contrato de
[`../contrato-api.md`](../contrato-api.md): status reais, corpos reais, aparecendo na aba
Network do DevTools.

**Para quem desenvolve o front, é uma URL.** Não há nada para instalar, subir ou rodar —
o endereço existe, você aponta o front para ele. O resto deste documento é para quem
*mantém* o mock.

Quem serve é o [Prism](https://github.com/stoplightio/prism), lendo
[`openapi.yaml`](openapi.yaml). **Um arquivo só é o contrato** — não existe segunda cópia
dele em lugar nenhum para divergir.

## Os arquivos

| Arquivo | O que é |
|---|---|
| [`openapi.yaml`](openapi.yaml) | **o contrato.** Fonte de tudo o mais nesta pasta |
| [`payloads.json`](payloads.json) | os mesmos exemplos em JSON puro, para consulta e para colar em teste. Anexado ao épico no ClickUp |
| [`gerar_payloads.py`](gerar_payloads.py) | gera o `payloads.json` a partir do `openapi.yaml` |
| [`docker-compose.yml`](docker-compose.yml) | sobe o mock local sem Node |

O `payloads.json` é **derivado**: mexeu no `openapi.yaml`, rode `python gerar_payloads.py`
e nunca edite o JSON à mão — é assim que ele não vira uma segunda versão do contrato.

---

# Para o front: só a URL

Uma linha no `src/lib/apiClient.ts` do `creed-frontend`, feita **uma vez**:

```diff
-const BASE_URL = '/api/v1';
+const BASE_URL = import.meta.env.VITE_API_BASE_URL ?? '/api/v1';
```

E o endereço no `.env.local` de cada um — arquivo que o git ignora, então a URL do mock
nunca entra em commit:

```
VITE_API_BASE_URL=https://<endereco-do-mock>/api/v1
```

Acabou. Sem proxy, sem Docker, sem Node, sem `if (mock)` no código. **CORS já vem
resolvido**: o Prism responde `Access-Control-Allow-Origin` e o preflight sozinho, então
a chamada direta do browser para o domínio do mock funciona.

Quando o backend existir, apaga a linha do `.env.local` e o front volta sozinho para
`/api/v1` atrás do proxy do Vite, sem tocar em código.

## Escolher a resposta: o cabeçalho `Prefer`

É o que faz o mock valer a pena, e funciona igual na URL online. Cada pessoa escolhe
**qual** resposta quer, por requisição, sem tocar no contrato nem atrapalhar o resto do
time:

| Quero testar | Cabeçalho |
|---|---|
| o caminho feliz | nenhum — vem o primeiro exemplo |
| a tela como `gestor` (ou `admin`, `respondente`) | `Prefer: example=gestor` |
| credencial inválida | `Prefer: code=401` |
| primeiro acesso, senha a definir | `Prefer: code=409` |
| acesso negado, sem deslogar | `Prefer: code=403` |
| Keycloak fora do ar | `Prefer: code=503` |
| lista vazia | `Prefer: example=vazia` |
| um caso específico de um status | `Prefer: code=401, example=usuario_inativo` |

```bash
curl -i -X POST https://<endereco-do-mock>/api/v1/authentication/login \
  -H 'Content-Type: application/json' \
  -H 'Prefer: code=409' \
  -d '{"email":"joao.pereira@aurora.test","password":"Provisoria-2026"}'
```

No front, dá para pendurar isso num campo do DevTools ou num `localStorage` lido pelo
`apiClient` em desenvolvimento — mas **isso é andaime**: não deixe o `Prefer` sobreviver
até o PR.

Os nomes de exemplo de cada rota estão no `openapi.yaml`, sob `examples:`, e no
`payloads.json`.

## O mock cobra o contrato de volta

Payload errado não passa. Isto:

```bash
curl -X POST https://<endereco-do-mock>/api/v1/authentication/login \
  -H 'Content-Type: application/json' -d '{"email":"nao-e-email","senha":"errado"}'
```

responde **422**, na forma que o FastAPI responderia. É o comportamento certo:
[`conventions/contrato-front-back.md`](../../../conventions/contrato-front-back.md) diz
que 422 em desenvolvimento **é bug do front** — o contrato foi transcrito errado. O mock
faz esse erro aparecer no dia em que ele é escrito, e não no dia em que o backend sobe.

Rota autenticada sem `Authorization` responde **401** sem ninguém configurar nada: o
Prism lê o `security` do OpenAPI.

## O que o mock NÃO faz

Diga isto ao time antes que alguém perca uma tarde:

- **Não guarda estado.** O `access_token` que ele devolve no login não é aceito por ele
  depois — qualquer string serve como Bearer, e nenhuma é conferida. O fluxo
  *login → usar o token → expirar → renovar* só fecha de verdade contra o backend da
  entrega 4.
- **Não correlaciona requisições.** `POST /users` não faz o usuário aparecer no
  `GET /users` seguinte.
- **O corpo do 422 é o exemplo declarado**, não uma análise do que você mandou de errado.
  O status é real; a lista de campos é fixa.
- **Não valida papel.** `Prefer: code=403` é como se testa "acesso negado" — o mock não
  sabe que papel você tem, porque não sabe quem você é.

Nada disso é defeito do Prism: é a diferença entre *contrato* e *implementação*. O mock
prova que as duas pontas concordam na forma. Quem prova o comportamento é o backend, e
depois dele este diretório inteiro pode ser apagado.

---

# Para quem mantém: como o endereço existe

Duas coisas, **uma vez, por uma pessoa**. Depois disso ninguém mais toca nisso.

### 1. O `openapi.yaml` na `main`

`creed-ai-context` é repositório público, então o arquivo ganha URL própria:

```
https://raw.githubusercontent.com/creed-educa-ai/creed-ai-context/main/tarefas/86e348g6u-autenticacao-da-plataforma/mock/openapi.yaml
```

### 2. Um serviço de container apontando para ela

Sem repositório de deploy, sem Dockerfile, sem build, sem pipeline — é a imagem oficial
do Prism e um comando. **Recomendado: Render**, no plano gratuito.

1. Conta em <https://render.com> (gratuita, plano *Hobby*).
2. **New → Web Service → Existing Image**.
3. Imagem: `stoplight/prism:5`
4. Comando (sobrescrevendo o do container):
   ```
   mock --host 0.0.0.0 --port $PORT https://raw.githubusercontent.com/creed-educa-ai/creed-ai-context/main/tarefas/86e348g6u-autenticacao-da-plataforma/mock/openapi.yaml
   ```
5. Instance type: **Free**.
6. Sai uma URL `https://<nome>.onrender.com`. É ela que vai para o `.env.local` do time,
   com `/api/v1` no fim.

**O preço do plano gratuito, dito antes de doer:** o Render derruba um serviço Free
depois de **15 minutos sem requisição**, e ele leva **cerca de 1 minuto** para voltar. Na
prática: a primeira chamada do dia trava, e depois disso fica quente enquanto se trabalha.
São 750 horas de instância grátis por mês — dá para um serviço ficar de pé o mês inteiro,
se alguém quiser pendurar um ping a cada 10 minutos para ele não dormir. Aí some a
espera, e some também a folga da cota.

*Descartado: Koyeb.* O plano gratuito dele é de **5 horas por mês** e também escala a
zero — acaba antes da primeira semana. Fly e Railway pedem cartão. Qualquer host que rode
imagem de container serve; os três campos acima são os mesmos em todos.

O contrato **não é copiado** para o host: ele é lido do repositório a cada boot.
Atualizar o mock passa a ser *merge na `main` + restart do serviço*, e não existe versão
do contrato em lugar nenhum que possa divergir do arquivo.

### Não existe versão sem conta em host nenhum

Vale dizer com todas as letras, porque é a pergunta natural: um endereço público que
responde sempre é um servidor de alguém, e todo serviço que hospeda servidor pede
cadastro. O que dá para reduzir é **quantas pessoas** passam por isso — e aqui é uma, uma
vez.

Se precisar de endereço público **hoje**, antes de existir conta em host algum, o atalho
é um túnel para um mock local:

```bash
npx --yes @stoplight/prism-cli@5 mock openapi.yaml --port 4010   # terminal 1
cloudflared tunnel --url http://localhost:4010                    # terminal 2
```

Sai uma `https://<aleatório>.trycloudflare.com` que o time inteiro alcança, e que **morre
quando você fechar o terminal**. Destrava uma tarde; não vira o padrão.

### Rodar local — só para quem edita o contrato

Para ver o efeito de uma mudança no `openapi.yaml` antes de abrir PR. Quem só consome o
contrato usa a URL online e não precisa disto.

```bash
npx --yes @stoplight/prism-cli@5 mock openapi.yaml --port 4010 --host 127.0.0.1
```

```bash
docker compose up   # mesma coisa, sem Node local
```

Nos dois casos a API fica em `http://localhost:4010/api/v1/...`, e o `.env.local` aponta
para lá em vez do endereço online.

*(O caminho do `npx` foi executado e verificado; o do Docker não — não havia Docker na
máquina em que este arquivo foi escrito.)*

### Três avisos, porque a URL é pública

- **Qualquer pessoa com o endereço alcança.** Não há autenticação na frente. Todo o dado
  do `openapi.yaml` é sintético por isso — `Instituto Aurora`, `@aurora.test` e os UUIDs
  não existem em lugar nenhum, e **nunca** devem ser trocados por dado real.
- **Não é infraestrutura do produto.** Não entra em `creed-infrastructure`, não vira ADR,
  não aparece no diagrama de `arquitetura.md`. É andaime, com data para morrer.
- **A URL não entra em arquivo versionado.** `.env.local` é ignorado pelo git de
  propósito: quando o mock morrer, ninguém deve ter que caçá-la em cinco lugares.

## E o webhook.site?

Não dá conta deste caso, e vale entender por quê antes de tentar: ele é um **inspetor de
requisição**, não um servidor de API. Cada URL devolve **uma** resposta fixa — não roteia
por caminho, não escolhe código de status por caso. Cobrir 8 endpoints × ~30 respostas
viraria dezenas de URLs soltas, cada uma uma cópia manual de um pedaço do contrato, que é
exatamente a divergência que o arquivo único existe para evitar. E as URLs gratuitas
expiram.

Onde ele **é** a ferramenta certa, e vale guardar: aponte o `VITE_API_BASE_URL` para uma
URL do webhook.site e leia o que o front está **mandando** — cabeçalho, corpo,
`Authorization`. Para responder "por que estou tomando 422", isso vale mais que o mock.

## O que foi descartado

| Alternativa | Por que não |
|---|---|
| **MSW** (Mock Service Worker) | Intercepta no browser: não há requisição real, não aparece na aba Network, e não há URL para compartilhar com o time. Pior — os handlers seriam uma **segunda cópia do contrato**, em TypeScript, livre para divergir do `openapi.yaml` sem ninguém perceber |
| **Stub em FastAPI** no `creed-backend` | É código de verdade que mente. Entra no repo, passa por review, ganha teste, e alguém acaba construindo em cima. Além disso, o domínio `authentication` vai nascer exatamente nesse endereço — o stub teria que ser apagado no meio da entrega 4 |
| **Postman / Mockoon Cloud** | Resolvem o "URL online para o time", mas o contrato passa a viver **fora do repositório**, copiado para dentro da ferramenta. Contrato que não está versionado ao lado da spec é contrato que ninguém revisa em PR — e que diverge na primeira mudança |
| **`json-server`** | Bom para CRUD, mas não sabe código de status por caso nem valida payload contra schema — que é metade do valor aqui |

## Quando apagar isto

Quando o `POST /api/v1/authentication/login` responder do `uvicorn`. A partir daí o
contrato de verdade é
[`http://localhost:8000/api/v1/openapi.json`](http://localhost:8000/api/v1/openapi.json),
gerado pelos schemas Pydantic, e manter um segundo OpenAPI escrito à mão é criar a
divergência que este arquivo existiu para evitar.

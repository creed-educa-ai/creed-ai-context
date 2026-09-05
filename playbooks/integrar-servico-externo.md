# Playbook: integrar serviço externo

**Quando:** a task faz o backend falar com algo de fora do processo — a esteira de IA no
N8N, e qualquer provedor que venha depois. Não vale para falar com o banco (isso é
repository) nem entre domínios (isso é service do dono).

**Molde:** não existe ainda. Este playbook **é** a fonte até o primeiro
`app/external_services/` nascer; o primeiro a nascer vira o molde e este texto passa a
ser lembrete.

**Regras que mandam:**
[`camadas-do-back.md`](../conventions/camadas-do-back.md) → "Serviços externos" ·
[ADR-0004](../decisoes/adrs/0004-camadas-do-backend.md) item 3 ·
[`../context/arquitetura.md`](../context/arquitetura.md) → "Esteira de IA (N8N)"

## Passo 0 — o contrato do provedor existe?

**Antes de qualquer código.** Serviço externo tem contrato como domínio tem campo, e
inventar um é o mesmo erro do front integrar contra stub:

| O que você tem | Caminho |
|---|---|
| workflow do N8N pronto, com payload de ida e volta conhecido | transcreva para `schemas.py` e siga |
| URL e segredo em `settings`, mas nenhum workflow definido | **é o estado de hoje.** O contrato vira premissa no ledger + pauta com quem constrói a esteira |
| provedor novo, com documentação pública | transcreva da documentação e cite a URL no docstring do client |

`N8N_WEBHOOK_URL`, `N8N_CALLBACK_SECRET` e `N8N_TIMEOUT_SECONDS` estão em
`core/config.py` desde o scaffold e **nenhuma linha usa**. Que a config exista não
significa que o contrato exista.

## Ordem

1. **Pasta** — `app/external_services/<provedor>/`, irmã de `domains/`. Um pacote por
   provedor, nunca um pacote "integracoes" com tudo dentro.

2. **`schemas.py`** — o payload de ida e o de volta, **no vocabulário do provedor**. Se
   o N8N chama de `payload.answers`, o schema chama de `answers`. Traduzir para o
   vocabulário do CREED é trabalho do service do domínio, mais adiante.

3. **`exceptions.py`** — uma exceção por modo de falha que o chamador precisa
   distinguir, herdando de `DomainError` (`app/shared/exceptions.py`). Comece com uma
   (`N8NIndisponivel`); a segunda nasce quando alguém precisar tratar diferente.

4. **`client.py`** — a classe. O que é obrigatório:

   - `httpx.AsyncClient`, recebido ou construído no `__init__` — nunca em nível de
     módulo, que fura o `lifespan` e vaza conexão entre testes.
   - **timeout vindo de `settings`**, sempre. Chamada sem timeout é o pod pendurado
     esperando um serviço que já morreu.
   - `try/except` estreito em volta da chamada, convertendo o erro da biblioteca na
     exceção do passo 3. Nada de `httpx` sai deste arquivo.
   - Zero conhecimento de domínio: o client não sabe o que é um prognóstico.

5. **Migration, se a falha for estado** — falha ao disparar não pode derrubar a
   requisição do usuário (a esteira é assíncrona por decisão de arquitetura). Então ela
   precisa de lugar para ficar: uma coluna de status no model do domínio dono, com
   reenvio possível. Isso é migration — [`criar-migration.md`](criar-migration.md).

6. **`dependencies.py` do domínio dono** — o client entra na cadeia de injeção junto do
   repository:
   `sessão → repository ─┐`
   `client ──────────────┴→ service`

7. **`service.py` do domínio dono** — é quem traduz CREED ↔ provedor, decide quando
   disparar, e decide o que fazer quando o disparo falha. A regra continua aqui; o
   client só transporta.

8. **Testes** — service com **client fake**, do mesmo jeito que já se usa repository
   fake. Cubra os dois caminhos: disparo aceito e disparo recusado. Nenhum teste toca a
   rede.

## O caminho de volta

O webhook que o provedor chama de volta **não mora em `external_services/`**. Quem entra
pela porta HTTP entra pelo domínio, sempre:

1. **Rota** no `router.py` do domínio dono (`prognosticos/router.py`), fina como
   qualquer outra: valida, delega ao service, devolve.
2. **Verificação da assinatura** é `Depends`, e mora em `app/core/security.py` — porque
   vale para qualquer webhook futuro, não só o do N8N. Compare o segredo com
   `hmac.compare_digest`, nunca com `==`.
3. **Idempotência**: o provedor pode reenviar. Chamada repetida com o mesmo
   identificador não pode duplicar registro nem disparar efeito duas vezes.
4. **Retorno inesperado é erro do domínio**, não `500` cru: callback para um recurso que
   não existe mais, ou já concluído, tem resposta definida e testada.

## Erros que este playbook existe para evitar

| Erro | Sinal |
|---|---|
| Contrato inventado | `schemas.py` do provedor com campo que ninguém viu num workflow |
| Client em nível de módulo | `client = N8NClient()` fora de função, no import |
| Chamada sem timeout | `httpx` sem `timeout=`, ou timeout literal em vez de `settings` |
| Erro de biblioteca vazando | `httpx.HTTPError` chegando ao router ou ao teste do service |
| Router chamando client | `client` como parâmetro da função de rota |
| Client conhecendo domínio | `from app.domains...` dentro de `external_services/` |
| Provedor derrubando o usuário | `503` na tela porque a esteira caiu — devia ser estado, com reenvio |
| Callback no lugar errado | `APIRouter` dentro de `external_services/` |
| Segredo comparado com `==` | comparação de segredo sem `hmac.compare_digest` |
| Teste tocando a rede | suíte que fica lenta ou vermelha com a internet desligada |
| Retry escondido | laço de retentativa dentro do client, multiplicando disparo sem ninguém ver |

## Antes de fechar

```bash
ruff check . && ruff format --check .
mypy app
pytest -q
pytest tests/test_arquitetura.py -q
```

E a checagem que nenhum comando faz: **desligue a rede e rode a suíte.** Se ficar
vermelha ou lenta, algum teste está falando com o mundo — e um dia vai falhar no CI por
motivo que não é o seu código.

A entrega didática diz, em uma linha cada: de onde veio o contrato do provedor (workflow
ou premissa), o que acontece quando ele está fora do ar, e onde esse estado fica gravado.

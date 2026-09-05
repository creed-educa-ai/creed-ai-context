---
name: integracao-externa
description: Fazer o creed-backend falar com serviço de fora do processo — a esteira de IA no N8N, webhook de saída, webhook de retorno, client HTTP, qualquer provedor externo. Use quando a task envolve N8N, integração, webhook, callback, httpx ou chamada a API de terceiro. Não vale para banco (repository) nem entre domínios (service do dono).
model: sonnet
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Você vai integrar o backend com um serviço externo. Leia ANTES:
`creed-ai-context/playbooks/integrar-servico-externo.md` (a sequência e a tabela de
erros) e `creed-ai-context/conventions/camadas-do-back.md` → "Serviços externos".

<critical>PASSO 0: o contrato do provedor existe? `N8N_WEBHOOK_URL`, `N8N_CALLBACK_SECRET` e `N8N_TIMEOUT_SECONDS` estão em `app/core/config.py` desde o scaffold e NENHUMA linha usa. Config existir não é contrato existir. Sem workflow do N8N definido, PARE: o payload vira premissa em `creed-ai-context/decisoes/premissas.md` + pauta com quem constrói a esteira. Não invente campo de payload.</critical>
<critical>O lugar é `app/external_services/<provedor>/`, IRMÃO de `domains/` — nunca dentro de um domínio, nunca um pacote "integracoes" com todos os provedores juntos. Arquivos: `client.py`, `schemas.py`, `exceptions.py`. Sem router, sem model, sem regra.</critical>
<critical>O client NÃO sabe o que é um prognóstico. Fala o vocabulário do provedor, com os schemas dele; traduzir CREED ↔ provedor é trabalho do `service.py` do domínio dono. `from app.domains...` dentro de `external_services/` é a seta apontando ao contrário.</critical>
<critical>TIMEOUT OBRIGATÓRIO, vindo de `settings` — nunca literal, nunca ausente. Chamada sem timeout é o pod pendurado esperando um serviço que já morreu. E o `httpx.AsyncClient` nasce no `__init__`, nunca em nível de módulo: cliente global fura o `lifespan` e vaza conexão entre testes.</critical>
<critical>Erro de biblioteca morre no client: `try/except` estreito converte para exceção própria herdando de `DomainError`. `httpx.HTTPError` chegando ao router ou ao teste do service é vazamento de camada.</critical>
<critical>Cair não pode derrubar a requisição do usuário — a esteira é assíncrona por decisão de arquitetura. Falha ao disparar é ESTADO DO DOMÍNIO, com reenvio possível, não `500` na cara de quem clicou. Estado precisa de coluna, e coluna é migration: skill `migration-back`.</critical>
<critical>O caminho de volta NÃO mora em `external_services/`. O webhook de retorno é rota do domínio dono (`prognosticos/router.py`) — quem entra pela porta HTTP entra pelo domínio, sempre.</critical>
<critical>No callback: compare o segredo com `hmac.compare_digest`, NUNCA com `==`, e ponha a verificação em `app/core/security.py` como `Depends`, porque vale para qualquer webhook futuro. O provedor reenvia: chamada repetida com o mesmo identificador não pode duplicar registro nem disparar efeito duas vezes.</critical>
<critical>Só o `service.py` chama o client, injetado por `dependencies.py` junto do repository. Router recebendo client como parâmetro é camada furada.</critical>
<critical>NENHUM teste toca a rede: client fake, do mesmo jeito que o repository fake, cobrindo disparo aceito E disparo recusado. Antes de fechar, desligue a rede e rode a suíte — se ficar vermelha ou lenta, algum teste está falando com o mundo. Encerre dizendo de onde veio o contrato (workflow ou premissa), o que acontece quando o provedor está fora do ar, e onde esse estado fica gravado.</critical>

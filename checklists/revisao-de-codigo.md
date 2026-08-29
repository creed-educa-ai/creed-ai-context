# Critérios de review

## Proporcionalidade

O custo do review escala com o risco, não com a burocracia.

| Tier | O que é | Review |
|---|---|---|
| **Trivial** | texto, estilo, config sem efeito, teste isolado | veredito inline, sem relatório |
| **Padrão** | endpoint, componente, regra de negócio dentro do molde | checklist abaixo |
| **Sensível** | migration, autenticação, contrato de API, agregação de indicador, infra | checklist + segunda leitura humana |

Migration é **sempre** Sensível, mesmo que tenha uma linha.

## Checklist

### Corretude
- [ ] Faz o que a task diz — e só isso.
- [ ] Borda tratada: lista vazia, nulo, valor no limite, resposta de erro do backend.
- [ ] Erro não é engolido (`except: pass`, `.catch(() => {})` sem tratamento).

### Camadas
- [ ] `router` sem regra, `service` sem query, `repository` sem decisão.
- [ ] Front não agrega.
- [ ] Domínio não importa `models.py` de outro domínio.

### Contratos
- [ ] `schemas.py` e `src/types/` batem.
- [ ] Mudança de contrato de API tem o par front/back no mesmo PR — ou é aditiva.

### Dados
- [ ] Migration revisada linha a linha; sem `drop` que devia ser rename.
- [ ] Índice para coluna nova usada em filtro/agregação.

### Segurança
- [ ] Sem credencial, token ou dado real no diff.
- [ ] Entrada validada na fronteira (`schemas.py`, form do front).

### Testes
- [ ] Existem, no nível certo, e falhariam sem a mudança.

## Vereditos

| Veredito | Quando |
|---|---|
| **Aprovado** | nenhum item aberto |
| **Aprovado com ressalva** | só ajuste cosmético pendente — diga qual é sugestão e qual é exigência |
| **Mudanças necessárias** | qualquer item de Corretude, Camadas, Dados ou Segurança aberto |

Ao revisar, **deixe explícito o que é exigência e o que é sugestão.** Com 1 aprovação
obrigatória, você é a única revisão — aprove quando estiver confortável em assinar
embaixo.

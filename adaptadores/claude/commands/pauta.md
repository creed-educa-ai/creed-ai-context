---
description: Monta a pauta da próxima reunião a partir das premissas abertas
model: haiku
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Monte a pauta da próxima reunião com a cliente.

Siga `creed-ai-context/workflows/duvidas-to-pauta.md`.

<critical>Leia `creed-ai-context/decisoes/premissas.md` e colete TODAS as premissas 🟡 abertas.</critical>
<critical>Traduza para linguagem de produto: a cliente não lê "P-007" nem sabe o que é `service.py`. Cada item = o que o time já fez + pergunta fechada + custo de mudar agora vs depois.</critical>
<critical>Ordene por custo de reverter, decrescente. O tempo da reunião acaba antes da lista.</critical>
<critical>Limite a 5–7 itens. O resto fica no ledger, listado em "Ficou para a próxima".</critical>
<critical>Corte dúvida técnica — ela não vai para a pauta.</critical>

Template: `creed-ai-context/templates/pauta-cliente-template.md`
Saída: `creed-ai-context/pauta/proxima-reuniao.md`

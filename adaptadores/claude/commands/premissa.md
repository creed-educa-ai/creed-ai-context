---
description: Registra uma premissa no ledger e marca o artefato
argument-hint: <a interpretação adotada>
model: haiku
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Registre a premissa: **$ARGUMENTS**

Siga `creed-ai-context/conventions/premissas-e-duvidas.md`.

<critical>Antes de registrar, VERIFIQUE se isto é mesmo lacuna de produto. Se a resposta está no harness, nos ADRs ou no código existente, não é premissa — é leitura. Diga isso e aponte onde está.</critical>
<critical>Escreva a premissa como AFIRMAÇÃO, não pergunta.</critical>
<critical>Justifique pelo critério aplicado: o que já existe > o mais barato de reverter > o menor escopo > o que não trava outra pessoa.</critical>
<critical>Estime o custo de reverter (baixo/médio/alto) — é o que vai ordenar a pauta da reunião.</critical>

1. Próximo ID livre em `creed-ai-context/decisoes/premissas.md` (nunca reaproveite ID).
2. Acrescente a linha na tabela, status 🟡 aberta.
3. Insira o marcador no artefato onde a premissa foi aplicada:
   `> 🟡 **Premissa P-NNN** — <interpretação>. Confirmar na próxima reunião.`

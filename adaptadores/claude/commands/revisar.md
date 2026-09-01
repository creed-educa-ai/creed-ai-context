---
description: Revisa o diff atual contra os checklists do projeto
argument-hint: [dev...HEAD | caminho]
model: sonnet
---
<!-- GERADO por creed-ai-context/scripts/instalar-adaptadores — não edite. -->

Revise **$ARGUMENTS** (padrão: `git diff dev...HEAD`).

Siga `creed-ai-context/workflows/revisao.md`, no papel de
`creed-ai-context/roles/revisor.md`.

<critical>Classifique o tier (Trivial/Padrão/Sensível) por `creed-ai-context/checklists/revisao-de-codigo.md`. Migration é SEMPRE Sensível.</critical>
<critical>Tier Sensível: aplique o checklist, emita o veredito e PARE. Esta passada roda em modelo médio e NÃO cumpre o tier sozinha — encerre com o bloco "Escalada exigida" de `creed-ai-context/workflows/revisao.md` → "Tier Sensível: pare e escale", incluindo a frase que o humano deve pedir numa sessão com modelo pesado. Não sugira re-rodar `/revisar`: o frontmatter vence o modelo da sessão.</critical>
<critical>Tier Trivial ou Padrão: `Escalada: não se aplica` no veredito, e siga normalmente — não invente escalada onde o tier não pede.</critical>
<critical>Leia o diff inteiro, arquivo por arquivo, E o contexto ao redor — bug de camada não aparece só nas linhas verdes.</critical>
<critical>Separe EXIGÊNCIA de SUGESTÃO, com arquivo e linha, e diga o que fazer.</critical>
<critical>A seção "Não verificado" é obrigatória. Com 1 aprovação por PR, review que omite o que não olhou dá falsa segurança.</critical>
<critical>Não aprove por educação: item aberto de Corretude, Camadas, Dados ou Segurança = "Mudanças necessárias".</critical>

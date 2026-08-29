# Papel: implementador

## Objetivo
Implementar uma task do CREED com a forma do código que já existe, sem inventar padrão
e sem estourar escopo.

## Regras

- **O molde manda.** `app/domains/respondentes/` e `src/features/respondentes/` são a
  referência. Abra-os antes de escrever. Diferença de forma precisa de justificativa.
- **Camadas:** router sem regra · service sem query · repository sem decisão · front
  sem agregação.
- **Espelhamento:** nome do domínio no back = nome da feature no front.
- **Idioma:** domínio em português sem acento; técnico em inglês.
- **Teste junto com o código**, no nível certo (`../conventions/testes.md`).
- **Escopo fechado.** Nada além da task entra no diff. Achou problema ao lado? Anote
  no encerramento, não conserte.
- **Sem git de escrita.** Deixe no working tree.
- **Migration é sempre proposta, nunca fato consumado** — encerre avisando que precisa
  de leitura humana.
- **Lacuna de produto vira premissa** e a task continua
  (`../conventions/premissas-e-duvidas.md`).

## Encerramento

Sempre no formato de `../workflows/tasks-to-code.md` → "Encerramento": arquivos
tocados, resultado da suíte, premissas usadas, o que ficou fora do escopo, próximo
passo humano.

## Antipadrões

- "Aproveitei para melhorar" — não aproveitou; poluiu o diff.
- Subir dependência nova sem pedir.
- Criar abstração para um caso de uso só.
- Comentar código gerado com `# gerado por IA`.
- Dizer que rodou os testes sem ter rodado.

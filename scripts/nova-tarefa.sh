#!/usr/bin/env bash
# Cria a pasta de artefatos de uma tarefa a partir dos templates.
#
#   bash creed-ai-context/scripts/nova-tarefa.sh 42 relatorio-por-organizacao
#
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "uso: nova-tarefa.sh <id-clickup> <slug-em-2-a-4-palavras>" >&2
  echo "ex.: nova-tarefa.sh 42 relatorio-por-organizacao" >&2
  exit 1
fi

ID="$1"
SLUG="$2"
HARNESS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$HARNESS/tarefas/$ID-$SLUG"

if [ -d "$DIR" ]; then
  echo "ja existe: ${DIR#$HARNESS/}" >&2
  exit 1
fi

mkdir -p "$DIR"
cp "$HARNESS/templates/spec-template.md"  "$DIR/spec.md"
cp "$HARNESS/templates/tasks-template.md" "$DIR/tasks.md"

echo "criado: tarefas/$ID-$SLUG/"
echo "  spec.md   (apague se a tarefa for pequena - ver workflows/tarefa-to-spec.md)"
echo "  tasks.md"
echo
echo "branch correspondente: <slug>/$ID-$SLUG"

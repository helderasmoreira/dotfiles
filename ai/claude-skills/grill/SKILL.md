---
name: grill
description: >-
  Grill the user relentlessly about a plan, decision, or idea until nothing is left silently assumed. Trigger on "/grill", "grill me", "stress-test this", "poke holes in this", or when the user wants their thinking interrogated before anything is planned, written, or built. Never acts on the outcome.
---

# Grill

Interview the user relentlessly until you reach a shared understanding. Map the idea as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you haven't heard yet. Ask the whole frontier in one round, numbered, each with your recommended answer. Then wait. A question whose answer depends on another question still open in this round belongs to a later round.

Ask in plain chat, not via AskUserQuestion: frontiers are often larger than four questions and answers are often free-form. Open the first round by stating the reply convention once: the user replies with exceptions only, and any question they don't mention is accepted as recommended.

Round format:

❓ **Q1 - <title>**: <question, with options where useful>

➡️ <your recommended answer>

---

❓ **Q2 - <title>**: ...

➡️ ...

Each round of answers reshapes the tree: settled decisions push the frontier outward and unblock what depended on them. Recompute and ask the next round.

Finding **facts** is your job, never the user's. When a question needs something from the environment (code, docs under `~/Work/Carwow/claude-docs/`, git history), dispatch an Explore agent. Don't block on it: only the questions downstream of that fact wait; ask the rest of the frontier now. **Decisions** are the user's: put each to them and wait.

The session is done when the frontier is empty. Close with a short list of the settled decisions, then stop. Do not plan, write, or build until the user says what comes next: typically /architect for a plan or /kanban-card for a card.

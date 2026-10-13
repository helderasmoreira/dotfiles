# Creating the card in Kanbanize

Call `create_card_batch` with:

- `board_id: 48` (GYC - Optimus)
- `workflow_name: "Cards workflow"`: the board has more than one workflow, so this is **required** or the call errors.
- `lane_name: "DELIVERY"`
- `column_name: "To be Defined"`
- `stickers_to_add: ["Needs Research"]`: signals the card needs a human review before it's picked up
- `title`: the `[<area>] <title>` line (without the `**Title:**` prefix)
- `description`: the Background / Requirements / Reviewers body **serialized to HTML**. Draft and preview the card in Markdown (step 6), since that's what renders readably in chat for the user's sign-off, then convert only at this send step, because the Kanbanize description field renders HTML and shows Markdown literally (`##`, `**`, and blank-line paragraph breaks all leak through as raw text). Mechanical conversion, same wording, only the markup changes. Convert **every** Markdown construct to its HTML equivalent (no Markdown may survive), including: `## Heading` → `<h2>Heading</h2>`, paragraphs → `<p>…</p>`, `**bold**` → `<strong>…</strong>`, `` `code` `` → `<code>…</code>`, bullet lists → `<ul><li>…</li></ul>`, `[text](url)` → `<a href="url">text</a>`, `> quote` → `<blockquote>…</blockquote>`.

Use the workflow, lane, column and sticker strings exactly as written (casing matters). They're the confirmed names on board 48 as of this writing. If a call fails on an unknown lane/column/sticker/workflow, the board was likely reconfigured; re-check with `search_cards` on board "GYC - Optimus" and adjust.

Linking to an archived card makes the whole create fail, so check the linked card's `state` first and, if archived, rely on the hyperlink in the description alone.

After it's created, check the returned `description`: `create_card_batch` sometimes wraps it in an outer `<p>`. If it did, re-save the same HTML with `update_card_details_batch`, which stores it verbatim. Then give the user the card URL/ID the tool returns.

For later edits: a description write replaces the whole field, so fetch the current description right before writing and build on that copy (the user may have edited it in the UI). Attachments go up as inline base64 and can't be deleted via MCP; compare the returned `size` with `wc -c` of the file before saying it's attached.

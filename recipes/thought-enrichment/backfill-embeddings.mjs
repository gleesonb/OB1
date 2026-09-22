#!/usr/bin/env node
/**
 * backfill-embeddings.mjs
 *
 * Backfills the `embedding` column in the `thoughts` table for rows where it is
 * NULL. Rows without an embedding are invisible to semantic search, so this
 * closes the gap left by the historic bulk imports (Apr-Aug 2026).
 *
 * Safe to stop and re-run: it always selects rows where embedding IS NULL and
 * pages by keyset (id ascending), so a partial run simply resumes where it
 * stopped. Nothing already embedded is touched or re-billed.
 *
 * Usage:
 *   node backfill-embeddings.mjs --dry-run
 *   node backfill-embeddings.mjs
 *   node backfill-embeddings.mjs --limit 200 --embed-batch 32
 */

import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));

// Load env
function loadEnv() {
  const envPath = join(__dirname, ".env.local");
  let text;
  try {
    text = readFileSync(envPath, "utf8");
  } catch {
    console.error("Missing .env.local — copy .env.local.example and fill in your values.");
    process.exit(1);
  }
  const env = {};
  for (const line of text.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const idx = trimmed.indexOf("=");
    if (idx === -1) continue;
    env[trimmed.slice(0, idx)] = trimmed.slice(idx + 1).replace(/^['"]|['"]$/g, "");
  }
  return env;
}

// The `embedding` column is vector(1536) and the importers all used
// text-embedding-3-small. Changing the model here would make new vectors
// incomparable with the 3,312 that already exist — don't, unless you re-embed
// the whole table.
const EMBEDDING_MODEL_DEFAULT = "openai/text-embedding-3-small";
const EMBEDDING_DIMS = 1536;
const MAX_CHARS = 8000; // same truncation the importers use

const args = process.argv.slice(2);
function argValue(flag, fallback) {
  const i = args.indexOf(flag);
  return i !== -1 ? parseInt(args[i + 1], 10) : fallback;
}

const DRY_RUN = args.includes("--dry-run");
const BATCH_SIZE = argValue("--batch-size", 200);   // rows fetched per page
const EMBED_BATCH = argValue("--embed-batch", 64);  // inputs per embeddings call
const LIMIT = argValue("--limit", 0);               // 0 = no cap

const env = loadEnv();
const SUPABASE_URL = env.SUPABASE_URL;
const SERVICE_ROLE_KEY = env.SUPABASE_SERVICE_ROLE_KEY;

// OPENAI_BASE_URL in .env.local points at the z.ai coding endpoint, which serves
// chat completions only. Embeddings default to OpenRouter; override with
// EMBEDDING_BASE_URL + EMBEDDING_API_KEY to use OpenAI directly.
const EMBEDDING_BASE_URL = (env.EMBEDDING_BASE_URL || "https://openrouter.ai/api/v1").replace(/\/+$/, "");
const EMBEDDING_API_KEY = env.EMBEDDING_API_KEY || env.OPENROUTER_API_KEY;
const EMBEDDING_MODEL = env.EMBEDDING_MODEL || EMBEDDING_MODEL_DEFAULT;

if (!SUPABASE_URL) {
  console.error("Missing SUPABASE_URL in .env.local");
  process.exit(1);
}
if (!SERVICE_ROLE_KEY) {
  console.error("Missing SUPABASE_SERVICE_ROLE_KEY in .env.local");
  process.exit(1);
}
if (!EMBEDDING_API_KEY) {
  console.error("Missing EMBEDDING_API_KEY (or OPENROUTER_API_KEY) in .env.local");
  process.exit(1);
}

const BASE = `${SUPABASE_URL}/rest/v1`;

const headers = {
  apikey: SERVICE_ROLE_KEY,
  Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
  "Content-Type": "application/json",
  Prefer: "return=minimal",
};

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isTransient(status) {
  return status === 429 || status === 500 || status === 502 || status === 503 || status === 504;
}

// ─── Supabase ───────────────────────────────────────────────────────────────

// Keyset pagination: offset paging would skip rows, because every row we write
// drops out of the `embedding is null` filter and shifts the window.
async function fetchPage(afterId, retries = 4) {
  const after = afterId ? `&id=gt.${afterId}` : "";
  const url = `${BASE}/thoughts?select=id,content&embedding=is.null${after}&order=id.asc&limit=${BATCH_SIZE}`;
  for (let attempt = 0; attempt <= retries; attempt++) {
    const r = await fetch(url, { headers });
    if (r.ok) return await r.json();
    const body = await r.text();
    if (isTransient(r.status) && attempt < retries) {
      const delay = Math.min(1000 * Math.pow(2, attempt), 16000);
      process.stderr.write(`\n[retry] fetch after ${afterId ?? "start"} got ${r.status}, waiting ${delay}ms\n`);
      await sleep(delay);
      continue;
    }
    throw new Error(`Fetch failed after ${afterId ?? "start"}: ${r.status} ${body.slice(0, 200)}`);
  }
}

async function updateRow(id, embedding, retries = 6) {
  const url = `${BASE}/thoughts?id=eq.${id}`;
  for (let attempt = 0; attempt <= retries; attempt++) {
    const r = await fetch(url, {
      method: "PATCH",
      headers,
      body: JSON.stringify({ embedding }),
    });
    if (r.ok) return;
    const body = await r.text();
    if (isTransient(r.status) && attempt < retries) {
      const delay = Math.min(1000 * Math.pow(2, attempt), 16000);
      process.stderr.write(`\n[retry] id ${id} got ${r.status}, waiting ${delay}ms (attempt ${attempt + 1}/${retries})\n`);
      await sleep(delay);
      continue;
    }
    throw new Error(`Update failed for id ${id}: ${r.status} ${body.slice(0, 200)}`);
  }
}

async function updateAll(updates) {
  const CONCURRENCY = 5;
  for (let i = 0; i < updates.length; i += CONCURRENCY) {
    const chunk = updates.slice(i, i + CONCURRENCY);
    await Promise.all(chunk.map(({ id, embedding }) => updateRow(id, embedding)));
    if (i + CONCURRENCY < updates.length) await sleep(200);
  }
}

// ─── Embeddings ─────────────────────────────────────────────────────────────

async function embedInputs(inputs, retries = 5) {
  for (let attempt = 0; attempt <= retries; attempt++) {
    const r = await fetch(`${EMBEDDING_BASE_URL}/embeddings`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${EMBEDDING_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ model: EMBEDDING_MODEL, input: inputs }),
    });

    if (r.ok) {
      const data = await r.json();
      // The API may return results out of order; `index` is authoritative.
      const vectors = new Array(inputs.length).fill(null);
      for (const item of data.data) vectors[item.index] = item.embedding;
      for (let i = 0; i < vectors.length; i++) {
        if (!Array.isArray(vectors[i]) || vectors[i].length !== EMBEDDING_DIMS) {
          throw new Error(
            `Embedding ${i} has ${vectors[i]?.length ?? "no"} dims, expected ${EMBEDDING_DIMS}. ` +
              `Check EMBEDDING_MODEL (${EMBEDDING_MODEL}).`
          );
        }
      }
      return { vectors, usage: data.usage || {} };
    }

    const body = await r.text();
    if (isTransient(r.status) && attempt < retries) {
      const delay = Math.min(2000 * Math.pow(2, attempt), 32000);
      process.stderr.write(`\n[retry] embeddings got ${r.status}, waiting ${delay}ms (${body.slice(0, 120)})\n`);
      await sleep(delay);
      continue;
    }
    throw new Error(`Embeddings request failed: ${r.status} ${body.slice(0, 200)}`);
  }
}

// ─── Main ───────────────────────────────────────────────────────────────────

async function main() {
  console.log(`Starting embedding backfill${DRY_RUN ? " (DRY RUN — no writes)" : ""}`);
  console.log(`Model:      ${EMBEDDING_MODEL} via ${EMBEDDING_BASE_URL}`);
  console.log(`Page size:  ${BATCH_SIZE} rows, ${EMBED_BATCH} inputs per embeddings call`);
  if (LIMIT) console.log(`Limit:      ${LIMIT} rows`);
  console.log("");

  let afterId = null;
  let seen = 0;
  let embedded = 0;
  let skippedEmpty = 0;
  let failed = 0;
  let totalTokens = 0;
  let totalCost = 0;

  while (true) {
    const rows = await fetchPage(afterId);
    if (!rows || rows.length === 0) break;

    afterId = rows[rows.length - 1].id;
    seen += rows.length;

    // Rows with no usable text can never get an embedding — count and move on
    // rather than sending empty input and failing the whole batch.
    const usable = [];
    for (const row of rows) {
      const text = (row.content || "").trim();
      if (!text) {
        skippedEmpty++;
        continue;
      }
      usable.push({ id: row.id, text: text.slice(0, MAX_CHARS) });
    }

    for (let i = 0; i < usable.length; i += EMBED_BATCH) {
      const chunk = usable.slice(i, i + EMBED_BATCH);
      let result;
      try {
        result = await embedInputs(chunk.map((c) => c.text));
      } catch (e) {
        failed += chunk.length;
        process.stderr.write(`\n[error] batch of ${chunk.length} failed: ${e.message}\n`);
        continue;
      }

      totalTokens += result.usage.total_tokens || 0;
      totalCost += result.usage.cost || 0;

      if (!DRY_RUN) {
        const updates = chunk.map((c, idx) => ({ id: c.id, embedding: result.vectors[idx] }));
        await updateAll(updates);
      }
      embedded += chunk.length;

      process.stdout.write(
        `\rProgress: ${seen} scanned, ${embedded} embedded, ${skippedEmpty} empty, ${failed} failed`
      );
    }

    if (LIMIT && seen >= LIMIT) {
      console.log(`\n\nReached --limit ${LIMIT}, stopping.`);
      break;
    }
    if (rows.length < BATCH_SIZE) break;
  }

  console.log("\n");
  console.log("=== BACKFILL COMPLETE ===");
  console.log("");
  console.log(`Rows scanned:        ${seen}`);
  console.log(`Embedded:            ${embedded}${DRY_RUN ? " (dry run, not written)" : ""}`);
  console.log(`Skipped (no text):   ${skippedEmpty}`);
  console.log(`Failed:              ${failed}`);
  if (totalTokens) console.log(`Tokens:              ${totalTokens.toLocaleString()}`);
  if (totalCost) console.log(`Cost:                $${totalCost.toFixed(4)}`);
  if (failed > 0) {
    console.log("");
    console.log("Re-run the script to retry failed rows — they still have embedding IS NULL.");
  }
}

main().catch((e) => {
  console.error(`\nFatal: ${e.message}`);
  process.exit(1);
});
